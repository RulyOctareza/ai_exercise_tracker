import 'package:ai_exercise_tracker/presentation/controller/auth_controller.dart';
import 'package:ai_exercise_tracker/presentation/controller/profile_controller.dart';
import 'package:get/get.dart';

import '../../domain/usecases/user/get_user_profile_usecase.dart';
import '../../domain/usecases/user/update_physical_data_usecase.dart';
import '../../domain/usecases/user/update_user_profile_usecase.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Use cases - menggunakan repository yang sudah ada
    Get.lazyPut<GetUserProfileUseCase>(
      () => GetUserProfileUseCase(Get.find()),
      fenix: true,
    );

    Get.lazyPut<UpdateUserProfileUseCase>(
      () => UpdateUserProfileUseCase(Get.find()),
      fenix: true,
    );

    Get.lazyPut<UpdatePhysicalDataUseCase>(
      () => UpdatePhysicalDataUseCase(Get.find()),
      fenix: true,
    );

    // Controller
    Get.lazyPut<ProfileController>(() {
      final authController = Get.find<AuthController>();
      final userId = authController.user.value?.id ?? '';

      return ProfileController(
        getUserProfileUseCase: Get.find<GetUserProfileUseCase>(),
        updateUserProfileUseCase: Get.find<UpdateUserProfileUseCase>(),
        updatePhysicalDataUseCase: Get.find<UpdatePhysicalDataUseCase>(),
        authController: authController,
        userId: userId,
      );
    });
  }
}
