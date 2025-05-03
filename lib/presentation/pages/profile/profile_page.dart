// lib/presentation/pages/profile/profile_page.dart
import 'package:ai_exercise_tracker/presentation/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../routes/app_routes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Loading profile...');
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header with user info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.purple, AppColors.lightPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purple.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Profile picture
                    Obx(() {
                      final photoUrl = controller.user.value?.photoUrl;
                      final name = controller.user.value?.name ?? 'User';

                      return GestureDetector(
                        onTap: controller.pickProfileImage,
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 3,
                                ),
                                image:
                                    photoUrl != null && photoUrl.isNotEmpty
                                        ? DecorationImage(
                                          image: NetworkImage(photoUrl),
                                          fit: BoxFit.cover,
                                        )
                                        : null,
                              ),
                              child:
                                  photoUrl == null || photoUrl.isEmpty
                                      ? Center(
                                        child: Text(
                                          _getInitials(name),
                                          style: TextStyles.heading1.copyWith(
                                            color: AppColors.purple,
                                          ),
                                        ),
                                      )
                                      : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.limeGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: AppColors.black,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // User name
                    Obx(
                      () => Text(
                        controller.user.value?.name ?? 'User',
                        style: TextStyles.heading2.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // User email
                    Obx(
                      () => Text(
                        controller.user.value?.email ?? '',
                        style: TextStyles.bodyMedium.copyWith(
                          color: AppColors.white.withOpacity(0.85),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Edit profile button
                    CustomButton(
                      text: 'Edit Profile',
                      icon: Icons.edit,
                      type: ButtonType.outline,
                      onPressed: () => Get.toNamed(AppRoutes.EDIT_PROFILE),
                      width: 150,
                      height: 40,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Physical stats section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Physical Stats',
                  style: TextStyles.heading3.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Height, Weight, BMI cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildPhysicalStatCard(
                        'Height',
                        controller.user.value?.height != null
                            ? '${controller.user.value!.height!.toStringAsFixed(1)} cm'
                            : 'Not set',
                        Icons.height,
                        AppColors.limeGreen,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPhysicalStatCard(
                        'Weight',
                        controller.user.value?.weight != null
                            ? '${controller.user.value!.weight!.toStringAsFixed(1)} kg'
                            : 'Not set',
                        Icons.fitness_center,
                        AppColors.purple,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // BMI Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(
                  () => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Body Mass Index (BMI)',
                                style: TextStyles.bodyLarge.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Measure of body fat based on height and weight',
                                style: TextStyles.bodySmall.copyWith(
                                  color: AppColors.lightPurple,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (controller.user.value?.bmi != null) ...[
                                Text(
                                  controller.user.value!.bmi!.toStringAsFixed(
                                    1,
                                  ),
                                  style: TextStyles.heading1.copyWith(
                                    color: _getBmiColor(
                                      controller.user.value!.bmi!,
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getBmiColor(
                                      controller.user.value!.bmi!,
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    controller.user.value!.bmiCategory!,
                                    style: TextStyles.bodySmall.copyWith(
                                      color: _getBmiColor(
                                        controller.user.value!.bmi!,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  'Set your height and weight to\ncalculate BMI',
                                  style: TextStyles.bodyMedium.copyWith(
                                    color: AppColors.lightPurple,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (controller.user.value?.bmi != null)
                          Expanded(
                            flex: 1,
                            child: _buildBmiGauge(controller.user.value!.bmi!),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Exercise stats section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Exercise Stats',
                  style: TextStyles.heading3.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Exercise stats cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() {
                  final totalReps = controller.totalRepetitions.value;
                  final totalWorkouts = controller.totalWorkouts.value;

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildExerciseStatCard(
                              'Total Reps',
                              '$totalReps',
                              Icons.fitness_center,
                              AppColors.purple,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildExerciseStatCard(
                              'Workouts',
                              '$totalWorkouts',
                              Icons.calendar_today,
                              AppColors.limeGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (controller.favoriteExercise.value != null)
                        _buildExerciseStatCard(
                          'Favorite Exercise',
                          controller.favoriteExercise.value!,
                          Icons.star,
                          AppColors.purple,
                        ),
                    ],
                  );
                }),
              ),

              const SizedBox(height: 32),

              // Logout button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomButton(
                  text: 'Logout',
                  icon: Icons.logout,
                  type: ButtonType.outline,
                  onPressed: () => _confirmLogout(context, controller),
                ),
              ),

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
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.offAllNamed('/home');
              break;
            case 1:
              Get.offAllNamed('/history');
              break;
            case 2:
              // Already on profile page
              break;
          }
        },
      ),
    );
  }

  Widget _buildPhysicalStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyles.heading3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.lightPurple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyles.heading3.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBmiGauge(double bmi) {
    return SizedBox(
      height: 100,
      width: 100,
      child: PieChart(
        PieChartData(
          sectionsSpace: 0,
          centerSpaceRadius: 30,
          sections: [
            // Underweight section
            PieChartSectionData(
              color: Colors.blue,
              value: 18.5,
              radius: 20,
              showTitle: false,
            ),
            // Normal section
            PieChartSectionData(
              color: Colors.green,
              value: 6.5, // 25 - 18.5
              radius: 20,
              showTitle: false,
            ),
            // Overweight section
            PieChartSectionData(
              color: Colors.orange,
              value: 5, // 30 - 25
              radius: 20,
              showTitle: false,
            ),
            // Obese section
            PieChartSectionData(
              color: Colors.red,
              value: 10, // 40 - 30
              radius: 20,
              showTitle: false,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, ProfileController controller) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              CustomButton(
                text: 'Logout',
                type: ButtonType.primary,
                onPressed: () {
                  Navigator.of(context).pop();
                  controller.logout();
                },
                width: 100,
                height: 40,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ],
          ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';

    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    } else {
      return name.substring(0, name.length > 1 ? 2 : 1);
    }
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) {
      return Colors.blue;
    } else if (bmi < 25) {
      return Colors.green;
    } else if (bmi < 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
