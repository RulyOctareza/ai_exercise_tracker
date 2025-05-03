// lib/presentation/bindings/exercise_binding.dart
import 'package:ai_exercise_tracker/data/repositories/exercise_repo_impl.dart';
import 'package:ai_exercise_tracker/domain/usecases/exercise/get_exercises_usecase.dart';
import 'package:ai_exercise_tracker/domain/usecases/exercise/get_last_record_usecase.dart';
import 'package:ai_exercise_tracker/domain/usecases/exercise/save_exercise_usecase.dart';
import 'package:ai_exercise_tracker/presentation/controller/auth_controller.dart';
import 'package:ai_exercise_tracker/presentation/controller/detection_controller.dart';
import 'package:ai_exercise_tracker/presentation/controller/exercise_list_controller.dart';
import 'package:ai_exercise_tracker/services/firebase_firestore_service.dart';
import 'package:get/get.dart';

import '../../services/camera_service.dart';
import '../../services/pose_detection_service.dart';


class ExerciseBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<CameraService>(() => CameraService().init(), fenix: true);

    Get.lazyPut<PoseDetectionService>(
      () => PoseDetectionService(cameraService: Get.find<CameraService>()),
      fenix: true,
    );

    // Repository
    Get.lazyPut<ExerciseRepositoryImpl>(
      () => ExerciseRepositoryImpl(
        firestoreService: Get.find<FirebaseFirestoreService>(),
      ),
      fenix: true,
    );

    // Use cases
    Get.lazyPut<GetExercisesUseCase>(
      () => GetExercisesUseCase(Get.find<ExerciseRepositoryImpl>()),
      fenix: true,
    );

    Get.lazyPut<GetLastExerciseRecordUseCase>(
      () => GetLastExerciseRecordUseCase(Get.find<ExerciseRepositoryImpl>()),
      fenix: true,
    );

    Get.lazyPut<SaveExerciseHistoryUseCase>(
      () => SaveExerciseHistoryUseCase(Get.find<ExerciseRepositoryImpl>()),
      fenix: true,
    );

    // Controllers
    Get.lazyPut<ExerciseListController>(
      () => ExerciseListController(
        getExercisesUseCase: Get.find<GetExercisesUseCase>(),
      ),
    );

    // Detection controller is created when needed with current user ID
    Get.create<DetectionController>(() {
      final authController = Get.find<AuthController>();
      final userId = authController.user.value?.id ?? '';

      return DetectionController(
        poseDetectionService: Get.find<PoseDetectionService>(),
        getLastExerciseRecordUseCase: Get.find<GetLastExerciseRecordUseCase>(),
        saveExerciseHistoryUseCase: Get.find<SaveExerciseHistoryUseCase>(),
        userId: userId,
      );
    });

    // Summary controller is created when needed
    Get.create<ExerciseSummaryController>(() => ExerciseSummaryController());
  }
}
