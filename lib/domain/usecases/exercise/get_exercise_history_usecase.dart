import '../../entities/exercise.dart';
import '../../entities/exercise_history.dart';
import '../../repositories/exercise_repository.dart';

class GetExerciseHistoryUseCase {
  final ExerciseRepository exerciseRepository;

  GetExerciseHistoryUseCase(this.exerciseRepository);

  Future<List<ExerciseHistory>> execute({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    ExerciseType? exerciseType,
  }) async {
    return await exerciseRepository.getExerciseHistoryForUser(
      userId,
      startDate: startDate,
      endDate: endDate,
      exerciseType: exerciseType,
    );
  }
}
