import '../entities/user.dart' as app_entity;

abstract class AuthRepository {
  // Get current user info
  Future<app_entity.User?> getCurrentUser();

  // Check if user is logged in
  Future<bool> isLoggedIn();

  // Login with email/password
  Future<app_entity.User> signInWithEmailAndPassword(
    String email,
    String password,
  );

  // Login with Google
  Future<app_entity.User> signInWithGoogle();

  // Register with email/password
  Future<app_entity.User> signUpWithEmailAndPassword(
    String email,
    String password,
  );

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  // Logout
  Future<void> signOut();
}
