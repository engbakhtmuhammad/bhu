class OpdVisitModel {
  final String opdTicketNo;
  final String patientId;
  final DateTime visitDateTime;
  final String reasonForVisit; // General OPD/OBGYN
  final bool isFollowUp;
  final List<String> diagnosis;
  final List<String> prescriptions;
  final List<String> labTests;
  final bool isReferred;
  final bool followUpAdvised;
  final int? followUpDays;
  final bool fpAdvised;
  final List<String> fpList;
  final String? obgynData; // JSON string for OBGYN data

  OpdVisitModel({
    required this.opdTicketNo,
    required this.patientId,
    required this.visitDateTime,
    required this.reasonForVisit,
    required this.isFollowUp,
    required this.diagnosis,
    required this.prescriptions,
    required this.labTests,
    required this.isReferred,
    required this.followUpAdvised,
    this.followUpDays,
    required this.fpAdvised,
    required this.fpList,
    this.obgynData,
  });

  Map<String, dynamic> toMap() {
    return {
      'opdTicketNo': opdTicketNo,
      'patientId': patientId,
      'visitDateTime': visitDateTime.toIso8601String(),
      'reasonForVisit': reasonForVisit,
      'isFollowUp': isFollowUp ? 1 : 0,
      'diagnosis': diagnosis.join(','),
      'prescriptions': prescriptions.join(','),
      'labTests': labTests.join(','),
      'isReferred': isReferred ? 1 : 0,
      'followUpAdvised': followUpAdvised ? 1 : 0,
      'followUpDays': followUpDays,
      'fpAdvised': fpAdvised ? 1 : 0,
      'fpList': fpList.join(','),
      'obgynData': obgynData,
    };
  }

  factory OpdVisitModel.fromMap(Map<String, dynamic> map) {
    return OpdVisitModel(
      opdTicketNo: map['opdTicketNo'] ?? '',
      patientId: map['patientId'] ?? '',
      visitDateTime: DateTime.parse(map['visitDateTime']),
      reasonForVisit: map['reasonForVisit'] ?? '',
      isFollowUp: map['isFollowUp'] == 1,
      diagnosis: map['diagnosis']?.split(',') ?? [],
      prescriptions: map['prescriptions']?.split(',') ?? [],
      labTests: map['labTests']?.split(',') ?? [],
      isReferred: map['isReferred'] == 1,
      followUpAdvised: map['followUpAdvised'] == 1,
      followUpDays: map['followUpDays'],
      fpAdvised: map['fpAdvised'] == 1,
      fpList: map['fpList']?.split(',') ?? [],
      obgynData: map['obgynData'],
    );
  }
}
