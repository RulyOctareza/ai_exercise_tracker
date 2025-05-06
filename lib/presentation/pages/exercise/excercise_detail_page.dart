// lib/presentation/pages/history/exercise_details_page.dart
import 'package:ai_exercise_tracker/core/utils/app_utils.dart' as app_date_utils;
import 'package:ai_exercise_tracker/presentation/controller/history_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/exercise_history.dart';

class ExerciseDetailsPage extends StatelessWidget {
  const ExerciseDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final exerciseType = args['exerciseType'] as ExerciseType;
    final title = args['title'] as String;
    final imageAsset = args['imageAsset'] as String;
    final color = Color(args['color'] as int);

    final controller = Get.find<HistoryController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.3), width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      imageAsset,
                      height: 50,
                      width: 50,
                      
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyles.heading3.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(() {
                          final totalReps =
                              controller
                                  .totalRepetitionsPerType[exerciseType] ??
                              0;
                          return Text(
                            'Total: $totalReps repetitions',
                            style: TextStyles.bodyMedium.copyWith(
                              color: AppColors.white,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Statistics section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Progress Overview',
                style: TextStyles.heading3.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Progress chart
            Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Obx(() {
                final history =
                    controller.exerciseHistory
                        .where((h) => h.exerciseType == exerciseType)
                        .toList();

                if (history.isEmpty) {
                  return Center(
                    child: Text(
                      'Not enough data for chart',
                      style: TextStyles.bodyMedium.copyWith(
                        color: AppColors.lightPurple,
                      ),
                    ),
                  );
                }

                // Take latest 7 records or less
                final chartData =
                    history.take(7).toList()
                      ..sort((a, b) => a.date.compareTo(b.date));

                return _buildLineChart(chartData, color);
              }),
            ),

            const SizedBox(height: 24),

            // Stats cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() {
                final history =
                    controller.exerciseHistory
                        .where((h) => h.exerciseType == exerciseType)
                        .toList();

                if (history.isEmpty) {
                  return Container();
                }

                // Calculate statistics
                final totalSessions = history.length;
                final totalReps = history.fold<int>(
                  0,
                  (sum, item) => sum + item.repetitions,
                );

                history.sort((a, b) => b.repetitions.compareTo(a.repetitions));
                final bestRecord = history.isNotEmpty ? history.first : null;

                final avgReps =
                    totalSessions > 0 ? (totalReps / totalSessions).round() : 0;

                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Best Record',
                        bestRecord != null
                            ? '${bestRecord.repetitions} reps'
                            : 'N/A',
                        Icons.emoji_events,
                        color,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Average',
                        '$avgReps reps',
                        Icons.bar_chart,
                        color,
                      ),
                    ),
                  ],
                );
              }),
            ),

            const SizedBox(height: 24),

            // History list section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Exercise History',
                style: TextStyles.heading3.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // List of history
            Obx(() {
              final history =
                  controller.exerciseHistory
                      .where((h) => h.exerciseType == exerciseType)
                      .toList()
                    ..sort((a, b) => b.date.compareTo(a.date));

              if (history.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.history,
                          color: AppColors.lightPurple,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No history available',
                          style: TextStyles.bodyLarge.copyWith(
                            color: AppColors.lightPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 40),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  return _buildHistoryItem(item, color);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<ExerciseHistory> data, Color color) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.lightPurple.withOpacity(0.15),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= data.length || value < 0) {
                  return Container();
                }
                final date = data[value.toInt()].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('MM/dd').format(date),
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.lightPurple,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.lightPurple,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: data.length - 1.0,
        minY: 0,
        maxY:
            data.map((e) => e.repetitions).reduce((a, b) => a > b ? a : b) *
            1.2,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              data.length,
              (index) =>
                  FlSpot(index.toDouble(), data[index].repetitions.toDouble()),
            ),
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: color,
                  strokeWidth: 2,
                  strokeColor: AppColors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyles.bodySmall.copyWith(
                  color: AppColors.lightPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyles.heading3.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(ExerciseHistory history, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                app_date_utils.AppDateUtils.formatDateWithDay(history.date),
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                app_date_utils.AppDateUtils.formatTime(history.date),
                style: TextStyles.bodySmall.copyWith(
                  color: AppColors.lightPurple,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.fitness_center, color: color, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${history.repetitions} reps',
                  style: TextStyles.bodyMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
