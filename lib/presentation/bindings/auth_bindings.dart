// lib/presentation/bindings/auth_binding.dart
import 'package:ai_exercise_tracker/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:ai_exercise_tracker/domain/usecases/auth/google_login_usecase.dart';
import 'package:ai_exercise_tracker/domain/usecases/auth/is_logged_in_usecase.dart';
import 'package:ai_exercise_tracker/domain/usecases/auth/login_usecase.dart';
import 'package:ai_exercise_tracker/domain/usecases/auth/logout_usecase.dart';
import 'package:ai_exercise_tracker/domain/usecases/auth/register_usecase.dart';
import 'package:ai_exercise_tracker/presentation/controller/auth_controller.dart';
import 'package:get/get.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Hanya controller yang perlu diregistrasi di sini, service dan repository
    // sudah di-register di AppBinding
    Get.lazyPut<AuthController>(
      () => AuthController(
        loginUseCase: Get.find<LoginUseCase>(),
        googleLoginUseCase: Get.find<GoogleLoginUseCase>(),
        registerUseCase: Get.find<RegisterUseCase>(),
        logoutUseCase: Get.find<LogoutUseCase>(),
        isLoggedInUseCase: Get.find<IsLoggedInUseCase>(),
        getCurrentUserUseCase: Get.find<GetCurrentUserUseCase>(),
      ),
    );
  }
}
