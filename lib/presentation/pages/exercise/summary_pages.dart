// lib/presentation/pages/exercise/exercise_summary_page.dart
import 'package:ai_exercise_tracker/core/constants/assets_paths.dart';
import 'package:ai_exercise_tracker/core/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';

import '../../../core/widgets/custom_button.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/exercise_history.dart';
import '../../../routes/app_routes.dart';

class ExerciseSummaryPage extends StatefulWidget {
  const ExerciseSummaryPage({super.key});

  @override
  State<ExerciseSummaryPage> createState() => _ExerciseSummaryPageState();
}

class _ExerciseSummaryPageState extends State<ExerciseSummaryPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScreenshotController _screenshotController = ScreenshotController();

  late Exercise exercise;
  late ExerciseHistory currentRecord;
  ExerciseHistory? previousRecord;
  String feedbackMessage = '';
  String animationPath = '';

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>;
    exercise = args['exercise'] as Exercise;
    currentRecord = args['currentRecord'] as ExerciseHistory;
    previousRecord = args['previousRecord'] as ExerciseHistory?;

    // Determine feedback message and animation
    if (previousRecord == null) {
      feedbackMessage = "First Time! Keep Going!";
      animationPath = AssetPaths.goodJobAnimPath;
    } else if (currentRecord.repetitions > previousRecord!.repetitions) {
      feedbackMessage = "Awesome Progress!";
      animationPath = AssetPaths.awesomeAnimPath;
    } else if (currentRecord.repetitions == previousRecord!.repetitions) {
      feedbackMessage = "Good Job, Keep Consistent!";
      animationPath = AssetPaths.goodJobAnimPath;
    } else {
      feedbackMessage = "Need More Effort!";
      animationPath = AssetPaths.tryHarderAnimPath;
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _shareResults() async {
    try {
      final image = await _screenshotController.capture();
      if (image == null) return;

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/exercise_summary.png';
      final File imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      await Share.shareXFiles(
        [XFile(imagePath)],
        text:
            'I just completed ${currentRecord.repetitions} ${exercise.title} using AI Exercise Tracker! 💪',
        subject: 'My Workout Results',
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share results: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Color(exercise.color);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Exercise Summary'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Animation for feedback
                Lottie.asset(
                  animationPath,
                  width: 150,
                  height: 150,
                  controller: _animationController,
                ),

                const SizedBox(height: 16),

                // Feedback message
                Text(
                  feedbackMessage,
                  style: TextStyles.heading2.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Screenshot area
                Screenshot(
                  controller: _screenshotController,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Exercise info
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(exercise.color).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                exercise.imageAsset,
                                height: 36,
                                width: 36,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.title,
                                    style: TextStyles.heading3.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    AppDateUtils.formatDateTime(
                                      currentRecord.date,
                                    ),
                                    style: TextStyles.bodySmall.copyWith(
                                      color: AppColors.lightPurple,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Current result
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.purple.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Today\'s Result',
                                    style: TextStyles.bodyMedium.copyWith(
                                      color: AppColors.lightPurple,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '${currentRecord.repetitions}',
                                        style: TextStyles.heading1.copyWith(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'reps',
                                        style: TextStyles.bodyLarge.copyWith(
                                          color: AppColors.lightPurple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (currentRecord.duration != null) ...[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Duration',
                                      style: TextStyles.bodyMedium.copyWith(
                                        color: AppColors.lightPurple,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${currentRecord.duration! ~/ 60}m ${currentRecord.duration! % 60}s',
                                      style: TextStyles.heading3.copyWith(
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Comparison with previous
                        if (previousRecord != null) ...[
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBackground,
                                    border: Border.all(
                                      color: AppColors.lightPurple.withOpacity(
                                        0.3,
                                      ),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Previous',
                                        style: TextStyles.bodySmall.copyWith(
                                          color: AppColors.lightPurple,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${previousRecord!.repetitions} reps',
                                        style: TextStyles.bodyLarge.copyWith(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        AppDateUtils.formatDate(
                                          previousRecord!.date,
                                        ),
                                        style: TextStyles.caption.copyWith(
                                          color: AppColors.lightPurple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBackground,
                                    border: Border.all(
                                      color: AppColors.lightPurple.withOpacity(
                                        0.3,
                                      ),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Difference',
                                        style: TextStyles.bodySmall.copyWith(
                                          color: AppColors.lightPurple,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          _buildDifferenceIcon(),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${_getDifferenceText()} reps',
                                            style: TextStyles.bodyLarge
                                                .copyWith(
                                                  color: _getDifferenceColor(),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Additional stats
                        // Average and total would be added here in a real app
                        // For now, let's just add a placeholder/mock data
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Weekly Avg',
                                '${_getMockWeeklyAvg()} reps',
                                Icons.auto_graph,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'Total',
                                '${_getMockTotalReps()} reps',
                                Icons.fitness_center,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                AssetPaths.logoPath,
                                height: 24,
                                width: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'AI Exercise Tracker',
                                style: TextStyles.bodySmall.copyWith(
                                  color: AppColors.lightPurple,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Share Results',
                        onPressed: _shareResults,
                        type: ButtonType.outline,
                        icon: Icons.share,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Continue',
                        onPressed: () => Get.offAllNamed(AppRoutes.HOME),
                        type: ButtonType.primary,
                        icon: Icons.check,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(
          color: AppColors.lightPurple.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.lightPurple),
              const SizedBox(width: 4),
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
            style: TextStyles.bodyLarge.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifferenceIcon() {
    if (previousRecord == null) return Container();

    final difference = currentRecord.repetitions - previousRecord!.repetitions;

    if (difference > 0) {
      return Icon(Icons.arrow_upward, size: 16, color: AppColors.success);
    } else if (difference < 0) {
      return Icon(Icons.arrow_downward, size: 16, color: AppColors.error);
    } else {
      return Icon(Icons.drag_handle, size: 16, color: AppColors.warning);
    }
  }

  String _getDifferenceText() {
    if (previousRecord == null) return '0';

    final difference = currentRecord.repetitions - previousRecord!.repetitions;

    if (difference > 0) {
      return '+$difference';
    } else {
      return '$difference';
    }
  }

  Color _getDifferenceColor() {
    if (previousRecord == null) return AppColors.white;

    final difference = currentRecord.repetitions - previousRecord!.repetitions;

    if (difference > 0) {
      return AppColors.success;
    } else if (difference < 0) {
      return AppColors.error;
    } else {
      return AppColors.warning;
    }
  }

  // Mock data methods - in a real app, these would be calculated from actual data
  int _getMockWeeklyAvg() {
    return (currentRecord.repetitions * 0.85).round();
  }

  int _getMockTotalReps() {
    return previousRecord == null
        ? currentRecord.repetitions
        : currentRecord.repetitions + previousRecord!.repetitions * 5;
  }
}
