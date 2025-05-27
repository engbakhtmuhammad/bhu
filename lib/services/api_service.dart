import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/api_models.dart';
import '../models/app_user_data.dart';
import 'encryption_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  final EncryptionService _encryptionService = EncryptionService();
  AppUserData? _lastDecryptedData; // Store the last decrypted data

  // Replace with your actual API base URL
  static const String baseUrl = 'http://68.178.169.119:7899/';

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for logging and error handling
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('API: $obj'),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        print('API Error: ${error.message}');
        handler.next(error);
      },
    ));

    _encryptionService.initialize();
  }

  /// Check internet connectivity
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Additional check by trying to reach a reliable server
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// User Registration
  Future<ApiResponse<String>> registerUser(RegisterRequest request) async {
    try {
      if (!await hasInternetConnection()) {
        return ApiResponse<String>(
          success: false,
          message: 'No internet connection available',
        );
      }

      final response = await _dio.post(
        '/api/AppUserManager/AppUserRegister',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return ApiResponse<String>(
          success: true,
          message: 'Registration successful',
          data: response.data.toString(),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<String>(
          success: false,
          message: 'Registration failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<String>(
        success: false,
        message: _handleDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        message: 'Unexpected error: $e',
      );
    }
  }

  /// User Login
  Future<ApiResponse<LoginResponse>> loginUser(LoginRequest request) async {
    try {
      if (!await hasInternetConnection()) {
        return ApiResponse<LoginResponse>(
          success: false,
          message: 'No internet connection available',
        );
      }

      final response = await _dio.post(
        '/api/AppUserManager/AppUserLogin',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Check if response has success and encrypted data
        if (responseData is Map<String, dynamic>) {
          final success = responseData['success'] ?? false;

          if (success) {
            // Get encrypted response data
            final encryptedData = responseData['response'];
            if (encryptedData != null) {
              try {
                // Decrypt, decompress and deserialize the response
                final appUserData = _encryptionService.decryptAndDecompressAndDeserialize(encryptedData);

                // Store the decrypted data for later use
                _lastDecryptedData = appUserData;

                // Create a basic LoginResponse with the token and user info
                // We'll store the full decrypted data separately for the sync system
                final loginResponse = LoginResponse.fromDecryptedData(appUserData);

                return ApiResponse<LoginResponse>(
                  success: true,
                  message: 'Login successful',
                  data: loginResponse,
                  statusCode: response.statusCode,
                );
              } catch (decryptError) {
                return ApiResponse<LoginResponse>(
                  success: false,
                  message: 'Failed to decrypt login response: $decryptError',
                  statusCode: response.statusCode,
                );
              }
            } else {
              return ApiResponse<LoginResponse>(
                success: false,
                message: 'No encrypted data received',
                statusCode: response.statusCode,
              );
            }
          } else {
            return ApiResponse<LoginResponse>(
              success: false,
              message: 'Login failed - server returned success: false',
              statusCode: response.statusCode,
            );
          }
        } else {
          return ApiResponse<LoginResponse>(
            success: false,
            message: 'Invalid response format',
            statusCode: response.statusCode,
          );
        }
      } else {
        return ApiResponse<LoginResponse>(
          success: false,
          message: 'Login failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<LoginResponse>(
        success: false,
        message: _handleDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse<LoginResponse>(
        success: false,
        message: 'Unexpected error: $e',
      );
    }
  }

  /// Handle Dio errors
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.badResponse:
        return 'Server error: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
      default:
        return 'Network error occurred. Please try again.';
    }
  }

  /// Set authorization token for authenticated requests
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear authorization token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Get the last decrypted data from login
  AppUserData? getLastDecryptedData() {
    return _lastDecryptedData;
  }

  /// Clear the stored decrypted data
  void clearDecryptedData() {
    _lastDecryptedData = null;
  }

  /// Get app user data (reference data like districts, diseases, etc.)
  Future<ApiResponse<Map<String, dynamic>>> getAppUserData() async {
    try {
      if (!await hasInternetConnection()) {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'No internet connection available',
        );
      }

      final response = await _dio.get('/api/AppUserManager/GetAppUserData');

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: 'App data fetched successfully',
          data: response.data,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Failed to fetch app data',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: _handleDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Unexpected error: $e',
      );
    }
  }

  /// Get filter data for dropdowns
  Future<ApiResponse<List<dynamic>>> getFilterData(String column, String type) async {
    try {
      if (!await hasInternetConnection()) {
        return ApiResponse<List<dynamic>>(
          success: false,
          message: 'No internet connection available',
        );
      }

      final response = await _dio.get('/api/AppUserManager/GetFilterData/$column/$type');

      if (response.statusCode == 200) {
        return ApiResponse<List<dynamic>>(
          success: true,
          message: 'Filter data fetched successfully',
          data: response.data,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<List<dynamic>>(
          success: false,
          message: 'Failed to fetch filter data',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<List<dynamic>>(
        success: false,
        message: _handleDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse<List<dynamic>>(
        success: false,
        message: 'Unexpected error: $e',
      );
    }
  }

  /// Upload patient data to server
  Future<ApiResponse<String>> uploadPatient(Map<String, dynamic> patientData) async {
    try {
      if (!await hasInternetConnection()) {
        return ApiResponse<String>(
          success: false,
          message: 'No internet connection available',
        );
      }

      final response = await _dio.post(
        '/api/Patient/Post', // Adjust endpoint as needed
        data: patientData,
      );

      if (response.statusCode == 200) {
        return ApiResponse<String>(
          success: true,
          message: 'Patient uploaded successfully',
          data: response.data.toString(),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<String>(
          success: false,
          message: 'Failed to upload patient',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<String>(
        success: false,
        message: _handleDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        message: 'Unexpected error: $e',
      );
    }
  }

  /// Upload OPD visit data to server
  Future<ApiResponse<String>> uploadOpdVisit(Map<String, dynamic> opdData) async {
    try {
      if (!await hasInternetConnection()) {
        return ApiResponse<String>(
          success: false,
          message: 'No internet connection available',
        );
      }

      final response = await _dio.post(
        '/api/OPDDetails/Post', // Adjust endpoint as needed
        data: opdData,
      );

      if (response.statusCode == 200) {
        return ApiResponse<String>(
          success: true,
          message: 'OPD visit uploaded successfully',
          data: response.data.toString(),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<String>(
          success: false,
          message: 'Failed to upload OPD visit',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<String>(
        success: false,
        message: _handleDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        message: 'Unexpected error: $e',
      );
    }
  }

  /// Upload OBGYN data to server
  Future<ApiResponse<String>> uploadObgynData(Map<String, dynamic> obgynData) async {
    try {
      if (!await hasInternetConnection()) {
        return ApiResponse<String>(
          success: false,
          message: 'No internet connection available',
        );
      }

      final response = await _dio.post(
        '/api/OBGYN/Post', // Adjust endpoint as needed
        data: obgynData,
      );

      if (response.statusCode == 200) {
        return ApiResponse<String>(
          success: true,
          message: 'OBGYN data uploaded successfully',
          data: response.data.toString(),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<String>(
          success: false,
          message: 'Failed to upload OBGYN data',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<String>(
        success: false,
        message: _handleDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        message: 'Unexpected error: $e',
      );
    }
  }
}
