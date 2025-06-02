import 'package:get/get.dart';
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
  
  // Reference data from SQLite
  var diseasesByCategory = <String, List<DiseaseModel>>{}.obs;
  var labTestOptions = <String>[].obs;
  var fpOptions = <String>[].obs;
  var antenatalVisitOptions = <String>[].obs;
  var deliveryModeOptions = <String>[].obs;
  var pregnancyIndicators = <String>[].obs;
  var ttAdvisedOptions = <String>[].obs;
  var postPartumStatusOptions = <String>[].obs;
  
  // Form reactive variables
  var selectedPatient = Rx<PatientModel?>(null);
  var reasonForVisit = 'General OPD'.obs;
  var isFollowUp = false.obs;
  var selectedDiseases = <String>[].obs;
  var selectedLabTests = <String>[].obs;
  var isReferred = false.obs;
  var followUpAdvised = false.obs;
  var followUpDays = 1.obs;
  var fpAdvised = false.obs;
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

  @override
  void onInit() {
    loadOpdVisits();
    loadPatients();
    loadDiseases();
    loadReferenceData();
    super.onInit();
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
        
        // Save default values to local table
        for (var option in fpOptions) {
          await db.database.then((dbClient) => dbClient.insert(
            'api_family_planning', 
            {'name': option},
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
        
        // Save default values to local table
        for (var option in labTestOptions) {
          await db.database.then((dbClient) => dbClient.insert(
            'api_lab_tests', 
            {'name': option},
            conflictAlgorithm: ConflictAlgorithm.ignore
          ));
        }
      }
      
      // Load antenatal visits
      var antenatalVisits = await db.getApiAntenatalVisits();
      if (antenatalVisits.isEmpty) {
        antenatalVisits = await db.getAntenatalVisits();
        print('API antenatal visits empty, loaded ${antenatalVisits.length} from local table');
      } else {
        print('Loaded ${antenatalVisits.length} antenatal visits from API table');
      }
      
      if (antenatalVisits.isNotEmpty) {
        antenatalVisitOptions.value = antenatalVisits.map((e) => e['name'] as String).toList();
      } else {
        // Fallback data for antenatal visits
        print('Using default antenatal visits');
        antenatalVisitOptions.value = [
          'ANC 1-4',
          'ANC 5-8',
          'ANC 9+',
          'No ANC'
        ];
        
        // Save default values to local table
        for (var option in antenatalVisitOptions) {
          await db.database.then((dbClient) => dbClient.insert(
            'api_antenatal_visits', 
            {'name': option},
            conflictAlgorithm: ConflictAlgorithm.ignore
          ));
        }
      }
      
      // Load delivery modes
      var deliveryModes = await db.getApiDeliveryModes();
      if (deliveryModes.isEmpty) {
        deliveryModes = await db.getDeliveryModes();
        print('API delivery modes empty, loaded ${deliveryModes.length} from local table');
      } else {
        print('Loaded ${deliveryModes.length} delivery modes from API table');
      }
      
      if (deliveryModes.isNotEmpty) {
        deliveryModeOptions.value = deliveryModes.map((e) => e['name'] as String).toList();
      } else {
        // Fallback data for delivery modes
        print('Using default delivery modes');
        deliveryModeOptions.value = [
          'Normal Delivery (Live Birth)',
          'C-Section (Live Birth)',
          'Normal Delivery (Stillbirth)',
          'C-Section (Stillbirth)',
          'Assisted Delivery'
        ];
        
        // Save default values to local table
        for (var option in deliveryModeOptions) {
          await db.database.then((dbClient) => dbClient.insert(
            'api_delivery_modes', 
            {'name': option},
            conflictAlgorithm: ConflictAlgorithm.ignore
          ));
        }
      }
      
      // Load pregnancy indicators
      var pregnancyIndicators = await db.getApiPregnancyIndicators();
      if (pregnancyIndicators.isEmpty) {
        pregnancyIndicators = await db.getPregnancyIndicators();
        print('API pregnancy indicators empty, loaded ${pregnancyIndicators.length} from local table');
      } else {
        print('Loaded ${pregnancyIndicators.length} pregnancy indicators from API table');
      }
      
      if (pregnancyIndicators.isNotEmpty) {
        this.pregnancyIndicators.value = pregnancyIndicators.map((e) => e['name'] as String).toList();
      } else {
        // Fallback data for pregnancy indicators
        print('Using default pregnancy indicators');
        this.pregnancyIndicators.value = [
          'Hypertension',
          'Diabetes',
          'Anemia',
          'Previous C-Section',
          'Multiple Pregnancy',
          'Teenage Pregnancy',
          'Advanced Maternal Age'
        ];
        
        // Save default values to local table
        for (var option in pregnancyIndicators) {
          await db.database.then((dbClient) => dbClient.insert(
            'api_pregnancy_indicators', 
            {'name': option},
            conflictAlgorithm: ConflictAlgorithm.ignore
          ));
        }
      }
      
      // Load TT advised options
      var ttAdvisedOptions = await db.getApiTTAdvised();
      if (ttAdvisedOptions.isEmpty) {
        ttAdvisedOptions = await db.getTTAdvised();
        print('API TT advised options empty, loaded ${ttAdvisedOptions.length} from local table');
      } else {
        print('Loaded ${ttAdvisedOptions.length} TT advised options from API table');
      }
      
      if (ttAdvisedOptions.isNotEmpty) {
        this.ttAdvisedOptions.value = ttAdvisedOptions.map((e) => e['name'] as String).toList();
      } else {
        // Fallback data for TT advised
        print('Using default TT advised options');
        this.ttAdvisedOptions.value = [
          'TT1',
          'TT2',
          'TT Booster',
          'Not Advised'
        ];
        
        // Save default values to local table
        for (var option in ttAdvisedOptions) {
          await db.database.then((dbClient) => dbClient.insert(
            'api_tt_advised', 
            {'name': option},
            conflictAlgorithm: ConflictAlgorithm.ignore
          ));
        }
      }
      
      // Load postpartum statuses
      var postpartumStatuses = await db.getApiPostpartumStatuses();
      if (postpartumStatuses.isEmpty) {
        postpartumStatuses = await db.getPostpartumStatuses();
        print('API postpartum statuses empty, loaded ${postpartumStatuses.length} from local table');
      } else {
        print('Loaded ${postpartumStatuses.length} postpartum statuses from API table');
      }
      
      if (postpartumStatuses.isNotEmpty) {
        postPartumStatusOptions.value = postpartumStatuses.map((e) => e['name'] as String).toList();
      } else {
        // Fallback data for postpartum statuses
        print('Using default postpartum statuses');
        postPartumStatusOptions.value = [
          'Normal Recovery',
          'Complications Present',
          'Referred for Higher Care',
          'Follow-up Required'
        ];
        
        // Save default values to local table
        for (var option in postPartumStatusOptions) {
          await db.database.then((dbClient) => dbClient.insert(
            'api_postpartum_statuses', 
            {'name': option},
            conflictAlgorithm: ConflictAlgorithm.ignore
          ));
        }
      }
      
      print('Reference data loading completed');
    } catch (e) {
      print('Error loading reference data: $e');
      // Set fallback values if there's an error
      fpOptions.value = [
        'Condoms',
        'Oral Contraceptive Pills',
        'Injectable Contraceptives',
        'IUD',
        'Implants',
        'Natural Family Planning',
        'Sterilization'
      ];
      
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
      
      antenatalVisitOptions.value = [
        'ANC 1-4',
        'ANC 5-8',
        'ANC 9+',
        'No ANC'
      ];
      
      deliveryModeOptions.value = [
        'Normal Delivery (Live Birth)',
        'C-Section (Live Birth)',
        'Normal Delivery (Stillbirth)',
        'C-Section (Stillbirth)',
        'Assisted Delivery'
      ];
      
      pregnancyIndicators.value = [
        'Hypertension',
        'Diabetes',
        'Anemia',
        'Previous C-Section',
        'Multiple Pregnancy',
        'Teenage Pregnancy',
        'Advanced Maternal Age'
      ];
      
      ttAdvisedOptions.value = [
        'TT1',
        'TT2',
        'TT Booster',
        'Not Advised'
      ];
      
      postPartumStatusOptions.value = [
        'Normal Recovery',
        'Complications Present',
        'Referred for Higher Care',
        'Follow-up Required'
      ];
    }
  }

  Future<void> loadOpdVisits() async {
    try {
      opdVisits.value = await db.getAllOpdVisits();
    } catch (e) {
      print('Error loading OPD visits: $e');
      // Initialize with empty list to prevent null errors
      opdVisits.value = [];
    }
  }

  Future<void> loadPatients() async {
    patients.value = await db.getAllPatients();
  }

  Future<void> loadDiseases() async {
    try {
      diseases.value = await db.getAllDiseases();
      
      if (diseases.isEmpty) {
        // Check if api_diseases table exists and has data
        final apiDiseases = await db.getApiDiseases();
        if (apiDiseases.isNotEmpty) {
          // Convert API diseases to local format
          diseases.value = apiDiseases.map((d) => 
            DiseaseModel(
              id: d['id'], 
              name: d['name'], 
              category: d['category'] ?? 'Uncategorized', 
              categoryId: d['category_id'] ?? 0
            )
          ).toList();
        } else {
          // Fallback data
          diseases.value = [
            DiseaseModel(id: 1, name: 'Common Cold', category: 'Respiratory diseases', categoryId: 1),
            DiseaseModel(id: 2, name: 'Pneumonia', category: 'Respiratory diseases', categoryId: 1),
            DiseaseModel(id: 3, name: 'Asthma', category: 'Respiratory diseases', categoryId: 1),
            DiseaseModel(id: 4, name: 'Hypertension', category: 'Cardiovascular diseases', categoryId: 2),
            DiseaseModel(id: 5, name: 'Diabetes', category: 'Endocrine diseases', categoryId: 3),
            DiseaseModel(id: 6, name: 'Malaria', category: 'Infectious diseases', categoryId: 4),
            DiseaseModel(id: 7, name: 'Typhoid', category: 'Infectious diseases', categoryId: 4),
            DiseaseModel(id: 8, name: 'Diarrhea', category: 'Gastrointestinal diseases', categoryId: 5),
            DiseaseModel(id: 9, name: 'Anemia', category: 'Hematological diseases', categoryId: 6),
            DiseaseModel(id: 10, name: 'Arthritis', category: 'Musculoskeletal diseases', categoryId: 7),
          ];
        }
      }
      
      // Populate diseasesByCategory
      Map<String, List<DiseaseModel>> grouped = {};
      for (var disease in diseases) {
        if (!grouped.containsKey(disease.category)) {
          grouped[disease.category] = [];
        }
        grouped[disease.category]!.add(disease);
      }
      diseasesByCategory.value = grouped;
    } catch (e) {
      print('Error loading diseases: $e');
      // Provide fallback diseases if there's an error
      diseases.value = [
        DiseaseModel(id: 1, name: 'Common Cold', category: 'Respiratory diseases', categoryId: 1),
        DiseaseModel(id: 2, name: 'Pneumonia', category: 'Respiratory diseases', categoryId: 1),
        DiseaseModel(id: 3, name: 'Asthma', category: 'Respiratory diseases', categoryId: 1),
        DiseaseModel(id: 4, name: 'Hypertension', category: 'Cardiovascular diseases', categoryId: 2),
        DiseaseModel(id: 5, name: 'Diabetes', category: 'Endocrine diseases', categoryId: 3),
        DiseaseModel(id: 6, name: 'Malaria', category: 'Infectious diseases', categoryId: 4),
        DiseaseModel(id: 7, name: 'Typhoid', category: 'Infectious diseases', categoryId: 4),
        DiseaseModel(id: 8, name: 'Diarrhea', category: 'Gastrointestinal diseases', categoryId: 5),
        DiseaseModel(id: 9, name: 'Anemia', category: 'Hematological diseases', categoryId: 6),
        DiseaseModel(id: 10, name: 'Arthritis', category: 'Musculoskeletal diseases', categoryId: 7),
      ];
      
      // Populate diseasesByCategory with fallback data
      Map<String, List<DiseaseModel>> grouped = {};
      for (var disease in diseases) {
        if (!grouped.containsKey(disease.category)) {
          grouped[disease.category] = [];
        }
        grouped[disease.category]!.add(disease);
      }
      diseasesByCategory.value = grouped;
    }
  }

  Future<void> saveOpdVisit() async {
    if (selectedPatient.value == null) {
      Get.snackbar("Error", "Please select a patient");
      return;
    }

    final ticketNo = await db.generateOpdTicketNo();
    
    // Prepare OBGYN data if needed
    String? obgynData;
    if (reasonForVisit.value == 'OBGYN') {
      final obgynModel = ObgynModel(
        visitType: obgynVisitType.value,
        ancCardAvailable: ancCardAvailable.value,
        gestationalAge: gestationalAge.value,
        antenatalVisits: antenatalVisits.value,
        fundalHeight: fundalHeight.value,
        ultrasoundReports: ultrasoundReports.value,
        highRiskIndicators: highRiskIndicators.value,
        parity: parity.value,
        gravida: gravida.value,
        complications: complications.value,
        expectedDeliveryDate: expectedDeliveryDate.value,
        deliveryFacility: deliveryFacility.value,
        referredToHigherTier: referredToHigherTier.value,
        ttAdvised: ttAdvised.value,
        deliveryMode: deliveryMode.value,
        postpartumFollowup: postpartumFollowup.value,
        familyPlanningServices: familyPlanningServices,
      );
      obgynData = jsonEncode(obgynModel.toMap());
    }

    // Convert prescriptions to a list of maps
    List<Map<String, dynamic>> prescriptionMaps = prescriptions.map((p) => {
      'drugName': p.drugName,
      'dosage': p.dosage,
      'duration': p.duration,
      'quantity': p.quantity,
    }).toList();

    final visit = OpdVisitModel(
      opdTicketNo: ticketNo,
      patientId: selectedPatient.value!.patientId,
      visitDateTime: DateTime.now(),
      reasonForVisit: reasonForVisit.value,
      isFollowUp: isFollowUp.value,
      diagnosis: selectedDiseases,
      prescriptions: prescriptionMaps, // Use the converted prescriptions
      labTests: selectedLabTests,
      isReferred: isReferred.value,
      followUpAdvised: followUpAdvised.value,
      followUpDays: followUpAdvised.value ? followUpDays.value : null,
      fpAdvised: fpAdvised.value,
      fpList: selectedFpList,
      obgynData: obgynData,
    );

    await db.database.then((dbClient) async {
      // First, check if the table has the required columns
      var tableInfo = await dbClient.rawQuery("PRAGMA table_info(opd_visits)");
      List<String> columns = tableInfo.map((col) => col['name'] as String).toList();
      
      // Create a map with only the columns that exist in the table
      Map<String, dynamic> visitMap = {};
      
      if (columns.contains('patient_id')) 
        visitMap['patient_id'] = visit.patientId;
      
      if (columns.contains('visit_date')) 
        visitMap['visit_date'] = visit.visitDateTime.toIso8601String();
      
      if (columns.contains('chief_complaint')) 
        visitMap['chief_complaint'] = visit.reasonForVisit;
      
      if (columns.contains('diagnosis')) 
        visitMap['diagnosis'] = visit.diagnosis.join(',');
      
      if (columns.contains('treatment')) 
        visitMap['treatment'] = jsonEncode(visit.prescriptions); // Store prescriptions as JSON
      
      if (columns.contains('lab_tests')) 
        visitMap['lab_tests'] = visit.labTests.join(',');
      
      if (columns.contains('is_referred')) 
        visitMap['is_referred'] = visit.isReferred ? 1 : 0;
      
      if (columns.contains('follow_up_advised')) 
        visitMap['follow_up_advised'] = visit.followUpAdvised ? 1 : 0;
      
      if (columns.contains('follow_up_days')) 
        visitMap['follow_up_days'] = visit.followUpDays;
      
      if (columns.contains('fp_advised')) 
        visitMap['fp_advised'] = visit.fpAdvised ? 1 : 0;
      
      if (columns.contains('fp_list')) 
        visitMap['fp_list'] = visit.fpList.join(',');
      
      if (columns.contains('obgyn_data')) 
        visitMap['obgyn_data'] = visit.obgynData;
      
      if (columns.contains('is_synced')) 
        visitMap['is_synced'] = 0;
      
      if (columns.contains('created_at')) 
        visitMap['created_at'] = DateTime.now().toIso8601String();
      
      if (columns.contains('updated_at')) 
        visitMap['updated_at'] = DateTime.now().toIso8601String();
      
      // Insert the visit with only the columns that exist
      int visitId = await dbClient.insert('opd_visits', visitMap);
      
      // No need to save prescriptions separately anymore
    });
    
    await loadOpdVisits();
    clearForm();
    Get.snackbar("Success", "OPD Visit saved with Ticket No: $ticketNo");
  }

  void clearForm() {
    selectedPatient.value = null;
    reasonForVisit.value = 'General OPD';
    isFollowUp.value = false;
    selectedDiseases.clear();
    selectedLabTests.clear();
    isReferred.value = false;
    followUpAdvised.value = false;
    followUpDays.value = 1;
    fpAdvised.value = false;
    selectedFpList.clear();
    
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
    deliveryMode.value = 'Normal Delivery (Live Birth)';
    postpartumFollowup.value = '';
    familyPlanningServices.clear();
    
    // Clear prescriptions
    prescriptions.clear();
  }

  Map<String, List<DiseaseModel>> get groupedDiseases {
    Map<String, List<DiseaseModel>> grouped = {};
    for (var disease in diseases) {
      if (!grouped.containsKey(disease.category)) {
        grouped[disease.category] = [];
      }
      grouped[disease.category]!.add(disease);
    }
    return grouped;
  }

  void toggleDiseaseSelection(String diseaseName) {
    if (selectedDiseases.contains(diseaseName)) {
      selectedDiseases.remove(diseaseName);
    } else {
      selectedDiseases.add(diseaseName);
    }
  }

  void toggleLabTestSelection(String labTest) {
    if (selectedLabTests.contains(labTest)) {
      selectedLabTests.remove(labTest);
    } else {
      selectedLabTests.add(labTest);
    }
  }

  void toggleFpSelection(String fp) {
    if (selectedFpList.contains(fp)) {
      selectedFpList.remove(fp);
    } else {
      selectedFpList.add(fp);
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
}
