import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

class SharedPrefsService extends GetxService {
  final SharedPreferences _prefs = Get.find<SharedPreferences>();

  // Auth token
  Future<bool> saveAuthToken(String token) async {
    return await _prefs.setString(AppConstants.keyAuthToken, token);
  }

  String? getAuthToken() {
    return _prefs.getString(AppConstants.keyAuthToken);
  }

  Future<bool> removeAuthToken() async {
    return await _prefs.remove(AppConstants.keyAuthToken);
  }

  // User ID
  Future<bool> saveUserId(String userId) async {
    return await _prefs.setString(AppConstants.keyUserId, userId);
  }

  String? getUserId() {
    return _prefs.getString(AppConstants.keyUserId);
  }

  Future<bool> removeUserId() async {
    return await _prefs.remove(AppConstants.keyUserId);
  }

  // User email
  Future<bool> saveUserEmail(String email) async {
    return await _prefs.setString(AppConstants.keyUserEmail, email);
  }

  String? getUserEmail() {
    return _prefs.getString(AppConstants.keyUserEmail);
  }

  Future<bool> removeUserEmail() async {
    return await _prefs.remove(AppConstants.keyUserEmail);
  }

  // Check if user is first time
  Future<bool> saveFirstTimeUser(bool isFirstTime) async {
    return await _prefs.setBool(AppConstants.keyFirstTimeUser, isFirstTime);
  }

  bool isFirstTimeUser() {
    return _prefs.getBool(AppConstants.keyFirstTimeUser) ?? true;
  }

  // Clear all authentication data
  Future<void> clearAuthData() async {
    await removeAuthToken();
    await removeUserId();
    await removeUserEmail();
  }
}
