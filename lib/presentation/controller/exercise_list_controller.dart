import 'package:get/get.dart';

import '../../domain/entities/exercise.dart';
import '../../domain/usecases/exercise/get_exercises_usecase.dart';
import '../../routes/app_routes.dart';

class ExerciseListController extends GetxController {
  final GetExercisesUseCase _getExercisesUseCase;

  ExerciseListController({required GetExercisesUseCase getExercisesUseCase})
    : _getExercisesUseCase = getExercisesUseCase;

  final RxList<Exercise> exercises = <Exercise>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadExercises();
  }

  Future<void> loadExercises() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final exerciseList = await _getExercisesUseCase.execute();
      exercises.value = exerciseList;
    } catch (e) {
      errorMessage.value = 'Failed to load exercises: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToDetectionScreen(Exercise exercise) {
    Get.toNamed(AppRoutes.DETECTION, arguments: exercise);
  }
}
