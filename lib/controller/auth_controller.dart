import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../models/api_models.dart';
import '../models/patient_model.dart';
import '../models/user.dart';
import '../services/api_service.dart';

import '../db/database_helper.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

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
  static const String _savedCnicKey = 'saved_cnic';

  @override
  void onInit() {
    super.onInit();
    _apiService.initialize(); // This also initializes the encryption service
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
    required String cnic,
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
        isActive: 2,
        cnic: cnic
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
    required String cnic,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      isLoading.value = true;

      final request = LoginRequest(
        cnic: cnic,
        password: password,
      );

      final response = await _apiService.loginUser(request);

      if (response.success && response.data != null) {
        // Account approved, proceed with login
        // Store authentication data
        await _storeAuthData(response.data!, cnic);

        // Store decrypted reference data in database
        final decryptedData = _apiService.getLastDecryptedData();
        if (decryptedData != null) {
          try {
            // Reset database before storing new reference data
            await _dbHelper.resetDatabase();
            
            // Store new reference data
            await _dbHelper.storeReferenceData(decryptedData);
            
            debugPrint('Reference data stored successfully in database');
          } catch (e) {
            debugPrint('Error storing reference data: $e');
          }
        }

        // Handle remember me
        if (rememberMe) {
          await _saveCredentials(cnic, password);
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
        // Handle specific error messages from API
        final errorMessage = response.message;
        
        if (errorMessage.contains('pending approval')) {
          Get.snackbar(
            'Account Pending',
            errorMessage,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        } else if (errorMessage.contains('rejected')) {
          Get.snackbar(
            'Account Rejected',
            errorMessage,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Login Failed',
            errorMessage,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
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

      // Create user model from decrypted data
      final decryptedData = _apiService.getLastDecryptedData();
      final user = UserModel(
        id: decryptedData?.userInfo?.id?.toString() ?? '1',
        userName: decryptedData?.userInfo?.userName ?? 'User',
        email: decryptedData?.userInfo?.email ?? email,
        phoneNo: decryptedData?.userInfo?.phoneNo ?? '',
        designation: decryptedData?.userInfo?.designation ?? '',
        isActive: true,
      );

      currentUser.value = user;
      await prefs.setString(_userKey, jsonEncode(user.toJson()));

      // Store patients from decrypted data if available
      if (decryptedData?.patients != null && decryptedData!.patients!.isNotEmpty) {
        await _storeDecryptedPatients(decryptedData.patients!);
      }

    } catch (e) {
      print('Error storing auth data: $e');
      throw Exception('Failed to store authentication data');
    }
  }

  /// Store decrypted patients in the local database
  Future<void> _storeDecryptedPatients(List<dynamic> patients) async {
    try {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;
      int storedCount = 0;
      // Begin transaction for better performance
      await db.transaction((txn) async {
        for (var patient in patients) {
          // Convert API patient model to local patient model
          final patientModel = PatientModel.fromApiModel(patient);
          
          // Insert into database with conflict resolution
          await txn.insert(
            'patients',
            patientModel.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          storedCount++;
        }
      });

      print('Successfully stored $storedCount patients in local database');
    } catch (e) {
      print('Error storing decrypted patients: $e');
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

      // Clear API token and decrypted data
      _apiService.clearAuthToken();
      _apiService.clearDecryptedData();

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
      await prefs.setString(_savedCnicKey, email);
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
      await prefs.remove(_savedCnicKey);
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
          'cnic': prefs.getString(_savedCnicKey),
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
