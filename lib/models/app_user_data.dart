// Model for decrypted app user data
class AppUserData {
  final UserInfo? userInfo;
  final String? token;
  final List<Disease>? diseases;
  final List<SubDisease>? subDiseases;
  final List<Medicine>? medicines;
  final List<DeliveryType>? deliveryTypes;
  final List<DeliveryMode>? deliveryModes;
  final List<AntenatalVisit>? antenatalVisits;
  final List<TTAdvised>? tTAdvisedList;
  final List<PregnancyIndicator>? pregnancyIndicators;
  final List<PostPartumStatus>? postPartumStatuses;
  final List<FamilyPlanningService>? familyPlanning;
  final List<RelationType>? relationTypes; // Add relation types
  final List<Gender>? genders; // Add genders field
  final List<dynamic>? patients; // Add this field for patients

  AppUserData({
    this.userInfo,
    this.token,
    this.diseases,
    this.subDiseases,
    this.medicines,
    this.deliveryTypes,
    this.deliveryModes,
    this.antenatalVisits,
    this.tTAdvisedList,
    this.pregnancyIndicators,
    this.postPartumStatuses,
    this.familyPlanning,
    this.relationTypes, // Include relation types in constructor
    this.genders, // Include genders in constructor
    this.patients, // Include in constructor
  });

  factory AppUserData.fromJson(Map<String, dynamic> json) {
    var returnData = AppUserData(
      userInfo:
      json['userInfo'] != null ? UserInfo.fromJson(json['userInfo']) : null,
      token: json['token'],
      diseases: json['diseases'] != null
          ? List<Disease>.from(json['diseases'].map((x) => Disease.fromJson(x)))
          : null,
      subDiseases: json['subDiseases'] != null
          ? List<SubDisease>.from(
          json['subDiseases'].map((x) => SubDisease.fromJson(x)))
          : null,
      medicines: json['medicines'] != null
          ? List<Medicine>.from(
          json['medicines'].map((x) => Medicine.fromJson(x)))
          : null,
      deliveryTypes: json['deliveryTypes'] != null
          ? List<DeliveryType>.from(
          json['deliveryTypes'].map((x) => DeliveryType.fromJson(x)))
          : null,
      deliveryModes: json['deliveryModes'] != null
          ? List<DeliveryMode>.from(
          json['deliveryModes'].map((x) => DeliveryMode.fromJson(x)))
          : null,
      antenatalVisits: json['antenatalVisits'] != null
          ? List<AntenatalVisit>.from(
          json['antenatalVisits'].map((x) => AntenatalVisit.fromJson(x)))
          : null,
      tTAdvisedList: json['tTAdvisedList'] != null
          ? List<TTAdvised>.from(
          json['tTAdvisedList'].map((x) => TTAdvised.fromJson(x)))
          : null,
      pregnancyIndicators: json['pregnancyIndicators'] != null
          ? List<PregnancyIndicator>.from(json['pregnancyIndicators']
          .map((x) => PregnancyIndicator.fromJson(x)))
          : null,
      postPartumStatuses: json['postPartumStatuses'] != null
          ? List<PostPartumStatus>.from(json['postPartumStatuses']
          .map((x) => PostPartumStatus.fromJson(x)))
          : null,
      familyPlanning: json['familyPlanning'] != null
          ? List<FamilyPlanningService>.from(json['familyPlanning']
          .map((x) => FamilyPlanningService.fromJson(x)))
          : null,
      relationTypes: json['relationType'] != null
          ? List<RelationType>.from(
          json['relationType'].map((x) => RelationType.fromJson(x)))
          : null,
      genders: json['gender'] != null
          ? List<Gender>.from(
          json['gender'].map((x) => Gender.fromJson(x)))
          : null,
      patients: json['patients'] != null
          ? List<dynamic>.from(json['patients'])
          : null,
    );
    return returnData;
  }
}

class UserInfo {
  final int? id;
  final String? userName;
  final String? email;
  final String? designation;
  final String? phoneNo;
  final int? healthFacilityId;
  final int? userRoleId;
  final int? isActive;

  UserInfo({
    this.id,
    this.userName,
    this.email,
    this.designation,
    this.phoneNo,
    this.healthFacilityId,
    this.userRoleId,
    this.isActive,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'],
      userName: json['userName'],
      email: json['email'],
      designation: json['designation'],
      phoneNo: json['phoneNo'],
      healthFacilityId: json['healthFacilityId'],
      userRoleId: json['userRoleId'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'email': email,
      'designation': designation,
      'phoneNo': phoneNo,
      'healthFacilityId': healthFacilityId,
      'userRoleId': userRoleId,
      'isActive': isActive,
    };
  }
}

class District {
  final int? id;
  final String? name;

  District({this.id, this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Disease {
  final int? id;
  final String? name;
  final String? color;
  final String? category;

  Disease({this.id, this.name, this.color, this.category});

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'category': category,
    };
  }
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

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'],
      name: json['name'],
      code: json['code'] ?? '',
      version: json['version'] ?? 0,
    );
  }
}

class BloodGroup {
  final int id;
  final String name;

  BloodGroup({required this.id, required this.name});

  factory BloodGroup.fromJson(Map<String, dynamic> json) {
    return BloodGroup(
      id: json['id'],
      name: json['name'],
    );
  }
}

class DeliveryType {
  final int id;
  final String name;

  DeliveryType({required this.id, required this.name});

  factory DeliveryType.fromJson(Map<String, dynamic> json) {
    return DeliveryType(
      id: json['id'],
      name: json['name'],
    );
  }
}

class DeliveryMode {
  final int id;
  final String name;

  DeliveryMode({required this.id, required this.name});

  factory DeliveryMode.fromJson(Map<String, dynamic> json) {
    return DeliveryMode(
      id: json['id'],
      name: json['name'],
    );
  }
}

class AntenatalVisit {
  final int id;
  final String name;

  AntenatalVisit({required this.id, required this.name});

  factory AntenatalVisit.fromJson(Map<String, dynamic> json) {
    return AntenatalVisit(
      id: json['id'],
      name: json['name'],
    );
  }
}

class TTAdvised {
  final int id;
  final String name;

  TTAdvised({required this.id, required this.name});

  factory TTAdvised.fromJson(Map<String, dynamic> json) {
    return TTAdvised(
      id: json['id'],
      name: json['name'],
    );
  }
}

class PregnancyIndicator {
  final int id;
  final String name;

  PregnancyIndicator({required this.id, required this.name});

  factory PregnancyIndicator.fromJson(Map<String, dynamic> json) {
    return PregnancyIndicator(
      id: json['id'],
      name: json['name'],
    );
  }
}

class PostPartumStatus {
  final int id;
  final String name;

  PostPartumStatus({required this.id, required this.name});

  factory PostPartumStatus.fromJson(Map<String, dynamic> json) {
    return PostPartumStatus(
      id: json['id'],
      name: json['name'],
    );
  }
}

class MedicineDosage {
  final int id;
  final String name;

  MedicineDosage({required this.id, required this.name});

  factory MedicineDosage.fromJson(Map<String, dynamic> json) {
    return MedicineDosage(
      id: json['id'],
      name: json['name'],
    );
  }
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

  factory SubDisease.fromJson(Map<String, dynamic> json) {
    return SubDisease(
      id: json['id'],
      name: json['name'],
      version: json['version'] ?? 0,
      diseaseId: json['diseaseId'],
    );
  }
}

class HealthFacility {
  final int? id;
  final String? name;
  final String? type;

  HealthFacility({this.id, this.name, this.type});

  factory HealthFacility.fromJson(Map<String, dynamic> json) {
    return HealthFacility(
      id: json['id'],
      name: json['name'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
    };
  }
}

class FamilyPlanningService {
  final int id;
  final String name;

  FamilyPlanningService({required this.id, required this.name});

  factory FamilyPlanningService.fromJson(Map<String, dynamic> json) {
    return FamilyPlanningService(
      id: json['id'],
      name: json['name'],
    );
  }
}

class RelationType {
  final int id;
  final String name;

  RelationType({required this.id, required this.name});

  factory RelationType.fromJson(Map<String, dynamic> json) {
    return RelationType(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Gender {
  final int id;
  final String name;

  Gender({required this.id, required this.name});

  factory Gender.fromJson(Map<String, dynamic> json) {
    return Gender(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
