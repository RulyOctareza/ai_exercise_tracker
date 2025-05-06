import 'dart:developer';

import 'package:ai_exercise_tracker/data/repositories/auth_repo_impl.dart';
import 'package:ai_exercise_tracker/data/repositories/exercise_repo_impl.dart';
import 'package:ai_exercise_tracker/data/repositories/user_repo_impl.dart';
import 'package:ai_exercise_tracker/domain/repositories/auth_repository.dart';
import 'package:ai_exercise_tracker/domain/repositories/exercise_repository.dart';
import 'package:ai_exercise_tracker/domain/repositories/user_repository.dart';
import 'package:ai_exercise_tracker/presentation/controller/auth_controller.dart';
import 'package:ai_exercise_tracker/services/firebase_auth_service.dart';
import 'package:ai_exercise_tracker/services/firebase_firestore_service.dart';
import 'package:ai_exercise_tracker/services/shared_pref_service.dart';
import 'package:get/get.dart';
import 'domain/usecases/auth/login_usecase.dart';
import 'domain/usecases/auth/google_login_usecase.dart';
import 'domain/usecases/auth/register_usecase.dart';
import 'domain/usecases/auth/logout_usecase.dart';
import 'domain/usecases/auth/is_logged_in_usecase.dart';
import 'domain/usecases/auth/get_current_user_usecase.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    log("Initializing core services...");
    // Core services
    Get.put<FirebaseAuthService>(FirebaseAuthService(), permanent: true);
    Get.put<FirebaseFirestoreService>(
      FirebaseFirestoreService(),
      permanent: true,
    );
    Get.put<SharedPrefsService>(SharedPrefsService(), permanent: true);

    log("Initializing repositories...");
    // Repositories
    final authRepo = AuthRepositoryImpl(
      authService: Get.find<FirebaseAuthService>(),
      firestoreService: Get.find<FirebaseFirestoreService>(),
      prefsService: Get.find<SharedPrefsService>(),
    );
    Get.put<AuthRepositoryImpl>(authRepo, permanent: true);
    Get.put<AuthRepository>(authRepo, permanent: true);

    final exerciseRepo = ExerciseRepositoryImpl(
      firestoreService: Get.find<FirebaseFirestoreService>(),
    );
    Get.put<ExerciseRepositoryImpl>(exerciseRepo, permanent: true);
    Get.put<ExerciseRepository>(exerciseRepo, permanent: true);

    final userRepo = UserRepositoryImpl(
      authService: Get.find<FirebaseAuthService>(),
      firestoreService: Get.find<FirebaseFirestoreService>(),
    );
    Get.put<UserRepositoryImpl>(userRepo, permanent: true);
    Get.put<UserRepository>(userRepo, permanent: true);

    log("Initializing use cases...");
    // Auth Use Cases
    Get.put<LoginUseCase>(
      LoginUseCase(Get.find<AuthRepository>()),
      permanent: true,
    );

    Get.put<GoogleLoginUseCase>(
      GoogleLoginUseCase(Get.find<AuthRepository>()),
      permanent: true,
    );

    Get.put<RegisterUseCase>(
      RegisterUseCase(Get.find<AuthRepository>()),
      permanent: true,
    );

    Get.put<LogoutUseCase>(
      LogoutUseCase(Get.find<AuthRepository>()),
      permanent: true,
    );

    Get.put<IsLoggedInUseCase>(
      IsLoggedInUseCase(Get.find<AuthRepository>()),
      permanent: true,
    );

    Get.put<GetCurrentUserUseCase>(
      GetCurrentUserUseCase(Get.find<AuthRepository>()),
      permanent: true,
    );

    log("Initializing controllers...");
    // Controllers
    Get.put<AuthController>(
      AuthController(
        loginUseCase: Get.find<LoginUseCase>(),
        googleLoginUseCase: Get.find<GoogleLoginUseCase>(),
        registerUseCase: Get.find<RegisterUseCase>(),
        logoutUseCase: Get.find<LogoutUseCase>(),
        isLoggedInUseCase: Get.find<IsLoggedInUseCase>(),
        getCurrentUserUseCase: Get.find<GetCurrentUserUseCase>(),
      ),
      permanent: true,
    );

    log("AppBinding initialized successfully");
  }
}
