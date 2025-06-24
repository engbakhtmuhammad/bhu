import 'dart:convert';
import 'dart:io';
import 'package:bhu/models/api_models.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../models/api_models.dart' as api_models;
import '../models/api_patient_models.dart';
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
  //static const String baseUrl = 'http://192.168.100.27:5004/';
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

      debugPrint('API: statusCode: ${response.statusCode}');
      debugPrint('API: headers:');
      response.headers.forEach((name, values) {
        debugPrint('API:  $name: ${values.join(', ')}');
      });
      debugPrint('API: Response Text:');
      debugPrint('API: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Check if response has success and encrypted data
        if (responseData is Map<String, dynamic>) {
          final success = responseData['success'] ?? false;
          final message = responseData['message'] ?? 'Unknown error';

          if (success) {
            // Get response data (could be encrypted or unencrypted)
            final responseContent = responseData['response'];
            if (responseContent != null) {
              try {
                AppUserData appUserData;

                // Check if the response is encrypted (long string) or unencrypted JSON string
                if (responseContent is String) {
                  // Check if it's a JSON string or encrypted data
                  try {
                    // Try to parse as JSON first
                    final jsonData = json.decode(responseContent);
                    debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> UNENCRYPTED JSON STRING DETECTED');
                    debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> RAW JSON: $responseContent');

                    // Log the JSON structure to see what fields are available
                    debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> JSON DATA KEYS: ${jsonData.keys.toList()}');
                    debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> HAS relationType: ${jsonData.containsKey('relationType')}');
                    debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> HAS relationTypes: ${jsonData.containsKey('relationTypes')}');
                    debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> HAS gender: ${jsonData.containsKey('gender')}');
                    debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> HAS genders: ${jsonData.containsKey('genders')}');

                    if (jsonData.containsKey('relationType')) {
                      debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> relationType VALUE: ${jsonData['relationType']}');
                    }
                    if (jsonData.containsKey('gender')) {
                      debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> gender VALUE: ${jsonData['gender']}');
                    }

                    appUserData = AppUserData.fromJson(jsonData);
                  } catch (e) {
                    // If JSON parsing fails, it's probably encrypted
                    debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ENCRYPTED RESPONSE DETECTED (JSON parse failed)');
                    appUserData = _encryptionService.decryptAndDecompressAndDeserialize(responseContent);
                    debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> DECRYPTED RESPONSE: $appUserData');
                  }
                } else {
                  // Unencrypted response - parse directly
                  debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> UNENCRYPTED RESPONSE DETECTED');
                  debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> RAW RESPONSE: $responseContent');

                  // Parse the JSON string if it's a string, otherwise use directly
                  Map<String, dynamic> jsonData;
                  if (responseContent is String) {
                    jsonData = json.decode(responseContent);
                  } else {
                    jsonData = responseContent as Map<String, dynamic>;
                  }

                  // Log the JSON structure to see what fields are available
                  debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> JSON DATA KEYS: ${jsonData.keys.toList()}');
                  debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> HAS relationTypes: ${jsonData.containsKey('relationTypes')}');
                  debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> HAS genders: ${jsonData.containsKey('genders')}');
                  debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> HAS gender: ${jsonData.containsKey('gender')}');
                  if (jsonData.containsKey('relationTypes')) {
                    debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> relationTypes VALUE: ${jsonData['relationTypes']}');
                  }
                  if (jsonData.containsKey('genders')) {
                    debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> genders VALUE: ${jsonData['genders']}');
                  }
                  if (jsonData.containsKey('gender')) {
                    debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> gender VALUE: ${jsonData['gender']}');
                  }

                  appUserData = AppUserData.fromJson(jsonData);
                }



                if (appUserData.relationTypes != null) {
                  debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> RELATION TYPES FROM API:');
                  for (var rt in appUserData.relationTypes!) {
                    debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> RELATION TYPE: ${rt.id} - ${rt.name}');
                  }
                } else {
                  debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> RELATION TYPES IS NULL IN API RESPONSE');
                }

                if (appUserData.genders != null) {
                  debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> GENDERS FROM API:');
                  for (var g in appUserData.genders!) {
                    debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> GENDER: ${g.id} - ${g.name}');
                  }
                } else {
                  debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> GENDERS IS NULL IN API RESPONSE');
                }

                // Store the decrypted/parsed data for later use
                _lastDecryptedData = appUserData;

                // Create a LoginResponse with the token and reference data
                final loginResponse = LoginResponse(
                  token: appUserData.token ?? '',
                  // bloodGroups: appUserData.bloodGroups?.map((bg) => api_models.BloodGroup(id: bg.id, name: bg.name)).toList() ?? [],
                  deliveryTypes: appUserData.deliveryTypes?.map((dt) => api_models.DeliveryType(id: dt.id, name: dt.name)).toList() ?? [],
                  deliveryModes: appUserData.deliveryModes?.map((dm) => api_models.DeliveryMode(id: dm.id, name: dm.name)).toList() ?? [],
                  familyPlanningServices: appUserData.familyPlanning?.map((fp) => api_models.FamilyPlanningService(id: fp.id, name: fp.name)).toList() ?? [],
                  antenatalVisits: appUserData.antenatalVisits?.map((av) => api_models.AntenatalVisit(id: av.id, name: av.name)).toList() ?? [],
                  tTAdvisedList: appUserData.tTAdvisedList?.map((tt) => api_models.TTAdvised(id: tt.id, name: tt.name)).toList() ?? [],
                  pregnancyIndicators: appUserData.pregnancyIndicators?.map((pi) => api_models.PregnancyIndicator(id: pi.id, name: pi.name)).toList() ?? [],
                  postPartumStatuses: appUserData.postPartumStatuses?.map((pps) => api_models.PostPartumStatus(id: pps.id, name: pps.name)).toList() ?? [],
                  // medicineDosages: appUserData.medicineDosages?.map((md) => api_models.MedicineDosage(id: md.id, name: md.name)).toList() ?? [],
                  // districts: appUserData.districts?.map((d) => api_models.District(id: d.id ?? 0, name: d.name ?? '', version: 1)).toList() ?? [],
                  relationTypes: appUserData.relationTypes?.map((rt) => api_models.RelationType(id: rt.id, name: rt.name)).toList() ?? [],
                  genders: appUserData.genders?.map((g) => api_models.Gender(id: g.id, name: g.name)).toList() ?? [],
                  patients: appUserData.patients?.map((p) => api_models.ApiPatient.fromJson(p)).toList() ?? [], // Convert patients data
                  diseases: appUserData.diseases?.map((d) => api_models.Disease(
                    id: d.id ?? 0, 
                    name: d.name ?? '',
                    color: d.color ?? '',
                    version: d.category != null ? 1 : 0
                  )).toList() ?? [],
                  subDiseases: appUserData.subDiseases?.map((sd) => api_models.SubDisease(
                    id: sd.id, 
                    name: sd.name, 
                    diseaseId: sd.diseaseId, 
                    version: sd.version
                  )).toList() ?? [],
                  labTests: [], // AppUserData doesn't have labTests property
                  medicines: appUserData.medicines?.map((m) => api_models.Medicine(
                    id: m.id, 
                    name: m.name, 
                    code: m.code ?? '', 
                    version: m.version
                  )).toList() ?? [],
                );

                return ApiResponse<LoginResponse>(
                  success: true,
                  message: 'Login successful',
                  data: loginResponse,
                  statusCode: response.statusCode,
                );
              } catch (decryptError) {
                return ApiResponse<LoginResponse>(
                  success: false,
                  message: 'Failed to decrypt login response: $decryptError\nCheck patient data for null values',
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
            // Return the exact error message from the API
            return ApiResponse<LoginResponse>(
              success: false,
              message: message,
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
        final responseData = response.data;
        // Check if the response has a success field
        if (responseData is Map<String, dynamic> && responseData.containsKey('success')) {
          if (responseData['success'] == true) {
            return ApiResponse<String>(
              success: true,
              message: 'Patient uploaded successfully',
              data: responseData['data']?.toString() ?? '',
              statusCode: response.statusCode,
            );
          } else {
            return ApiResponse<String>(
              success: false,
              message: responseData['message'] ?? 'Server returned failure',
              statusCode: response.statusCode,
            );
          }
        } else {
          return ApiResponse<String>(
            success: true,
            message: 'Patient uploaded successfully',
            data: response.data.toString(),
            statusCode: response.statusCode,
          );
        }
      } else {
        return ApiResponse<String>(
          success: false,
          message: 'Failed to upload patient',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      // Log the error response for debugging
      if (e.response?.data != null) {
        debugPrint('Server error response: ${json.encode(e.response?.data)}');
      }
      
      return ApiResponse<String>(
        success: false,
        message: _handleDioError(e),
        statusCode: e.response?.statusCode,
        data: e.response?.data.toString(),
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

  /// Submit form data to the server
  Future<ApiResponse<String>> submitFormData(Map<String, dynamic> formData) async {
    try {
      if (!await hasInternetConnection()) {
        return ApiResponse<String>(
          success: false,
          message: 'No internet connection available',
        );
      }

      final response = await _dio.post(
        '/api/FormSubmission/CreateForm',
        queryParameters: {'val': jsonEncode(formData)},
      );

      if (response.statusCode == 200) {
        return ApiResponse<String>(
          success: true,
          message: 'Form data submitted successfully',
          data: response.data.toString(),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<String>(
          success: false,
          message: 'Failed to submit form data',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        message: 'Error submitting form data: $e',
      );
    }
  }

  /// Submit encrypted form data to the server
  Future<ApiResponse<String>> submitEncryptedFormData(String encryptedData) async {
    try {
      if (!await hasInternetConnection()) {
        return ApiResponse<String>(
          success: false,
          message: 'No internet connection available',
        );
      }

      final response = await _dio.post(
        '/api/FormSubmission/CreateForm',
        queryParameters: {'val': encryptedData},
      );

      if (response.statusCode == 200) {
        return ApiResponse<String>(
          success: true,
          message: 'Encrypted form data submitted successfully',
          data: response.data.toString(),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<String>(
          success: false,
          message: 'Failed to submit encrypted form data',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('API: DioException [bad response]: ${e.message}');
      debugPrint('API: uri: ${e.requestOptions.uri}');
      debugPrint('API: statusCode: ${e.response?.statusCode}');
      debugPrint('API: headers:');
      e.response?.headers.forEach((name, values) {
        debugPrint('API:  $name: ${values.join(', ')}');
      });
      debugPrint('API: Response Text:');
      debugPrint('API: ${e.response?.data}');
      debugPrint('API: Request Data Length: ${encryptedData.length}');
      debugPrint('API: Request Data (first 200 chars): ${encryptedData.substring(0, encryptedData.length > 200 ? 200 : encryptedData.length)}');
      debugPrint('API: ');
      debugPrint('API Error: ${e.message}');

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

  /// Get health facilities list
  Future<ApiResponse<List<dynamic>>> getHealthFacilities() async {
    try {
      if (!await hasInternetConnection()) {
        return ApiResponse<List<dynamic>>(
          success: false,
          message: 'No internet connection available',
        );
      }

      final response = await _dio.get('/api/HealthFacilities/GetHealthFacilitiesList');

      if (response.statusCode == 200) {
        return ApiResponse<List<dynamic>>(
          success: true,
          message: 'Health facilities fetched successfully',
          data: response.data,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<List<dynamic>>(
          success: false,
          message: 'Failed to fetch health facilities',
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
}
