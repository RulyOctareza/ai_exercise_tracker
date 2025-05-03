import 'package:ai_exercise_tracker/core/utils/app_utils.dart'
    as app_date_utils;
import 'package:ai_exercise_tracker/presentation/controller/history_controller.dart';
import 'package:ai_exercise_tracker/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';

import '../../../core/widgets/loading_widget.dart';
import '../../../domain/entities/exercise.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Exercise History'), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Loading your history...');
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendar View
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: _buildCalendar(controller),
              ),

              const SizedBox(height: 16),

              // Selected Date Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(
                  () => Text(
                    'Activity on ${app_date_utils.AppDateUtils.formatDateWithDay(controller.selectedDate.value)}',
                    style: TextStyles.heading3.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Selected Date Activities
              Obx(() {
                final selectedDateActivities = controller.getActivitiesForDate(
                  controller.selectedDate.value,
                );

                if (selectedDateActivities.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.fitness_center,
                            color: AppColors.lightPurple,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No exercises on this day',
                            style: TextStyles.bodyLarge.copyWith(
                              color: AppColors.lightPurple,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Select a different date or start a new exercise!',
                            style: TextStyles.bodySmall.copyWith(
                              color: AppColors.lightPurple.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: selectedDateActivities.length,
                  itemBuilder: (context, index) {
                    final activity = selectedDateActivities[index];
                    final exerciseColor = _getExerciseColor(
                      activity.exerciseType,
                    );

                    return GestureDetector(
                      onTap:
                          () =>
                              navigateToExerciseDetails(activity.exerciseType),
                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: 12,
                          left: 16,
                          right: 16,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(exerciseColor).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Color(exerciseColor).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Icon(
                                  _getExerciseIcon(activity.exerciseType),
                                  color: Color(exerciseColor),
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getExerciseName(activity.exerciseType),
                                    style: TextStyles.bodyLarge.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    app_date_utils.AppDateUtils.formatTime(
                                      activity.date,
                                    ),
                                    style: TextStyles.bodySmall.copyWith(
                                      color: AppColors.lightPurple,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Color(exerciseColor).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${activity.repetitions} reps',
                                style: TextStyles.bodyMedium.copyWith(
                                  color: Color(exerciseColor),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),

              const SizedBox(height: 24),

              // Activity Chart Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Weekly Activity',
                  style: TextStyles.heading3.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Chart
              Container(
                height: 220,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Obx(() {
                  final weeklyData = controller.getWeeklyActivityData();

                  if (weeklyData.isEmpty) {
                    return Center(
                      child: Text(
                        'Not enough data for chart',
                        style: TextStyles.bodyMedium.copyWith(
                          color: AppColors.lightPurple,
                        ),
                      ),
                    );
                  }

                  return _buildBarChart(weeklyData);
                }),
              ),

              const SizedBox(height: 24),

              // Total Statistics
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Exercise Summary',
                  style: TextStyles.heading3.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Exercise totals
              Obx(() {
                final totals = controller.totalRepetitionsPerType;

                if (totals.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Center(
                      child: Text(
                        'No data available yet',
                        style: TextStyles.bodyMedium.copyWith(
                          color: AppColors.lightPurple,
                        ),
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: totals.length,
                  itemBuilder: (context, index) {
                    final entry = totals.entries.elementAt(index);
                    final exerciseType = entry.key;
                    final totalReps = entry.value;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(
                            _getExerciseColor(exerciseType),
                          ).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getExerciseIcon(exerciseType),
                            color: Color(_getExerciseColor(exerciseType)),
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getExerciseName(exerciseType),
                            style: TextStyles.bodyMedium.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$totalReps reps',
                            style: TextStyles.bodyLarge.copyWith(
                              color: Color(_getExerciseColor(exerciseType)),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),

              const SizedBox(height: 40),
            ],
          ),
        );
      }),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.purple,
        unselectedItemColor: AppColors.lightPurple,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Exercises',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.offAllNamed('/home');
              break;
            case 1:
              // Already on history page
              break;
            case 2:
              Get.offAllNamed('/profile');
              break;
          }
        },
      ),
    );
  }

  navigateToExerciseDetails(ExerciseType exerciseType) {
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

  Widget _buildCalendar(HistoryController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Obx(
        () => TableCalendar(
          firstDay: DateTime.utc(2023, 1, 1),
          lastDay: DateTime.now().add(const Duration(days: 0)),
          focusedDay: controller.focusedDate.value,
          calendarFormat: controller.calendarFormat.value,
          selectedDayPredicate: (day) {
            return isSameDay(controller.selectedDate.value, day);
          },
          eventLoader: (day) {
            return controller.getActivitiesForDate(day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            controller.selectedDate.value = selectedDay;
            controller.focusedDate.value = focusedDay;
          },
          onFormatChanged: (format) {
            controller.calendarFormat.value = format;
          },
          onPageChanged: (focusedDay) {
            controller.focusedDate.value = focusedDay;
          },
          calendarStyle: CalendarStyle(
            markersMaxCount: 3,
            markerDecoration: const BoxDecoration(
              color: AppColors.purple,
              shape: BoxShape.circle,
            ),
            todayDecoration: const BoxDecoration(
              color: AppColors.purple,
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppColors.limeGreen,
              shape: BoxShape.circle,
            ),
            outsideDaysVisible: false,
            weekendTextStyle: TextStyles.bodySmall.copyWith(
              color: AppColors.white,
            ),
            defaultTextStyle: TextStyles.bodySmall.copyWith(
              color: AppColors.white,
            ),
          ),
          headerStyle: HeaderStyle(
            titleTextStyle: TextStyles.bodyLarge.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
            formatButtonTextStyle: TextStyles.bodySmall.copyWith(
              color: AppColors.black,
            ),
            formatButtonDecoration: BoxDecoration(
              color: AppColors.limeGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            leftChevronIcon: const Icon(
              Icons.chevron_left,
              color: AppColors.purple,
            ),
            rightChevronIcon: const Icon(
              Icons.chevron_right,
              color: AppColors.purple,
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyles.bodySmall.copyWith(
              color: AppColors.lightPurple,
            ),
            weekendStyle: TextStyles.bodySmall.copyWith(
              color: AppColors.lightPurple,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, int> weeklyData) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    weeklyData.keys.elementAt(value.toInt()),
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.lightPurple,
                    ),
                  ),
                );
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value == 0) return Container();
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    value.toInt().toString(),
                    style: TextStyles.caption.copyWith(
                      color: AppColors.lightPurple,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 10,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.lightPurple.withOpacity(0.15),
              strokeWidth: 1,
            );
          },
        ),
        barGroups: List.generate(weeklyData.length, (index) {
          final value = weeklyData.values.elementAt(index);
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value.toDouble(),
                gradient: const LinearGradient(
                  colors: [AppColors.purple, AppColors.limeGreen],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 15,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  IconData _getExerciseIcon(ExerciseType type) {
    switch (type) {
      case ExerciseType.pushUps:
        return Icons.fitness_center;
      case ExerciseType.squats:
        return Icons.accessible;
      case ExerciseType.downwardDogPlank:
        return Icons.airline_seat_flat;
      case ExerciseType.jumpingJack:
        return Icons.directions_run;
      case ExerciseType.clap:
        return Icons.back_hand;
    }
  }
}
