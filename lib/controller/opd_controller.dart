import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';
import '../models/disease_model.dart';
import '../models/obgyn_model.dart';
import '../models/opd_visit_model.dart';
import '../models/patient_model.dart';
import 'dart:convert';

import '../models/prescription_model.dart';

class OpdController extends GetxController {
  final db = DatabaseHelper();
  
  var opdVisits = <OpdVisitModel>[].obs;
  var patients = <PatientModel>[].obs;
  var diseases = <DiseaseModel>[].obs;
  var prescriptions = <PrescriptionModel>[].obs;
  var subdiseases = <SubDiseaseModel>[].obs;
  
  // Reference data from SQLite
  var diseasesByCategory = <DiseaseModel, List<SubDiseaseModel>>{}.obs;
  var labTestOptions = <String>[].obs;
  var fpOptions = <String>[].obs;
  var antenatalVisitOptions = <String>[].obs;
  var antenatalVisitOptionsWithIds = <Map<String, dynamic>>[].obs;
  var deliveryModeOptions = <String>[].obs;
  var pregnancyIndicators = <String>[].obs;
  var ttAdvisedOptions = <String>[].obs;
  var postPartumStatusOptions = <String>[].obs;
  
  // Form reactive variables
  var selectedPatient = Rx<PatientModel?>(null);
  var patientSearchController = TextEditingController();
  var filteredPatients = <PatientModel>[].obs;
  var searchText = ''.obs; // Reactive variable to track search text
  var reasonForVisit = 'General OPD'.obs;
  var isFollowUp = false.obs;
  var selectedDiseaseIds = <int>[].obs;  // Changed from selectedDiseases string list
  var selectedLabTestIds = <int>[].obs;  // Changed from selectedLabTests string list
  var isReferred = false.obs;
  var followUpAdvised = false.obs;
  var followUpDays = 1.obs;
  var fpAdvised = false.obs;
  var selectedFpIds = <int>[].obs;       // Changed from selectedFpList string list
  var opdTicketNo = ''.obs;

  // Keep the original lists for UI display purposes
  var selectedDiseases = <String>[].obs;
  var selectedLabTests = <String>[].obs;
  var selectedFpList = <String>[].obs;

  // OBGYN variables
  var obgynVisitType = 'Pre-Delivery'.obs;
  var ancCardAvailable = false.obs;
  var gestationalAge = 1.obs;
  var antenatalVisits = 'ANC 1-4'.obs;
  var fundalHeight = 1.obs;
  var ultrasoundReports = false.obs;
  var highRiskIndicators = ''.obs;
  var parity = 1.obs;
  var gravida = 1.obs;
  var complications = ''.obs;
  var expectedDeliveryDate = Rx<DateTime?>(null);
  var deliveryFacility = ''.obs;
  var referredToHigherTier = false.obs;
  var ttAdvised = false.obs;
  var deliveryMode = 'Normal Delivery (Live Birth)'.obs;
  var postpartumFollowup = ''.obs;
  var familyPlanningServices = <String>[].obs;
  var babyGender = ''.obs;
  var babyWeight = 0.obs;
  var antenatalVisitId = 0.obs;
  var babyGenderId = 0.obs;
  var ttAdvisedId = 0.obs; // Add ID for TT advised

  // Add maps to store ID-to-name mappings
  var labTestMap = <int, String>{}.obs;
  var fpMap = <int, String>{}.obs;

  // Add this property for antenatal visit selection
  var selectedAntenatalVisit = Rx<Map<String, dynamic>?>(null);

  // Add these new variables
  var pregnancyIndicatorsWithIds = <Map<String, dynamic>>[].obs;
  var postpartumStatusOptionsWithIds = <Map<String, dynamic>>[].obs;
  var genderOptions = <Map<String, dynamic>>[].obs;
  var selectedPregnancyIndicator = Rx<Map<String, dynamic>?>(null);
  var selectedPostpartumStatus = Rx<Map<String, dynamic>?>(null);
  var pregnancyIndicatorId = 0.obs;
  var postpartumStatusId = 0.obs;
  var deliveryModeOptionsWithIds = <Map<String, dynamic>>[].obs;
  var selectedDeliveryMode = Rx<Map<String, dynamic>?>(null);
  var selectedBabyGender = Rx<Map<String, dynamic>?>(null);
  var deliveryModeId = 0.obs;
  var ttAdvisedOptionsWithIds = <Map<String, dynamic>>[].obs;
  var selectedTTAdvised = Rx<Map<String, dynamic>?>(null);

  // For prescription
  var selectedDrug = Rx<Map<String, dynamic>?>(null);
  var drugId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadReferenceData();
    loadPatients();
    loadDiseases();
  }

  Future<void> loadReferenceData() async {
    try {
      print('Loading reference data for OPD form...');
      
      // Load family planning services
      var fpServices = await db.getApiFamilyPlanningServices();
      if (fpServices.isEmpty) {
        fpServices = await db.getFamilyPlanningServices();
        print('API family planning services empty, loaded ${fpServices.length} from local table');
      } else {
        print('Loaded ${fpServices.length} family planning services from API table');
      }
      
      if (fpServices.isNotEmpty) {
        fpOptions.value = fpServices.map((e) => e['name'] as String).toList();
        
        // Create ID-to-name mapping
        fpMap.clear();
        for (var i = 0; i < fpServices.length; i++) {
          int id = fpServices[i]['id'] ?? (i + 1);
          String name = fpServices[i]['name'] as String;
          fpMap[id] = name;
        }
      } else {
        // Fallback data for family planning
        print('Using default family planning services');
        fpOptions.value = [
          'Condoms',
          'Oral Contraceptive Pills',
          'Injectable Contraceptives',
          'IUD',
          'Implants',
          'Natural Family Planning',
          'Sterilization'
        ];
        
        // Create ID-to-name mapping for defaults
        fpMap.clear();
        for (var i = 0; i < fpOptions.length; i++) {
          fpMap[i + 1] = fpOptions[i];
        }
        
        // Save default values to local table
        for (var i = 0; i < fpOptions.length; i++) {
          await db.database.then((dbClient) => dbClient.insert(
            'api_family_planning', 
            {'id': i + 1, 'name': fpOptions[i]},
            conflictAlgorithm: ConflictAlgorithm.ignore
          ));
        }
      }
      
      // Load lab tests
      var labTests = await db.getApiLabTests();
      if (labTests.isEmpty) {
        labTests = await db.getLabTests();
        print('API lab tests empty, loaded ${labTests.length} from local table');
      } else {
        print('Loaded ${labTests.length} lab tests from API table');
      }
      
      if (labTests.isNotEmpty) {
        labTestOptions.value = labTests.map((e) => e['name'] as String).toList();
        
        // Create ID-to-name mapping
        labTestMap.clear();
        for (var i = 0; i < labTests.length; i++) {
          int id = labTests[i]['id'] ?? (i + 1);
          String name = labTests[i]['name'] as String;
          labTestMap[id] = name;
        }
      } else {
        // Fallback data for lab tests
        print('Using default lab tests');
        labTestOptions.value = [
          'Complete Blood Count',
          'Blood Glucose',
          'Lipid Profile',
          'Liver Function Test',
          'Kidney Function Test',
          'Urine Analysis',
          'Stool Examination',
          'X-Ray',
          'Ultrasound'
        ];
        
        // Create ID-to-name mapping for defaults
        labTestMap.clear();
        for (var i = 0; i < labTestOptions.length; i++) {
          labTestMap[i + 1] = labTestOptions[i];
        }
        
        // Save default values to local table
        for (var i = 0; i < labTestOptions.length; i++) {
          await db.database.then((dbClient) => dbClient.insert(
            'api_lab_tests', 
            {'id': i + 1, 'name': labTestOptions[i]},
            conflictAlgorithm: ConflictAlgorithm.ignore
          ));
        }
      }
      
      // Load antenatal visits
      var antenatalVisits = await db.getApiAntenatalVisits();
      antenatalVisitOptions.value = antenatalVisits.isNotEmpty ? antenatalVisits.map((e) => e['name'] as String).toList() : [];
      
      // Load delivery modes
      var deliveryModes = await db.getApiDeliveryModes();
      deliveryModeOptions.value = deliveryModes.isNotEmpty ? deliveryModes.map((e) => e['name'] as String).toList() : [];

      // Create list with IDs for dropdown
      deliveryModeOptionsWithIds.value = deliveryModes.isNotEmpty ? deliveryModes.map((e) => {
        'id': e['id'] as int,
        'name': e['name'] as String
      }).toList() : [];
      
      // Load pregnancy indicators
      var pregnancyIndicators = await db.getApiPregnancyIndicators();
      this.pregnancyIndicators.value = pregnancyIndicators.isNotEmpty ? pregnancyIndicators.map((e) => e['name'] as String).toList() : [];
      
      // Load TT advised options
      var ttAdvisedOptions = await db.getApiTTAdvised();
      this.ttAdvisedOptions.value = ttAdvisedOptions.isNotEmpty ?
          ttAdvisedOptions.map((e) => e['name'] as String).toList() : [];
      ttAdvisedOptionsWithIds.value = ttAdvisedOptions.isNotEmpty ? ttAdvisedOptions : [];
      
      // Load postpartum statuses
      var postpartumStatuses = await db.getApiPostpartumStatuses();
      postPartumStatusOptions.value = postpartumStatuses.isNotEmpty ?
          postpartumStatuses.map((e) => e['name'] as String).toList() : [];
      
      // Load subdiseases
      final subDiseasesList = await db.getAllSubDiseases();
      subdiseases.value = subDiseasesList.isNotEmpty ? subDiseasesList : [];
      
      // Load antenatal visits with IDs
      final antenatalVisitsWithIds = await db.getAntenatalVisits();
      antenatalVisitOptionsWithIds.value = antenatalVisitsWithIds.isNotEmpty ? antenatalVisitsWithIds.map((e) => {
        'id': e['id'] as int,
        'name': e['name'] as String
      }).toList() : [];
      
      // Load pregnancy indicators with IDs
      final pregnancyIndicatorsWithIdsData = await db.getPregnancyIndicators();
      pregnancyIndicatorsWithIds.value = pregnancyIndicatorsWithIdsData.isNotEmpty ? pregnancyIndicatorsWithIdsData.map((e) => {
        'id': e['id'] as int,
        'name': e['name'] as String
      }).toList() : [];
      
      // Load postpartum statuses with IDs
      final postpartumStatusesWithIdsData = await db.getApiPostpartumStatuses();
      postpartumStatusOptionsWithIds.value = postpartumStatusesWithIdsData.isNotEmpty ? postpartumStatusesWithIdsData.map((e) => {
        'id': e['id'] as int,
        'name': e['name'] as String
      }).toList() : [];
      
      // Load genders
      var genders = await db.getApiGenders();
      genderOptions.value = genders.isNotEmpty ? genders : [];
    } catch (e) {
      print('Error loading reference data: $e');
    }
  }

  Future<void> loadOpdVisits() async {
    try {
      opdVisits.value = await db.getAllOpdVisits();
    } catch (e) {
      print('<><><><><><><><><><><><><><><<>Error loading OPD visits: $e');
      // Initialize with empty list to prevent null errors
      opdVisits.value = [];
    }
  }

  Future<void> loadPatients() async {
    patients.value = await db.getAllPatients();
    filteredPatients.assignAll(patients); // Initialize filtered list
  }

  /// Filter patients based on search query
  void filterPatients(String query) {
    searchText.value = query; // Update reactive search text
    if (query.isEmpty) {
      filteredPatients.assignAll(patients);
    } else {
      final filtered = patients.where((patient) {
        final name = patient.fullName.toLowerCase();
        final cnic = patient.cnic.toLowerCase();
        final contact = patient.contact.toLowerCase();
        final searchQuery = query.toLowerCase();

        return name.contains(searchQuery) ||
               cnic.contains(searchQuery) ||
               contact.contains(searchQuery);
      }).toList();
      filteredPatients.assignAll(filtered);
    }
  }

  Future<void> loadDiseases() async {
    try {
      diseases.value = await db.getAllDiseases();
      
      if (diseases.isEmpty) {
        // Check if api_diseases table exists and has data
        final apiDiseases = await db.getApiDiseases();
        diseases.value = apiDiseases.map((d) =>
            DiseaseModel(
                id: d['id'],
                name: d['name'],
                color: d['color'],
                version: d['version'] ?? 1
            )
        ).toList();
      }
      
      // Load subdiseases
      final subDiseasesList = await db.getAllSubDiseases();
      if (subDiseasesList.isNotEmpty) {
        subdiseases.value = subDiseasesList;
      }
      
      // Group subdiseases by their parent disease
      Map<DiseaseModel, List<SubDiseaseModel>> grouped = {};
      for (var disease in diseases) {
        // Create an entry for each disease with its subdiseases
        grouped[disease] = subdiseases
            .where((sd) => sd.disease_id == disease.id)
            .toList();
      }
      
      // Assign the grouped map directly without casting
      diseasesByCategory.value = grouped;
    } catch (e) {
      print('Error loading diseases: $e');
    }
  }

  Future<void> saveOpdVisit() async {
    if (selectedPatient.value == null) {
      Get.snackbar("Error", "Please select a patient");
      return;
    }

    final ticketNo = await db.generateOpdTicketNo();
    opdTicketNo.value = ticketNo; // Store the ticket number
    
    // Prepare OBGYN data if needed
    String? obgynData;
    if (reasonForVisit.value == 'OBGYN') {
      final obgynModel = ObgynModel(
        visitType: obgynVisitType.value,
        ancCardAvailable: ancCardAvailable.value,
        gestationalAge: gestationalAge.value,
        antenatalVisits: antenatalVisitId.value.toString(),
        fundalHeight: fundalHeight.value,
        ultrasoundReports: ultrasoundReports.value,
        highRiskIndicators: highRiskIndicators.value,
        parity: parity.value,
        gravida: gravida.value,
        complications: complications.value,
        expectedDeliveryDate: expectedDeliveryDate.value,
        deliveryFacility: deliveryFacility.value,
        referredToHigherTier: referredToHigherTier.value,
        ttAdvised: ttAdvisedId.value.toString(), // Use ID instead of boolean
        deliveryMode: deliveryModeId.value.toString(), // Use ID instead of name
        babyGender: babyGenderId.value.toString(),
        babyWeight: babyWeight.value,
        postpartumFollowup: postpartumStatusId.value.toString(), // Use ID instead of name
        familyPlanningServices: familyPlanningServices,
      );
      obgynData = jsonEncode(obgynModel.toJson());
    }

    // Convert prescriptions to a list of maps
    List<Map<String, dynamic>> prescriptionMaps = prescriptions.map((p) => {
      'id': p.id,  // Store the prescription ID
      'drugName': p.drugName,
      'dosage': p.dosage,
      'duration': p.duration,
      'quantity': p.quantity,
    }).toList();

    final visit = OpdVisitModel(
      opdTicketNo: ticketNo,
      patientId: selectedPatient.value!.patientId,
      visitDateTime: DateTime.now(),
      reasonForVisit: reasonForVisit.value=='General OPD'?true:false,
      isFollowUp: isFollowUp.value,
      diagnosisIds: selectedDiseaseIds,  // Store IDs instead of names
      diagnosisNames: selectedDiseases,  // Keep names for display
      prescriptions: prescriptionMaps,
      labTestIds: selectedLabTestIds,    // Store IDs instead of names
      labTestNames: selectedLabTests,    // Keep names for display
      isReferred: isReferred.value,
      followUpAdvised: followUpAdvised.value,
      followUpDays: followUpAdvised.value ? followUpDays.value : null,
      fpAdvised: fpAdvised.value,
      fpIds: selectedFpIds,              // Store IDs instead of names
      fpNames: selectedFpList,           // Keep names for display
      obgynData: obgynData,
      pregnancyIndicatorId: pregnancyIndicatorId.value > 0 ? pregnancyIndicatorId.value : null,
      postpartumStatusId: postpartumStatusId.value > 0 ? postpartumStatusId.value : null,
    );

    await db.database.then((dbClient) async {
      // First, check if the table has the required columns
      var tableInfo = await dbClient.rawQuery("PRAGMA table_info(opd_visits)");
      List<String> columns = tableInfo.map((col) => col['name'] as String).toList();

      // Debug log available columns
      print('Available columns in opd_visits table: $columns');
      
      // Create a map with only the columns that exist in the table
      Map<String, dynamic> visitMap = {};
      
      if (columns.contains('patient_id')) 
        visitMap['patient_id'] = visit.patientId;
      
      if (columns.contains('visit_date')) 
        visitMap['visit_date'] = visit.visitDateTime.toIso8601String();
      
      if (columns.contains('chief_complaint')) 
        visitMap['chief_complaint'] = visit.reasonForVisit;
      
      if (columns.contains('diagnosis')) 
        visitMap['diagnosis'] = jsonEncode(visit.diagnosisIds);  // Store IDs as JSON
      
      if (columns.contains('diagnosis_names')) 
        visitMap['diagnosis_names'] = visit.diagnosisNames.join(',');  // Store names for display
      
      if (columns.contains('treatment')) 
        visitMap['treatment'] = jsonEncode(visit.prescriptions);
      
      if (columns.contains('lab_tests')) 
        visitMap['lab_tests'] = jsonEncode(visit.labTestIds);  // Store IDs as JSON
      
      if (columns.contains('lab_test_names')) 
        visitMap['lab_test_names'] = visit.labTestNames.join(',');  // Store names for display
      
      if (columns.contains('is_referred')) 
        visitMap['is_referred'] = visit.isReferred ? 1 : 0;
      
      if (columns.contains('follow_up_advised')) 
        visitMap['follow_up_advised'] = visit.followUpAdvised ? 1 : 0;
      
      if (columns.contains('follow_up_days')) 
        visitMap['follow_up_days'] = visit.followUpDays;
      
      if (columns.contains('fp_advised')) 
        visitMap['fp_advised'] = visit.fpAdvised ? 1 : 0;
      
      if (columns.contains('fp_list')) 
        visitMap['fp_list'] = jsonEncode(visit.fpIds);  // Store IDs as JSON
      
      if (columns.contains('fp_names')) 
        visitMap['fp_names'] = visit.fpNames.join(',');  // Store names for display
      
      if (columns.contains('obgyn_data'))
        visitMap['obgyn_data'] = visit.obgynData;

      if (columns.contains('opdTicketNo'))
        visitMap['opdTicketNo'] = visit.opdTicketNo;

      if (columns.contains('is_synced'))
        visitMap['is_synced'] = 0;
      
      if (columns.contains('created_at')) 
        visitMap['created_at'] = DateTime.now().toIso8601String();
      
      if (columns.contains('updated_at')) 
        visitMap['updated_at'] = DateTime.now().toIso8601String();
      
      // Debug log what we're about to insert
      print('Visit map to insert: $visitMap');

      // Insert the visit with only the columns that exist
      int visitId = await dbClient.insert('opd_visits', visitMap);

      // Verify the insert by querying back
      final verifyResult = await dbClient.query(
        'opd_visits',
        where: 'id = ?',
        whereArgs: [visitId],
      );
      if (verifyResult.isNotEmpty) {
        print('Verified insert - opdTicketNo in DB: ${verifyResult.first['opdTicketNo']}');
      } else {
        print('ERROR: Could not verify OPD visit insert');
      }
    });
    
    await loadOpdVisits();
    clearForm();
    Get.snackbar("Success", "OPD Visit saved with Ticket No: $ticketNo");
  }

  void clearForm() {
    selectedPatient.value = null;
    patientSearchController.clear();
    searchText.value = '';
    filteredPatients.assignAll(patients);
    reasonForVisit.value = 'General OPD';
    isFollowUp.value = false;
    selectedDiseases.clear();
    selectedDiseaseIds.clear();  // Clear IDs
    selectedLabTests.clear();
    selectedLabTestIds.clear();  // Clear IDs
    isReferred.value = false;
    followUpAdvised.value = false;
    followUpDays.value = 1;
    fpAdvised.value = false;
    selectedFpList.clear();
    selectedFpIds.clear();  // Clear IDs
    
    // Clear OBGYN fields
    obgynVisitType.value = 'Pre-Delivery';
    ancCardAvailable.value = false;
    gestationalAge.value = 1;
    antenatalVisits.value = 'ANC 1-4';
    fundalHeight.value = 1;
    ultrasoundReports.value = false;
    highRiskIndicators.value = '';
    parity.value = 1;
    gravida.value = 1;
    complications.value = '';
    expectedDeliveryDate.value = null;
    deliveryFacility.value = '';
    referredToHigherTier.value = false;
    ttAdvised.value = false;
    ttAdvisedId.value = 0;
    selectedTTAdvised.value = null;
    deliveryMode.value = 'Normal Delivery (Live Birth)';
    postpartumFollowup.value = '';
    familyPlanningServices.clear();
    babyGender.value = '';
    babyWeight.value = 0;
    
    // Clear prescriptions
    prescriptions.clear();
    
    // Clear new fields
    selectedPregnancyIndicator.value = null;
    selectedPostpartumStatus.value = null;
    pregnancyIndicatorId.value = 0;
    postpartumStatusId.value = 0;
    
    // Clear delivery mode fields
    selectedDeliveryMode.value = null;
    selectedBabyGender.value = null;
    deliveryModeId.value = 0;
  }

  Map<String, List<DiseaseModel>> get groupedDiseases {
    Map<String, List<DiseaseModel>> grouped = {};
    for (var disease in diseases) {
      if (!grouped.containsKey(disease.name)) {
        grouped[disease.name] = [];
      }
      grouped[disease.name]!.add(disease);
    }
    return grouped;
  }

  void toggleDiseaseSelection(String diseaseName, int diseaseId, {bool isSubdisease = true, int? parentDiseaseId}) {
    if (selectedDiseases.contains(diseaseName)) {
      selectedDiseases.remove(diseaseName);
      selectedDiseaseIds.remove(diseaseId);
    } else {
      selectedDiseases.add(diseaseName);
      selectedDiseaseIds.add(diseaseId);
    }
  }

  void toggleLabTestSelection(String labTest, int labTestId) {
    if (selectedLabTests.contains(labTest)) {
      selectedLabTests.remove(labTest);
      selectedLabTestIds.remove(labTestId);
    } else {
      selectedLabTests.add(labTest);
      selectedLabTestIds.add(labTestId);
    }
  }

  void toggleFpSelection(String fp, int fpId) {
    if (selectedFpList.contains(fp)) {
      selectedFpList.remove(fp);
      selectedFpIds.remove(fpId);
    } else {
      selectedFpList.add(fp);
      selectedFpIds.add(fpId);
    }
  }

  void toggleFamilyPlanningService(String service) {
    if (familyPlanningServices.contains(service)) {
      familyPlanningServices.remove(service);
    } else {
      familyPlanningServices.add(service);
    }
  }

  // Add this method to reload patients from the database
  Future<void> refreshPatients() async {
    await loadPatients();
  }

  List<SubDiseaseModel> getSubdiseasesForDisease(int diseaseId) {
    return subdiseases.where((sd) => sd.disease_id == diseaseId).toList();
  }

  // Method to clear Family Planning fields when visit type changes
  void clearFamilyPlanningFields() {
    fpAdvised.value = false;
    selectedFpList.clear();
    selectedFpIds.clear();
  }

  // Override the reasonForVisit setter to clear FP fields when changing from OBGYN
  void setReasonForVisit(String value) {
    if (reasonForVisit.value == 'OBGYN' && value != 'OBGYN') {
      clearFamilyPlanningFields();
    }
    reasonForVisit.value = value;
  }

  // Override the obgynVisitType setter to clear FP fields when changing from Post-Delivery
  void setObgynVisitType(String value) {
    if (obgynVisitType.value == 'Post-Delivery' && value != 'Post-Delivery') {
      clearFamilyPlanningFields();
    }
    obgynVisitType.value = value;
  }
}
