// lib/presentation/pages/splash_page.dart
import 'package:ai_exercise_tracker/core/constants/assets_paths.dart';
import 'package:ai_exercise_tracker/core/theme/app_colors.dart';
import 'package:ai_exercise_tracker/core/theme/text_styles.dart';
import 'package:ai_exercise_tracker/presentation/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  final AuthController _authController = Get.find<AuthController>();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animationController.forward();

    // Delayed navigation to allow animation to play
    Future.delayed(const Duration(seconds: 3), () {
      _authController.checkLoginStatus();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Animation
              Lottie.asset(
                AssetPaths.loadingAnimPath,
                width: 200,
                height: 200,
                controller: _animationController,
              ),

              // App Name
              Text(
                'AI Exercise Tracker',
                style: TextStyles.heading1.copyWith(
                  color: AppColors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Tagline
              Text(
                'Your personal fitness companion',
                style: TextStyles.bodyLarge.copyWith(
                  color: AppColors.lightPurple,
                ),
              ),

              const SizedBox(height: 48),

              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.limeGreen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
