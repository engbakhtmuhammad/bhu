// Model for decrypted app user data
class AppUserData {
  final String? token;
  final UserInfo? userInfo;
  final List<District>? districts;
  final List<Disease>? diseases;
  final List<Medicine>? medicines;
  final List<BloodGroup>? bloodGroups;
  final List<UserRole>? userRoles;
  final List<HealthFacility>? healthFacilities;

  AppUserData({
    this.token,
    this.userInfo,
    this.districts,
    this.diseases,
    this.medicines,
    this.bloodGroups,
    this.userRoles,
    this.healthFacilities,
  });

  factory AppUserData.fromJson(Map<String, dynamic> json) {
    return AppUserData(
      token: json['token'],
      userInfo: json['userInfo'] != null ? UserInfo.fromJson(json['userInfo']) : null,
      districts: json['districts'] != null 
          ? (json['districts'] as List).map((e) => District.fromJson(e)).toList()
          : null,
      diseases: json['diseases'] != null
          ? (json['diseases'] as List).map((e) => Disease.fromJson(e)).toList()
          : null,
      medicines: json['medicines'] != null
          ? (json['medicines'] as List).map((e) => Medicine.fromJson(e)).toList()
          : null,
      bloodGroups: json['bloodGroups'] != null
          ? (json['bloodGroups'] as List).map((e) => BloodGroup.fromJson(e)).toList()
          : null,
      userRoles: json['userRoles'] != null
          ? (json['userRoles'] as List).map((e) => UserRole.fromJson(e)).toList()
          : null,
      healthFacilities: json['healthFacilities'] != null
          ? (json['healthFacilities'] as List).map((e) => HealthFacility.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'userInfo': userInfo?.toJson(),
      'districts': districts?.map((e) => e.toJson()).toList(),
      'diseases': diseases?.map((e) => e.toJson()).toList(),
      'medicines': medicines?.map((e) => e.toJson()).toList(),
      'bloodGroups': bloodGroups?.map((e) => e.toJson()).toList(),
      'userRoles': userRoles?.map((e) => e.toJson()).toList(),
      'healthFacilities': healthFacilities?.map((e) => e.toJson()).toList(),
    };
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
  final String? category;

  Disease({this.id, this.name, this.category});

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      id: json['id'],
      name: json['name'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
    };
  }
}

class Medicine {
  final int? id;
  final String? name;
  final String? dosage;

  Medicine({this.id, this.name, this.dosage});

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
    };
  }
}

class BloodGroup {
  final int? id;
  final String? name;

  BloodGroup({this.id, this.name});

  factory BloodGroup.fromJson(Map<String, dynamic> json) {
    return BloodGroup(
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

class UserRole {
  final int? id;
  final String? name;

  UserRole({this.id, this.name});

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
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
