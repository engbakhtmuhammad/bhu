import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/auth_controller.dart';
import '../view/onboarding/onboarding.dart';
import '../view/auth/signin.dart';
import '../view/navigation/navigation.dart';

class AppController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  
  // Observable variables
  var isLoading = true.obs;
  var isFirstTime = true.obs;

  // SharedPreferences keys
  static const String _firstTimeKey = 'is_first_time';

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  /// Initialize the app and determine the initial route
  Future<void> _initializeApp() async {
    try {
      isLoading.value = true;
      
      // Check if it's the first time opening the app
      await _checkFirstTime();
      
      // Wait a bit for splash screen effect
      await Future.delayed(const Duration(seconds: 2));
      
      // Navigate to appropriate screen
      _navigateToInitialScreen();
      
    } catch (e) {
      debugPrint('Error initializing app: $e');
      // Default to onboarding on error
      Get.offAll(() => const OnboardingScreen());
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if this is the first time opening the app
  Future<void> _checkFirstTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isFirstTime.value = prefs.getBool(_firstTimeKey) ?? true;
    } catch (e) {
      debugPrint('Error checking first time: $e');
      isFirstTime.value = true;
    }
  }

  /// Navigate to the appropriate initial screen
  void _navigateToInitialScreen() {
    if (isFirstTime.value) {
      // First time - show onboarding
      Get.offAll(() => const OnboardingScreen());
    } else if (_authController.isAuthenticated) {
      // User is logged in - go to main app
      Get.offAll(() => const NavigationScreen());
    } else {
      // User is not logged in - show login
      Get.offAll(() => const LoginScreen());
    }
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_firstTimeKey, false);
      isFirstTime.value = false;
      
      // Navigate to login screen
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      Get.offAll(() => const LoginScreen());
    }
  }

  /// Handle successful login
  void onLoginSuccess() {
    Get.offAll(() => const NavigationScreen());
  }

  /// Handle logout
  Future<void> onLogout() async {
    await _authController.logout();
    Get.offAll(() => const LoginScreen());
  }

  /// Reset app to first time (for testing purposes)
  Future<void> resetToFirstTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_firstTimeKey, true);
      isFirstTime.value = true;
      
      // Clear all auth data
      await _authController.clearAuthData();
      
      // Navigate to onboarding
      Get.offAll(() => const OnboardingScreen());
    } catch (e) {
      debugPrint('Error resetting app: $e');
    }
  }

  /// Check authentication status and navigate accordingly
  void checkAuthAndNavigate() {
    if (_authController.isAuthenticated) {
      Get.offAll(() => const NavigationScreen());
    } else {
      Get.offAll(() => const LoginScreen());
    }
  }
}
