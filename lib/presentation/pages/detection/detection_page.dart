import 'package:ai_exercise_tracker/presentation/controller/detection_controller.dart';
import 'package:ai_exercise_tracker/presentation/pages/exercise/widgets/pose_painter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/custom_button.dart';

class DetectionPage extends StatefulWidget {
  const DetectionPage({super.key});

  @override
  State<DetectionPage> createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage>
    with WidgetsBindingObserver {
  late DetectionController controller;
  CameraController? cameraController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = Get.find<DetectionController>();

    // Reinitialize camera each time page opens
    _initializeCamera();

    // Also listen for changes to the camera controller
    ever(controller.camera.isInitialized, (_) {
      if (mounted) {
        setState(() {
          cameraController = controller.camera.cameraController;
        });
      }
    });
  }

  Future<void> _initializeCamera() async {
    // Re-initialize camera service to fix issues when reopening page
    await controller.camera.init();

    // Update local controller reference
    if (mounted && controller.camera.cameraController != null) {
      setState(() {
        cameraController = controller.camera.cameraController;
        print(
          "Camera controller updated: ${cameraController?.value.isInitialized}",
        );
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes to properly manage camera resource
    final CameraController? ctlr = cameraController;

    if (ctlr == null || !ctlr.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      // Free up resources when app is inactive
      ctlr.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize when app resumes
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // We don't dispose the camera here as it's managed by the service
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
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

        if (result == true) {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Camera preview
            if (cameraController != null &&
                cameraController!.value.isInitialized)
              Positioned.fill(
                child: Transform.scale(
                  scale: 1.0,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: cameraController!.value.aspectRatio,
                      child: CameraPreview(cameraController!),
                    ),
                  ),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: AppColors.purple),
              ),

            // Pose Detection Overlay - adjusted to match camera preview size/position
            Obx(() {
              if (controller.poses.isEmpty ||
                  cameraController == null ||
                  !cameraController!.value.isInitialized ||
                  cameraController!.value.previewSize == null) {
                return Container();
              }

              // Use positioned.fill to match the camera preview exactly
              return Positioned.fill(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: cameraController!.value.aspectRatio,
                    child: CustomPaint(
                      // Using the same size as camera preview
                      size: Size(
                        cameraController!.value.previewSize!.width.toDouble(),
                        cameraController!.value.previewSize!.height.toDouble(),
                      ),
                      painter: PosePainter(
                        poses: controller.poses,
                        imageSize: Size(
                          cameraController!.value.previewSize!.height,
                          cameraController!.value.previewSize!.width,
                        ),
                      ),
                    ),
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
              top: 120,
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
