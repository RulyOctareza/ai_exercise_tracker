import 'package:ai_exercise_tracker/data/repositories/auth_repo_impl.dart';
import 'package:ai_exercise_tracker/presentation/controller/auth_controller.dart';
import 'package:ai_exercise_tracker/services/firebase_auth_service.dart';
import 'package:ai_exercise_tracker/services/firebase_firestore_service.dart';
import 'package:ai_exercise_tracker/services/shared_pref_service.dart';
import 'package:get/get.dart';

import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/google_login_usecase.dart';
import '../../domain/usecases/auth/is_logged_in_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<FirebaseAuthService>(() => FirebaseAuthService(), fenix: true);
    Get.lazyPut<FirebaseFirestoreService>(
      () => FirebaseFirestoreService(),
      fenix: true,
    );
    Get.lazyPut<SharedPrefsService>(() => SharedPrefsService(), fenix: true);

    // Repository
    Get.lazyPut<AuthRepositoryImpl>(
      () => AuthRepositoryImpl(
        authService: Get.find<FirebaseAuthService>(),
        firestoreService: Get.find<FirebaseFirestoreService>(),
        prefsService: Get.find<SharedPrefsService>(),
      ),
      fenix: true,
    );

    // Use cases
    Get.lazyPut<LoginUseCase>(
      () => LoginUseCase(Get.find<AuthRepositoryImpl>()),
      fenix: true,
    );
    Get.lazyPut<GoogleLoginUseCase>(
      () => GoogleLoginUseCase(Get.find<AuthRepositoryImpl>()),
      fenix: true,
    );
    Get.lazyPut<RegisterUseCase>(
      () => RegisterUseCase(Get.find<AuthRepositoryImpl>()),
      fenix: true,
    );
    Get.lazyPut<LogoutUseCase>(
      () => LogoutUseCase(Get.find<AuthRepositoryImpl>()),
      fenix: true,
    );
    Get.lazyPut<IsLoggedInUseCase>(
      () => IsLoggedInUseCase(Get.find<AuthRepositoryImpl>()),
      fenix: true,
    );
    Get.lazyPut<GetCurrentUserUseCase>(
      () => GetCurrentUserUseCase(Get.find<AuthRepositoryImpl>()),
      fenix: true,
    );

    // Controller
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
