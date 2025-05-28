// API Request Models
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class RegisterRequest {
  final String userName;
  final String email;
  final String designation;
  final String password;
  final String phoneNo;
  final int healthFacilityId;
  final int userRoleId;
  final int isActive;

  RegisterRequest({
    required this.userName,
    required this.email,
    required this.designation,
    required this.password,
    required this.phoneNo,
    required this.healthFacilityId,
    required this.userRoleId,
    required this.isActive
  });

  Map<String, dynamic> toJson() => {
    'userName': userName,
    'email': email,
    'designation': designation,
    'password': password,
    'phoneNo': phoneNo,
    'healthFacilityId': healthFacilityId,
    'userRoleId': userRoleId,
    'isActive': isActive,
  };
}

// API Response Models
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : null,
      statusCode: json['statusCode'],
    );
  }
}

class LoginResponse {
  final String token;
  final List<BloodGroup> bloodGroups;
  final List<DeliveryType> deliveryTypes;
  final List<DeliveryMode> deliveryModes;
  final List<FamilyPlanningService> familyPlanningServices;
  final List<AntenatalVisit> antenatalVisits;
  final List<TTAdvised> tTAdvisedList;
  final List<PregnancyIndicator> pregnancyIndicators;
  final List<PostPartumStatus> postPartumStatuses;
  final List<MedicineDosage> medicineDosages;
  final List<District> districts;
  final List<ApiPatient> patients;
  final List<Disease> diseases;
  final List<SubDisease> subDiseases;
  final List<LabTest> labTests;
  final List<Medicine> medicines;

  LoginResponse({
    required this.token,
    required this.bloodGroups,
    required this.deliveryTypes,
    required this.deliveryModes,
    required this.familyPlanningServices,
    required this.antenatalVisits,
    required this.tTAdvisedList,
    required this.pregnancyIndicators,
    required this.postPartumStatuses,
    required this.medicineDosages,
    required this.districts,
    required this.patients,
    required this.diseases,
    required this.subDiseases,
    required this.labTests,
    required this.medicines,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['Token'] ?? '',
      bloodGroups: (json['bloodGroups'] as List?)?.map((x) => BloodGroup.fromJson(x)).toList() ?? [],
      deliveryTypes: (json['deliveryTypes'] as List?)?.map((x) => DeliveryType.fromJson(x)).toList() ?? [],
      deliveryModes: (json['deliveryModes'] as List?)?.map((x) => DeliveryMode.fromJson(x)).toList() ?? [],
      familyPlanningServices: (json['familyPlanningServices'] as List?)?.map((x) => FamilyPlanningService.fromJson(x)).toList() ?? [],
      antenatalVisits: (json['antenatalVisits'] as List?)?.map((x) => AntenatalVisit.fromJson(x)).toList() ?? [],
      tTAdvisedList: (json['tTAdvisedList'] as List?)?.map((x) => TTAdvised.fromJson(x)).toList() ?? [],
      pregnancyIndicators: (json['pregnancyIndicators'] as List?)?.map((x) => PregnancyIndicator.fromJson(x)).toList() ?? [],
      postPartumStatuses: (json['postPartumStatuses'] as List?)?.map((x) => PostPartumStatus.fromJson(x)).toList() ?? [],
      medicineDosages: (json['medicineDosages'] as List?)?.map((x) => MedicineDosage.fromJson(x)).toList() ?? [],
      districts: (json['districts'] as List?)?.map((x) => District.fromJson(x)).toList() ?? [],
      patients: (json['patients'] as List?)?.map((x) => ApiPatient.fromJson(x)).toList() ?? [],
      diseases: (json['diseases'] as List?)?.map((x) => Disease.fromJson(x)).toList() ?? [],
      subDiseases: (json['subDiseases'] as List?)?.map((x) => SubDisease.fromJson(x)).toList() ?? [],
      labTests: (json['labTests'] as List?)?.map((x) => LabTest.fromJson(x)).toList() ?? [],
      medicines: (json['medicines'] as List?)?.map((x) => Medicine.fromJson(x)).toList() ?? [],
    );
  }

  // Factory method to create LoginResponse from decrypted AppUserData
  factory LoginResponse.fromDecryptedData(dynamic appUserData) {
    return LoginResponse(
      token: appUserData.token ?? '',
      bloodGroups: appUserData.bloodGroups?.map<BloodGroup>((bg) => BloodGroup(
        id: bg.id ?? 0,
        name: bg.name ?? '',
      )).toList() ?? [],
      deliveryTypes: [], // Empty for now - add if available in appUserData
      deliveryModes: [], // Empty for now - add if available in appUserData
      familyPlanningServices: [], // Empty for now - add if available in appUserData
      antenatalVisits: [], // Empty for now - add if available in appUserData
      tTAdvisedList: [], // Empty for now - add if available in appUserData
      pregnancyIndicators: [], // Empty for now - add if available in appUserData
      postPartumStatuses: [], // Empty for now - add if available in appUserData
      medicineDosages: [], // Empty for now - add if available in appUserData
      districts: appUserData.districts?.map<District>((d) => District(
        id: d.id ?? 0,
        name: d.name ?? '',
        version: 1, // Default version
      )).toList() ?? [],
      patients: [], // Empty for now - add if available in appUserData
      diseases: appUserData.diseases?.map<Disease>((d) => Disease(
        id: d.id ?? 0,
        name: d.name ?? '',
        version: 1, // Default version
      )).toList() ?? [],
      subDiseases: [], // Empty for now - add if available in appUserData
      labTests: [], // Empty for now - add if available in appUserData
      medicines: appUserData.medicines?.map<Medicine>((m) => Medicine(
        id: m.id ?? 0,
        name: m.name ?? '',
        code: '', // Default empty code
        version: 1, // Default version
      )).toList() ?? [],
    );
  }
}

// Enum Models (id, name format)
class BloodGroup {
  final int id;
  final String name;

  BloodGroup({required this.id, required this.name});

  factory BloodGroup.fromJson(Map<String, dynamic> json) => BloodGroup(
    id: json['id'],
    name: json['name'],
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class DeliveryType {
  final int id;
  final String name;

  DeliveryType({required this.id, required this.name});

  factory DeliveryType.fromJson(Map<String, dynamic> json) => DeliveryType(
    id: json['id'],
    name: json['name'],
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class DeliveryMode {
  final int id;
  final String name;

  DeliveryMode({required this.id, required this.name});

  factory DeliveryMode.fromJson(Map<String, dynamic> json) => DeliveryMode(
    id: json['id'],
    name: json['name'],
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class FamilyPlanningService {
  final int id;
  final String name;

  FamilyPlanningService({required this.id, required this.name});

  factory FamilyPlanningService.fromJson(Map<String, dynamic> json) => FamilyPlanningService(
    id: json['id'],
    name: json['name'],
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class AntenatalVisit {
  final int id;
  final String name;

  AntenatalVisit({required this.id, required this.name});

  factory AntenatalVisit.fromJson(Map<String, dynamic> json) => AntenatalVisit(
    id: json['id'],
    name: json['name'],
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class TTAdvised {
  final int id;
  final String name;

  TTAdvised({required this.id, required this.name});

  factory TTAdvised.fromJson(Map<String, dynamic> json) => TTAdvised(
    id: json['id'],
    name: json['name'],
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class PregnancyIndicator {
  final int id;
  final String name;

  PregnancyIndicator({required this.id, required this.name});

  factory PregnancyIndicator.fromJson(Map<String, dynamic> json) => PregnancyIndicator(
    id: json['id'],
    name: json['name'],
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class PostPartumStatus {
  final int id;
  final String name;

  PostPartumStatus({required this.id, required this.name});

  factory PostPartumStatus.fromJson(Map<String, dynamic> json) => PostPartumStatus(
    id: json['id'],
    name: json['name'],
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class MedicineDosage {
  final int id;
  final String name;

  MedicineDosage({required this.id, required this.name});

  factory MedicineDosage.fromJson(Map<String, dynamic> json) => MedicineDosage(
    id: json['id'],
    name: json['name'],
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

// Complex Models with version tracking
class District {
  final int id;
  final String name;
  final int version;

  District({required this.id, required this.name, required this.version});

  factory District.fromJson(Map<String, dynamic> json) => District(
    id: json['id'],
    name: json['name'],
    version: json['version'],
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'version': version};
}

class ApiPatient {
  final int id;
  final String name;
  final String address;
  final int version;
  final int age;
  final String bloodGroup;
  final String cnic;
  final String contact;
  final String emergencyContact;
  final String fatherName;
  final String gender;
  final String husbandName;
  final bool immunization;
  final String medicalHistory;
  final String uniqueId;

  ApiPatient({
    required this.id,
    required this.name,
    required this.address,
    required this.version,
    required this.age,
    required this.bloodGroup,
    required this.cnic,
    required this.contact,
    required this.emergencyContact,
    required this.fatherName,
    required this.gender,
    required this.husbandName,
    required this.immunization,
    required this.medicalHistory,
    required this.uniqueId,
  });

  factory ApiPatient.fromJson(Map<String, dynamic> json) => ApiPatient(
    id: json['id'],
    name: json['name'],
    address: json['address'],
    version: json['version'],
    age: json['age'],
    bloodGroup: json['bloodGroup'],
    cnic: json['cnic'],
    contact: json['contact'],
    emergencyContact: json['emergencyContact'],
    fatherName: json['fatherName'],
    gender: json['gender'],
    husbandName: json['husbandName'],
    immunization: json['immunization'],
    medicalHistory: json['medicalHistory'],
    uniqueId: json['uniqueId'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'version': version,
    'age': age,
    'bloodGroup': bloodGroup,
    'cnic': cnic,
    'contact': contact,
    'emergencyContact': emergencyContact,
    'fatherName': fatherName,
    'gender': gender,
    'husbandName': husbandName,
    'immunization': immunization,
    'medicalHistory': medicalHistory,
    'uniqueId': uniqueId,
  };
}

class Disease {
  final int id;
  final String name;
  final int version;

  Disease({required this.id, required this.name, required this.version});

  factory Disease.fromJson(Map<String, dynamic> json) => Disease(
    id: json['id'],
    name: json['name'],
    version: json['version'],
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'version': version};
}

class SubDisease {
  final int id;
  final String name;
  final int version;
  final int diseaseId;

  SubDisease({
    required this.id,
    required this.name,
    required this.version,
    required this.diseaseId,
  });

  factory SubDisease.fromJson(Map<String, dynamic> json) => SubDisease(
    id: json['id'],
    name: json['name'],
    version: json['version'],
    diseaseId: json['diseaseId'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'version': version,
    'diseaseId': diseaseId,
  };
}

class LabTest {
  final int id;
  final String name;
  final int version;

  LabTest({required this.id, required this.name, required this.version});

  factory LabTest.fromJson(Map<String, dynamic> json) => LabTest(
    id: json['id'],
    name: json['name'],
    version: json['version'],
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'version': version};
}

class Medicine {
  final int id;
  final String name;
  final String code;
  final int version;

  Medicine({
    required this.id,
    required this.name,
    required this.code,
    required this.version,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
    id: json['id'],
    name: json['name'],
    code: json['code'],
    version: json['version'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'version': version,
  };
}

class FormSubmissionModel {
  final List<PatientFormData> patients;
  final List<OpdFormData> opdVisits;
  final int hospitalId;

  FormSubmissionModel({
    required this.patients,
    required this.opdVisits,
    required this.hospitalId,
  });

  Map<String, dynamic> toJson() {
    return {
      'patients': patients.map((p) => p.toJson()).toList(),
      'opdVisits': opdVisits.map((o) => o.toJson()).toList(),
      'hospitalId': hospitalId,
    };
  }
}

class PatientFormData {
  final String patientId;
  final String fullName;
  final String relationCnic;
  final String relationType;
  final String contact;
  final String address;
  final int gender;
  final int bloodGroup;
  final String medicalHistory;
  final bool immunized;

  PatientFormData({
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

  Map<String, dynamic> toJson() => {
    'patientId': patientId,
    'fullName': fullName,
    'relationCnic': relationCnic,
    'relationType': relationType,
    'contact': contact,
    'address': address,
    'gender': gender,
    'bloodGroup': bloodGroup,
    'medicalHistory': medicalHistory,
    'immunized': immunized,
  };
}

class OpdFormData {
  final String opdTicketNo;
  final String patientId;
  final String visitDateTime;
  final String reasonForVisit;
  final bool isFollowUp;
  final List<String> diagnosis;
  final List<String> prescriptions;
  final List<String> labTests;
  final bool isReferred;
  final bool followUpAdvised;
  final int? followUpDays;
  final bool fpAdvised;
  final List<String> fpList;
  final String? obgynData;

  OpdFormData({
    required this.opdTicketNo,
    required this.patientId,
    required this.visitDateTime,
    required this.reasonForVisit,
    required this.isFollowUp,
    required this.diagnosis,
    required this.prescriptions,
    required this.labTests,
    required this.isReferred,
    required this.followUpAdvised,
    this.followUpDays,
    required this.fpAdvised,
    required this.fpList,
    this.obgynData,
  });

  Map<String, dynamic> toJson() => {
    'opdTicketNo': opdTicketNo,
    'patientId': patientId,
    'visitDateTime': visitDateTime,
    'reasonForVisit': reasonForVisit,
    'isFollowUp': isFollowUp,
    'diagnosis': diagnosis,
    'prescriptions': prescriptions,
    'labTests': labTests,
    'isReferred': isReferred,
    'followUpAdvised': followUpAdvised,
    'followUpDays': followUpDays,
    'fpAdvised': fpAdvised,
    'fpList': fpList,
    'obgynData': obgynData,
  };
}
