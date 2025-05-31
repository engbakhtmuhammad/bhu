import 'package:get/get.dart';
import '../db/database_helper.dart';
import '../models/opd_visit_model.dart';
import '../models/prescription_model.dart' as prescription;

class PrescriptionController extends GetxController {
  final db = DatabaseHelper();

  var opdVisits = <OpdVisitModel>[].obs;
  var currentPrescriptions = <prescription.PrescriptionModel>[].obs;
  var selectedOpdTicket = ''.obs;
  var selectedDrug = ''.obs;

  var commonDrugs = <String>[].obs;
  var medicineDosages = <String>[].obs;

  @override
  void onInit() {
    loadOpdVisits();
    loadMedicines();
    super.onInit();
  }

  Future<void> loadOpdVisits() async {
    opdVisits.value = await db.getAllOpdVisits();
  }

  Future<void> loadPrescriptions(String opdTicketNo) async {
    if (opdTicketNo.isNotEmpty) {
      currentPrescriptions.value = await db.getPrescriptionsByTicket(opdTicketNo);
    } else {
      currentPrescriptions.clear();
    }
  }

  Future<void> addPrescription(String drugName, String dosage, String duration) async {
    if (selectedOpdTicket.value.isEmpty) {
      Get.snackbar("Error", "Please select an OPD visit");
      return;
    }

    final newPrescription = prescription.PrescriptionModel(
      // Don't specify id - let SQLite auto-generate it
      drugName: drugName,
      dosage: dosage,
      duration: duration,
      opdTicketNo: selectedOpdTicket.value,
    );

    int newId = await db.insertPrescription(newPrescription);
    await loadPrescriptions(selectedOpdTicket.value);
    Get.snackbar("Success", "Prescription added successfully (ID: $newId)");
  }

  Future<void> deletePrescription(int? id) async {
    if (id == null) return;

    final dbClient = await db.database;
    await dbClient.delete('prescriptions', where: 'id = ?', whereArgs: [id]);
    await loadPrescriptions(selectedOpdTicket.value);
    Get.snackbar("Success", "Prescription deleted");
  }

  Future<void> loadMedicines() async {
    try {
      // Load medicines from SQLite
      final medicines = await db.getMedicines();
      if (medicines.isNotEmpty) {
        commonDrugs.value = medicines.map((e) => e['name'] as String).toList();
      } else {
        // Fallback to default medicines
        commonDrugs.value = [
          'Paracetamol',
          'Ibuprofen',
          'Aspirin',
          'Amoxicillin',
          'Ciprofloxacin',
          'Metronidazole',
          'Omeprazole',
          'Diazepam',
          'Atenolol',
          'Metformin',
          'Salbutamol',
          'Hydrocortisone',
          'Chlorpheniramine',
          'Albendazole',
          'Artemether/Lumefantrine'
        ];
      }
      
      // Load medicine dosages
      final dosages = await db.getMedicineDosages();
      if (dosages.isNotEmpty) {
        medicineDosages.value = dosages.map((e) => e['name'] as String).toList();
      } else {
        // Fallback to default dosages
        medicineDosages.value = [
          '1 tablet twice daily',
          '1 tablet three times daily',
          '2 tablets twice daily',
          '1 tablet once daily',
          '1 tablet at bedtime',
          '1 capsule three times daily',
          '2 capsules twice daily',
          '5ml three times daily',
          '10ml twice daily',
          '1 injection daily',
          '1 injection weekly',
          'Apply topically twice daily',
          'Apply topically three times daily',
          'Use as directed'
        ];
      }
    } catch (e) {
      print('Error loading medicines: $e');
      // Keep the default values if there's an error
      commonDrugs.value = [
        'Paracetamol',
        'Ibuprofen',
        'Aspirin',
        'Amoxicillin',
        'Ciprofloxacin',
        'Metronidazole',
        'Omeprazole',
        'Diazepam',
        'Atenolol',
        'Metformin',
        'Salbutamol',
        'Hydrocortisone',
        'Chlorpheniramine',
        'Albendazole',
        'Artemether/Lumefantrine'
      ];
      
      medicineDosages.value = [
        '1 tablet twice daily',
        '1 tablet three times daily',
        '2 tablets twice daily',
        '1 tablet once daily',
        '1 tablet at bedtime',
        '1 capsule three times daily',
        '2 capsules twice daily',
        '5ml three times daily',
        '10ml twice daily',
        '1 injection daily',
        '1 injection weekly',
        'Apply topically twice daily',
        'Apply topically three times daily',
        'Use as directed'
      ];
    }
  }
}
