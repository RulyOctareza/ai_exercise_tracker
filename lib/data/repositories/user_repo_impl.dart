import 'package:ai_exercise_tracker/services/firebase_auth_service.dart';
import 'package:ai_exercise_tracker/services/firebase_firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseAuthService _authService;
  final FirebaseFirestoreService _firestoreService;

  UserRepositoryImpl({
    required FirebaseAuthService authService,
    required FirebaseFirestoreService firestoreService,
  }) : _authService = authService,
       _firestoreService = firestoreService;

  @override
  Future<User?> getUserById(String userId) async {
    try {
      final userDoc = await _firestoreService.userDocument(userId).get();

      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  @override
  Future<void> saveUserProfile(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await _firestoreService
          .userDocument(user.id)
          .set(userModel.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user profile: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePhysicalData(
    String userId,
    double? height,
    double? weight,
  ) async {
    try {
      Map<String, dynamic> data = {
        'height': height,
        'weight': weight,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _firestoreService.userDocument(userId).update(data);
    } catch (e) {
      throw Exception('Failed to update physical data: ${e.toString()}');
    }
  }

  @override
  Future<String?> updateProfilePicture(
    String userId,
    String localImagePath,
  ) async {
    // This would typically use Firebase Storage
    // For now, we'll just mock the functionality
    try {
      // Mock successful upload with a dummy URL
      String photoUrl = 'https://example.com/profile/$userId.jpg';

      // Update user document
      await _firestoreService.userDocument(userId).update({
        'photoUrl': photoUrl,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return photoUrl;
    } catch (e) {
      throw Exception('Failed to update profile picture: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUserAccount(String userId) async {
    try {
      // Delete user document from Firestore
      await _firestoreService.userDocument(userId).delete();

      // Delete user from Firebase Auth
      await _authService.currentUser?.delete();
    } catch (e) {
      throw Exception('Failed to delete user account: ${e.toString()}');
    }
  }
}
