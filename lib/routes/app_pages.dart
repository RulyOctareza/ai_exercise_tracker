// lib/routes/app_pages.dart
import 'package:ai_exercise_tracker/presentation/bindings/auth_bindings.dart';
import 'package:ai_exercise_tracker/presentation/bindings/exercise_binding.dart';
import 'package:ai_exercise_tracker/presentation/bindings/history_bindings.dart';
import 'package:ai_exercise_tracker/presentation/bindings/profile_binding.dart';
import 'package:ai_exercise_tracker/presentation/pages/auth/login_page.dart';
import 'package:ai_exercise_tracker/presentation/pages/auth/register_page.dart';
import 'package:ai_exercise_tracker/presentation/pages/detection/detection_page.dart';
import 'package:ai_exercise_tracker/presentation/pages/exercise/excercise_detail_page.dart';
import 'package:ai_exercise_tracker/presentation/pages/exercise/exercise_list_page.dart';
import 'package:ai_exercise_tracker/presentation/pages/exercise/summary_pages.dart';
import 'package:ai_exercise_tracker/presentation/pages/history/history_page.dart';
import 'package:ai_exercise_tracker/presentation/pages/profile/edit_profile_page.dart';
import 'package:ai_exercise_tracker/presentation/pages/profile/profile_page.dart';
import 'package:ai_exercise_tracker/presentation/pages/splashpage/splash_page.dart';
import 'package:get/get.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => SplashPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => RegisterPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => ExerciseListPage(),
      binding: ExerciseBinding(),
    ),
    GetPage(
      name: AppRoutes.EXERCISE_LIST,
      page: () => ExerciseListPage(),
      binding: ExerciseBinding(),
    ),
    GetPage(
      name: AppRoutes.DETECTION,
      page: () => DetectionPage(),
      binding: ExerciseBinding(),
    ),
    GetPage(
      name: AppRoutes.EXERCISE_SUMMARY,
      page: () => ExerciseSummaryPage(),
      binding: ExerciseBinding(),
    ),
    GetPage(
      name: AppRoutes.HISTORY,
      page: () => HistoryPage(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: AppRoutes.EXERCISE_DETAILS,
      page: () => ExerciseDetailsPage(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => ProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.EDIT_PROFILE,
      page: () => EditProfilePage(),
      binding: ProfileBinding(),
    ),
  ];
}
