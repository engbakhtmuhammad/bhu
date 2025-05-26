import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/disease_model.dart';
import '../models/patient_model.dart';
import '../models/opd_visit_model.dart';
import '../models/prescription_model.dart' as prescription;
import '../models/api_models.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'bhu.db');
    return await openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Patients table
    await db.execute('''
      CREATE TABLE patients(
        patientId TEXT PRIMARY KEY,
        fullName TEXT,
        relationCnic TEXT,
        relationType TEXT,
        contact TEXT,
        address TEXT,
        gender TEXT,
        bloodGroup TEXT,
        medicalHistory TEXT,
        immunized INTEGER
      )
    ''');

    // OPD Visits table
    await db.execute('''
      CREATE TABLE opd_visits(
        opdTicketNo TEXT PRIMARY KEY,
        patientId TEXT,
        visitDateTime TEXT,
        reasonForVisit TEXT,
        isFollowUp INTEGER,
        diagnosis TEXT,
        prescriptions TEXT,
        labTests TEXT,
        isReferred INTEGER,
        followUpAdvised INTEGER,
        followUpDays INTEGER,
        fpAdvised INTEGER,
        fpList TEXT,
        obgynData TEXT,
        FOREIGN KEY (patientId) REFERENCES patients (patientId)
      )
    ''');

    // Diseases table
    await db.execute('''
      CREATE TABLE diseases(
        id INTEGER PRIMARY KEY,
        name TEXT,
        category TEXT,
        categoryId INTEGER
      )
    ''');

    // Prescriptions table
    await db.execute('''
      CREATE TABLE prescriptions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        drugName TEXT,
        dosage TEXT,
        duration TEXT,
        opdTicketNo TEXT,
        FOREIGN KEY (opdTicketNo) REFERENCES opd_visits (opdTicketNo)
      )
    ''');

    // Insert default diseases and categories
    await _insertDefaultDiseases(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE opd_visits(
          opdTicketNo TEXT PRIMARY KEY,
          patientId TEXT,
          visitDateTime TEXT,
          reasonForVisit TEXT,
          isFollowUp INTEGER,
          diagnosis TEXT,
          prescriptions TEXT,
          labTests TEXT,
          isReferred INTEGER,
          followUpAdvised INTEGER,
          followUpDays INTEGER,
          fpAdvised INTEGER,
          fpList TEXT,
          obgynData TEXT,
          FOREIGN KEY (patientId) REFERENCES patients (patientId)
        )
      ''');

      await db.execute('''
        CREATE TABLE diseases(
          id INTEGER PRIMARY KEY,
          name TEXT,
          category TEXT,
          categoryId INTEGER
        )
      ''');

      await db.execute('''
        CREATE TABLE prescriptions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          drugName TEXT,
          dosage TEXT,
          duration TEXT,
          opdTicketNo TEXT,
          FOREIGN KEY (opdTicketNo) REFERENCES opd_visits (opdTicketNo)
        )
      ''');

      await _insertDefaultDiseases(db);
    }
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
}