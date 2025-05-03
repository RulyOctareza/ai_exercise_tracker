import '../../entities/exercise.dart';
import '../../repositories/exercise_repository.dart';

class GetTotalRepetitionsPerTypeUseCase {
  final ExerciseRepository exerciseRepository;

  GetTotalRepetitionsPerTypeUseCase(this.exerciseRepository);

  Future<Map<ExerciseType, int>> execute(String userId) async {
    return await exerciseRepository.getTotalRepetitionsPerType(userId);
  }
}
