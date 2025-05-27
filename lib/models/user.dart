
class UserModel {
  String? id;
  String? userName;
  String? email;
  String? designation;
  String? phoneNo;
  int? healthFacilityId;
  int? userRoleId;
  bool? isActive;
  String? createdDate;
  String? updatedDate;

  // Additional fields for local storage
  String? address;
  String? image;
  String? bio;

  UserModel({
    this.id,
    this.userName,
    this.email,
    this.designation,
    this.phoneNo,
    this.healthFacilityId,
    this.userRoleId,
    this.isActive,
    this.createdDate,
    this.updatedDate,
    this.address,
    this.image,
    this.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"]?.toString(),
      userName: json["userName"] ?? json["name"],
      email: json["email"],
      designation: json["designation"] ?? json["userType"],
      phoneNo: json["phoneNo"] ?? json["phone"],
      healthFacilityId: json["healthFacilityId"],
      userRoleId: json["userRoleId"],
      isActive: json["isActive"],
      createdDate: json["createdDate"],
      updatedDate: json["updatedDate"],
      address: json["address"],
      image: json["image"],
      bio: json["bio"],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["userName"] = userName;
    data["email"] = email;
    data["designation"] = designation;
    data["phoneNo"] = phoneNo;
    data["healthFacilityId"] = healthFacilityId;
    data["userRoleId"] = userRoleId;
    data["isActive"] = isActive;
    data["createdDate"] = createdDate;
    data["updatedDate"] = updatedDate;
    data["address"] = address;
    data["image"] = image;
    data["bio"] = bio;
    return data;
  }

  // For API registration request
  Map<String, dynamic> toRegistrationJson() {
    return {
      "userName": userName,
      "email": email,
      "designation": designation,
      "password": "", // This will be set separately
      "phoneNo": phoneNo,
      "healthFacilityId": healthFacilityId ?? 1,
      "userRoleId": userRoleId ?? 2,
    };
  }

  // Getters for backward compatibility
  String? get name => userName;
  String? get phone => phoneNo;
  String? get userType => designation;
}
