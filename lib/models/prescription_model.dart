class PrescriptionModel {
  final int? id; // Made nullable for auto-increment
  final String drugName;
  final String dosage;
  final String duration;
  final String opdTicketNo;

  PrescriptionModel({
    this.id, // Now nullable
    required this.drugName,
    required this.dosage,
    required this.duration,
    required this.opdTicketNo,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'drugName': drugName,
      'dosage': dosage,
      'duration': duration,
      'opdTicketNo': opdTicketNo,
    };
    
    // Only include id if it's not null (for updates)
    if (id != null) {
      map['id'] = id! as String;
    }
    
    return map;
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