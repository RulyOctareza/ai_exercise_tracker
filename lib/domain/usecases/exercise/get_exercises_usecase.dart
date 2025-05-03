// lib/domain/usecases/exercise/get_exercises_usecase.dart
import '../../entities/exercise.dart';
import '../../repositories/exercise_repository.dart';

class GetExercisesUseCase {
  final ExerciseRepository exerciseRepository;

  GetExercisesUseCase(this.exerciseRepository);

  Future<List<Exercise>> execute() async {
    return await exerciseRepository.getExercises();
  }
}
