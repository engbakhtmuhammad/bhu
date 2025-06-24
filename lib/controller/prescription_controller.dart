import 'package:bhu/models/prescription_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';
import '../models/opd_visit_model.dart';
import '../models/prescription_model.dart' as prescription;

class PrescriptionController extends GetxController {
  final db = DatabaseHelper();
  
  // Observable lists for dropdown options
  final RxList<String> commonDrugs = <String>[].obs;
  final RxList<Map<String, dynamic>> medicinesWithIds = <Map<String, dynamic>>[].obs;
  var drugSearchController = TextEditingController();
  var drugSearchText = ''.obs;
  var filteredDrugs = <Map<String, dynamic>>[].obs;
  // Selected values
  final RxString selectedOpdTicket = ''.obs;
  
  // Current prescriptions for selected OPD visit
  final RxList<PrescriptionModel> currentPrescriptions = <PrescriptionModel>[].obs;
  
  // OPD visits for dropdown
  final RxList<OpdVisitModel> opdVisits = <OpdVisitModel>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadMedicines();
    loadOpdVisits();
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

    // Create a timestamp for created_at and updated_at
    final now = DateTime.now().toIso8601String();

    final newPrescription = prescription.PrescriptionModel(
      // Don't specify id - let SQLite auto-generate it
      drugName: drugName,
      dosage: dosage,
      duration: duration,
      opdTicketNo: selectedOpdTicket.value,
      // Add created_at and updated_at fields
      createdAt: now,
      updatedAt: now,
    );

    int newId = await db.insertPrescription(newPrescription);
    
    // Debug log to verify prescription was added
    print('Added prescription with ID: $newId, OPD Ticket: ${selectedOpdTicket.value}');
    
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

  void filterDrugs(String search) {
    drugSearchText.value = search;
    if (search.isEmpty) {
      filteredDrugs.value = medicinesWithIds;
    } else {
      filteredDrugs.value = medicinesWithIds
          .where((drug) =>
          drug['name'].toString().toLowerCase().contains(search.toLowerCase()))
          .toList();
    }
  }


  Future<void> loadMedicines() async {
    try {
      // First try to get medicines from API table
      var medicines = await db.getApiMedicines();
      commonDrugs.value = medicines.map((e) => e['name'] as String).toList();
      medicinesWithIds.value = medicines.map((e) => {
        'id': e['id'],
        'name': e['name']
      }).toList();
      
      update(); // Notify UI of changes

    } catch (e) {
      print('Error loading medicines: $e');
    }
  }
}
