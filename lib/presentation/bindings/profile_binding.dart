import 'package:ai_exercise_tracker/data/repositories/user_repo_impl.dart';
import 'package:ai_exercise_tracker/services/firebase_auth_service.dart';
import 'package:ai_exercise_tracker/services/firebase_firestore_service.dart';
import 'package:get/get.dart';

import '../../domain/usecases/user/get_user_profile_usecase.dart';
import '../../domain/usecases/user/update_physical_data_usecase.dart';
import '../../domain/usecases/user/update_user_profile_usecase.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<UserRepositoryImpl>(
      () => UserRepositoryImpl(
        authService: Get.find<FirebaseAuthService>(),
        firestoreService: Get.find<FirebaseFirestoreService>(),
      ),
      fenix: true,
    );

    // Use cases
    Get.lazyPut<GetUserProfileUseCase>(
      () => GetUserProfileUseCase(Get.find<UserRepositoryImpl>()),
      fenix: true,
    );

    Get.lazyPut<UpdateUserProfileUseCase>(
      () => UpdateUserProfileUseCase(Get.find<UserRepositoryImpl>()),
      fenix: true,
    );

    Get.lazyPut<UpdatePhysicalDataUseCase>(
      () => UpdatePhysicalDataUseCase(Get.find<UserRepositoryImpl>()),
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
