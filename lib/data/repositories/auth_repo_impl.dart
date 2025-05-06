import 'dart:developer';

import 'package:ai_exercise_tracker/services/firebase_auth_service.dart';
import 'package:ai_exercise_tracker/services/firebase_firestore_service.dart';
import 'package:ai_exercise_tracker/services/shared_pref_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/entities/user.dart' as app_entity;
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _authService;
  final FirebaseFirestoreService _firestoreService;
  final SharedPrefsService _prefsService;

  AuthRepositoryImpl({
    required FirebaseAuthService authService,
    required FirebaseFirestoreService firestoreService,
    required SharedPrefsService prefsService,
  }) : _authService = authService,
       _firestoreService = firestoreService,
       _prefsService = prefsService;

  @override
  Future<app_entity.User?> getCurrentUser() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser == null) return null;

    log('Attempting to get user document with UID: ${firebaseUser.uid}');

    try {
      final userDoc =
          await _firestoreService.userDocument(firebaseUser.uid).get();

      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      } else {
        // User exists in Firebase Auth but not in Firestore
        // Return basic user info
        return app_entity.User(
          id: firebaseUser.uid,
          email: firebaseUser.email!,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      log('Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = _prefsService.getAuthToken();
    final user = _authService.currentUser;
    return token != null && user != null;
  }

  @override
  Future<app_entity.User> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to sign in: user is null');
      }

      // Save auth data to shared preferences
      await _saveAuthData(user);

      // Get user data from Firestore
      final userData = await _getUserDataFromFirestore(user.uid);
      return userData;
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  @override
  Future<app_entity.User> signInWithGoogle() async {
    try {
      final userCredential = await _authService.signInWithGoogle();
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to sign in with Google: user is null');
      }

      // Save auth data to shared preferences
      await _saveAuthData(user);

      // Check if user exists in Firestore
      final userDoc = await _firestoreService.userDocument(user.uid).get();

      if (!userDoc.exists) {
        // Create new user in Firestore
        final newUser = UserModel(
          id: user.uid,
          email: user.email!,
          name: user.displayName,
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestoreService.userDocument(user.uid).set(newUser.toJson());
        return newUser;
      }

      // Get existing user data
      return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to sign in with Google: ${e.toString()}');
    }
  }

  @override
  Future<app_entity.User> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _authService.createUserWithEmailAndPassword(
        email,
        password,
      );
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to sign up: user is null');
      }

      // Save auth data to shared preferences
      await _saveAuthData(user);

      // Create new user in Firestore
      final newUser = UserModel(
        id: user.uid,
        email: user.email!,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.userDocument(user.uid).set(newUser.toJson());
      return newUser;
    } catch (e) {
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      await _prefsService.clearAuthData();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  // Helper methods
  Future<void> _saveAuthData(firebase_auth.User user) async {
    await _prefsService.saveUserId(user.uid);
    await _prefsService.saveUserEmail(user.email ?? '');
    await _prefsService.saveAuthToken(await user.getIdToken() ?? '');
  }

  Future<app_entity.User> _getUserDataFromFirestore(String userId) async {
    try {
      final userDoc = await _firestoreService.userDocument(userId).get();

      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      } else {
        // User not found in Firestore, create basic profile
        final firebaseUser = _authService.currentUser!;
        final newUser = UserModel(
          id: userId,
          email: firebaseUser.email!,
          name: firebaseUser.displayName,
          photoUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestoreService.userDocument(userId).set(newUser.toJson());
        return newUser;
      }
    } catch (e) {
      log('Error getting user data: $e');
      throw Exception('Failed to get user data from Firestore');
    }
  }
}
