class DiseaseModel {
  final int id;
  final String name;
  final String color;
  final int version;

  DiseaseModel({
    required this.id,
    required this.name,
    required this.color,
    required this.version,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'version': version,
    };
  }

  factory DiseaseModel.fromMap(Map<String, dynamic> map) {
    return DiseaseModel(
      id: map['id'],
      name: map['name'],
      color: map['color'],
      version: map['version'],
    );
  }
}

class SubDiseaseModel {
  final int id;
  final String name;
  final int disease_id;
  final int version;

  SubDiseaseModel({
    required this.id,
    required this.name,
    required this.disease_id,
    required this.version,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'disease_id': disease_id,
      'version': version,
    };
  }

  factory SubDiseaseModel.fromMap(Map<String, dynamic> map) {
    return SubDiseaseModel(
      id: map['id'],
      name: map['name'],
      disease_id: map['disease_id'],
      version: map['version'],
    );
  }
}