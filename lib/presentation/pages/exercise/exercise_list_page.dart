// lib/presentation/pages/exercise/exercise_list_page.dart
import 'package:ai_exercise_tracker/presentation/controller/auth_controller.dart';
import 'package:ai_exercise_tracker/presentation/controller/exercise_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/exercise_card.dart';
import '../../../core/widgets/loading_widget.dart';

class ExerciseListPage extends StatelessWidget {
  const ExerciseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final exerciseController = Get.find<ExerciseListController>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Exercise Tracker'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.toNamed('/profile'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section with user greeting
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        final user = authController.user.value;
                        final greeting =
                            user?.name != null
                                ? 'Hey, ${user!.name!.split(' ').first}'
                                : 'Welcome';
                        return Text(
                          greeting,
                          style: TextStyles.heading2.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                      const SizedBox(height: 4),
                      Text(
                        'Ready for your workout today?',
                        style: TextStyles.bodyMedium.copyWith(
                          color: AppColors.lightPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.limeGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.history,
                        color: AppColors.black,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'History',
                        style: TextStyles.bodySmall.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Title for exercise list
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Text(
              'Available Exercises',
              style: TextStyles.heading3.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Exercise list
          Expanded(
            child: Obx(() {
              if (exerciseController.isLoading.value) {
                return const LoadingWidget(message: 'Loading exercises...');
              }

              if (exerciseController.exercises.isEmpty) {
                return Center(
                  child: Text(
                    'No exercises available',
                    style: TextStyles.bodyLarge.copyWith(
                      color: AppColors.lightPurple,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: exerciseController.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exerciseController.exercises[index];
                  return ExerciseCard(
                    exercise: exercise,
                    onTap:
                        () => exerciseController.navigateToDetectionScreen(
                          exercise,
                        ),
                  );
                },
              );
            }),
          ),
        ],
      ),
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
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on exercises page
              break;
            case 1:
              Get.toNamed('/history');
              break;
            case 2:
              Get.toNamed('/profile');
              break;
          }
        },
      ),
    );
  }
}
