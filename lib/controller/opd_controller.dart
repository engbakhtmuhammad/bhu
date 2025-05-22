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

  final fpOptions = [
    'Pills',
    'Injections', 
    'Condoms',
    'IUCD/Implants',
    'FP Counseling'
  ];

  final labTestOptions = [
    'Blood Test',
    'Urine Test',
    'X-Ray',
    'ECG',
    'Ultrasound',
    'CT Scan',
    'MRI',
    'Blood Sugar',
    'Blood Pressure',
    'Cholesterol Test'
  ];

  final antenatalVisitOptions = [
    'ANC 1-4',
    '5+',
    'Additional Checkup'
  ];

  final deliveryModeOptions = [
    'Normal Delivery (Live Birth)',
    'Maternal Death',
    'Still Birth',
    'Neonatal Death (within 28 Days)',
    'Intra Uterine Death (IUD)',
    'Abortion'
  ];

  @override
  void onInit() {
    loadOpdVisits();
    loadPatients();
    loadDiseases();
    super.onInit();
  }

  Future<void> loadOpdVisits() async {
    opdVisits.value = await db.getAllOpdVisits();
  }

  Future<void> loadPatients() async {
    patients.value = await db.getAllPatients();
  }

  Future<void> loadDiseases() async {
    diseases.value = await db.getAllDiseases();
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
  }

  Map<String, List<DiseaseModel>> get diseasesByCategory {
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
}