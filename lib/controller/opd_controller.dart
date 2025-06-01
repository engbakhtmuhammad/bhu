import 'package:get/get.dart';
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
      // Load family planning services
      final fpServices = await db.getFamilyPlanningServices();
      if (fpServices.isNotEmpty) {
        fpOptions.value = fpServices.map((e) => e['name'] as String).toList();
      } else {
        // Fallback data for family planning
        fpOptions.value = [
          'Condoms',
          'Oral Contraceptive Pills',
          'Injectable Contraceptives',
          'IUD',
          'Implants',
          'Natural Family Planning',
          'Sterilization'
        ];
      }
      
      // Load lab tests
      final labTests = await db.getLabTests();
      if (labTests.isNotEmpty) {
        labTestOptions.value = labTests.map((e) => e['name'] as String).toList();
      } else {
        // Fallback data for lab tests
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
      }
      
      // Load antenatal visits
      final antenatalVisits = await db.getAntenatalVisits();
      if (antenatalVisits.isNotEmpty) {
        antenatalVisitOptions.value = antenatalVisits.map((e) => e['name'] as String).toList();
      } else {
        // Fallback data for antenatal visits
        antenatalVisitOptions.value = [
          'ANC 1-4',
          'ANC 5-8',
          'ANC 9+',
          'No ANC'
        ];
      }
      
      // Load delivery modes
      final deliveryModes = await db.getDeliveryModes();
      if (deliveryModes.isNotEmpty) {
        deliveryModeOptions.value = deliveryModes.map((e) => e['name'] as String).toList();
      } else {
        // Fallback data for delivery modes
        deliveryModeOptions.value = [
          'Normal Delivery (Live Birth)',
          'C-Section (Live Birth)',
          'Normal Delivery (Stillbirth)',
          'C-Section (Stillbirth)',
          'Assisted Delivery'
        ];
      }
      
      // Load pregnancy indicators
      final indicators = await db.getPregnancyIndicators();
      if (indicators.isNotEmpty) {
        pregnancyIndicators.value = indicators.map((e) => e['name'] as String).toList();
      } else {
        // Fallback data for pregnancy indicators
        pregnancyIndicators.value = [
          'Hypertension',
          'Diabetes',
          'Anemia',
          'Previous C-Section',
          'Multiple Pregnancy',
          'Teenage Pregnancy',
          'Advanced Maternal Age'
        ];
      }
      
      // Load TT advised options
      final ttAdvised = await db.getTTAdvised();
      if (ttAdvised.isNotEmpty) {
        ttAdvisedOptions.value = ttAdvised.map((e) => e['name'] as String).toList();
      } else {
        // Fallback data for TT advised
        ttAdvisedOptions.value = [
          'TT1',
          'TT2',
          'TT Booster',
          'Not Advised'
        ];
      }
      
      // Load postpartum statuses
      final postpartumStatuses = await db.getPostpartumStatuses();
      if (postpartumStatuses.isNotEmpty) {
        postPartumStatusOptions.value = postpartumStatuses.map((e) => e['name'] as String).toList();
      } else {
        // Fallback data for postpartum statuses
        postPartumStatusOptions.value = [
          'Normal Recovery',
          'Complications Present',
          'Referred for Higher Care',
          'Follow-up Required'
        ];
      }
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
    opdVisits.value = await db.getAllOpdVisits();
  }

  Future<void> loadPatients() async {
    patients.value = await db.getAllPatients();
  }

  Future<void> loadDiseases() async {
    try {
      diseases.value = await db.getAllDiseases();
      
      if (diseases.isEmpty) {
        // Provide fallback diseases if none are found in the database
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
      
      // Populate diseasesByCategory after loading diseases
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

    final visit = OpdVisitModel(
      opdTicketNo: ticketNo,
      patientId: selectedPatient.value!.patientId,
      visitDateTime: DateTime.now(),
      reasonForVisit: reasonForVisit.value,
      isFollowUp: isFollowUp.value,
      diagnosis: selectedDiseases,
      prescriptions: [], // Will be added separately
      labTests: selectedLabTests,
      isReferred: isReferred.value,
      followUpAdvised: followUpAdvised.value,
      followUpDays: followUpAdvised.value ? followUpDays.value : null,
      fpAdvised: fpAdvised.value,
      fpList: selectedFpList,
      obgynData: obgynData,
    );

    await db.insertOpdVisit(visit);
    
    // Save prescriptions
    for (var prescription in prescriptions) {
      // Create a new prescription model instance
      await db.insertPrescription(PrescriptionModel(
        drugName: prescription.drugName,
        dosage: prescription.dosage,
        duration: prescription.duration,
        opdTicketNo: ticketNo,
        quantity: prescription.quantity,
      ));
    }
    
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
