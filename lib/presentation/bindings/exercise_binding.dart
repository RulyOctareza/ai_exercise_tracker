import 'package:ai_exercise_tracker/domain/repositories/exercise_repository.dart';
import 'package:ai_exercise_tracker/domain/usecases/exercise/get_last_record_usecase.dart';
import 'package:ai_exercise_tracker/domain/usecases/exercise/save_exercise_usecase.dart';
import 'package:ai_exercise_tracker/presentation/controller/auth_controller.dart';
import 'package:ai_exercise_tracker/presentation/controller/detection_controller.dart';
import 'package:ai_exercise_tracker/presentation/controller/exercise_list_controller.dart';
import 'package:ai_exercise_tracker/presentation/controller/exercise_summary_controller.dart';
import 'package:get/get.dart';
import '../../domain/usecases/exercise/get_exercises_usecase.dart';
import '../../services/camera_service.dart';
import '../../services/pose_detection_service.dart';

class ExerciseBinding extends Bindings {
  @override
  void dependencies() {
    // Camera & Pose Detection Services
    Get.lazyPut<CameraService>(() => CameraService(), fenix: true);

    Get.lazyPut<PoseDetectionService>(
      () => PoseDetectionService(cameraService: Get.find<CameraService>()),
      fenix: true,
    );

    // Use cases - menggunakan repository yang sudah ada
    Get.lazyPut<GetExercisesUseCase>(
      () => GetExercisesUseCase(Get.find<ExerciseRepository>()),
      fenix: true,
    );

    Get.lazyPut<GetLastExerciseRecordUseCase>(
      () => GetLastExerciseRecordUseCase(Get.find()),
      fenix: true,
    );

    Get.lazyPut<SaveExerciseHistoryUseCase>(
      () => SaveExerciseHistoryUseCase(Get.find()),
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
        cameraService: Get.find<CameraService>(),
        getLastExerciseRecordUseCase: Get.find<GetLastExerciseRecordUseCase>(),
        saveExerciseHistoryUseCase: Get.find<SaveExerciseHistoryUseCase>(),
        userId: userId,
      );
    });

    // Summary controller is created when needed
    Get.create<ExerciseSummaryController>(() => ExerciseSummaryController());
  }
}
