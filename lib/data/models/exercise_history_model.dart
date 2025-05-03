// lib/data/models/exercise_history_model.dart
import '../../domain/entities/exercise.dart';
import '../../domain/entities/exercise_history.dart' as entity;

class ExerciseHistoryModel extends entity.ExerciseHistory {
  ExerciseHistoryModel({
    required super.id,
    required super.userId,
    required super.exerciseId,
    required super.exerciseType,
    required super.repetitions,
    required super.date,
    super.duration,
    super.notes,
  });

  factory ExerciseHistoryModel.fromEntity(entity.ExerciseHistory history) {
    return ExerciseHistoryModel(
      id: history.id,
      userId: history.userId,
      exerciseId: history.exerciseId,
      exerciseType: history.exerciseType,
      repetitions: history.repetitions,
      date: history.date,
      duration: history.duration,
      notes: history.notes,
    );
  }

  factory ExerciseHistoryModel.fromJson(Map<String, dynamic> json) {
    return ExerciseHistoryModel(
      id: json['id'],
      userId: json['userId'],
      exerciseId: json['exerciseId'],
      exerciseType: typeFromString(json['exerciseType']),
      repetitions: json['repetitions'],
      date: DateTime.parse(json['date']),
      duration: json['duration'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'exerciseId': exerciseId,
      'exerciseType': exerciseType.toString().split('.').last,
      'repetitions': repetitions,
      'date': date.toIso8601String(),
      'duration': duration,
      'notes': notes,
    };
  }

  static ExerciseType typeFromString(String typeString) {
    switch (typeString) {
      case 'pushUps':
        return ExerciseType.pushUps;
      case 'squats':
        return ExerciseType.squats;
      case 'downwardDogPlank':
        return ExerciseType.downwardDogPlank;
      case 'jumpingJack':
        return ExerciseType.jumpingJack;
      case 'clap':
        return ExerciseType.clap;
      default:
        throw ArgumentError('Unknown exercise type: $typeString');
    }
  }
}
