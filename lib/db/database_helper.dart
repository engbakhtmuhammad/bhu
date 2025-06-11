import 'package:bhu/models/prescription_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/api_patient_models.dart';
import '../models/disease_model.dart';
import '../models/patient_model.dart';
import '../models/opd_visit_model.dart';
import '../models/app_user_data.dart';
import 'dart:convert';

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Database reference
  Database? _database;

  // Get database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Reset database on login
  Future<void> resetDatabase() async {
    try {
      // Close existing database if open
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      // Delete the database file
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'bhu_health.db');

      if (await databaseExists(path)) {
        await deleteDatabase(path);
        print('Existing database deleted successfully');
      }

      // Reinitialize the database
      _database = await _initDatabase();
      print('Database reinitialized successfully');
    } catch (e) {
      print('Error resetting database: $e');
    }
  }

  // Increase the database version to trigger migration
  final int _databaseVersion = 2; // Increment this from whatever it was before

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'bhu_health.db');
    
    print('Initializing database at $path');
    
    // Open the database
    return await openDatabase(
      path,
      version: 2, // Increment version to trigger upgrade
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create database tables
  Future<void> _onCreate(Database db, int version) async {
    print('Creating database tables for version $version');

    // Create patients table with relationType column
    await db.execute('''
      CREATE TABLE patients (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        age INTEGER,
        gender TEXT,
        relationCnic TEXT,
        relationType INTEGER DEFAULT 1,
        phoneNumber TEXT,
        address TEXT,
        bloodGroup TEXT,
        isPregnant INTEGER DEFAULT 0,
        isLactating INTEGER DEFAULT 0,
        isSynced INTEGER DEFAULT 0,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    // Create opd_visits table
    await db.execute('''
      CREATE TABLE opd_visits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id TEXT NOT NULL,
        visit_date TEXT NOT NULL,
        chief_complaint TEXT,
        diagnosis TEXT,
        treatment TEXT,
        lab_tests TEXT,
        is_referred INTEGER DEFAULT 0,
        follow_up_advised INTEGER DEFAULT 0,
        follow_up_days INTEGER,
        fp_advised INTEGER DEFAULT 0,
        fp_list TEXT,
        obgyn_data TEXT,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE
      )
    ''');

    // Create prescriptions table
    await db.execute('''
      CREATE TABLE prescriptions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        opdTicketNo TEXT NOT NULL,
        medicine TEXT NOT NULL,
        dosage TEXT,
        duration TEXT,
        instructions TEXT,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Create diseases table
    await db.execute('''
      CREATE TABLE diseases (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT,
        categoryId INTEGER
      )
    ''');

    // Create medicines table
    await db.execute('''
      CREATE TABLE medicines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        code TEXT,
        version INTEGER DEFAULT 1
      )
    ''');

    // Create all reference data tables
    await createReferenceTables(db);
  }

  Future<void> _initializeDefaultData(Database db) async {
    // Insert default medicines
    final defaultMedicines = [
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

    for (var medicine in defaultMedicines) {
      await db.insert('medicines', {'name': medicine},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // Insert default dosages
    final defaultDosages = [
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

    for (var dosage in defaultDosages) {
      await db.insert('medicine_dosages', {'name': dosage},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // ... other default data initialization ...
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');

    if (oldVersion < 2) {
      // Create any missing reference tables
      await createReferenceTables(db);
    }
  }

  Future<void> _insertDefaultDiseases(Database db) async {
    final diseases = [
      // Respiratory diseases (1)
      {
        'id': 1,
        'name': 'Common Cold',
        'category': 'Respiratory diseases',
        'categoryId': 1
      },
      {
        'id': 2,
        'name': 'Pneumonia',
        'category': 'Respiratory diseases',
        'categoryId': 1
      },
      {
        'id': 3,
        'name': 'Asthma',
        'category': 'Respiratory diseases',
        'categoryId': 1
      },
      {
        'id': 4,
        'name': 'Bronchitis',
        'category': 'Respiratory diseases',
        'categoryId': 1
      },
      {
        'id': 5,
        'name': 'Tuberculosis',
        'category': 'Respiratory diseases',
        'categoryId': 1
      },

      // Gastrointestinal disease (2)
      {
        'id': 6,
        'name': 'Diarrhea',
        'category': 'Gastrointestinal disease',
        'categoryId': 2
      },
      {
        'id': 7,
        'name': 'Gastroenteritis',
        'category': 'Gastrointestinal disease',
        'categoryId': 2
      },
      {
        'id': 8,
        'name': 'Constipation',
        'category': 'Gastrointestinal disease',
        'categoryId': 2
      },
      {
        'id': 9,
        'name': 'Peptic Ulcer',
        'category': 'Gastrointestinal disease',
        'categoryId': 2
      },

      // Urinary tract infection (3)
      {
        'id': 10,
        'name': 'Cystitis',
        'category': 'Urinary tract infection',
        'categoryId': 3
      },
      {
        'id': 11,
        'name': 'Pyelonephritis',
        'category': 'Urinary tract infection',
        'categoryId': 3
      },
      {
        'id': 12,
        'name': 'Urethritis',
        'category': 'Urinary tract infection',
        'categoryId': 3
      },

      // Other communicable diseases (4)
      {
        'id': 13,
        'name': 'Malaria',
        'category': 'Other communicable diseases',
        'categoryId': 4
      },
      {
        'id': 14,
        'name': 'Dengue Fever',
        'category': 'Other communicable diseases',
        'categoryId': 4
      },
      {
        'id': 15,
        'name': 'Typhoid',
        'category': 'Other communicable diseases',
        'categoryId': 4
      },
      {
        'id': 16,
        'name': 'Hepatitis',
        'category': 'Other communicable diseases',
        'categoryId': 4
      },

      // Blood disorder (5)
      {
        'id': 17,
        'name': 'Anemia',
        'category': 'Blood disorder',
        'categoryId': 5
      },
      {
        'id': 18,
        'name': 'Thrombocytopenia',
        'category': 'Blood disorder',
        'categoryId': 5
      },

      // Vaccine preventable diseases (6)
      {
        'id': 19,
        'name': 'Measles',
        'category': 'Vaccine preventable diseases',
        'categoryId': 6
      },
      {
        'id': 20,
        'name': 'Polio',
        'category': 'Vaccine preventable diseases',
        'categoryId': 6
      },
      {
        'id': 21,
        'name': 'Tetanus',
        'category': 'Vaccine preventable diseases',
        'categoryId': 6
      },

      // Cardiovascular diseases (7)
      {
        'id': 22,
        'name': 'Hypertension',
        'category': 'Cardiovascular diseases',
        'categoryId': 7
      },
      {
        'id': 23,
        'name': 'Heart Disease',
        'category': 'Cardiovascular diseases',
        'categoryId': 7
      },
      {
        'id': 24,
        'name': 'Stroke',
        'category': 'Cardiovascular diseases',
        'categoryId': 7
      },

      // Bone disorder, skin diseases (8)
      {
        'id': 25,
        'name': 'Arthritis',
        'category': 'Bone disorder, skin diseases',
        'categoryId': 8
      },
      {
        'id': 26,
        'name': 'Eczema',
        'category': 'Bone disorder, skin diseases',
        'categoryId': 8
      },
      {
        'id': 27,
        'name': 'Psoriasis',
        'category': 'Bone disorder, skin diseases',
        'categoryId': 8
      },
      {
        'id': 28,
        'name': 'Osteoporosis',
        'category': 'Bone disorder, skin diseases',
        'categoryId': 8
      },

      // Endocrine disorder (9)
      {
        'id': 29,
        'name': 'Diabetes',
        'category': 'Endocrine disorder',
        'categoryId': 9
      },
      {
        'id': 30,
        'name': 'Thyroid Disorder',
        'category': 'Endocrine disorder',
        'categoryId': 9
      },

      // Neuro-psychiatric disorder (10)
      {
        'id': 31,
        'name': 'Depression',
        'category': 'Neuro-psychiatric disorder',
        'categoryId': 10
      },
      {
        'id': 32,
        'name': 'Anxiety',
        'category': 'Neuro-psychiatric disorder',
        'categoryId': 10
      },
      {
        'id': 33,
        'name': 'Epilepsy',
        'category': 'Neuro-psychiatric disorder',
        'categoryId': 10
      },

      // Eye diseases (11)
      {
        'id': 34,
        'name': 'Conjunctivitis',
        'category': 'Eye diseases',
        'categoryId': 11
      },
      {
        'id': 35,
        'name': 'Cataract',
        'category': 'Eye diseases',
        'categoryId': 11
      },
      {
        'id': 36,
        'name': 'Glaucoma',
        'category': 'Eye diseases',
        'categoryId': 11
      },

      // ENT diseases (12)
      {
        'id': 37,
        'name': 'Otitis Media',
        'category': 'ENT diseases',
        'categoryId': 12
      },
      {
        'id': 38,
        'name': 'Sinusitis',
        'category': 'ENT diseases',
        'categoryId': 12
      },
      {
        'id': 39,
        'name': 'Tonsillitis',
        'category': 'ENT diseases',
        'categoryId': 12
      },

      // Oral/dental diseases (13)
      {
        'id': 40,
        'name': 'Dental Caries',
        'category': 'Oral/dental diseases',
        'categoryId': 13
      },
      {
        'id': 41,
        'name': 'Gingivitis',
        'category': 'Oral/dental diseases',
        'categoryId': 13
      },
      {
        'id': 42,
        'name': 'Periodontal Disease',
        'category': 'Oral/dental diseases',
        'categoryId': 13
      },

      // Injuries/poisoning (14)
      {
        'id': 43,
        'name': 'Fracture',
        'category': 'Injuries/poisoning',
        'categoryId': 14
      },
      {
        'id': 44,
        'name': 'Burns',
        'category': 'Injuries/poisoning',
        'categoryId': 14
      },
      {
        'id': 45,
        'name': 'Cuts/Wounds',
        'category': 'Injuries/poisoning',
        'categoryId': 14
      },

      // Other diseases (15)
      {
        'id': 46,
        'name': 'Fever',
        'category': 'Other diseases',
        'categoryId': 15
      },
      {
        'id': 47,
        'name': 'Headache',
        'category': 'Other diseases',
        'categoryId': 15
      },
      {
        'id': 48,
        'name': 'General Pain',
        'category': 'Other diseases',
        'categoryId': 15
      },
    ];

    for (var disease in diseases) {
      await db.insert('diseases', disease);
    }
  }

  // Patient methods
  Future<List<PatientModel>> getPatientsByCnic(String cnic) async {
    final db = await database;
    final result = await db
        .query('patients', where: 'relationCnic = ?', whereArgs: [cnic]);
    return result.map((e) => PatientModel.fromMap(e)).toList();
  }

  Future<void> insertPatient(PatientModel patient) async {
    final db = await database;
    await db.insert('patients', patient.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<PatientModel>> getAllPatients() async {
    final db = await database;
    final result = await db.query('patients');
    return result.map((e) => PatientModel.fromMap(e)).toList();
  }

  // OPD Visit methods
  Future<void> insertOpdVisit(OpdVisitModel visit) async {
    final db = await database;

    // Convert the OpdVisitModel to a map that matches the database schema
    final Map<String, dynamic> visitMap = {
      'id': null, // Let SQLite auto-generate the ID
      'patient_id': visit.patientId,
      'visit_date': visit.visitDateTime.toIso8601String(),
      'chief_complaint': visit.reasonForVisit,
      'diagnosis': visit.diagnosisIds.isNotEmpty ? visit.diagnosisIds.join(',') : '',
      'treatment': '', // Prescriptions will be stored in a separate table
      'lab_tests': visit.labTestIds.isNotEmpty ? visit.labTestIds.join(',') : '',
      'is_referred': visit.isReferred ? 1 : 0,
      'follow_up_advised': visit.followUpAdvised ? 1 : 0,
      'follow_up_days': visit.followUpDays,
      'fp_advised': visit.fpAdvised ? 1 : 0,
      'fp_list': visit.fpIds.isNotEmpty ? visit.fpIds.join(',') : '',
      'obgyn_data': visit.obgynData,
      'is_synced': 0,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    await db.insert('opd_visits', visitMap,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<OpdVisitModel>> getOpdVisitsByPatient(String patientId) async {
    final db = await database;
    final result = await db
        .query('opd_visits', where: 'patientId = ?', whereArgs: [patientId]);
    return result.map((e) => OpdVisitModel.fromMap(e)).toList();
  }

  Future<List<OpdVisitModel>> getAllOpdVisits() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps =
          await db.query('opd_visits', orderBy: 'visit_date DESC');
      
      return List.generate(maps.length, (i) {
        // Generate a ticket number if it doesn't exist
        String ticketNo = maps[i]['opd_ticket_no'] ?? 
                          'OPD${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}${(i + 1).toString().padLeft(4, '0')}';
        
        // Handle prescriptions
        List<Map<String, dynamic>> prescriptions = [];
        if (maps[i]['prescriptions'] != null) {
          try {
            // Try to parse JSON if it's stored as a string
            final dynamic prescData = maps[i]['prescriptions'];
            if (prescData is String) {
              try {
                prescriptions = List<Map<String, dynamic>>.from(
                    json.decode(prescData) as List);
              } catch (e) {
                print('Error parsing prescriptions JSON: $e');
                // If parsing fails, split by comma as fallback
                prescriptions = [];
              }
            } else if (prescData is List) {
              prescriptions = List<Map<String, dynamic>>.from(prescData);
            }
          } catch (e) {
            print('Error processing prescriptions: $e');
            prescriptions = [];
          }
        }

        // Parse boolean fields safely
        bool isFollowUp = false;
        if (maps[i]['is_follow_up'] != null) {
          isFollowUp = maps[i]['is_follow_up'] is bool 
              ? maps[i]['is_follow_up'] 
              : maps[i]['is_follow_up'] == 1 || maps[i]['is_follow_up'] == '1' || maps[i]['is_follow_up'] == 'true';
        }
        
        bool isReferred = false;
        if (maps[i]['is_referred'] != null) {
          isReferred = maps[i]['is_referred'] is bool 
              ? maps[i]['is_referred'] 
              : maps[i]['is_referred'] == 1 || maps[i]['is_referred'] == '1' || maps[i]['is_referred'] == 'true';
        }
        
        bool followUpAdvised = false;
        if (maps[i]['follow_up_advised'] != null) {
          followUpAdvised = maps[i]['follow_up_advised'] is bool 
              ? maps[i]['follow_up_advised'] 
              : maps[i]['follow_up_advised'] == 1 || maps[i]['follow_up_advised'] == '1' || maps[i]['follow_up_advised'] == 'true';
        }
        
        bool fpAdvised = false;
        if (maps[i]['fp_advised'] != null) {
          fpAdvised = maps[i]['fp_advised'] is bool 
              ? maps[i]['fp_advised'] 
              : maps[i]['fp_advised'] == 1 || maps[i]['fp_advised'] == '1' || maps[i]['fp_advised'] == 'true';
        }
        
        // Parse reason for visit
        String reasonForVisit = maps[i]['chief_complaint'] ?? 'General OPD';
        bool isGeneralOPD = true;
        if (maps[i]['reasonForVisit'] != null) {
          if (maps[i]['reasonForVisit'] is bool) {
            isGeneralOPD = maps[i]['reasonForVisit'];
          } else if (maps[i]['reasonForVisit'] is String) {
            reasonForVisit = maps[i]['reasonForVisit'];
            isGeneralOPD = reasonForVisit == 'General OPD';
          }
        }

        return OpdVisitModel(
          opdTicketNo: ticketNo,
          patientId: maps[i]['patient_id']?.toString() ?? '',
          visitDateTime: DateTime.parse(
              maps[i]['visit_date'] ?? DateTime.now().toIso8601String()),
          reasonForVisit: reasonForVisit=='General OPD'?true:false,
          isFollowUp: isFollowUp,
          diagnosisIds: _parseIds(maps[i]['diagnosis']),
          diagnosisNames: _parseNames(maps[i]['diagnosis_names']),
          prescriptions: prescriptions,
          labTestIds: _parseIds(maps[i]['lab_tests']),
          labTestNames: _parseNames(maps[i]['lab_test_names']),
          isReferred: isReferred,
          followUpAdvised: followUpAdvised,
          followUpDays: maps[i]['follow_up_days'],
          fpAdvised: fpAdvised,
          fpIds: _parseIds(maps[i]['fp_list']),
          fpNames: _parseNames(maps[i]['fp_names']),
          obgynData: maps[i]['obgyn_data'],
        );
      });
    } catch (e) {
      print('Error getting OPD visits: $e');
      return [];
    }
  }

  Future<String> generateOpdTicketNo() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM opd_visits');
    final count = result.first['count'] as int;
    final date = DateTime.now();
    return 'OPD${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}${(count + 1).toString().padLeft(4, '0')}';
  }

  // Disease methods
  Future<List<DiseaseModel>> getAllDiseases() async {
    final db = await database;
    final result = await db.query('diseases', orderBy: 'category, name');
    return result.map((e) => DiseaseModel.fromMap(e)).toList();
  }

  Future<List<DiseaseModel>> getDiseasesByCategory(int categoryId) async {
    final db = await database;
    final result = await db
        .query('diseases', where: 'categoryId = ?', whereArgs: [categoryId]);
    return result.map((e) => DiseaseModel.fromMap(e)).toList();
  }

  // Prescription methods
  Future<int> insertPrescription(PrescriptionModel prescription) async {
    final db = await database;
    
    // Ensure the quantity column exists
    await addQuantityColumnToPrescriptions();
    
    // Create a map that matches the database schema
    final Map<String, dynamic> prescriptionMap = {
      // Don't include id to let SQLite auto-generate it
      'medicine': prescription.drugName,  // Use 'medicine' field as in the schema
      'dosage': prescription.dosage,
      'duration': prescription.duration,
      'opdTicketNo': prescription.opdTicketNo,
      'quantity': prescription.quantity,
      'is_synced': 0,
      'created_at': prescription.createdAt ?? DateTime.now().toIso8601String(),
      'updated_at': prescription.updatedAt ?? DateTime.now().toIso8601String(),
    };
    
    // Debug log
    print('Inserting prescription: $prescriptionMap');
    
    // Insert and return the new ID
    return await db.insert('prescriptions', prescriptionMap);
  }

  Future<List<PrescriptionModel>> getPrescriptionsByOpdTicket(String opdTicketNo) async {
    final db = await database;
    final result = await db.query('prescriptions',
        where: 'opdTicketNo = ?', whereArgs: [opdTicketNo]);
    return result
        .map((e) => PrescriptionModel.fromMap(e))
        .toList();
  }

  // Reference data storage methods
  Future<void> storeReferenceData(AppUserData data) async {
    final db = await database;
    final batch = db.batch();

    try {
      // Store blood groups
      if (data.bloodGroups != null) {
        for (final item in data.bloodGroups!) {
          batch.insert('api_blood_groups', {'id': item.id, 'name': item.name},
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      // Store delivery types
      if (data.deliveryTypes != null) {
        for (final item in data.deliveryTypes!) {
          batch.insert('api_delivery_types', {'id': item.id, 'name': item.name},
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      // Store delivery modes
      if (data.deliveryModes != null) {
        for (final item in data.deliveryModes!) {
          batch.insert('api_delivery_modes', {'id': item.id, 'name': item.name},
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      // Store family planning services
      if (data.familyPlanning != null) {
        for (final item in data.familyPlanning!) {
          batch.insert(
              'api_family_planning', {'id': item.id, 'name': item.name},
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      // Store antenatal visits
      if (data.antenatalVisits != null) {
        for (final item in data.antenatalVisits!) {
          batch.insert(
              'api_antenatal_visits', {'id': item.id, 'name': item.name},
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      // Store TT advised options
      if (data.tTAdvisedList != null) {
        for (final item in data.tTAdvisedList!) {
          batch.insert('api_tt_advised', {'id': item.id, 'name': item.name},
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      // Store pregnancy indicators
      if (data.pregnancyIndicators != null) {
        for (final item in data.pregnancyIndicators!) {
          batch.insert(
              'api_pregnancy_indicators', {'id': item.id, 'name': item.name},
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      // Store postpartum statuses
      if (data.postPartumStatuses != null) {
        for (final item in data.postPartumStatuses!) {
          batch.insert(
              'api_postpartum_statuses', {'id': item.id, 'name': item.name},
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      // Store medicine dosages
      if (data.medicineDosages != null) {
        for (final item in data.medicineDosages!) {
          batch.insert(
              'api_medicine_dosages', {'id': item.id, 'name': item.name},
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      // Store districts
      if (data.districts != null) {
        for (final item in data.districts!) {
          batch.insert('api_districts', {'id': item.id, 'name': item.name},
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      // Store diseases
      if (data.diseases != null) {
        for (final item in data.diseases!) {
          batch.insert(
              'api_diseases',
              {
                'id': item.id,
                'name': item.name,
                'category': item.category,
                'category_id': item.category != null ? item.id : null,
                'version': 1
              },
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      // Store sub-diseases
      if (data.subDiseases != null) {
        for (final item in data.subDiseases!) {
          batch.insert(
              'api_sub_diseases',
              {
                'id': item.id,
                'name': item.name,
                'disease_id': item.diseaseId,
                'version': item.version
              },
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      // Store medicines
      if (data.medicines != null) {
        for (final item in data.medicines!) {
          batch.insert(
              'api_medicines',
              {
                'id': item.id,
                'name': item.name,
                'code': item.code,
                'version': item.version
              },
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      // Store health facilities
      if (data.healthFacilities != null) {
        for (final item in data.healthFacilities!) {
          batch.insert(
              'api_health_facilities', {'id': item.id, 'name': item.name},
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      // Store user roles
      if (data.userInfo?.userRoleId != null) {
        batch.insert('api_user_roles',
            {'id': data.userInfo!.userRoleId, 'name': data.userInfo!.userName},
            conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // Store patients if available
      if (data.patients != null && data.patients!.isNotEmpty) {
        print('Storing ${data.patients!.length} patients from reference data');
        
        // First clear existing patients if needed
        // Uncomment the next line if you want to clear existing patients
        // await db.delete('patients');
        
        for (var patientData in data.patients!) {
          try {
            // Convert to PatientModel
            final patient = PatientModel.fromApiModel(
              ApiPatientModel.fromJson(patientData)
            );
            
            // Insert into database
            await db.insert(
              'patients',
              patient.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace
            );
          } catch (e) {
            print('Error storing patient: $e');
          }
        }
      }

      // Execute all inserts as a batch
      await batch.commit();
      print('Reference data stored successfully');
    } catch (e) {
      print('Error storing reference data: $e');
      throw e;
    }
  }

  // Methods to get table information for profile screen
  Future<Map<String, int>> getTableCounts() async {
    final db = await database;
    final Map<String, int> counts = {};

    // Get all table names
    final tableNames = await getAllTableNames();

    // Count records in each table
    for (String table in tableNames) {
      try {
        final result =
            await db.rawQuery('SELECT COUNT(*) as count FROM $table');
        counts[table] = result.first['count'] as int;
      } catch (e) {
        counts[table] = 0;
      }
    }

    return counts;
  }

  Future<List<Map<String, dynamic>>> getTableData(String tableName,
      {int limit = 100}) async {
    final db = await database;
    try {
      final result = await db.query(tableName, limit: limit);
      return result;
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getAllTableNames() async {
    final db = await database;
    final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");
    return result.map((row) => row['name'] as String).toList();
  }

  // Create all reference data tables
  Future<void> createReferenceTables(Database db) async {
    print('Creating reference data tables');
    
    // Create all API reference tables
    await db.execute('CREATE TABLE IF NOT EXISTS api_blood_groups (id INTEGER PRIMARY KEY, name TEXT NOT NULL)');
    await db.execute('CREATE TABLE IF NOT EXISTS api_delivery_types (id INTEGER PRIMARY KEY, name TEXT NOT NULL)');
    await db.execute('CREATE TABLE IF NOT EXISTS api_delivery_modes (id INTEGER PRIMARY KEY, name TEXT NOT NULL)');
    await db.execute('CREATE TABLE IF NOT EXISTS api_family_planning (id INTEGER PRIMARY KEY, name TEXT NOT NULL)');
    await db.execute('CREATE TABLE IF NOT EXISTS api_antenatal_visits (id INTEGER PRIMARY KEY, name TEXT NOT NULL)');
    await db.execute('CREATE TABLE IF NOT EXISTS api_tt_advised (id INTEGER PRIMARY KEY, name TEXT NOT NULL)');
    await db.execute('CREATE TABLE IF NOT EXISTS api_pregnancy_indicators (id INTEGER PRIMARY KEY, name TEXT NOT NULL)');
    await db.execute('CREATE TABLE IF NOT EXISTS api_postpartum_statuses (id INTEGER PRIMARY KEY, name TEXT NOT NULL)');
    await db.execute('CREATE TABLE IF NOT EXISTS api_medicine_dosages (id INTEGER PRIMARY KEY, name TEXT NOT NULL)');
    await db.execute('CREATE TABLE IF NOT EXISTS api_districts (id INTEGER PRIMARY KEY, name TEXT, version INTEGER DEFAULT 0)');
    await db.execute('CREATE TABLE IF NOT EXISTS api_diseases (id INTEGER PRIMARY KEY, name TEXT, category TEXT, category_id INTEGER, version INTEGER DEFAULT 0)');
    await db.execute('CREATE TABLE IF NOT EXISTS api_sub_diseases (id INTEGER PRIMARY KEY, name TEXT, disease_id INTEGER, version INTEGER DEFAULT 0)');
    await db.execute('CREATE TABLE IF NOT EXISTS api_lab_tests (id INTEGER PRIMARY KEY, name TEXT)');
    await db.execute('CREATE TABLE IF NOT EXISTS api_medicines (id INTEGER PRIMARY KEY, name TEXT, code TEXT, version INTEGER DEFAULT 0)');
    await db.execute('CREATE TABLE IF NOT EXISTS api_health_facilities (id INTEGER PRIMARY KEY, name TEXT)');
    await db.execute('CREATE TABLE IF NOT EXISTS api_user_roles (id INTEGER PRIMARY KEY, name TEXT)');
    await db.execute('CREATE TABLE IF NOT EXISTS api_patients (id INTEGER PRIMARY KEY, name TEXT, address TEXT, version INTEGER DEFAULT 0, age INTEGER DEFAULT 0, bloodGroup INTEGER DEFAULT 1, cnic TEXT, contact TEXT, emergencyContact TEXT, fatherName TEXT, gender INTEGER DEFAULT 1, husbandName TEXT, immunization INTEGER DEFAULT 0, medicalHistory TEXT, uniqueId TEXT)');
  }

  // Method to check if tables exist and print their schema
  Future<void> debugDatabaseSchema() async {
    final db = await database;

    // Get all tables
    final tables =
        await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    print('Database tables: ${tables.map((t) => t['name']).toList()}');

    // For each table, print its schema
    for (var table in tables) {
      final tableName = table['name'];
      if (tableName != 'android_metadata' && tableName != 'sqlite_sequence') {
        final columns = await db.rawQuery("PRAGMA table_info($tableName)");
        print(
            'Table $tableName schema: ${columns.map((c) => "${c['name']} (${c['type']})").toList()}');
      }
    }
  }

  // Methods to retrieve reference data

  Future<List<Map<String, dynamic>>> getBloodGroups() async {
    final db = await database;
    return await db.query('api_blood_groups');
  }

  Future<List<Map<String, dynamic>>> getDeliveryTypes() async {
    final db = await database;
    return await db.query('api_delivery_types');
  }

  Future<List<Map<String, dynamic>>> getDeliveryModes() async {
    final db = await database;
    return await db.query('api_delivery_modes');
  }

  Future<List<Map<String, dynamic>>> getFamilyPlanningServices() async {
    final db = await database;
    return await db.query('api_family_planning');
  }

  Future<List<Map<String, dynamic>>> getAntenatalVisits() async {
    final db = await database;
    return await db.query('api_antenatal_visits');
  }

  Future<List<Map<String, dynamic>>> getTTAdvised() async {
    final db = await database;
    return await db.query('api_tt_advised');
  }

  Future<List<Map<String, dynamic>>> getPregnancyIndicators() async {
    final db = await database;
    return await db.query('api_pregnancy_indicators');
  }
  
  Future<List<Map<String, dynamic>>> getPostpartumStatuses() async {
    final db = await database;
    return await db.query('api_postpartum_statuses');
  }

  Future<List<Map<String, dynamic>>> getLocalMedicineDosages() async {
    final db = await database;
    return await db.query('api_medicine_dosages');
  }

  Future<List<Map<String, dynamic>>> getDistricts() async {
    final db = await database;
    return await db.query('api_districts');
  }

  Future<List<Map<String, dynamic>>> getApiDiseases() async {
    try {
      final db = await database;
      return await db.query('api_diseases');
    } catch (e) {
      print('Error getting API diseases: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSubDiseases(int diseaseId) async {
    final db = await database;
    return await db.query(
      'api_sub_diseases',
      where: 'diseaseId = ?',
      whereArgs: [diseaseId],
    );
  }

  Future<List<Map<String, dynamic>>> getLocalMedicines() async {
    final db = await database;
    return await db.query('api_medicines');
  }

  Future<List<Map<String, dynamic>>> getLabTests() async {
    final db = await database;
    return await db.query('api_lab_tests');
  }

  // Add this method to clear all reference data tables
  Future<void> clearReferenceData() async {
    final db = await database;
    final batch = db.batch();

    final tables = [
      'api_blood_groups',
      'api_delivery_types',
      'api_delivery_modes',
      'api_family_planning',
      'api_antenatal_visits',
      'api_tt_advised',
      'api_pregnancy_indicators',
      'api_postpartum_statuses',
      'api_medicine_dosages',
      'api_districts',
      'api_diseases',
      'api_sub_diseases',
      'api_lab_tests',
      'api_medicines',
      'api_health_facilities',
      'api_user_roles'
    ];

    for (final table in tables) {
      try {
        batch.delete(table);
      } catch (e) {
        print('Error clearing table $table: $e');
        // Continue with other tables even if one fails
      }
    }

    try {
      await batch.commit();
      print('Reference data cleared successfully');
    } catch (e) {
      print('Error clearing reference data: $e');
      // We'll continue even if there's an error
    }
  }

  // Add this method to force recreate the database
  Future<void> recreateDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'bhu_database.db');

    // Delete the database
    await deleteDatabase(path);

    // Reinitialize the database
    await database;

    print('Database recreated successfully');
  }

  // Methods for API medicines
  Future<List<Map<String, dynamic>>> getApiMedicines() async {
    final db = await database;
    try {
      // Try to query the API medicines table
      return await db.query('api_medicines');
    } catch (e) {
      print('Error getting API medicines: $e');
      // If table doesn't exist or other error, return empty list
      return [];
    }
  }

  // Methods for API medicine dosages
  Future<List<Map<String, dynamic>>> getApiMedicineDosages() async {
    final db = await database;
    try {
      // Try to query the API medicine dosages table
      return await db.query('api_medicine_dosages');
    } catch (e) {
      print('Error getting API medicine dosages: $e');
      // If table doesn't exist or other error, return empty list
      return [];
    }
  }

  // Methods for local medicines
  Future<List<Map<String, dynamic>>> getMedicines() async {
    final db = await database;
    try {
      return await db.query('medicines');
    } catch (e) {
      print('Error getting medicines: $e');
      // If table doesn't exist, create it
      await db.execute('''
        CREATE TABLE IF NOT EXISTS medicines (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT UNIQUE
        )
      ''');
      return [];
    }
  }

  // Methods for local medicine dosages
  Future<List<Map<String, dynamic>>> getMedicineDosages() async {
    final db = await database;
    try {
      return await db.query('medicine_dosages');
    } catch (e) {
      print('Error getting medicine dosages: $e');
      // If table doesn't exist, create it
      await db.execute('''
        CREATE TABLE IF NOT EXISTS medicine_dosages (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT UNIQUE
        )
      ''');
      return [];
    }
  }

  // API table query methods
  Future<List<Map<String, dynamic>>> getApiFamilyPlanningServices() async {
    final db = await database;
    try {
      return await db.query('api_family_planning_services');
    } catch (e) {
      print('Error getting API family planning services: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getApiLabTests() async {
    final db = await database;
    try {
      return await db.query('api_lab_tests');
    } catch (e) {
      print('Error getting API lab tests: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getApiAntenatalVisits() async {
    final db = await database;
    try {
      return await db.query('api_antenatal_visits');
    } catch (e) {
      print('Error getting API antenatal visits: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getApiDeliveryModes() async {
    final db = await database;
    try {
      return await db.query('api_delivery_modes');
    } catch (e) {
      print('Error getting API delivery modes: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getApiPregnancyIndicators() async {
    final db = await database;
    try {
      return await db.query('api_pregnancy_indicators');
    } catch (e) {
      print('Error getting API pregnancy indicators: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getApiTTAdvised() async {
    final db = await database;
    try {
      return await db.query('api_tt_advised');
    } catch (e) {
      print('Error getting API TT advised options: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getApiPostpartumStatuses() async {
    final db = await database;
    try {
      return await db.query('api_postpartum_statuses');
    } catch (e) {
      print('Error getting API postpartum statuses: $e');
      return [];
    }
  }

  // Add this method to get prescriptions by ticket number
  Future<List<PrescriptionModel>> getPrescriptionsByTicket(String opdTicketNo) async {
    final db = await database;
    try {
      // Debug log
      print('Fetching prescriptions for ticket: $opdTicketNo');
      
      // Get table info to check column names
      var tableInfo = await db.rawQuery("PRAGMA table_info(prescriptions)");
      List<String> columns = tableInfo.map((col) => col['name'] as String).toList();
      print('Prescription table columns: $columns');
      
      // Determine which column name to use for the query
      String ticketColumn = columns.contains('opdTicketNo') ? 'opdTicketNo' : 'opdTicketNo';
      String drugColumn = columns.contains('drugName') ? 'drugName' : 'medicine';
      
      final List<Map<String, dynamic>> maps = await db.query(
        'prescriptions',
        where: '$ticketColumn = ?',
        whereArgs: [opdTicketNo],
      );
      
      print('Found ${maps.length} prescriptions for ticket $opdTicketNo in database');
      
      return List.generate(maps.length, (i) {
        // Create a normalized map with consistent keys
        Map<String, dynamic> normalizedMap = {
          'id': maps[i]['id'],
          'drugName': maps[i][drugColumn],
          'dosage': maps[i]['dosage'],
          'duration': maps[i]['duration'],
          'opdTicketNo': maps[i][ticketColumn],
          'quantity': maps[i]['quantity'] ?? 1,
          'created_at': maps[i]['created_at'],
          'updated_at': maps[i]['updated_at'],
        };
        
        return PrescriptionModel.fromMap(normalizedMap);
      });
    } catch (e) {
      print('Error getting prescriptions by ticket: $e');
      return [];
    }
  }

  // Add this method to add sync columns to tables
  Future<void> addSyncColumns() async {
    final db = await database;
    try {
      // Check if columns exist before adding them
      var patientsInfo = await db.rawQuery('PRAGMA table_info(patients)');
      var opdVisitsInfo = await db.rawQuery('PRAGMA table_info(opd_visits)');
      var prescriptionsInfo = await db.rawQuery('PRAGMA table_info(prescriptions)');
      
      // Extract column names
      List<String> patientColumns = patientsInfo.map((col) => col['name'].toString()).toList();
      List<String> opdVisitColumns = opdVisitsInfo.map((col) => col['name'].toString()).toList();
      List<String> prescriptionColumns = prescriptionsInfo.map((col) => col['name'].toString()).toList();
      
      // Add is_synced column to patients if it doesn't exist
      if (!patientColumns.contains('is_synced')) {
        await db.execute('ALTER TABLE patients ADD COLUMN is_synced INTEGER DEFAULT 0');
        print('Added is_synced column to patients table');
      }
      
      // Add is_synced column to opd_visits if it doesn't exist
      if (!opdVisitColumns.contains('is_synced')) {
        await db.execute('ALTER TABLE opd_visits ADD COLUMN is_synced INTEGER DEFAULT 0');
        print('Added is_synced column to opd_visits table');
      }
      
      // Add is_synced column to prescriptions if it doesn't exist
      if (!prescriptionColumns.contains('is_synced')) {
        await db.execute('ALTER TABLE prescriptions ADD COLUMN is_synced INTEGER DEFAULT 0');
        print('Added is_synced column to prescriptions table');
      }
    } catch (e) {
      print('Error adding sync columns: $e');
    }
  }

  // Add this method to add the relationType column to the patients table
  Future<void> addRelationTypeColumn() async {
    final db = await database;
    try {
      // Check if column exists before adding it
      var patientsInfo = await db.rawQuery('PRAGMA table_info(patients)');
      
      // Extract column names
      List<String> patientColumns = patientsInfo.map((col) => col['name'].toString()).toList();
      
      // Add relationType column to patients if it doesn't exist
      if (!patientColumns.contains('relationType')) {
        await db.execute('ALTER TABLE patients ADD COLUMN relationType INTEGER DEFAULT 1');
        print('Added relationType column to patients table');
      }
    } catch (e) {
      print('Error adding relationType column: $e');
    }
  }

  // Add this method to add the quantity column to the prescriptions table
  Future<void> addQuantityColumnToPrescriptions() async {
    final db = await database;
    try {
      // Check if column exists before adding it
      var prescriptionsInfo = await db.rawQuery('PRAGMA table_info(prescriptions)');
      
      // Extract column names
      List<String> prescriptionColumns = prescriptionsInfo.map((col) => col['name'].toString()).toList();
      
      // Add quantity column to prescriptions if it doesn't exist
      if (!prescriptionColumns.contains('quantity')) {
        await db.execute('ALTER TABLE prescriptions ADD COLUMN quantity INTEGER DEFAULT 1');
        print('Added quantity column to prescriptions table');
      }
    } catch (e) {
      print('Error adding quantity column: $e');
    }
  }

  // Helper method to parse IDs from JSON or comma-separated string
  List<int> _parseIds(dynamic value) {
    if (value == null) return [];
    
    try {
      if (value is String) {
        // Try to parse as JSON first
        try {
          final List<dynamic> parsed = json.decode(value);
          return parsed.map((id) => int.tryParse(id.toString()) ?? 0).toList();
        } catch (_) {
          // If JSON parsing fails, try comma-separated string
          return value.split(',')
              .where((s) => s.isNotEmpty)
              .map((s) => int.tryParse(s) ?? 0)
              .toList();
        }
      } else if (value is List) {
        return value.map((id) => int.tryParse(id.toString()) ?? 0).toList();
      }
    } catch (e) {
      print('Error parsing IDs: $e');
    }
    
    return [];
  }

  // Helper method to parse names from comma-separated string
  List<String> _parseNames(dynamic value) {
    if (value == null) return [];
    
    try {
      if (value is String) {
        return value.split(',')
            .where((s) => s.isNotEmpty)
            .toList();
      } else if (value is List) {
        return value.map((item) => item.toString()).toList();
      }
    } catch (e) {
      print('Error parsing names: $e');
    }
    
    return [];
  }

  // Get all sub-diseases
  Future<List<SubDiseaseModel>> getAllSubDiseases() async {
    final db = await database;
    try {
      final result = await db.query('api_sub_diseases');
      return result.map((e) => SubDiseaseModel.fromMap(e)).toList();
    } catch (e) {
      print('Error getting sub-diseases: $e');
      return [];
    }
  }
}
