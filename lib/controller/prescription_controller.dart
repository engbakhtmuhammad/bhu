import 'package:get/get.dart';
import '../db/database_helper.dart';
import '../models/opd_visit_model.dart';
import '../models/prescription_model.dart';

class PrescriptionController extends GetxController {
  final db = DatabaseHelper();
  
  var opdVisits = <OpdVisitModel>[].obs;
  var currentPrescriptions = <PrescriptionModel>[].obs;
  var selectedOpdTicket = ''.obs;
  var selectedDrug = ''.obs;

  final commonDrugs = [
    'Paracetamol',
    'Ibuprofen',
    'Aspirin',
    'Amoxicillin',
    'Ciprofloxacin',
    'Metformin',
    'Omeprazole',
    'Cetirizine',
    'Salbutamol',
    'Prednisolone',
    'Atorvastatin',
    'Lisinopril',
    'Furosemide',
    'Warfarin',
    'Insulin',
    'Vitamin D',
    'Iron Tablets',
    'Calcium',
    'Multivitamin',
    'Folic Acid',
    'Azithromycin',
    'Doxycycline',
    'Tramadol',
    'Diclofenac',
    'Loratadine',
    'Montelukast',
    'Ranitidine',
    'Simvastatin',
    'Amlodipine',
    'Hydrochlorothiazide',
  ];

  @override
  void onInit() {
    loadOpdVisits();
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

    final prescription = PrescriptionModel(
      id: 0, // Auto-increment
      drugName: drugName,
      dosage: dosage,
      duration: duration,
      opdTicketNo: selectedOpdTicket.value,
    );

    await db.insertPrescription(prescription);
    await loadPrescriptions(selectedOpdTicket.value);
    Get.snackbar("Success", "Prescription added successfully");
  }

  Future<void> deletePrescription(int id) async {
    final dbClient = await db.database;
    await dbClient.delete('prescriptions', where: 'id = ?', whereArgs: [id]);
    await loadPrescriptions(selectedOpdTicket.value);
    Get.snackbar("Success", "Prescription deleted");
  }
}