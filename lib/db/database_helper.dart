import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/disease_model.dart';
import '../models/patient_model.dart';
import '../models/opd_visit_model.dart';
import '../models/prescription_model.dart' as prescription;
import '../models/app_user_data.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Update the database version to trigger schema migration
  static const int _databaseVersion = 3;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'bhu.db');
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print('Creating database tables for version $version');
    
    // Create tables for reference data
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_blood_groups (
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_delivery_types (
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_delivery_modes (
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_family_planning (
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_antenatal_visits (
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_tt_advised (
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_pregnancy_indicators (
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_postpartum_statuses (
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_medicine_dosages (
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_districts (
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_diseases (
        id INTEGER PRIMARY KEY,
        name TEXT,
        category TEXT,
        category_id INTEGER,
        version INTEGER
      )
    ''');
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_sub_diseases (
        id INTEGER PRIMARY KEY,
        name TEXT,
        disease_id INTEGER,
        version INTEGER
      )
    ''');
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_lab_tests (
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_medicines (
        id INTEGER PRIMARY KEY,
        name TEXT,
        code TEXT,
        version INTEGER
      )
    ''');
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_health_facilities (
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_user_roles (
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');
    
    // Create tables for local data
    await db.execute('''
      CREATE TABLE IF NOT EXISTS patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        cnic TEXT,
        age INTEGER,
        gender TEXT,
        address TEXT,
        phone TEXT,
        district_id INTEGER,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS opd_visits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id INTEGER,
        visit_date TEXT,
        chief_complaint TEXT,
        diagnosis TEXT,
        treatment TEXT,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (patient_id) REFERENCES patients (id)
      )
    ''');
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS prescriptions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        opd_visit_id INTEGER,
        medicine_name TEXT,
        dosage TEXT,
        duration TEXT,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (opd_visit_id) REFERENCES opd_visits (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');
    
    // Drop existing tables if they exist
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
        await db.execute('DROP TABLE IF EXISTS $table');
      } catch (e) {
        print('Error dropping table $table: $e');
      }
    }
    
    // Recreate all tables
    await _onCreate(db, newVersion);
  }

  Future<void> _insertDefaultDiseases(Database db) async {
    final diseases = [
      // Respiratory diseases (1)
      {'id': 1, 'name': 'Common Cold', 'category': 'Respiratory diseases', 'categoryId': 1},
      {'id': 2, 'name': 'Pneumonia', 'category': 'Respiratory diseases', 'categoryId': 1},
      {'id': 3, 'name': 'Asthma', 'category': 'Respiratory diseases', 'categoryId': 1},
      {'id': 4, 'name': 'Bronchitis', 'category': 'Respiratory diseases', 'categoryId': 1},
      {'id': 5, 'name': 'Tuberculosis', 'category': 'Respiratory diseases', 'categoryId': 1},

      // Gastrointestinal disease (2)
      {'id': 6, 'name': 'Diarrhea', 'category': 'Gastrointestinal disease', 'categoryId': 2},
      {'id': 7, 'name': 'Gastroenteritis', 'category': 'Gastrointestinal disease', 'categoryId': 2},
      {'id': 8, 'name': 'Constipation', 'category': 'Gastrointestinal disease', 'categoryId': 2},
      {'id': 9, 'name': 'Peptic Ulcer', 'category': 'Gastrointestinal disease', 'categoryId': 2},

      // Urinary tract infection (3)
      {'id': 10, 'name': 'Cystitis', 'category': 'Urinary tract infection', 'categoryId': 3},
      {'id': 11, 'name': 'Pyelonephritis', 'category': 'Urinary tract infection', 'categoryId': 3},
      {'id': 12, 'name': 'Urethritis', 'category': 'Urinary tract infection', 'categoryId': 3},

      // Other communicable diseases (4)
      {'id': 13, 'name': 'Malaria', 'category': 'Other communicable diseases', 'categoryId': 4},
      {'id': 14, 'name': 'Dengue Fever', 'category': 'Other communicable diseases', 'categoryId': 4},
      {'id': 15, 'name': 'Typhoid', 'category': 'Other communicable diseases', 'categoryId': 4},
      {'id': 16, 'name': 'Hepatitis', 'category': 'Other communicable diseases', 'categoryId': 4},

      // Blood disorder (5)
      {'id': 17, 'name': 'Anemia', 'category': 'Blood disorder', 'categoryId': 5},
      {'id': 18, 'name': 'Thrombocytopenia', 'category': 'Blood disorder', 'categoryId': 5},

      // Vaccine preventable diseases (6)
      {'id': 19, 'name': 'Measles', 'category': 'Vaccine preventable diseases', 'categoryId': 6},
      {'id': 20, 'name': 'Polio', 'category': 'Vaccine preventable diseases', 'categoryId': 6},
      {'id': 21, 'name': 'Tetanus', 'category': 'Vaccine preventable diseases', 'categoryId': 6},

      // Cardiovascular diseases (7)
      {'id': 22, 'name': 'Hypertension', 'category': 'Cardiovascular diseases', 'categoryId': 7},
      {'id': 23, 'name': 'Heart Disease', 'category': 'Cardiovascular diseases', 'categoryId': 7},
      {'id': 24, 'name': 'Stroke', 'category': 'Cardiovascular diseases', 'categoryId': 7},

      // Bone disorder, skin diseases (8)
      {'id': 25, 'name': 'Arthritis', 'category': 'Bone disorder, skin diseases', 'categoryId': 8},
      {'id': 26, 'name': 'Eczema', 'category': 'Bone disorder, skin diseases', 'categoryId': 8},
      {'id': 27, 'name': 'Psoriasis', 'category': 'Bone disorder, skin diseases', 'categoryId': 8},
      {'id': 28, 'name': 'Osteoporosis', 'category': 'Bone disorder, skin diseases', 'categoryId': 8},

      // Endocrine disorder (9)
      {'id': 29, 'name': 'Diabetes', 'category': 'Endocrine disorder', 'categoryId': 9},
      {'id': 30, 'name': 'Thyroid Disorder', 'category': 'Endocrine disorder', 'categoryId': 9},

      // Neuro-psychiatric disorder (10)
      {'id': 31, 'name': 'Depression', 'category': 'Neuro-psychiatric disorder', 'categoryId': 10},
      {'id': 32, 'name': 'Anxiety', 'category': 'Neuro-psychiatric disorder', 'categoryId': 10},
      {'id': 33, 'name': 'Epilepsy', 'category': 'Neuro-psychiatric disorder', 'categoryId': 10},

      // Eye diseases (11)
      {'id': 34, 'name': 'Conjunctivitis', 'category': 'Eye diseases', 'categoryId': 11},
      {'id': 35, 'name': 'Cataract', 'category': 'Eye diseases', 'categoryId': 11},
      {'id': 36, 'name': 'Glaucoma', 'category': 'Eye diseases', 'categoryId': 11},

      // ENT diseases (12)
      {'id': 37, 'name': 'Otitis Media', 'category': 'ENT diseases', 'categoryId': 12},
      {'id': 38, 'name': 'Sinusitis', 'category': 'ENT diseases', 'categoryId': 12},
      {'id': 39, 'name': 'Tonsillitis', 'category': 'ENT diseases', 'categoryId': 12},

      // Oral/dental diseases (13)
      {'id': 40, 'name': 'Dental Caries', 'category': 'Oral/dental diseases', 'categoryId': 13},
      {'id': 41, 'name': 'Gingivitis', 'category': 'Oral/dental diseases', 'categoryId': 13},
      {'id': 42, 'name': 'Periodontal Disease', 'category': 'Oral/dental diseases', 'categoryId': 13},

      // Injuries/poisoning (14)
      {'id': 43, 'name': 'Fracture', 'category': 'Injuries/poisoning', 'categoryId': 14},
      {'id': 44, 'name': 'Burns', 'category': 'Injuries/poisoning', 'categoryId': 14},
      {'id': 45, 'name': 'Cuts/Wounds', 'category': 'Injuries/poisoning', 'categoryId': 14},

      // Other diseases (15)
      {'id': 46, 'name': 'Fever', 'category': 'Other diseases', 'categoryId': 15},
      {'id': 47, 'name': 'Headache', 'category': 'Other diseases', 'categoryId': 15},
      {'id': 48, 'name': 'General Pain', 'category': 'Other diseases', 'categoryId': 15},
    ];

    for (var disease in diseases) {
      await db.insert('diseases', disease);
    }
  }

  // Patient methods
  Future<List<PatientModel>> getPatientsByCnic(String cnic) async {
    final db = await database;
    final result = await db.query('patients', where: 'relationCnic = ?', whereArgs: [cnic]);
    return result.map((e) => PatientModel.fromMap(e)).toList();
  }

  Future<void> insertPatient(PatientModel patient) async {
    final db = await database;
    await db.insert('patients', patient.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<PatientModel>> getAllPatients() async {
    final db = await database;
    final result = await db.query('patients');
    return result.map((e) => PatientModel.fromMap(e)).toList();
  }

  // OPD Visit methods
  Future<void> insertOpdVisit(OpdVisitModel visit) async {
    final db = await database;
    await db.insert('opd_visits', visit.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<OpdVisitModel>> getOpdVisitsByPatient(String patientId) async {
    final db = await database;
    final result = await db.query('opd_visits', where: 'patientId = ?', whereArgs: [patientId]);
    return result.map((e) => OpdVisitModel.fromMap(e)).toList();
  }

  Future<List<OpdVisitModel>> getAllOpdVisits() async {
    final db = await database;
    final result = await db.query('opd_visits', orderBy: 'visitDateTime DESC');
    return result.map((e) => OpdVisitModel.fromMap(e)).toList();
  }

  Future<String> generateOpdTicketNo() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM opd_visits');
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
    final result = await db.query('diseases', where: 'categoryId = ?', whereArgs: [categoryId]);
    return result.map((e) => DiseaseModel.fromMap(e)).toList();
  }

  // Prescription methods
  Future<int> insertPrescription(prescription.PrescriptionModel prescription) async {
    final db = await database;
    return await db.insert('prescriptions', prescription.toMap());
  }

  Future<List<prescription.PrescriptionModel>> getPrescriptionsByTicket(String opdTicketNo) async {
    final db = await database;
    final result = await db.query('prescriptions', where: 'opdTicketNo = ?', whereArgs: [opdTicketNo]);
    return result.map((e) => prescription.PrescriptionModel.fromMap(e)).toList();
  }

  // Reference data storage methods
  Future<void> storeReferenceData(AppUserData data) async {
    final db = await database;
    final batch = db.batch();
    
    try {
      // Store blood groups
      if (data.bloodGroups != null) {
        for (final item in data.bloodGroups!) {
          batch.insert('api_blood_groups', {
            'id': item.id,
            'name': item.name
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      
      // Store delivery types
      if (data.deliveryTypes != null) {
        for (final item in data.deliveryTypes!) {
          batch.insert('api_delivery_types', {
            'id': item.id,
            'name': item.name
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      
      // Store delivery modes
      if (data.deliveryModes != null) {
        for (final item in data.deliveryModes!) {
          batch.insert('api_delivery_modes', {
            'id': item.id,
            'name': item.name
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      
      // Store family planning services
      if (data.familyPlanning != null) {
        for (final item in data.familyPlanning!) {
          batch.insert('api_family_planning', {
            'id': item.id,
            'name': item.name
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      
      // Store antenatal visits
      if (data.antenatalVisits != null) {
        for (final item in data.antenatalVisits!) {
          batch.insert('api_antenatal_visits', {
            'id': item.id,
            'name': item.name
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      
      // Store TT advised options
      if (data.tTAdvisedList != null) {
        for (final item in data.tTAdvisedList!) {
          batch.insert('api_tt_advised', {
            'id': item.id,
            'name': item.name
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      
      // Store pregnancy indicators
      if (data.pregnancyIndicators != null) {
        for (final item in data.pregnancyIndicators!) {
          batch.insert('api_pregnancy_indicators', {
            'id': item.id,
            'name': item.name
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      
      // Store postpartum statuses
      if (data.postPartumStatuses != null) {
        for (final item in data.postPartumStatuses!) {
          batch.insert('api_postpartum_statuses', {
            'id': item.id,
            'name': item.name
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      
      // Store medicine dosages
      if (data.medicineDosages != null) {
        for (final item in data.medicineDosages!) {
          batch.insert('api_medicine_dosages', {
            'id': item.id,
            'name': item.name
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      
      // Store districts
      if (data.districts != null) {
        for (final item in data.districts!) {
          batch.insert('api_districts', {
            'id': item.id,
            'name': item.name
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      
      // Store diseases
      if (data.diseases != null) {
        for (final item in data.diseases!) {
          batch.insert('api_diseases', {
            'id': item.id,
            'name': item.name,
            'category': item.category,
            'category_id': item.category != null ? item.id : null,
            'version': 1
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      
      // Store sub-diseases
      if (data.subDiseases != null) {
        for (final item in data.subDiseases!) {
          batch.insert('api_sub_diseases', {
            'id': item.id,
            'name': item.name,
            'disease_id': item.diseaseId,
            'version': item.version
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      
      // Store medicines
      if (data.medicines != null) {
        for (final item in data.medicines!) {
          batch.insert('api_medicines', {
            'id': item.id,
            'name': item.name,
            'code': item.code,
            'version': item.version
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      
      // Store health facilities
      if (data.healthFacilities != null) {
        for (final item in data.healthFacilities!) {
          batch.insert('api_health_facilities', {
            'id': item.id,
            'name': item.name
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      
      // Store user roles
      if (data.userInfo?.userRoleId != null) {
        batch.insert('api_user_roles', {
          'id': data.userInfo!.userRoleId,
          'name': data.userInfo!.userName
        }, conflictAlgorithm: ConflictAlgorithm.replace);
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
        final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
        counts[table] = result.first['count'] as int;
      } catch (e) {
        counts[table] = 0;
      }
    }

    return counts;
  }

  Future<List<Map<String, dynamic>>> getTableData(String tableName, {int limit = 100}) async {
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
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
    );
    return result.map((row) => row['name'] as String).toList();
  }

  // Create all reference data tables
  Future<void> createReferenceTables(Database db) async {
    // Districts table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_districts(
        id INTEGER PRIMARY KEY,
        name TEXT,
        version INTEGER DEFAULT 0
      )
    ''');

    // Medicines table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_medicines(
        id INTEGER PRIMARY KEY,
        name TEXT,
        code TEXT,
        version INTEGER DEFAULT 0
      )
    ''');

    // Blood groups table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_blood_groups(
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');

    // Diseases table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_diseases(
        id INTEGER PRIMARY KEY,
        name TEXT,
        version INTEGER DEFAULT 0
      )
    ''');

    // Sub-diseases table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_sub_diseases(
        id INTEGER PRIMARY KEY,
        name TEXT,
        diseaseId INTEGER,
        version INTEGER DEFAULT 0
      )
    ''');

    // Delivery types table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_delivery_types(
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');

    // Delivery modes table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_delivery_modes(
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');

    // Antenatal visits table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_antenatal_visits(
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');

    // TT advised list table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_tt_advised_list(
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');

    // Pregnancy indicators table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_pregnancy_indicators(
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');

    // Post-partum statuses table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_post_partum_statuses(
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');

    // Medicine dosages table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_medicine_dosages(
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');
  }

  // Method to check if tables exist and print their schema
  Future<void> debugDatabaseSchema() async {
    final db = await database;
    
    // Get all tables
    final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    print('Database tables: ${tables.map((t) => t['name']).toList()}');
    
    // For each table, print its schema
    for (var table in tables) {
      final tableName = table['name'];
      if (tableName != 'android_metadata' && tableName != 'sqlite_sequence') {
        final columns = await db.rawQuery("PRAGMA table_info($tableName)");
        print('Table $tableName schema: ${columns.map((c) => "${c['name']} (${c['type']})").toList()}');
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

  Future<List<Map<String, dynamic>>> getMedicineDosages() async {
    final db = await database;
    return await db.query('api_medicine_dosages');
  }

  Future<List<Map<String, dynamic>>> getDistricts() async {
    final db = await database;
    return await db.query('api_districts');
  }

  Future<List<Map<String, dynamic>>> getDiseases() async {
    final db = await database;
    return await db.query('api_diseases');
  }

  Future<List<Map<String, dynamic>>> getSubDiseases(int diseaseId) async {
    final db = await database;
    return await db.query(
      'api_sub_diseases',
      where: 'diseaseId = ?',
      whereArgs: [diseaseId],
    );
  }

  Future<List<Map<String, dynamic>>> getMedicines() async {
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
}
