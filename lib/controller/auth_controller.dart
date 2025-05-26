import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_models.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();

  // Observable variables
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var currentUser = Rxn<UserModel>();
  var authToken = ''.obs;
  var loginResponse = Rxn<LoginResponse>();

  // SharedPreferences keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _rememberMeKey = 'remember_me';
  static const String _savedEmailKey = 'saved_email';
  static const String _savedPasswordKey = 'saved_password';

  @override
  void onInit() {
    super.onInit();
    _apiService.initialize();
    _loadStoredAuthData();
  }

  /// Load stored authentication data from SharedPreferences
  Future<void> _loadStoredAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final storedToken = prefs.getString(_tokenKey);
      final isStoredLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      final storedUserJson = prefs.getString(_userKey);

      if (storedToken != null && isStoredLoggedIn && storedUserJson != null) {
        authToken.value = storedToken;
        isLoggedIn.value = true;
        _apiService.setAuthToken(storedToken);

        // Parse stored user data
        final userMap = Map<String, dynamic>.from(
          await compute(_parseJson, storedUserJson)
        );
        currentUser.value = UserModel.fromJson(userMap);
      }
    } catch (e) {
      print('Error loading stored auth data: $e');
      await clearAuthData();
    }
  }

  /// Parse JSON in isolate to avoid blocking UI
  static Map<String, dynamic> _parseJson(String jsonString) {
    return Map<String, dynamic>.from(jsonDecode(jsonString));
  }

  /// User Registration
  Future<bool> registerUser({
    required String userName,
    required String email,
    required String designation,
    required String password,
    required String phoneNo,
    required int healthFacilityId,
    required int userRoleId,
  }) async {
    try {
      isLoading.value = true;

      final request = RegisterRequest(
        userName: userName,
        email: email,
        designation: designation,
        password: password,
        phoneNo: phoneNo,
        healthFacilityId: healthFacilityId,
        userRoleId: userRoleId,
      );

      final response = await _apiService.registerUser(request);

      if (response.success) {
        Get.snackbar(
          'Success',
          'Registration successful! Please wait for approval.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Registration Failed',
          response.message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Registration failed: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// User Login
  Future<bool> loginUser({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      isLoading.value = true;

      final request = LoginRequest(
        email: email,
        password: password,
      );

      final response = await _apiService.loginUser(request);

      if (response.success && response.data != null) {
        // Store authentication data
        await _storeAuthData(response.data!, email);

        // Handle remember me
        if (rememberMe) {
          await _saveCredentials(email, password);
        } else {
          await _clearSavedCredentials();
        }

        Get.snackbar(
          'Success',
          'Login successful!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        return true;
      } else {
        Get.snackbar(
          'Login Failed',
          response.message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Login failed: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Store authentication data locally
  Future<void> _storeAuthData(LoginResponse response, String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Store token and login status
      authToken.value = response.token;
      isLoggedIn.value = true;
      loginResponse.value = response;

      await prefs.setString(_tokenKey, response.token);
      await prefs.setBool(_isLoggedInKey, true);

      // Set API token
      _apiService.setAuthToken(response.token);

      // Create user model from response (you may need to adjust this based on your API)
      final user = UserModel(
        id: '1', // You might get this from the token or API
        userName: 'User', // Extract from token or make another API call
        email: email, // Store email used for login
        isActive: true,
      );

      currentUser.value = user;
      await prefs.setString(_userKey, jsonEncode(user.toJson()));

    } catch (e) {
      print('Error storing auth data: $e');
      throw Exception('Failed to store authentication data');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await clearAuthData();

      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  /// Clear all authentication data
  Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear local variables
      authToken.value = '';
      isLoggedIn.value = false;
      currentUser.value = null;
      loginResponse.value = null;

      // Clear stored data
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      await prefs.remove(_isLoggedInKey);

      // Clear API token
      _apiService.clearAuthToken();

    } catch (e) {
      print('Error clearing auth data: $e');
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => isLoggedIn.value && authToken.value.isNotEmpty;

  /// Get current auth token
  String get token => authToken.value;

  /// Save credentials for remember me
  Future<void> _saveCredentials(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rememberMeKey, true);
      await prefs.setString(_savedEmailKey, email);
      await prefs.setString(_savedPasswordKey, password); // In production, consider encrypting this
    } catch (e) {
      debugPrint('Error saving credentials: $e');
    }
  }

  /// Clear saved credentials
  Future<void> _clearSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rememberMeKey, false);
      await prefs.remove(_savedEmailKey);
      await prefs.remove(_savedPasswordKey);
    } catch (e) {
      debugPrint('Error clearing credentials: $e');
    }
  }

  /// Get saved credentials
  Future<Map<String, String?>> getSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(_rememberMeKey) ?? false;

      if (rememberMe) {
        return {
          'email': prefs.getString(_savedEmailKey),
          'password': prefs.getString(_savedPasswordKey),
        };
      }
    } catch (e) {
      debugPrint('Error getting saved credentials: $e');
    }
    return {'email': null, 'password': null};
  }

  /// Check if remember me is enabled
  Future<bool> isRememberMeEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_rememberMeKey) ?? false;
    } catch (e) {
      debugPrint('Error checking remember me: $e');
      return false;
    }
  }
}