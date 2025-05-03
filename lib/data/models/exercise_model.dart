// lib/data/models/exercise_model.dart
import '../../domain/entities/exercise.dart';

class ExerciseModel extends Exercise {
  ExerciseModel({
    required super.id,
    required super.title,
    required super.imageAsset,
    required super.type,
    required super.description,
    super.targetRepetitions,
    super.isActive,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'],
      title: json['title'],
      imageAsset: json['imageAsset'],
      type: _typeFromString(json['type']),
      description: json['description'],
      targetRepetitions: json['targetRepetitions'] ?? 10,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageAsset': imageAsset,
      'type': type.toString().split('.').last,
      'description': description,
      'targetRepetitions': targetRepetitions,
      'isActive': isActive,
    };
  }

  static ExerciseType _typeFromString(String typeString) {
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
