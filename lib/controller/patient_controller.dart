// controllers/patient_controller.dart
import 'package:get/get.dart';
import '../db/database_helper.dart';
import '../models/patient_model.dart';

class PatientController extends GetxController {
  final db = DatabaseHelper();

  var patients = <PatientModel>[].obs;

  @override
  void onInit() {
    loadPatients();
    super.onInit();
  }

  Future<void> loadPatients() async {
    final dbClient = await db.database;
    final result = await dbClient.query('patients');
    patients.value = result.map((e) => PatientModel.fromMap(e)).toList();
  }

  Future<void> savePatient(PatientModel patient) async {
    // First ensure the relationType column exists
    await db.addRelationTypeColumn();
    
    // Then insert the patient
    await db.insertPatient(patient);
    await loadPatients(); // Refresh list after insert
  }

  Future<String> generatePatientId(String cnic, String relationType) async {
    final existing = await db.getPatientsByCnic(cnic);
    int suffix = 0;

    if (relationType == "own") {
      return "${cnic}000";
    } else if (relationType == "father") {
      suffix = existing.length + 1;
      return "${cnic}${suffix.toString().padLeft(3, '0')}";
    } else if (relationType == "husband") {
      suffix = existing.length + 96;
      return "${cnic}${suffix.toString().padLeft(3, '0')}";
    } else if (relationType == "mother") {
      suffix = existing.length + 50;
      return "${cnic}${suffix.toString().padLeft(3, '0')}";
    }

    return "${cnic}000"; // fallback
  }
}
