class PrescriptionModel {
  final int? id;
  final String drugName;
  final String dosage;
  final String duration;
  final String opdTicketNo;
  final int quantity;

  PrescriptionModel({
    this.id,
    required this.drugName,
    this.dosage = '',
    this.duration = '',
    required this.opdTicketNo,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'drugName': drugName,
      'dosage': dosage,
      'duration': duration,
      'opdTicketNo': opdTicketNo,
      'quantity': quantity,
    };
    
  }

  factory PrescriptionModel.fromMap(Map<String, dynamic> map) {
    return PrescriptionModel(
      id: map['id'],
      drugName: map['drugName'],
      dosage: map['dosage'],
      duration: map['duration'],
      opdTicketNo: map['opdTicketNo'],
      quantity: map['quantity'] ?? 1,
    );
  }
}
