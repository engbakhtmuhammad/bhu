class DiseaseModel {
  final int id;
  final String name;
  final String category;
  final int categoryId;

  DiseaseModel({
    required this.id,
    required this.name,
    required this.category,
    required this.categoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'categoryId': categoryId,
    };
  }

  factory DiseaseModel.fromMap(Map<String, dynamic> map) {
    return DiseaseModel(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      categoryId: map['categoryId'],
    );
  }
}