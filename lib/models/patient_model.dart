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
    };
  }

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      patientId: map['id']?.toString() ?? '',
      fullName: map['name']?.toString() ?? '',
      relationCnic: map['cnic']?.toString() ?? '',
      relationType: map['relationType']?.toString() ?? 'own',
      contact: map['phone']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      gender: map['gender']?.toString() ?? '',
      bloodGroup: map['bloodGroup']?.toString() ?? '',
      medicalHistory: map['medicalHistory']?.toString() ?? '',
      immunized: map['immunized'] == 1,
    );
  }
}
