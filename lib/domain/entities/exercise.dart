enum ExerciseType { pushUps, squats, downwardDogPlank, jumpingJack, clap }

class Exercise {
  final String id;
  final String title;
  final String imageAsset; // Path to the exercise image asset
  final ExerciseType type;
  final String description;
  final int targetRepetitions; // Target reps for beginners
  final bool isActive; // For disabling exercises temporarily if needed

  Exercise({
    required this.id,
    required this.title,
    required this.imageAsset,
    required this.type,
    required this.description,
    this.targetRepetitions = 10,
    this.isActive = true,
  });

  // Helper method to get string representation of exercise type
  String get typeAsString {
    switch (type) {
      case ExerciseType.pushUps:
        return 'Push Ups';
      case ExerciseType.squats:
        return 'Squats';
      case ExerciseType.downwardDogPlank:
        return 'Plank to Downward Dog';
      case ExerciseType.jumpingJack:
        return 'Jumping Jack';
      case ExerciseType.clap:
        return 'Clap';
    }
  }

  // Get color associated with exercise type
  dynamic get color {
    switch (type) {
      case ExerciseType.pushUps:
        return 0xFF896CFE; // Purple
      case ExerciseType.squats:
        return 0xFFE2F163; // Lime Green
      case ExerciseType.downwardDogPlank:
        return 0xFFFFD700; // Gold
      case ExerciseType.jumpingJack:
        return 0xFFFF6B6B; // Coral
      case ExerciseType.clap:
        return 0xFF64D2FF; // Light Blue
    }
  }
}
