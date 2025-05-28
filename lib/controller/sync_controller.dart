import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/auth_controller.dart';
import '../db/database_helper.dart';
import '../models/api_models.dart';
import '../models/patient_model.dart';
import '../services/api_service.dart';

class SyncController extends GetxController {
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final AuthController _authController = Get.put(AuthController());

  // Observable variables
  var isSyncing = false.obs;
  var syncProgress = 0.0.obs;
  var syncStatus = 'Ready to sync'.obs;
  var lastSyncTime = Rxn<DateTime>();
  var hasUnsyncedData = false.obs;

  // Sync statistics
  var uploadedPatients = 0.obs;
  var uploadedOpdVisits = 0.obs;
  var downloadedData = 0.obs;

  // SharedPreferences keys
  static const String _lastSyncKey = 'last_sync_time';
  static const String _hasUnsyncedKey = 'has_unsynced_data';

  @override
  void onInit() {
    super.onInit();
    _loadSyncStatus();
    _checkUnsyncedData();
  }

  /// Load sync status from SharedPreferences
  Future<void> _loadSyncStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncString = prefs.getString(_lastSyncKey);
      final hasUnsynced = prefs.getBool(_hasUnsyncedKey) ?? false;

      if (lastSyncString != null) {
        lastSyncTime.value = DateTime.parse(lastSyncString);
      }
      hasUnsyncedData.value = hasUnsynced;
    } catch (e) {
      debugPrint('Error loading sync status: $e');
    }
  }

  /// Check if there's unsynced data in local database
  Future<void> _checkUnsyncedData() async {
    try {
      // Check for unsynced patients and OPD visits
      final patients = await _dbHelper.getAllPatients();
      final opdVisits = await _dbHelper.getAllOpdVisits();

      // For now, assume all local data needs to be synced
      // You can add sync status fields to your database tables
      hasUnsyncedData.value = patients.isNotEmpty || opdVisits.isNotEmpty;

      await _saveSyncStatus();
    } catch (e) {
      debugPrint('Error checking unsynced data: $e');
    }
  }

  /// Save sync status to SharedPreferences
  Future<void> _saveSyncStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (lastSyncTime.value != null) {
        await prefs.setString(_lastSyncKey, lastSyncTime.value!.toIso8601String());
      }
      await prefs.setBool(_hasUnsyncedKey, hasUnsyncedData.value);
    } catch (e) {
      debugPrint('Error saving sync status: $e');
    }
  }

  /// Main sync function
  Future<bool> syncData() async {
    if (!_authController.isAuthenticated) {
      Get.snackbar(
        'Authentication Required',
        'Please login to sync data',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (!await _apiService.hasInternetConnection()) {
      Get.snackbar(
        'No Internet',
        'Please check your internet connection',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      isSyncing.value = true;
      syncProgress.value = 0.0;
      syncStatus.value = 'Starting sync...';

      // Submit all data together using form submission
      syncStatus.value = 'Preparing data for submission...';
      syncProgress.value = 0.2;
      
      final success = await submitFormData();
      
      if (success) {
        syncProgress.value = 1.0;
        syncStatus.value = 'Sync completed successfully';
        lastSyncTime.value = DateTime.now();
        hasUnsyncedData.value = false;
        await _saveSyncStatus();
        
        Get.snackbar(
          'Sync Complete',
          'Data synchronized successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        return true;
      } else {
        throw Exception('Form submission failed');
      }
    } catch (e) {
      syncStatus.value = 'Sync failed: $e';
      Get.snackbar(
        'Sync Failed',
        'Failed to sync data: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSyncing.value = false;
    }
  }

  /// Upload local data to server
  Future<void> _uploadLocalData() async {
    syncStatus.value = 'Uploading local data...';

    // Reset counters
    uploadedPatients.value = 0;
    uploadedOpdVisits.value = 0;

    // Upload patients
    await _uploadPatients();

    // Upload OPD visits
    await _uploadOpdVisits();
  }

  /// Upload patients to server
  Future<void> _uploadPatients() async {
    try {
      final patients = await _dbHelper.getAllPatients();

      for (int i = 0; i < patients.length; i++) {
        syncStatus.value = 'Uploading patient ${i + 1}/${patients.length}...';

        // Convert local patient to API format
        final apiPatient = _convertPatientToApiFormat(patients[i]);
        
        // Log the request payload for debugging
        debugPrint('Uploading patient: ${json.encode(apiPatient)}');

        // Upload patient to server
        final result = await _apiService.uploadPatient(apiPatient);
        if (!result.success) {
          debugPrint('Failed to upload patient: ${result.message}');
          debugPrint('Status code: ${result.statusCode}');
          
          if (result.statusCode == 400) {
            // Handle bad request specifically
            throw Exception('Server rejected patient data (400): ${result.message}');
          } else {
            throw Exception('Failed to upload patient: ${result.message}');
          }
        }

        uploadedPatients.value++;

        // Update progress within the upload phase
        final uploadProgress = (i + 1) / patients.length * 0.15; // 15% of total for patients
        syncProgress.value = uploadProgress;
      }
    } catch (e) {
      throw Exception('Failed to upload patients: $e');
    }
  }

  /// Upload OPD visits to server
  Future<void> _uploadOpdVisits() async {
    try {
      final opdVisits = await _dbHelper.getAllOpdVisits();

      for (int i = 0; i < opdVisits.length; i++) {
        syncStatus.value = 'Uploading OPD visit ${i + 1}/${opdVisits.length}...';

        // Convert local OPD visit to API format
        final apiOpdVisit = _convertOpdVisitToApiFormat(opdVisits[i]);

        // Upload OPD visit to server
        final result = await _apiService.uploadOpdVisit(apiOpdVisit);
        if (!result.success) {
          throw Exception('Failed to upload OPD visit: ${result.message}');
        }

        uploadedOpdVisits.value++;

        // Update progress within the upload phase
        final uploadProgress = 0.15 + ((i + 1) / opdVisits.length * 0.15); // Next 15% of total
        syncProgress.value = uploadProgress;
      }
    } catch (e) {
      throw Exception('Failed to upload OPD visits: $e');
    }
  }

  /// Download server data and store locally
  Future<void> _downloadServerData() async {
    syncStatus.value = 'Downloading server data...';

    try {
      // Get the login response data which contains all the server data
      final loginResponse = _authController.loginResponse.value;

      if (loginResponse != null) {
        await _storeServerDataLocally(loginResponse);
        downloadedData.value = 1; // Mark as downloaded
      } else {
        throw Exception('No login response data available');
      }
    } catch (e) {
      throw Exception('Failed to download server data: $e');
    }
  }

  /// Store server data in local database
  Future<void> _storeServerDataLocally(LoginResponse response) async {
    syncStatus.value = 'Storing data locally...';

    try {
      // Fetch app user data (reference data)
      final appDataResult = await _apiService.getAppUserData();
      if (appDataResult.success && appDataResult.data != null) {
        // Store reference data in local database
        // You can implement specific storage logic based on the data structure
        // App data received successfully

        // Example: Store districts, diseases, medicines, etc.
        // await _dbHelper.storeReferenceData(appDataResult.data!);
      }

      // Fetch filter data for dropdowns (if needed)
      // Example: Get blood groups
      final bloodGroupsResult = await _apiService.getFilterData('bloodGroup', 'enum');
      if (bloodGroupsResult.success) {
        // Blood groups data received successfully
      }

      syncStatus.value = 'Server data stored locally';
    } catch (e) {
      throw Exception('Failed to store server data locally: $e');
    }
  }

  /// Convert local patient model to API format
  Map<String, dynamic> _convertPatientToApiFormat(PatientModel patient) {
    // Extract father/husband name from relation data
    String fatherName = '';
    String? husbandName;

    if (patient.relationType == 'father') {
      fatherName = patient.relationCnic; // Assuming this contains the name
    } else if (patient.relationType == 'husband') {
      husbandName = patient.relationCnic; // Assuming this contains the name
    }

    // Convert gender to proper format expected by API
    String gender = patient.gender.toLowerCase();
    
    // Convert blood group string to ID
    int bloodGroupId = 1; // Default
    switch (patient.bloodGroup.toLowerCase()) {
      case 'a+': bloodGroupId = 1; break;
      case 'a-': bloodGroupId = 2; break;
      case 'b+': bloodGroupId = 3; break;
      case 'b-': bloodGroupId = 4; break;
      case 'ab+': bloodGroupId = 5; break;
      case 'ab-': bloodGroupId = 6; break;
      case 'o+': bloodGroupId = 7; break;
      case 'o-': bloodGroupId = 8; break;
    }

    // Calculate age from DOB if available, or use default
    double age = 25.0; // Default age
    // TODO: Calculate actual age if DOB is available

    return {
      'id': 0, // New record
      'uniqueId': patient.patientId,
      'name': patient.fullName,
      'fatherName': fatherName,
      'husbandName': husbandName,
      'age': age,
      'gender': gender,
      'cnic': patient.relationCnic,
      'version': 1,
      'contact': patient.contact,
      'emergencyContact': patient.contact, // Using same contact as emergency
      'address': patient.address,
      'medicalHistory': patient.medicalHistory,
      'immunization': patient.immunized,
      'bloodGroup': bloodGroupId,
    };
  }

  /// Convert local OPD visit model to API format
  Map<String, dynamic> _convertOpdVisitToApiFormat(opdVisit) {
    return {
      'id': 0, // New record
      'ticketNo': opdVisit.opdTicketNo,
      'visitDateTime': opdVisit.visitDateTime.toIso8601String(),
      'reasonForVisit': opdVisit.reasonForVisit == 'General OPD', // Convert to boolean
      'followUps': opdVisit.isFollowUp,
      'followUpsAdvised': opdVisit.followUpAdvised,
      'fpAdvised': opdVisit.fpAdvised,
      'referred': opdVisit.isReferred,
      'prescription': opdVisit.prescriptions.join(', '), // Join prescriptions
      'patientId': int.tryParse(opdVisit.patientId) ?? 0,
      'subDiseases': opdVisit.diagnosis.join(','), // Assuming diagnosis contains disease IDs
      'labTests': opdVisit.labTests.join(','),
      'familyPlannings': opdVisit.fpList.join(','),
      'medicineDosages': opdVisit.prescriptions.join(','), // Assuming prescriptions contain medicine IDs
    };
  }

  /// Get sync status text
  String get syncStatusText {
    if (lastSyncTime.value == null) {
      return 'Never synced';
    }

    final now = DateTime.now();
    final difference = now.difference(lastSyncTime.value!);

    if (difference.inMinutes < 1) {
      return 'Synced just now';
    } else if (difference.inHours < 1) {
      return 'Synced ${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return 'Synced ${difference.inHours} hours ago';
    } else {
      return 'Synced ${difference.inDays} days ago';
    }
  }

  /// Force sync (ignores last sync time)
  Future<bool> forceSyncData() async {
    lastSyncTime.value = null;
    return await syncData();
  }

  /// Mark data as needing sync
  void markDataForSync() {
    hasUnsyncedData.value = true;
    _saveSyncStatus();
  }

  /// Convert local patient model to form submission format
  Map<String, dynamic> _convertPatientToFormFormat(PatientModel patient) {
    // Convert gender to integer
    int genderId = 1; // Default to male
    if (patient.gender.toLowerCase() == 'female') {
      genderId = 2;
    }
    
    // Convert blood group string to ID
    int bloodGroupId = 1; // Default
    switch (patient.bloodGroup.toLowerCase()) {
      case 'a+': bloodGroupId = 1; break;
      case 'a-': bloodGroupId = 2; break;
      case 'b+': bloodGroupId = 3; break;
      case 'b-': bloodGroupId = 4; break;
      case 'ab+': bloodGroupId = 5; break;
      case 'ab-': bloodGroupId = 6; break;
      case 'o+': bloodGroupId = 7; break;
      case 'o-': bloodGroupId = 8; break;
    }

    return {
      'patientId': patient.patientId,
      'fullName': patient.fullName,
      'relationCnic': patient.relationCnic,
      'relationType': patient.relationType,
      'contact': patient.contact,
      'address': patient.address,
      'gender': genderId,
      'bloodGroup': bloodGroupId,
      'medicalHistory': patient.medicalHistory,
      'immunized': patient.immunized,
    };
  }

  /// Submit form data to the server using models
  Future<bool> submitFormData() async {
    if (!_authController.isAuthenticated) {
      Get.snackbar(
        'Authentication Required',
        'Please login to submit data',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      syncStatus.value = 'Preparing form data...';
      
      // Get all patients and OPD visits
      final patients = await _dbHelper.getAllPatients();
      final opdVisits = await _dbHelper.getAllOpdVisits();
      
      // Reset counters
      uploadedPatients.value = patients.length;
      uploadedOpdVisits.value = opdVisits.length;
      
      // Convert patients to form data
      List<PatientFormData> patientFormData = patients.map((p) {
        // Convert gender to integer
        int genderId = 1; // Default to male
        if (p.gender.toLowerCase() == 'female') {
          genderId = 2;
        }
        
        // Convert blood group string to ID
        int bloodGroupId = 1; // Default
        switch (p.bloodGroup.toLowerCase()) {
          case 'a+': bloodGroupId = 1; break;
          case 'a-': bloodGroupId = 2; break;
          case 'b+': bloodGroupId = 3; break;
          case 'b-': bloodGroupId = 4; break;
          case 'ab+': bloodGroupId = 5; break;
          case 'ab-': bloodGroupId = 6; break;
          case 'o+': bloodGroupId = 7; break;
          case 'o-': bloodGroupId = 8; break;
        }
        
        return PatientFormData(
          patientId: p.patientId,
          fullName: p.fullName,
          relationCnic: p.relationCnic,
          relationType: p.relationType,
          contact: p.contact,
          address: p.address,
          gender: genderId,
          bloodGroup: bloodGroupId,
          medicalHistory: p.medicalHistory,
          immunized: p.immunized,
        );
      }).toList();
      
      syncProgress.value = 0.4;
      syncStatus.value = 'Processing OPD visits...';
      
      // For each OPD visit, get its prescriptions
      List<OpdFormData> opdFormData = [];
      for (var visit in opdVisits) {
        // Get prescriptions for this visit
        final prescriptions = await _dbHelper.getPrescriptionsByTicket(visit.opdTicketNo);
        final prescriptionTexts = prescriptions.map((p) => "${p.drugName} - ${p.dosage} - ${p.duration}").toList();
        
        opdFormData.add(OpdFormData(
          opdTicketNo: visit.opdTicketNo,
          patientId: visit.patientId,
          visitDateTime: visit.visitDateTime.toIso8601String(),
          reasonForVisit: visit.reasonForVisit,
          isFollowUp: visit.isFollowUp,
          diagnosis: visit.diagnosis,
          prescriptions: prescriptionTexts,
          labTests: visit.labTests,
          isReferred: visit.isReferred,
          followUpAdvised: visit.followUpAdvised,
          followUpDays: visit.followUpDays,
          fpAdvised: visit.fpAdvised,
          fpList: visit.fpList,
          obgynData: visit.obgynData,
        ));
      }
      
      syncProgress.value = 0.6;
      
      // Create form submission model
      final formSubmission = FormSubmissionModel(
        patients: patientFormData,
        opdVisits: opdFormData,
      );
      
      // Log the data being sent
      debugPrint('Submitting form data: ${json.encode(formSubmission.toJson())}');
      
      syncStatus.value = 'Submitting form data...';
      syncProgress.value = 0.8;
      
      final result = await _apiService.submitFormData(formSubmission.toJson());
      
      if (result.success) {
        syncStatus.value = 'Form data submitted successfully';
        downloadedData.value = 1; // Mark as processed
        return true;
      } else {
        throw Exception(result.message);
      }
    } catch (e) {
      syncStatus.value = 'Form submission failed: $e';
      Get.snackbar(
        'Submission Failed',
        'Failed to submit form data: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }
}
