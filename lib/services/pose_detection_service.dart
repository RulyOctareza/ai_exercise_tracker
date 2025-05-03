import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/services.dart';

import 'camera_service.dart';

class PoseDetectionService extends GetxService {
  final CameraService _cameraService;
  late final PoseDetector _poseDetector;
  final isDetectorReady = false.obs;

  // Callback functions
  Function(Pose)? onPoseDetected;
  Function(bool)? onBusyStateChanged;

  PoseDetectionService({required CameraService cameraService})
    : _cameraService = cameraService {
    _initializeDetector();
  }

  Future<void> _initializeDetector() async {
    final options = PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.accurate,
    );
    _poseDetector = PoseDetector(options: options);
    isDetectorReady.value = true;
  }

  void initialize({
    required Function(Pose) onPoseDetected,
    required Function(bool) onBusyStateChanged,
  }) {
    this.onPoseDetected = onPoseDetected;
    this.onBusyStateChanged = onBusyStateChanged;

    // Start processing camera feed
    _processCameraFeed();
  }

  void _processCameraFeed() {
    if (!isDetectorReady.value) return;

    _cameraService.startImageStream(_processImage);
  }

  Future<void> _processImage(CameraImage image) async {
    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) {
        _cameraService.processingDone();
        return;
      }

      final List<Pose> poses = await _poseDetector.processImage(inputImage);

      if (poses.isNotEmpty && onPoseDetected != null) {
        onPoseDetected!(poses.first);
      }

      _cameraService.processingDone();
    } catch (e) {
      print('Error processing image: $e');
      _cameraService.processingDone();
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final camera = _cameraService.cameraController?.description;
    if (camera == null) return null;

    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = 0;
      // Handle Android rotation based on device orientation
      // This is a simplified version - in a real app, you would get the actual device orientation
      rotation = InputImageRotationValue.fromRawValue(
        (sensorOrientation + rotationCompensation) % 360,
      );
    }

    if (rotation == null) return null;

    // Format will depend on platform
    final format =
        Platform.isAndroid ? InputImageFormat.nv21 : InputImageFormat.bgra8888;

    if (image.planes.length != (Platform.isAndroid ? 3 : 1)) return null;

    // Setup plane data based on platform
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  // Functions to detect specific exercises
  // These will be called from the controller to process poses

  bool detectPushUp(
    Map<PoseLandmarkType, PoseLandmark> landmarks, {
    required bool isLowered,
  }) {
    // Check if key landmarks are available
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final leftElbow = landmarks[PoseLandmarkType.leftElbow];
    final rightElbow = landmarks[PoseLandmarkType.rightElbow];
    final leftWrist = landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = landmarks[PoseLandmarkType.rightWrist];
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];

    if (leftShoulder == null ||
        rightShoulder == null ||
        leftElbow == null ||
        rightElbow == null ||
        leftWrist == null ||
        rightWrist == null ||
        leftHip == null ||
        rightHip == null) {
      return false;
    }

    // Calculate angles for push-up detection
    final leftElbowAngle = calculateAngle(leftShoulder, leftElbow, leftWrist);
    final rightElbowAngle = calculateAngle(
      rightShoulder,
      rightElbow,
      rightWrist,
    );
    final avgElbowAngle = (leftElbowAngle + rightElbowAngle) / 2;

    // Calculate torso angle
    final leftTorsoAngle = calculateAngle(
      leftShoulder,
      leftHip,
      landmarks[PoseLandmarkType.leftKnee] ?? leftHip,
    );
    final rightTorsoAngle = calculateAngle(
      rightShoulder,
      rightHip,
      landmarks[PoseLandmarkType.rightKnee] ?? rightHip,
    );
    final avgTorsoAngle = (leftTorsoAngle + rightTorsoAngle) / 2;

    // Check if in plank position (torso is straight)
    final inPlankPosition = avgTorsoAngle > 150;

    // Detect push-up state
    if (avgElbowAngle < 100 && inPlankPosition && !isLowered) {
      return false; // Going down but not yet in down position
    } else if (avgElbowAngle < 100 && inPlankPosition) {
      return false; // Still in down position
    } else if (avgElbowAngle > 150 && isLowered && inPlankPosition) {
      HapticFeedback.mediumImpact();
      return true; // Push-up completed
    }

    return false;
  }

  bool detectSquat(
    Map<PoseLandmarkType, PoseLandmark> landmarks, {
    required bool isSquatting,
  }) {
    // Check if key landmarks are available
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];
    final leftKnee = landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = landmarks[PoseLandmarkType.rightKnee];
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];

    if (leftHip == null ||
        rightHip == null ||
        leftKnee == null ||
        rightKnee == null ||
        leftAnkle == null ||
        rightAnkle == null ||
        leftShoulder == null ||
        rightShoulder == null) {
      return false;
    }

    // Calculate knee angles
    final leftKneeAngle = calculateAngle(leftHip, leftKnee, leftAnkle);
    final rightKneeAngle = calculateAngle(rightHip, rightKnee, rightAnkle);
    final avgKneeAngle = (leftKneeAngle + rightKneeAngle) / 2;

    // Calculate if hips are lowered
    final hipY = (leftHip.y + rightHip.y) / 2;
    final shoulderY = (leftShoulder.y + rightShoulder.y) / 2;
    final hipsLowered = hipY > shoulderY + 20;

    // Detect squat
    final deepSquat = avgKneeAngle < 110;

    if (deepSquat && hipsLowered && !isSquatting) {
      return false; // Going down to squat position
    } else if (deepSquat && hipsLowered) {
      return false; // Still in squat position
    } else if (!deepSquat && isSquatting) {
      HapticFeedback.mediumImpact();
      return true; // Squat completed
    }

    return false;
  }

  bool detectJumpingJack(Pose pose, {required bool isJumpingJackOpen}) {
    final landmarks = pose.landmarks;
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final leftWrist = landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = landmarks[PoseLandmarkType.rightWrist];
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];

    if (leftShoulder == null ||
        rightShoulder == null ||
        leftWrist == null ||
        rightWrist == null ||
        leftAnkle == null ||
        rightAnkle == null ||
        leftHip == null ||
        rightHip == null) {
      return false;
    }

    // Calculate body proportions for thresholds
    final shoulderWidth = distance(leftShoulder, rightShoulder);
    final hipWidth = distance(leftHip, rightHip);
    final bodyScale = (shoulderWidth + hipWidth) / 2;

    // Measure arm and leg spread
    final armSpread = distance(leftWrist, rightWrist);
    final legSpread = distance(leftAnkle, rightAnkle);

    // Check if arms are raised
    final wristAvgY = (leftWrist.y + rightWrist.y) / 2;
    final shoulderAvgY = (leftShoulder.y + rightShoulder.y) / 2;

    // Thresholds based on body proportions
    final armSpreadThreshold = bodyScale * 1.8;
    final legSpreadThreshold = bodyScale * 1.5;
    final armRaiseThreshold = shoulderAvgY - (bodyScale * 0.3);

    final armsExtended = armSpread > armSpreadThreshold;
    final legsExtended = legSpread > legSpreadThreshold;
    final armsRaised = wristAvgY < armRaiseThreshold;

    // Detect jumping jack state
    if ((armsExtended || armsRaised) && legsExtended && !isJumpingJackOpen) {
      return false; // Going to open position
    } else if ((armsExtended || armsRaised) && legsExtended) {
      return false; // Still in open position
    } else if (!armsExtended && !legsExtended && isJumpingJackOpen) {
      HapticFeedback.mediumImpact();
      return true; // Jumping jack completed
    }

    return false;
  }

  bool detectPlankToDownwardDog(Pose pose, {required bool isInDownwardDog}) {
    final landmarks = pose.landmarks;
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];
    final leftWrist = landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = landmarks[PoseLandmarkType.rightWrist];

    if (leftHip == null ||
        rightHip == null ||
        leftShoulder == null ||
        rightShoulder == null ||
        leftAnkle == null ||
        rightAnkle == null ||
        leftWrist == null ||
        rightWrist == null) {
      return false;
    }

    // Calculate distances for detecting plank and downward dog
    final hipToShoulderYDist =
        ((leftHip.y - leftShoulder.y).abs() +
            (rightHip.y - rightShoulder.y).abs()) /
        2;
    final hipToAnkleYDist =
        ((leftHip.y - leftAnkle.y).abs() + (rightHip.y - rightAnkle.y).abs()) /
        2;
    final shoulderWidth = distance(leftShoulder, rightShoulder);

    // Detect plank position
    final isPlank =
        hipToShoulderYDist < shoulderWidth * 0.5 &&
        hipToAnkleYDist > shoulderWidth * 1.5;

    // Detect downward dog position
    final hipElevation =
        (leftShoulder.y - leftHip.y + rightShoulder.y - rightHip.y) / 2;
    final isDownwardDog =
        hipElevation > shoulderWidth * 0.4 &&
        leftAnkle.y > leftHip.y &&
        rightAnkle.y > rightHip.y;

    // State machine for detecting transition
    if (isDownwardDog && !isInDownwardDog) {
      return false; // Moving to downward dog
    } else if (isPlank && isInDownwardDog) {
      HapticFeedback.mediumImpact();
      return true; // Completed transition back to plank
    }

    return false;
  }

  bool detectClap(
    Map<PoseLandmarkType, PoseLandmark> landmarks, {
    required bool handsTogether,
    required DateTime? lastClapTime,
  }) {
    // Check if key landmarks are available
    final leftWrist = landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = landmarks[PoseLandmarkType.rightWrist];
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];

    if (leftWrist == null ||
        rightWrist == null ||
        leftShoulder == null ||
        rightShoulder == null) {
      return false;
    }

    // Calculate current distance between wrists
    final currentDistance = distance(leftWrist, rightWrist);
    final shoulderWidth = distance(leftShoulder, rightShoulder);

    // Set threshold based on shoulder width
    final clapThreshold = shoulderWidth * 0.4;

    // Check if hands are close enough for a clap
    if (currentDistance < clapThreshold && !handsTogether) {
      final now = DateTime.now();

      // Check if enough time has passed since last clap (debounce)
      if (lastClapTime == null ||
          now.difference(lastClapTime).inMilliseconds > 300) {
        HapticFeedback.mediumImpact();
        return true; // Clap detected
      }
    }

    return false;
  }

  // Utility methods
  double calculateAngle(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    final ab = distance(a, b);
    final bc = distance(b, c);
    final ac = distance(a, c);

    // Handle edge case to avoid divide by zero
    final denominator = 2 * ab * bc;
    if (denominator == 0) return 0.0;

    // Calculate angle using law of cosines
    final cosTheta = (ab * ab + bc * bc - ac * ac) / denominator;
    final clampedCosTheta = cosTheta.clamp(-1.0, 1.0); // Avoid domain error

    return (180 / 3.14159) * acos(clampedCosTheta); // Convert to degrees
  }

  double distance(PoseLandmark p1, PoseLandmark p2) {
    final dx = p1.x - p2.x;
    final dy = p1.y - p2.y;
    final dz = (p1.z - p2.z) / 10; // Scale Z-axis for better proportions
    return sqrt(dx * dx + dy * dy + dz * dz);
  }

  @override
  void onClose() {
    _poseDetector.close();
    super.onClose();
  }
}

// Helper extension for math operations
extension on PoseDetectionService {
  // double sqrt(double value) => value <= 0 ? 0 : value.sqrt;
}
