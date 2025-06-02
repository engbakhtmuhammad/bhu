class PatientModel {
  final String patientId;
  final String fullName;
  final String relationCnic;
  final String relationType; // own, father, husband
  final String contact;
  final String address;
  final String gender;
  final String bloodGroup;
  final String medicalHistory;
  final bool immunized;
  final int? districtId;
  final bool isSynced;
  final String? createdAt;
  final String? updatedAt;

  PatientModel({
    required this.patientId,
    required this.fullName,
    required this.relationCnic,
    required this.relationType,
    required this.contact,
    required this.address,
    required this.gender,
    required this.bloodGroup,
    required this.medicalHistory,
    required this.immunized,
    this.districtId,
    this.isSynced = false,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'fullName': fullName,
      'relationCnic': relationCnic,
      'relationType': relationType,
      'contact': contact,
      'address': address,
      'gender': gender,
      'bloodGroup': bloodGroup,
      'medicalHistory': medicalHistory,
      'immunized': immunized ? 1 : 0,
      'district_id': districtId,
      'is_synced': isSynced ? 1 : 0,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
      'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      patientId: map['patientId'] ?? '',
      fullName: map['fullName'] ?? '',
      relationCnic: map['relationCnic'] ?? '',
      relationType: map['relationType'] ?? '',
      contact: map['contact'] ?? '',
      address: map['address'] ?? '',
      gender: map['gender'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      medicalHistory: map['medicalHistory'] ?? '',
      immunized: map['immunized'] == 1,
      districtId: map['district_id'],
      isSynced: map['is_synced'] == 1,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}
