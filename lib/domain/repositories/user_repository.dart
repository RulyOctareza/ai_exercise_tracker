import '../entities/user.dart';

abstract class UserRepository {
  // Get user by id
  Future<User?> getUserById(String userId);

  // Create or update user profile
  Future<void> saveUserProfile(User user);

  // Update user physical data (height, weight)
  Future<void> updatePhysicalData(
    String userId,
    double? height,
    double? weight,
  );

  // Update user profile picture
  Future<String?> updateProfilePicture(String userId, String localImagePath);

  // Delete user account
  Future<void> deleteUserAccount(String userId);
}
