import 'api_patient_models.dart';

class PatientModel {
  final String patientId;  // This corresponds to uniqueId in ApiPatientModel
  final String fullName;   // This corresponds to name in ApiPatientModel
  final String fatherName;
  final String? husbandName;
  final int age;
  final int relationType;
  final String gender;
  final String cnic;
  final int version;
  final String contact;
  /*final String emergencyContact;
  final String address;
  final String medicalHistory;
  final bool immunized;    // This corresponds to immunization in ApiPatientModel
  final int bloodGroup; */   // Changed from string to int to match API model
  final int? districtId;
  final bool isSynced;
  final String? createdAt;
  final String? updatedAt;

  PatientModel({
    required this.patientId,
    required this.fullName,
    required this.fatherName,
    required this.relationType,
    this.husbandName,
    required this.age,
    required this.gender,
    required this.cnic,
    this.version = 1,
    required this.contact,
    /*required this.emergencyContact,
    required this.address,
    required this.medicalHistory,
    required this.immunized,
    required this.bloodGroup,*/
    this.districtId,
    this.isSynced = false,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': patientId,
      'name': fullName,
      'age': age,
      'gender': gender,
      'relationCnic': cnic,
      'relationType': relationType,
      'phoneNumber': contact,
      'isPregnant': 0,
      'isLactating': 0,
      'isSynced': isSynced ? 1 : 0,
      'createdAt': createdAt ?? DateTime.now().toIso8601String(),
      'updatedAt': updatedAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      patientId: map['id'] ?? '',
      fullName: map['name'] ?? '',
      fatherName: map['fatherName'] ?? '',
      husbandName: map['husbandName'],
      age: map['age'] ?? 18,
      gender: map['gender'] ?? '',
      cnic: map['relationCnic'] ?? '',
      relationType: map['relationType'] ?? 1,
      version: map['version'] ?? 1,
      contact: map['phoneNumber'] ?? '',
      /*emergencyContact: map['emergencyContact'] ?? map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      medicalHistory: map['medicalHistory'] ?? '',
      immunized: map['immunized'] == 1,
      bloodGroup: int.tryParse(map['bloodGroup'] ?? '1') ?? 1,*/
      districtId: map['district_id'],
      isSynced: map['isSynced'] == 1,
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  // Convert to ApiPatientModel format for API requests
  Map<String, dynamic> toApiJson() {
    return {
      'id': 0, // New record for API
      'uniqueId': patientId,
      'name': fullName,
      'relationType': relationType,
      'fatherName': fatherName,
      'husbandName': husbandName,
      'age': age,
      'gender': gender,
      'cnic': cnic,
      'version': version,
      'contact': contact,
      /*'emergencyContact': emergencyContact,
      'address': address,
      'medicalHistory': medicalHistory,
      'immunization': immunized,
      'bloodGroup': bloodGroup,*/
    };
  }

  // Create PatientModel from ApiPatientModel
  factory PatientModel.fromApiModel(ApiPatientModel apiModel) {
    var returnData = PatientModel(
      patientId: apiModel.uniqueId,
      fullName: apiModel.name,
      fatherName: apiModel.fatherName,
      husbandName: apiModel.husbandName,
      age: apiModel.ageGroup, // Use ageGroup from API
      relationType: apiModel.relationType,
      gender: apiModel.gender.toString(), // Convert int gender ID to string
      cnic: apiModel.cnic,
      version: apiModel.version,
      contact: apiModel.contact,
      isSynced: true, // Coming from API, so it's synced
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    return returnData;
  }
}
