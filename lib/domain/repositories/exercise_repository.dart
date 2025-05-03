import '../entities/exercise.dart';
import '../entities/exercise_history.dart';

abstract class ExerciseRepository {
  // Get list of available exercises
  Future<List<Exercise>> getExercises();

  // Get exercise by id
  Future<Exercise?> getExerciseById(String exerciseId);

  // Get exercise by type
  Future<Exercise?> getExerciseByType(ExerciseType type);

  // Save exercise history record
  Future<void> saveExerciseHistory(ExerciseHistory history);

  // Get exercise history for a user
  Future<List<ExerciseHistory>> getExerciseHistoryForUser(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    ExerciseType? exerciseType,
  });

  // Get user's last exercise record for a specific type
  Future<ExerciseHistory?> getLastExerciseRecord(
    String userId,
    ExerciseType exerciseType,
  );

  // Get user's best record for a specific exercise type
  Future<ExerciseHistory?> getBestExerciseRecord(
    String userId,
    ExerciseType exerciseType,
  );

  // Get total repetitions per exercise type
  Future<Map<ExerciseType, int>> getTotalRepetitionsPerType(String userId);

  // Get exercise history grouped by date (for calendar view)
  Future<Map<DateTime, List<ExerciseHistory>>> getExerciseHistoryByDate(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  });
}
