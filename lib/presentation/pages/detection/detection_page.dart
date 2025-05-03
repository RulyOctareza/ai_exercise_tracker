import 'package:ai_exercise_tracker/presentation/controller/detection_controller.dart';
import 'package:ai_exercise_tracker/presentation/pages/exercise/widgets/pose_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/custom_button.dart';

class DetectionPage extends StatelessWidget {
  const DetectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DetectionController>();
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        // Confirm before exiting
        final result = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Exit Exercise'),
                content: const Text(
                  'Are you sure you want to exit? Your progress will not be saved.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Exit'),
                  ),
                ],
              ),
        );
        return result ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Camera preview with pose detection overlay
            Obx(() {
              final cameraController = controller.camera.cameraController;

              if (cameraController == null ||
                  !cameraController.value.isInitialized) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.purple),
                );
              }

              return SizedBox(
                width: size.width,
                height: size.height,
                child: AspectRatio(
                  aspectRatio: cameraController.value.aspectRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CameraPreview(cameraController),
                      Obx(() {
                        if (controller.poses.isNotEmpty) {
                          return CustomPaint(
                            painter: PosePainter(
                              poses: controller.poses,
                              imageSize: Size(
                                cameraController.value.previewSize!.height,
                                cameraController.value.previewSize!.width,
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      }),
                    ],
                  ),
                ),
              );
            }),

            // Exercise title at top
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Obx(() {
                final exercise = controller.exercise.value;
                if (exercise == null) return Container();

                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Color(exercise.color).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          exercise.title,
                          style: TextStyles.heading3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Image.asset(exercise.imageAsset, height: 36, width: 36),
                    ],
                  ),
                );
              }),
            ),

            // Counter at center bottom
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.purple.withOpacity(0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purple.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Obx(
                      () => Text(
                        '${controller.repetitionCount.value}',
                        style: TextStyles.exerciseCounter,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Reset button at bottom right
            Positioned(
              bottom: 30,
              right: 30,
              child: FloatingActionButton(
                heroTag: 'resetButton',
                backgroundColor: AppColors.error,
                onPressed: controller.resetCounter,
                child: const Icon(Icons.refresh, color: Colors.white),
              ),
            ),

            // Finish button at top right
            Positioned(
              top: 50,
              right: 20,
              child: FloatingActionButton.small(
                heroTag: 'finishButton',
                backgroundColor: AppColors.limeGreen,
                onPressed: () => _showFinishDialog(context, controller),
                child: const Icon(Icons.check, color: Colors.black),
              ),
            ),

            // Debug info if enabled
            Obx(() {
              if (!controller.showDebugInfo.value ||
                  controller.debugInfo.value.isEmpty) {
                return Container();
              }

              return Positioned(
                bottom: 30,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    controller.debugInfo.value,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showFinishDialog(BuildContext context, DetectionController controller) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Finish Exercise'),
            content: Obx(
              () => Text(
                'You completed ${controller.repetitionCount.value} repetitions. Save your progress?',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continue Exercise'),
              ),
              CustomButton(
                text: 'Save & Finish',
                type: ButtonType.primary,
                onPressed: () {
                  Navigator.of(context).pop();
                  controller.finishExercise();
                },
                width: 150,
                height: 44,
              ),
            ],
          ),
    );
  }
}
