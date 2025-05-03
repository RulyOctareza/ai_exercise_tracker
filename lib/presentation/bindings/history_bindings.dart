import 'package:ai_exercise_tracker/data/repositories/exercise_repo_impl.dart';
import 'package:ai_exercise_tracker/domain/usecases/exercise/get_exercise_history_usecase.dart';
import 'package:ai_exercise_tracker/presentation/controller/history_controller.dart';
import 'package:get/get.dart';



class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    // Use cases
    Get.lazyPut<GetExerciseHistoryUseCase>(
      () => GetExerciseHistoryUseCase(Get.find<ExerciseRepositoryImpl>()),
      fenix: true,
    );

    Get.lazyPut<GetTotalRepetitionsPerTypeUseCase>(
      () =>
          GetTotalRepetitionsPerTypeUseCase(Get.find<ExerciseRepositoryImpl>()),
      fenix: true,
    );

    // Controller
    Get.lazyPut<HistoryController>(() {
      final authController = Get.find<AuthController>();
      final userId = authController.user.value?.id ?? '';

      return HistoryController(
        getExerciseHistoryUseCase: Get.find<GetExerciseHistoryUseCase>(),
        getTotalRepetitionsPerTypeUseCase:
            Get.find<GetTotalRepetitionsPerxTypeUseCase>(),
        userId: userId,
      );
    });
  }
}
