// lib/presentation/bindings/history_binding.dart
import 'package:ai_exercise_tracker/domain/usecases/exercise/get_total_rep_per_type_usecase.dart';
import 'package:ai_exercise_tracker/presentation/controller/auth_controller.dart';
import 'package:ai_exercise_tracker/presentation/controller/history_controller.dart';
import 'package:get/get.dart';

import '../../domain/usecases/exercise/get_exercise_history_usecase.dart';


class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    // Use cases - menggunakan repository yang sudah ada
    Get.lazyPut<GetExerciseHistoryUseCase>(
      () => GetExerciseHistoryUseCase(Get.find()),
      fenix: true,
    );

    Get.lazyPut<GetTotalRepetitionsPerTypeUseCase>(
      () => GetTotalRepetitionsPerTypeUseCase(Get.find()),
      fenix: true,
    );

    // Controller
    Get.lazyPut<HistoryController>(() {
      final authController = Get.find<AuthController>();
      final userId = authController.user.value?.id ?? '';

      return HistoryController(
        getExerciseHistoryUseCase: Get.find<GetExerciseHistoryUseCase>(),
        getTotalRepetitionsPerTypeUseCase:
            Get.find<GetTotalRepetitionsPerTypeUseCase>(),
        userId: userId,
      );
    });
  }
}
