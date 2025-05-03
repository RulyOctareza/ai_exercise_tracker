import 'package:ai_exercise_tracker/domain/usecases/exercise/get_total_rep_per_type_usecase.dart';
import 'package:ai_exercise_tracker/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../domain/entities/exercise.dart';
import '../../domain/entities/exercise_history.dart';
import '../../domain/usecases/exercise/get_exercise_history_usecase.dart';

class HistoryController extends GetxController {
  final GetExerciseHistoryUseCase _getExerciseHistoryUseCase;
  final GetTotalRepetitionsPerTypeUseCase _getTotalRepetitionsPerTypeUseCase;
  final String _userId;

  HistoryController({
    required GetExerciseHistoryUseCase getExerciseHistoryUseCase,
    required GetTotalRepetitionsPerTypeUseCase
    getTotalRepetitionsPerTypeUseCase,
    required String userId,
  }) : _getExerciseHistoryUseCase = getExerciseHistoryUseCase,
       _getTotalRepetitionsPerTypeUseCase = getTotalRepetitionsPerTypeUseCase,
       _userId = userId;

  // Observable state
  final RxList<ExerciseHistory> exerciseHistory = <ExerciseHistory>[].obs;
  final RxMap<ExerciseType, int> totalRepetitionsPerType =
      <ExerciseType, int>{}.obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // Calendar state
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<DateTime> focusedDate = DateTime.now().obs;
  final Rx<CalendarFormat> calendarFormat = CalendarFormat.month.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Get exercise history
      final history = await _getExerciseHistoryUseCase.execute(
        userId: _userId,
        startDate: DateTime.now().subtract(const Duration(days: 90)),
      );
      exerciseHistory.value = history;

      // Get total repetitions per exercise type
      final totals = await _getTotalRepetitionsPerTypeUseCase.execute(_userId);
      totalRepetitionsPerType.value = totals;
    } catch (e) {
      errorMessage.value = 'Failed to load history: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Get activities for a specific date
  List<ExerciseHistory> getActivitiesForDate(DateTime date) {
    return exerciseHistory
        .where((history) => isSameDay(history.date, date))
        .toList();
  }

  // Get weekly activity data for chart
  Map<String, int> getWeeklyActivityData() {
    // Get the start and end of the current week
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    final Map<String, int> result = {};

    // Initialize days of week
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (final day in weekDays) {
      result[day] = 0;
    }

    // Aggregate data
    for (final history in exerciseHistory) {
      if (history.date.isAfter(weekStart) ||
          isSameDay(history.date, weekStart)) {
        final dayIndex = history.date.weekday - 1; // 0 = Monday
        final day = weekDays[dayIndex];
        result[day] = (result[day] ?? 0) + history.repetitions;
      }
    }

    return result;
  }

  // Get monthly activity data for heatmap
  Map<DateTime, int> getMonthlyActivityData() {
    final Map<DateTime, int> result = {};

    for (final history in exerciseHistory) {
      final date = DateTime(
        history.date.year,
        history.date.month,
        history.date.day,
      );
      result[date] = (result[date] ?? 0) + history.repetitions;
    }

    return result;
  }

  // Get most active day
  DateTime? getMostActiveDay() {
    if (exerciseHistory.isEmpty) return null;

    final activityByDate = getMonthlyActivityData();
    if (activityByDate.isEmpty) return null;

    return activityByDate.entries
        .reduce((max, entry) => entry.value > max.value ? entry : max)
        .key;
  }

  // Get favorite exercise type
  ExerciseType? getFavoriteExerciseType() {
    if (totalRepetitionsPerType.isEmpty) return null;

    return totalRepetitionsPerType.entries
        .reduce((max, entry) => entry.value > max.value ? entry : max)
        .key;
  }
}

// Tambahkan method ini di history_controller.dart
void navigateToExerciseDetails(ExerciseType exerciseType) {
  // Get exercise info
  final exerciseName = _getExerciseName(exerciseType);
  final exerciseImageAsset = _getExerciseImageAsset(exerciseType);
  final exerciseColor = _getExerciseColor(exerciseType);

  Get.toNamed(
    AppRoutes.EXERCISE_DETAILS,
    arguments: {
      'exerciseType': exerciseType,
      'title': exerciseName,
      'imageAsset': exerciseImageAsset,
      'color': exerciseColor,
    },
  );
}

String _getExerciseName(ExerciseType type) {
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

String _getExerciseImageAsset(ExerciseType type) {
  switch (type) {
    case ExerciseType.pushUps:
      return 'assets/icons/pushup.gif';
    case ExerciseType.squats:
      return 'assets/icons/squat.gif';
    case ExerciseType.downwardDogPlank:
      return 'assets/icons/plank.gif';
    case ExerciseType.jumpingJack:
      return 'assets/icons/jumping.gif';
    case ExerciseType.clap:
      return 'assets/icons/clap.gif';
  }
}

int _getExerciseColor(ExerciseType type) {
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
