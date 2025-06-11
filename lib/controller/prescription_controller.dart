import 'package:bhu/models/prescription_model.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';
import '../models/opd_visit_model.dart';
import '../models/prescription_model.dart' as prescription;

class PrescriptionController extends GetxController {
  final db = DatabaseHelper();
  
  // Observable lists for dropdown options
  final RxList<String> commonDrugs = <String>[].obs;
  final RxList<String> medicineDosages = <String>[].obs;
  final RxList<Map<String, dynamic>> medicinesWithIds = <Map<String, dynamic>>[].obs;
  
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

  Future<void> loadMedicines() async {
    try {
      print('Loading medicines and dosages from database...');
      
      // First try to get medicines from API table
      var medicines = await db.getApiMedicines();
      
      if (medicines.isEmpty) {
        // If API table is empty, try local medicines table
        medicines = await db.getMedicines();
        print('API medicines table empty, loaded ${medicines.length} medicines from local table');
      } else {
        print('Loaded ${medicines.length} medicines from API table');
      }
      
      if (medicines.isNotEmpty) {
        commonDrugs.value = medicines.map((e) => e['name'] as String).toList();
        medicinesWithIds.value = medicines.map((e) => {
          'id': e['id'],
          'name': e['name']
        }).toList();
      } else {
        // Fallback to default medicines only if both tables are empty
        print('Both API and local medicines tables are empty, using default list');
        List<Map<String, dynamic>> defaultMedicines = [
          {'id': 1, 'name': 'Paracetamol'},
          {'id': 2, 'name': 'Ibuprofen'},
          {'id': 3, 'name': 'Aspirin'},
          {'id': 4, 'name': 'Amoxicillin'},
          {'id': 5, 'name': 'Ciprofloxacin'},
          {'id': 6, 'name': 'Metronidazole'},
          {'id': 7, 'name': 'Omeprazole'},
          {'id': 8, 'name': 'Diazepam'},
          {'id': 9, 'name': 'Atenolol'},
          {'id': 10, 'name': 'Metformin'},
          {'id': 11, 'name': 'Salbutamol'},
          {'id': 12, 'name': 'Hydrocortisone'},
          {'id': 13, 'name': 'Chlorpheniramine'},
          {'id': 14, 'name': 'Albendazole'},
          {'id': 15, 'name': 'Artemether/Lumefantrine'}
        ];
        
        commonDrugs.value = defaultMedicines.map((e) => e['name'] as String).toList();
        medicinesWithIds.value = defaultMedicines;
        
        // Save default medicines to database for future use
        for (var drug in defaultMedicines) {
          await db.database.then((dbClient) => dbClient.insert(
            'medicines', 
            {'id': drug['id'], 'name': drug['name']},
            conflictAlgorithm: ConflictAlgorithm.ignore
          ));
        }
      }
      
      // First try to get dosages from API table
      var dosages = await db.getApiMedicineDosages();
      
      if (dosages.isEmpty) {
        // If API table is empty, try local dosages table
        dosages = await db.getMedicineDosages();
        print('API dosages table empty, loaded ${dosages.length} dosages from local table');
      } else {
        print('Loaded ${dosages.length} dosages from API table');
      }
      
      if (dosages.isNotEmpty) {
        medicineDosages.value = dosages.map((e) => e['name'] as String).toList();
      } else {
        // Fallback to default dosages only if both tables are empty
        print('Both API and local dosage tables are empty, using default list');
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
        
        // Save default dosages to database for future use
        for (var dosage in medicineDosages) {
          await db.database.then((dbClient) => dbClient.insert(
            'medicine_dosages', 
            {'name': dosage},
            conflictAlgorithm: ConflictAlgorithm.ignore
          ));
        }
      }
      
      update(); // Notify UI of changes
      print('Medicines loaded: ${commonDrugs.length}, Dosages loaded: ${medicineDosages.length}');
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
      
      update(); // Notify UI of changes
    }
  }
}
