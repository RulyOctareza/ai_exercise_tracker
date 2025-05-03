import '../../entities/exercise.dart';
import '../../entities/exercise_history.dart';
import '../../repositories/exercise_repository.dart';

class GetLastExerciseRecordUseCase {
  final ExerciseRepository exerciseRepository;

  GetLastExerciseRecordUseCase(this.exerciseRepository);

  Future<ExerciseHistory?> execute(
    String userId,
    ExerciseType exerciseType,
  ) async {
    return await exerciseRepository.getLastExerciseRecord(userId, exerciseType);
  }
}
