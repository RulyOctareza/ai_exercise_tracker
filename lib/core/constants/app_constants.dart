class AppConstants {
  // App info
  static const String appName = 'AI Exercise Tracker';
  static const String appVersion = '1.0.0';

  // SharedPreferences keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyFirstTimeUser = 'first_time_user';

  // Exercise related
  static const int minClapInterval = 300; // milliseconds
  static const int minExerciseToSave = 1; // minimum reps to save

  // UI related
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
}
