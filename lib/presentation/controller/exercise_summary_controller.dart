// lib/presentation/controllers/exercise_summary_controller.dart
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io';

import '../../domain/entities/exercise.dart';
import '../../domain/entities/exercise_history.dart';

class ExerciseSummaryController extends GetxController {
  final ScreenshotController screenshotController = ScreenshotController();

  late Rx<Exercise> exercise;
  late Rx<ExerciseHistory> currentRecord;
  final Rx<ExerciseHistory?> previousRecord = Rx<ExerciseHistory?>(null);

  final RxString feedbackMessage = ''.obs;
  final RxString animationPath = ''.obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>;
    exercise = Rx<Exercise>(args['exercise'] as Exercise);
    currentRecord = Rx<ExerciseHistory>(
      args['currentRecord'] as ExerciseHistory,
    );
    previousRecord.value = args['previousRecord'] as ExerciseHistory?;

    // Set feedback message and animation
    _setFeedbackAndAnimation();
  }

  void _setFeedbackAndAnimation() {
    if (previousRecord.value == null) {
      feedbackMessage.value = "First Time! Keep Going!";
      animationPath.value = 'assets/animations/good_job.json';
    } else if (currentRecord.value.repetitions >
        previousRecord.value!.repetitions) {
      feedbackMessage.value = "Awesome Progress!";
      animationPath.value = 'assets/animations/awesome.json';
    } else if (currentRecord.value.repetitions ==
        previousRecord.value!.repetitions) {
      feedbackMessage.value = "Good Job, Keep Consistent!";
      animationPath.value = 'assets/animations/good_job.json';
    } else {
      feedbackMessage.value = "Need More Effort!";
      animationPath.value = 'assets/animations/nice_try.json';
    }
  }

  Future<void> shareResults() async {
    try {
      final image = await screenshotController.capture();
      if (image == null) {
        Get.snackbar('Error', 'Failed to capture screenshot');
        return;
      }

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/exercise_summary.png';
      final File imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      await Share.shareXFiles(
        [XFile(imagePath)],
        text:
            'I just completed ${currentRecord.value.repetitions} ${exercise.value.title} using AI Exercise Tracker! 💪',
        subject: 'My Workout Results',
      );

      // Provide haptic feedback
      HapticFeedback.mediumImpact();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share results: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Calculate mock weekly average (in a real app, this would come from history data)
  int getWeeklyAverage() {
    final base = currentRecord.value.repetitions - 2;
    return base > 0 ? base : currentRecord.value.repetitions;
  }

  // Calculate mock total reps (in a real app, this would come from history data)
  int getTotalReps() {
    return previousRecord.value != null
        ? currentRecord.value.repetitions +
            previousRecord.value!.repetitions +
            15
        : currentRecord.value.repetitions;
  }

  // Calculate approximate calories burned
  int getEstimatedCalories() {
    if (currentRecord.value.duration == null) return 0;

    // Very approximate MET values
    double met;
    switch (exercise.value.type) {
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

    // Estimated average weight of 70kg if not available
    const weight = 70.0;

    // Calories = MET * weight in kg * time in hours
    final hours = currentRecord.value.duration! / 3600;
    return (met * weight * hours).round();
  }
}
