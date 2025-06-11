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
  var subdiseases = <SubDiseaseModel>[].obs;
  
  // Reference data from SQLite
  var diseasesByCategory = <String, List<SubDiseaseModel>>{}.obs;
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
  var reasonForVisit = 'General OPD'.obs;
  var isFollowUp = false.obs;
  var selectedDiseaseIds = <int>[].obs;  // Changed from selectedDiseases string list
  var selectedLabTestIds = <int>[].obs;  // Changed from selectedLabTests string list
  var isReferred = false.obs;
  var followUpAdvised = false.obs;
  var followUpDays = 1.obs;
  var fpAdvised = false.obs;
  var selectedFpIds = <int>[].obs;       // Changed from selectedFpList string list

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

  // Add maps to store ID-to-name mappings
  var labTestMap = <int, String>{}.obs;
  var fpMap = <int, String>{}.obs;

  // Add this property for antenatal visit selection
  var selectedAntenatalVisit = Rx<Map<String, dynamic>?>(null);

  // Add these new variables
  var pregnancyIndicatorsWithIds = <Map<String, dynamic>>[].obs;
  var postpartumStatusOptionsWithIds = <Map<String, dynamic>>[].obs;
  var selectedPregnancyIndicator = Rx<Map<String, dynamic>?>(null);
  var selectedPostpartumStatus = Rx<Map<String, dynamic>?>(null);
  var pregnancyIndicatorId = 0.obs;
  var postpartumStatusId = 0.obs;
  var deliveryModeOptionsWithIds = <Map<String, dynamic>>[].obs;
  var selectedDeliveryMode = Rx<Map<String, dynamic>?>(null);
  var selectedBabyGender = Rx<Map<String, dynamic>?>(null);
  var deliveryModeId = 0.obs;

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
        
        // Create list with IDs for dropdown
        deliveryModeOptionsWithIds.value = deliveryModes.map((e) => {
          'id': e['id'] as int,
          'name': e['name'] as String
        }).toList();
      } else {
        // Fallback data for delivery modes
        print('Using default delivery modes');
        final defaultModes = [
          {'id': 1, 'name': 'Normal Delivery (Live Birth)'},
          {'id': 2, 'name': 'C-Section (Live Birth)'},
          {'id': 3, 'name': 'Normal Delivery (Stillbirth)'},
          {'id': 4, 'name': 'C-Section (Stillbirth)'},
          {'id': 5, 'name': 'Assisted Delivery'}
        ];
        
        deliveryModeOptions.value = defaultModes.map((e) => e['name'] as String).toList();
        deliveryModeOptionsWithIds.value = defaultModes;
        
        // Save default values to local table
        for (var option in defaultModes) {
          await db.database.then((dbClient) => dbClient.insert(
            'api_delivery_modes', 
            {'id': option['id'], 'name': option['name']},
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
      
      // Load subdiseases
      final subDiseasesList = await db.getAllSubDiseases();
      if (subDiseasesList.isNotEmpty) {
        subdiseases.value = subDiseasesList;
      }
      
      // Load antenatal visits with IDs
      final antenatalVisitsWithIds = await db.getAntenatalVisits();
      if (antenatalVisitsWithIds.isNotEmpty) {
        antenatalVisitOptionsWithIds.value = antenatalVisitsWithIds.map((e) => {
          'id': e['id'] as int,
          'name': e['name'] as String
        }).toList();
      } else {
        // Fallback data for antenatal visits
        print('Using default antenatal visits');
        final defaultVisits = [
          {'id': 1, 'name': 'ANC 1-4'},
          {'id': 2, 'name': 'ANC 5-8'},
          {'id': 3, 'name': 'ANC 9+'},
          {'id': 4, 'name': 'No ANC'}
        ];
        
        antenatalVisitOptionsWithIds.value = defaultVisits;
        
        // Save default values to local table
        for (var option in defaultVisits) {
          await db.database.then((dbClient) => dbClient.insert(
            'api_antenatal_visits', 
            {'id': option['id'], 'name': option['name']},
            conflictAlgorithm: ConflictAlgorithm.ignore
          ));
        }
      }
      
      // Load pregnancy indicators with IDs
      final pregnancyIndicatorsWithIdsData = await db.getPregnancyIndicators();
      if (pregnancyIndicatorsWithIdsData.isNotEmpty) {
        pregnancyIndicatorsWithIds.value = pregnancyIndicatorsWithIdsData.map((e) => {
          'id': e['id'] as int,
          'name': e['name'] as String
        }).toList();
      } else {
        // Fallback data for pregnancy indicators
        print('Using default pregnancy indicators');
        final defaultIndicators = [
          {'id': 1, 'name': 'High'},
          {'id': 2, 'name': 'Medium'},
          {'id': 3, 'name': 'Low'},
        ];
        
        pregnancyIndicatorsWithIds.value = defaultIndicators;
        
        // Save default values to local table
        for (var option in defaultIndicators) {
          await db.database.then((dbClient) => dbClient.insert(
            'api_pregnancy_indicators', 
            {'id': option['id'], 'name': option['name']},
            conflictAlgorithm: ConflictAlgorithm.ignore
          ));
        }
      }
      
      // Load postpartum statuses with IDs
      final postpartumStatusesWithIdsData = await db.getPostpartumStatuses();
      if (postpartumStatusesWithIdsData.isNotEmpty) {
        postpartumStatusOptionsWithIds.value = postpartumStatusesWithIdsData.map((e) => {
          'id': e['id'] as int,
          'name': e['name'] as String
        }).toList();
      } else {
        // Fallback data for postpartum statuses
        print('Using default postpartum statuses');
        final defaultStatuses = [
          {'id': 1, 'name': 'Hight'},
          {'id': 2, 'name': 'Medium'},
          {'id': 3, 'name': 'Low'},
        ];
        
        postpartumStatusOptionsWithIds.value = defaultStatuses;
        
        // Save default values to local table
        for (var option in defaultStatuses) {
          await db.database.then((dbClient) => dbClient.insert(
            'api_postpartum_statuses', 
            {'id': option['id'], 'name': option['name']},
            conflictAlgorithm: ConflictAlgorithm.ignore
          ));
        }
      }
      
      print('Reference data loading completed');
    } catch (e) {
      print('Error loading reference data: $e');
      // Set fallback values if there's an error
      fpOptions.value = [
        'Pills',
        'Injections',
        'Condoms',
        'IUCD/Implants',
        'FP Counseling',
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
        'ANC 1',
        'ANC 2',
        'ANC 3',
        'ANC 4',
        'ANC 5+',
        'Additional Checkup',
      ];
      
      deliveryModeOptions.value = [
        'Normal Delivery (Live Birth)',
        'Maternal Death',
        'Still Birth',
        'Neonatal Death (within 28 days)',
        'Intra Uterine Death',
        'Abortion'
      ];
      
      pregnancyIndicators.value = [
        'High',
        'Medium',
        'Low'
      ];
      
      ttAdvisedOptions.value = [
        'TT1 Advised',
        'TT1 Given',
        'TT2 Advised',
        'TT2 Given',
      ];
      
      postPartumStatusOptions.value = [
        'Normal Recovery',
        'Complications Present',
        'Referred for Higher Care',
        'Follow-up Required'
      ];
      
      // Add fallback for delivery modes with IDs
      deliveryModeOptionsWithIds.value = [
        {'id': 1, 'name': 'Normal Delivery (Live Birth)'},
        {'id': 2, 'name': 'Maternal Death'},
        {'id': 3, 'name': 'Still Birth'},
        {'id': 4, 'name': 'Neonatal Death (within 28 days)'},
        {'id': 5, 'name': 'Intra Uterine Death'},
        {'id': 6, 'name': 'Abortion'}
      ];
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
              version: d['version'] ?? 1
            )
          ).toList();
        } else {
          // Fallback data
          diseases.value = [
            DiseaseModel(id: 1, name: 'Common Cold', version: 1),
            DiseaseModel(id: 2, name: 'Pneumonia', version: 1),
            DiseaseModel(id: 3, name: 'Asthma', version: 1),
            DiseaseModel(id: 4, name: 'Hypertension', version: 1),
            DiseaseModel(id: 5, name: 'Diabetes', version: 1),
            DiseaseModel(id: 6, name: 'Malaria', version: 1),
            DiseaseModel(id: 7, name: 'Typhoid', version: 1),
          ];
        }
      }
      
      // Load subdiseases
      final subDiseasesList = await db.getAllSubDiseases();
      if (subDiseasesList.isNotEmpty) {
        subdiseases.value = subDiseasesList;
      }
      
      // Group subdiseases by their parent disease
      Map<String, List<SubDiseaseModel>> grouped = {};
      for (var disease in diseases) {
        // Create an entry for each disease with its subdiseases
        grouped[disease.name] = subdiseases
            .where((sd) => sd.disease_id == disease.id)
            .toList();
      }
      
      // If there are any orphaned subdiseases, add them to "Other Diseases"
      var orphanedSubdiseases = subdiseases
          .where((sd) => !diseases.any((d) => d.id == sd.disease_id))
          .toList();
      
      if (orphanedSubdiseases.isNotEmpty) {
        grouped["Other Diseases"] = orphanedSubdiseases;
      }
      
      // If we have no categories with subdiseases, create a default structure
      if (grouped.isEmpty) {
        grouped = {
          "Respiratory Diseases": [
            SubDiseaseModel(id: 1, name: 'Common Cold', disease_id: 1, version: 1),
            SubDiseaseModel(id: 2, name: 'Pneumonia', disease_id: 1, version: 1),
            SubDiseaseModel(id: 3, name: 'Asthma', disease_id: 1, version: 1),
          ],
          "Cardiovascular Diseases": [
            SubDiseaseModel(id: 4, name: 'Hypertension', disease_id: 2, version: 1),
          ],
          "Endocrine Diseases": [
            SubDiseaseModel(id: 5, name: 'Diabetes', disease_id: 3, version: 1),
          ],
          "Infectious Diseases": [
            SubDiseaseModel(id: 6, name: 'Malaria', disease_id: 4, version: 1),
            SubDiseaseModel(id: 7, name: 'Typhoid', disease_id: 4, version: 1),
          ],
        };
      }
      
      // Assign the grouped map directly without casting
      diseasesByCategory.value = grouped;
    } catch (e) {
      print('Error loading diseases: $e');
      // Provide fallback structure if there's an error
      diseasesByCategory.value = {
        "Respiratory Diseases": [
          SubDiseaseModel(id: 1, name: 'Common Cold', disease_id: 1, version: 1),
          SubDiseaseModel(id: 2, name: 'Pneumonia', disease_id: 1, version: 1),
          SubDiseaseModel(id: 3, name: 'Asthma', disease_id: 1, version: 1),
        ],
        "Cardiovascular Diseases": [
          SubDiseaseModel(id: 4, name: 'Hypertension', disease_id: 2, version: 1),
        ],
        "Endocrine Diseases": [
          SubDiseaseModel(id: 5, name: 'Diabetes', disease_id: 3, version: 1),
        ],
        "Infectious Diseases": [
          SubDiseaseModel(id: 6, name: 'Malaria', disease_id: 4, version: 1),
          SubDiseaseModel(id: 7, name: 'Typhoid', disease_id: 4, version: 1),
        ],
      };
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
        ttAdvised: ttAdvised.value,
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
      
      if (columns.contains('is_synced')) 
        visitMap['is_synced'] = 0;
      
      if (columns.contains('created_at')) 
        visitMap['created_at'] = DateTime.now().toIso8601String();
      
      if (columns.contains('updated_at')) 
        visitMap['updated_at'] = DateTime.now().toIso8601String();
      
      // Insert the visit with only the columns that exist
      int visitId = await dbClient.insert('opd_visits', visitMap);
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
}
