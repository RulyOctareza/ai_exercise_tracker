// lib/presentation/controllers/detection_controller.dart
import 'package:ai_exercise_tracker/domain/usecases/exercise/get_last_record_usecase.dart';
import 'package:ai_exercise_tracker/domain/usecases/exercise/save_exercise_usecase.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../domain/entities/exercise.dart';
import '../../domain/entities/exercise_history.dart';

import '../../services/camera_service.dart';
import '../../services/pose_detection_service.dart';
import '../../routes/app_routes.dart';

class DetectionController extends GetxController {
  final PoseDetectionService _poseDetectionService;
  final CameraService _cameraService;
  final GetLastExerciseRecordUseCase _getLastExerciseRecordUseCase;
  final SaveExerciseHistoryUseCase _saveExerciseHistoryUseCase;
  final String _userId;
  final Uuid _uuid = Uuid();

  DetectionController({
    required PoseDetectionService poseDetectionService,
    required CameraService cameraService,
    required GetLastExerciseRecordUseCase getLastExerciseRecordUseCase,
    required SaveExerciseHistoryUseCase saveExerciseHistoryUseCase,
    required String userId,
  }) : _poseDetectionService = poseDetectionService,
       _cameraService = cameraService,
       _getLastExerciseRecordUseCase = getLastExerciseRecordUseCase,
       _saveExerciseHistoryUseCase = saveExerciseHistoryUseCase,
       _userId = userId;

  // Observable state
  final Rx<Exercise?> exercise = Rx<Exercise?>(null);
  final RxInt repetitionCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString debugInfo = ''.obs;
  final RxBool showDebugInfo = true.obs; // Set to false in production

  // Required public getters for the view
  CameraService get camera => _cameraService;
  final RxList<Pose> poses = <Pose>[].obs; // For storing detected poses

  // Exercise state trackers
  final RxBool isLowered = false.obs; // for push-ups
  final RxBool isSquatting = false.obs; // for squats
  final RxBool isInDownwardDog = false.obs; // for plank to downward dog
  final RxBool isJumpingJackOpen = false.obs; // for jumping jacks
  final RxBool handsTogether = false.obs; // for clap
  final Rx<DateTime?> lastClapTime = Rx<DateTime?>(null);

  // Session tracking
  final Rx<DateTime> startTime = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    exercise.value = Get.arguments as Exercise;
    startTime.value = DateTime.now();

    // Initialize camera
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.init();

      // Initialize pose detection service
      _poseDetectionService.initialize(
        onPoseDetected: (detectedPose) {
          poses.clear();
          poses.add(detectedPose);
          _processPose(detectedPose);
        },
        onBusyStateChanged: (busy) => isLoading.value = busy,
      );
    } catch (e) {
      debugInfo.value = 'Camera error: ${e.toString()}';
    }
  }

  void _processPose(pose) {
    if (exercise.value == null) return;

    final landmarks = pose.landmarks;

    switch (exercise.value!.type) {
      case ExerciseType.pushUps:
        if (_poseDetectionService.detectPushUp(
          landmarks,
          isLowered: isLowered.value,
        )) {
          incrementCount();
          isLowered.value = false;
        } else if (!isLowered.value &&
            landmarks[PoseLandmarkType.leftElbow] != null) {
          // Update lowered state without incrementing count
          final leftElbow = landmarks[PoseLandmarkType.leftElbow]!;
          final rightElbow = landmarks[PoseLandmarkType.rightElbow]!;
          final leftShoulder = landmarks[PoseLandmarkType.leftShoulder]!;
          final rightShoulder = landmarks[PoseLandmarkType.rightShoulder]!;
          final leftWrist = landmarks[PoseLandmarkType.leftWrist]!;
          final rightWrist = landmarks[PoseLandmarkType.rightWrist]!;

          final leftElbowAngle = calculateAngle(
            leftShoulder,
            leftElbow,
            leftWrist,
          );
          final rightElbowAngle = calculateAngle(
            rightShoulder,
            rightElbow,
            rightWrist,
          );
          final avgElbowAngle = (leftElbowAngle + rightElbowAngle) / 2;

          if (avgElbowAngle < 100) {
            isLowered.value = true;
          }
        }
        break;

      case ExerciseType.squats:
        if (_poseDetectionService.detectSquat(
          landmarks,
          isSquatting: isSquatting.value,
        )) {
          incrementCount();
          isSquatting.value = false;
        } else if (!isSquatting.value &&
            landmarks[PoseLandmarkType.leftKnee] != null) {
          // Update squatting state
          final leftHip = landmarks[PoseLandmarkType.leftHip]!;
          final rightHip = landmarks[PoseLandmarkType.rightHip]!;
          final leftKnee = landmarks[PoseLandmarkType.leftKnee]!;
          final rightKnee = landmarks[PoseLandmarkType.rightKnee]!;
          final leftAnkle = landmarks[PoseLandmarkType.leftAnkle]!;
          final rightAnkle = landmarks[PoseLandmarkType.rightAnkle]!;

          final leftKneeAngle = calculateAngle(leftHip, leftKnee, leftAnkle);
          final rightKneeAngle = calculateAngle(
            rightHip,
            rightKnee,
            rightAnkle,
          );
          final avgKneeAngle = (leftKneeAngle + rightKneeAngle) / 2;

          if (avgKneeAngle < 110) {
            isSquatting.value = true;
          }
        }
        break;

      case ExerciseType.downwardDogPlank:
        if (_poseDetectionService.detectPlankToDownwardDog(
          pose,
          isInDownwardDog: isInDownwardDog.value,
        )) {
          incrementCount();
          isInDownwardDog.value = false;
        } else if (!isInDownwardDog.value) {
          // Update downward dog state
          final landmarks = pose.landmarks;
          final leftHip = landmarks[PoseLandmarkType.leftHip];
          final rightHip = landmarks[PoseLandmarkType.rightHip];
          final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
          final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];

          if (leftHip != null &&
              rightHip != null &&
              leftShoulder != null &&
              rightShoulder != null) {
            final hipElevation =
                (leftShoulder.y - leftHip.y + rightShoulder.y - rightHip.y) / 2;
            final shoulderWidth = distance(leftShoulder, rightShoulder);

            if (hipElevation > shoulderWidth * 0.4) {
              isInDownwardDog.value = true;
            }
          }
        }
        break;

      case ExerciseType.jumpingJack:
        if (_poseDetectionService.detectJumpingJack(
          pose,
          isJumpingJackOpen: isJumpingJackOpen.value,
        )) {
          incrementCount();
          isJumpingJackOpen.value = false;
        } else if (!isJumpingJackOpen.value) {
          // Update jumping jack state
          final landmarks = pose.landmarks;
          final leftWrist = landmarks[PoseLandmarkType.leftWrist];
          final rightWrist = landmarks[PoseLandmarkType.rightWrist];
          final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
          final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];

          if (leftWrist != null &&
              rightWrist != null &&
              leftAnkle != null &&
              rightAnkle != null) {
            final armSpread = distance(leftWrist, rightWrist);
            final legSpread = distance(leftAnkle, rightAnkle);

            if (armSpread > 100 && legSpread > 100) {
              // Simplified thresholds
              isJumpingJackOpen.value = true;
            }
          }
        }
        break;

      case ExerciseType.clap:
        if (_poseDetectionService.detectClap(
          landmarks,
          handsTogether: handsTogether.value,
          lastClapTime: lastClapTime.value,
        )) {
          incrementCount();
          handsTogether.value = true;
          lastClapTime.value = DateTime.now();
        } else if (handsTogether.value) {
          // Reset handsTogether when wrists move apart
          final leftWrist = landmarks[PoseLandmarkType.leftWrist];
          final rightWrist = landmarks[PoseLandmarkType.rightWrist];
          final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
          final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];

          if (leftWrist != null &&
              rightWrist != null &&
              leftShoulder != null &&
              rightShoulder != null) {
            final currentDistance = distance(leftWrist, rightWrist);
            final shoulderWidth = distance(leftShoulder, rightShoulder);

            if (currentDistance > shoulderWidth * 0.6) {
              handsTogether.value = false;
            }
          }
        }
        break;
    }

    // Update debug info
    if (showDebugInfo.value) {
      String info = '';
      switch (exercise.value!.type) {
        case ExerciseType.pushUps:
          info = 'Lowered: ${isLowered.value}';
          break;
        case ExerciseType.squats:
          info = 'Squatting: ${isSquatting.value}';
          break;
        case ExerciseType.downwardDogPlank:
          info = 'In Downward Dog: ${isInDownwardDog.value}';
          break;
        case ExerciseType.jumpingJack:
          info = 'Jack Open: ${isJumpingJackOpen.value}';
          break;
        case ExerciseType.clap:
          info = 'Hands Together: ${handsTogether.value}';
          break;
      }

      info += '\nCount: ${repetitionCount.value}';
      debugInfo.value = info;
    }
  }

  void incrementCount() {
    repetitionCount.value++;
    HapticFeedback.mediumImpact();
  }

  void resetCounter() {
    repetitionCount.value = 0;
    HapticFeedback.mediumImpact();
  }

  Future<void> finishExercise() async {
    if (repetitionCount.value > 0) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime.value).inSeconds;

      // Create exercise history record
      final history = ExerciseHistory(
        id: _uuid.v4(),
        userId: _userId,
        exerciseId: exercise.value!.id,
        exerciseType: exercise.value!.type,
        repetitions: repetitionCount.value,
        date: endTime,
        duration: duration,
      );

      try {
        // Save exercise history
        await _saveExerciseHistoryUseCase.execute(history);

        // Get previous record for comparison in summary
        final previousRecord = await _getLastExerciseRecordUseCase.execute(
          _userId,
          exercise.value!.type,
        );

        // Navigate to summary screen
        Get.toNamed(
          AppRoutes.EXERCISE_SUMMARY,
          arguments: {
            'exercise': exercise.value,
            'currentRecord': history,
            'previousRecord': previousRecord,
          },
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to save exercise data: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      Get.back();
    }
  }

  // Utility methods for calculation
  double calculateAngle(dynamic a, dynamic b, dynamic c) {
    return _poseDetectionService.calculateAngle(a, b, c);
  }

  double distance(dynamic p1, dynamic p2) {
    return _poseDetectionService.distance(p1, p2);
  }
}
