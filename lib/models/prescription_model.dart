class PrescriptionModel {
  final int? id;
  final String drugName;
  final String dosage;
  final String duration;
  final String opdTicketNo;
  final int quantity;
  final String? createdAt;
  final String? updatedAt;

  PrescriptionModel({
    this.id,
    required this.drugName,
    this.dosage = '',
    this.duration = '',
    required this.opdTicketNo,
    this.quantity = 1,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'drugName': drugName,
      'dosage': dosage,
      'duration': duration,
      'opdTicketNo': opdTicketNo,
      'quantity': quantity,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory PrescriptionModel.fromMap(Map<String, dynamic> map) {
    return PrescriptionModel(
      id: map['id'],
      drugName: map['drugName'] ?? map['medicine'] ?? '',
      dosage: map['dosage'] ?? '',
      duration: map['duration'] ?? '',
      opdTicketNo: map['opdTicketNo'] ?? map['opdTicketNo'] ?? '',
      quantity: map['quantity'] ?? 1,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}
