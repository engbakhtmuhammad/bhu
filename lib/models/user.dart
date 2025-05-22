

class UserModel {
  String? id;
  String? name;
  String? address;
  String? userType;
  bool? isActive;
  String? email;
  String? phone;
  String? image;
  String? bio;

  UserModel({
    this.id,
    this.name,
    this.address,
    this.userType,
    this.isActive,
    this.email,this.phone,
    this.image,this.bio
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      name: json["name"],
      address: json["address"],
      userType: json["userType"],
      email: json["email"],
      isActive: json["isActive"],
      phone: json["phone"],
      image: json["image"],
      bio: json["bio"],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["id"] = id;
    data["name"] = name;
    data["address"] = address;
    data["userType"] = userType;
    data["email"] = email;
    data["isActive"]=isActive;
    data["phone"]=phone;
    data["image"]=image;
    data["bio"]=bio;
    return data;
  }
}
