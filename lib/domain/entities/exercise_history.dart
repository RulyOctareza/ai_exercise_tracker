// lib/domain/entities/exercise_history.dart
import 'exercise.dart';

class ExerciseHistory {
  final String id;
  final String userId;
  final String exerciseId;
  final ExerciseType exerciseType;
  final int repetitions;
  final DateTime date;
  final int? duration; // Duration in seconds (optional)
  final String? notes;

  ExerciseHistory({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.exerciseType,
    required this.repetitions,
    required this.date,
    this.duration,
    this.notes,
  });

  // Helper to estimate calories burned (very approximate)
  // This is a simplistic approach and not medically accurate
  double estimateCaloriesBurned(double? weight) {
    if (weight == null || duration == null) return 0;

    // MET (Metabolic Equivalent of Task) values (approximate)
    double met;
    switch (exerciseType) {
      case ExerciseType.pushUps:
        met = 3.8;
        break;
      case ExerciseType.squats:
        met = 5.0;
        break;
      case ExerciseType.downwardDogPlank:
        met = 4.0;
        break;
      case ExerciseType.jumpingJack:
        met = 8.0;
        break;
      case ExerciseType.clap:
        met = 2.5;
        break;
    }

    // Calories = MET * weight in kg * time in hours
    final hours = duration! / 3600;
    return met * weight * hours;
  }

  ExerciseHistory copyWith({
    String? id,
    String? userId,
    String? exerciseId,
    ExerciseType? exerciseType,
    int? repetitions,
    DateTime? date,
    int? duration,
    String? notes,
  }) {
    return ExerciseHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseType: exerciseType ?? this.exerciseType,
      repetitions: repetitions ?? this.repetitions,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
    );
  }
}
