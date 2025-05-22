class PrescriptionModel {
  final int id;
  final String drugName;
  final String dosage;
  final String duration;
  final String opdTicketNo;

  PrescriptionModel({
    required this.id,
    required this.drugName,
    required this.dosage,
    required this.duration,
    required this.opdTicketNo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'drugName': drugName,
      'dosage': dosage,
      'duration': duration,
      'opdTicketNo': opdTicketNo,
    };
  }

  factory PrescriptionModel.fromMap(Map<String, dynamic> map) {
    return PrescriptionModel(
      id: map['id'],
      drugName: map['drugName'],
      dosage: map['dosage'],
      duration: map['duration'],
      opdTicketNo: map['opdTicketNo'],
    );
  }
}