// lib/presentation/pages/profile/edit_profile_page.dart
import 'package:ai_exercise_tracker/presentation/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/custom_button.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ProfileController _controller = Get.find<ProfileController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  DateTime? _selectedBirthDate;

  @override
  void initState() {
    super.initState();
    _nameController = _controller.nameController.value;
    _heightController = _controller.heightController.value;
    _weightController = _controller.weightController.value;
    _selectedBirthDate = _controller.user.value?.birthDate;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.purple,
              onPrimary: AppColors.white,
              surface: AppColors.cardBackground,
              onSurface: AppColors.white,
            ),
            dialogTheme: DialogThemeData(backgroundColor: AppColors.background),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      _controller.updateProfile(
        name: _nameController.text,
        birthDate: _selectedBirthDate,
      );
    }
  }

  void _savePhysicalData() {
    if (_formKey.currentState!.validate()) {
      final height =
          _heightController.text.isNotEmpty
              ? double.tryParse(_heightController.text)
              : null;

      final weight =
          _weightController.text.isNotEmpty
              ? double.tryParse(_weightController.text)
              : null;

      _controller.updatePhysicalData(height: height, weight: weight);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Edit Profile'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personal Information Section
                Text(
                  'Personal Information',
                  style: TextStyles.heading3.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                // Name field
                Text(
                  'Name',
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.lightPurple,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppColors.lightPurple,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Birth date field
                Text(
                  'Birth Date',
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.lightPurple,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lightPurple),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.lightPurple,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          _selectedBirthDate != null
                              ? DateFormat(
                                'MMMM d, yyyy',
                              ).format(_selectedBirthDate!)
                              : 'Select your birth date',
                          style: TextStyles.bodyMedium.copyWith(
                            color:
                                _selectedBirthDate != null
                                    ? AppColors.white
                                    : AppColors.lightPurple.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Save personal info button
                CustomButton(
                  text: 'Save Personal Info',
                  icon: Icons.save,
                  onPressed: _saveProfile,
                  isLoading: _controller.isLoading.value,
                ),

                const SizedBox(height: 32),
                const Divider(color: AppColors.lightPurple),
                const SizedBox(height: 32),

                // Physical Data Section
                Text(
                  'Physical Data',
                  style: TextStyles.heading3.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                // Height field
                Text(
                  'Height (cm)',
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.lightPurple,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter your height in cm',
                    prefixIcon: const Icon(
                      Icons.height,
                      color: AppColors.lightPurple,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final height = double.tryParse(value);
                      if (height == null) {
                        return 'Please enter a valid number';
                      }
                      if (height < 50 || height > 250) {
                        return 'Please enter a height between 50 and 250 cm';
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Weight field
                Text(
                  'Weight (kg)',
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.lightPurple,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter your weight in kg',
                    prefixIcon: const Icon(
                      Icons.fitness_center,
                      color: AppColors.lightPurple,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final weight = double.tryParse(value);
                      if (weight == null) {
                        return 'Please enter a valid number';
                      }
                      if (weight < 20 || weight > 250) {
                        return 'Please enter a weight between 20 and 250 kg';
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // BMI info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.purple.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.purple),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Your BMI will be calculated automatically based on your height and weight.',
                          style: TextStyles.bodySmall.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Save physical data button
                CustomButton(
                  text: 'Save Physical Data',
                  icon: Icons.save,
                  onPressed: _savePhysicalData,
                  isLoading: _controller.isLoading.value,
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
