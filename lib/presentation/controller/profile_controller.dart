
import 'package:ai_exercise_tracker/presentation/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';


import '../../domain/entities/user.dart';

import '../../domain/usecases/user/get_user_profile_usecase.dart';
import '../../domain/usecases/user/update_user_profile_usecase.dart';
import '../../domain/usecases/user/update_physical_data_usecase.dart';


class ProfileController extends GetxController {
  final GetUserProfileUseCase _getUserProfileUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final UpdatePhysicalDataUseCase _updatePhysicalDataUseCase;
  final AuthController _authController;
  final String _userId;

  ProfileController({
    required GetUserProfileUseCase getUserProfileUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
    required UpdatePhysicalDataUseCase updatePhysicalDataUseCase,
    required AuthController authController,
    required String userId,
  }) : _getUserProfileUseCase = getUserProfileUseCase,
       _updateUserProfileUseCase = updateUserProfileUseCase,
       _updatePhysicalDataUseCase = updatePhysicalDataUseCase,
       _authController = authController,
       _userId = userId;

  // Observable state
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // Form controllers
  final Rx<TextEditingController> nameController = TextEditingController().obs;
  final Rx<TextEditingController> heightController =
      TextEditingController().obs;
  final Rx<TextEditingController> weightController =
      TextEditingController().obs;

  // Stats for UI
  final RxInt totalRepetitions = 0.obs;
  final RxInt totalWorkouts = 0.obs;
  final Rx<String?> favoriteExercise = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();

    // Set mock data for stats (in a real app, this would come from repositories)
    totalRepetitions.value = 450;
    totalWorkouts.value = 15;
    favoriteExercise.value = 'Push Ups';
  }

  Future<void> loadUserProfile() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userProfile = await _getUserProfileUseCase.execute(_userId);
      user.value = userProfile;

      // Initialize form controllers
      if (userProfile != null) {
        nameController.value.text = userProfile.name ?? '';
        heightController.value.text = userProfile.height?.toString() ?? '';
        weightController.value.text = userProfile.weight?.toString() ?? '';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load profile: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({
    required String name,
    DateTime? birthDate,
  }) async {
    if (user.value == null) return;

    isLoading.value = true;

    try {
      final updatedUser = user.value!.copyWith(
        name: name,
        birthDate: birthDate,
        updatedAt: DateTime.now(),
      );

      await _updateUserProfileUseCase.execute(updatedUser);
      user.value = updatedUser;

      Get.back();
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      errorMessage.value = 'Failed to update profile: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePhysicalData({
    required double? height,
    required double? weight,
  }) async {
    if (user.value == null) return;

    isLoading.value = true;

    try {
      await _updatePhysicalDataUseCase.execute(_userId, height, weight);

      // Update local user object
      user.value = user.value!.copyWith(
        height: height,
        weight: weight,
        updatedAt: DateTime.now(),
      );

      Get.back();
      Get.snackbar('Success', 'Physical data updated successfully');
    } catch (e) {
      errorMessage.value = 'Failed to update physical data: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // In a real app, this would upload the image to storage
      // For now, we'll just mock it
      Get.snackbar(
        'Coming Soon',
        'Image upload will be available in a future update',
      );
    }
  }

  Future<void> logout() async {
    try {
      await _authController.logout();
    } catch (e) {
      Get.snackbar('Error', 'Failed to logout: ${e.toString()}');
    }
  }
}
