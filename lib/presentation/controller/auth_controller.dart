import 'package:get/get.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/google_login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/is_logged_in_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../routes/app_routes.dart';

class AuthController extends GetxController {
  final LoginUseCase _loginUseCase;
  final GoogleLoginUseCase _googleLoginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final IsLoggedInUseCase _isLoggedInUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthController({
    required LoginUseCase loginUseCase,
    required GoogleLoginUseCase googleLoginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required IsLoggedInUseCase isLoggedInUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  }) : _loginUseCase = loginUseCase,
       _googleLoginUseCase = googleLoginUseCase,
       _registerUseCase = registerUseCase,
       _logoutUseCase = logoutUseCase,
       _isLoggedInUseCase = isLoggedInUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase;

  final Rx<User?> user = Rx<User?>(null);
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  bool _isChecking = false;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    // Guard against multiple calls
    if (_isChecking) return;
    _isChecking = true;

    isLoading.value = false;
    try {
      final isLoggedIn = await _isLoggedInUseCase.execute();
      if (isLoggedIn) {
        final currentUser = await _getCurrentUserUseCase.execute();
        user.value = currentUser;

        // Use offAll to prevent stacking routes
        await Get.offAllNamed(AppRoutes.HOME);
        print("Navigation to HOME completed"); // Debugging
      } else {
        await Get.offAllNamed(AppRoutes.LOGIN);
      }
    } catch (e) {
      print("Login check error: $e"); // Debugging
      errorMessage.value = 'Failed to check login status: ${e.toString()}';
      await Get.offAllNamed(AppRoutes.LOGIN);
    } finally {
      isLoading.value = false;
      _isChecking = false;
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      user.value = await _loginUseCase.execute(email, password);
      Get.offAllNamed(AppRoutes.HOME);
    } catch (e) {
      errorMessage.value = 'Login failed: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      user.value = await _googleLoginUseCase.execute();
      Get.offAllNamed(AppRoutes.HOME);
    } catch (e) {
      errorMessage.value = 'Google login failed: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      user.value = await _registerUseCase.execute(email, password);
      Get.offAllNamed(AppRoutes.HOME);
    } catch (e) {
      errorMessage.value = 'Registration failed: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;

    try {
      await _logoutUseCase.execute();
      user.value = null;
      Get.offAllNamed(AppRoutes.LOGIN);
    } catch (e) {
      errorMessage.value = 'Logout failed: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
}
