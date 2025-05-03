// lib/domain/usecases/exercise/save_exercise_history_usecase.dart
import '../../entities/exercise_history.dart';
import '../../repositories/exercise_repository.dart';

class SaveExerciseHistoryUseCase {
  final ExerciseRepository exerciseRepository;

  SaveExerciseHistoryUseCase(this.exerciseRepository);

  Future<void> execute(ExerciseHistory history) async {
    await exerciseRepository.saveExerciseHistory(history);
  }
}
