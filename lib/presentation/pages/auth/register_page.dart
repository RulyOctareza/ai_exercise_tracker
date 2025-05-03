// lib/presentation/pages/auth/register_page.dart
import 'package:ai_exercise_tracker/core/constants/assets_paths.dart';
import 'package:ai_exercise_tracker/presentation/controller/auth_controller.dart';
import 'package:awesome_icons/awesome_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../routes/app_routes.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthController _authController = Get.find<AuthController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final RxBool _isPasswordVisible = false.obs;
  final RxBool _isConfirmPasswordVisible = false.obs;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      _authController.register(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

                // Logo and title
                Center(
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        AssetPaths.logoPath,
                        height: 80,
                        width: 80,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Create Account',
                        style: TextStyles.heading1.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign up to start your fitness journey',
                        style: TextStyles.bodyMedium.copyWith(
                          color: AppColors.lightPurple,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Registration form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email field
                      Text(
                        'Email',
                        style: TextStyles.bodyMedium.copyWith(
                          color: AppColors.lightPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppColors.lightPurple,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!GetUtils.isEmail(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Password field
                      Text(
                        'Password',
                        style: TextStyles.bodyMedium.copyWith(
                          color: AppColors.lightPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible.value,
                          decoration: InputDecoration(
                            hintText: 'Create a password',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: AppColors.lightPurple,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible.value
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.lightPurple,
                              ),
                              onPressed: () => _isPasswordVisible.toggle(),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Confirm Password field
                      Text(
                        'Confirm Password',
                        style: TextStyles.bodyMedium.copyWith(
                          color: AppColors.lightPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible.value,
                          decoration: InputDecoration(
                            hintText: 'Confirm your password',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: AppColors.lightPurple,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible.value
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.lightPurple,
                              ),
                              onPressed:
                                  () => _isConfirmPasswordVisible.toggle(),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Register button
                Obx(
                  () => CustomButton(
                    text: 'Register',
                    onPressed: _register,
                    isLoading: _authController.isLoading.value,
                    icon: Icons.person_add,
                  ),
                ),

                const SizedBox(height: 24),

                // Divider with "or"
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: AppColors.lightPurple,
                        thickness: 0.5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyles.bodySmall.copyWith(
                          color: AppColors.lightPurple,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        color: AppColors.lightPurple,
                        thickness: 0.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Google sign in button
                CustomButton(
                  text: 'Continue with Google',
                  onPressed: _authController.loginWithGoogle,
                  type: ButtonType.outline,
                  icon: FontAwesomeIcons.google,
                ),

                const SizedBox(height: 32),

                // Login link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyles.bodyMedium.copyWith(
                          color: AppColors.lightPurple,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.offNamed(AppRoutes.LOGIN),
                        child: Text(
                          'Login',
                          style: TextStyles.bodyMedium.copyWith(
                            color: AppColors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
