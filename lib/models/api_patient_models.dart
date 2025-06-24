// API Patient Models matching the exact API specification

class ApiPatientModel {
  final int id;
  final String uniqueId;
  final String name;
  final String fatherName;
  final String? husbandName;
  final int ageGroup; // Changed from age to ageGroup to match API
  final int relationType;
  final int gender; // Changed to int to match API response
  final String cnic;
  final int version;
  final String contact;
  /*final String? emergencyContact; // Make optional since not in API response
  final String address;
  final String? medicalHistory; // Make optional since not in API response
  final bool? immunization; // Make optional since not in API response
  final int? bloodGroup; // Make optional since not in API response*/
  final int? healthFacilityId; // Add field from API response
  final String? healthFacility; // Add field from API response

  ApiPatientModel({
    required this.id,
    required this.uniqueId,
    required this.name,
    required this.fatherName,
    this.husbandName,
    required this.ageGroup,
    required this.relationType,
    required this.gender,
    required this.cnic,
    required this.version,
    required this.contact,
    /*this.emergencyContact,
    required this.address,
    this.medicalHistory,
    this.immunization,
    this.bloodGroup,*/
    this.healthFacilityId,
    this.healthFacility,
  });

  factory ApiPatientModel.fromJson(Map<String, dynamic> json) {
    return ApiPatientModel(
      id: json['id'] ?? 0,
      uniqueId: json['uniqueId'] ?? '',
      name: json['name'] ?? '',
      fatherName: json['fatherName'] ?? '',
      husbandName: json['husbandName'],
      ageGroup: json['ageGroup'] ?? 3, // Default to age group 3 (12-59 months)
      relationType: json['relationType'] ?? 1,
      gender: json['gender'] ?? 1, // Default to 1 (Male) if not provided
      cnic: json['cnic'] ?? '',
      version: json['version'] ?? 1,
      contact: json['contact'] ?? '',
      /*emergencyContact: json['emergencyContact'],
      address: json['address'] ?? '',
      medicalHistory: json['medicalHistory'],
      immunization: json['immunization'],
      bloodGroup: json['bloodGroup'],*/
      healthFacilityId: json['healthFacilityId'],
      healthFacility: json['healthFacility'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uniqueId': uniqueId,
      'name': name,
      'fatherName': fatherName,
      'husbandName': husbandName,
      'ageGroup': ageGroup,
      'gender': gender,
      'cnic': cnic,
      'relationType': relationType,
      'version': version,
      'contact': contact,
      /*'emergencyContact': emergencyContact,
      'address': address,
      'medicalHistory': medicalHistory,
      'immunization': immunization,
      'bloodGroup': bloodGroup,*/
      'healthFacilityId': healthFacilityId,
      'healthFacility': healthFacility,
    };
  }
}

class ApiOPDDetailsModel {
  final int id;
  final String ticketNo;
  final String visitDateTime;
  final bool reasonForVisit;
  final bool followUps;
  final bool followUpsAdvised;
  final bool fpAdvised;
  final bool referred;
  final String prescription;
  final int patientId;
  final String subDiseases;
  final String labTests;
  final String familyPlannings;
  final String medicineDosages;

  ApiOPDDetailsModel({
    required this.id,
    required this.ticketNo,
    required this.visitDateTime,
    required this.reasonForVisit,
    required this.followUps,
    required this.followUpsAdvised,
    required this.fpAdvised,
    required this.referred,
    required this.prescription,
    required this.patientId,
    required this.subDiseases,
    required this.labTests,
    required this.familyPlannings,
    required this.medicineDosages,
  });

  factory ApiOPDDetailsModel.fromJson(Map<String, dynamic> json) {
    return ApiOPDDetailsModel(
      id: json['id'] ?? 0,
      ticketNo: json['ticketNo'] ?? '',
      visitDateTime: json['visitDateTime'] ?? '',
      reasonForVisit: json['reasonForVisit'] ?? false,
      followUps: json['followUps'] ?? false,
      followUpsAdvised: json['followUpsAdvised'] ?? false,
      fpAdvised: json['fpAdvised'] ?? false,
      referred: json['referred'] ?? false,
      prescription: json['prescription'] ?? '',
      patientId: json['patientId'] ?? 0,
      subDiseases: json['subDiseases'] ?? '',
      labTests: json['labTests'] ?? '',
      familyPlannings: json['familyPlannings'] ?? '',
      medicineDosages: json['medicineDosages'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketNo': ticketNo,
      'visitDateTime': visitDateTime,
      'reasonForVisit': reasonForVisit,
      'followUps': followUps,
      'followUpsAdvised': followUpsAdvised,
      'fpAdvised': fpAdvised,
      'referred': referred,
      'prescription': prescription,
      'patientId': patientId,
      'subDiseases': subDiseases,
      'labTests': labTests,
      'familyPlannings': familyPlannings,
      'medicineDosages': medicineDosages,
    };
  }
}

class ApiOBGYNModel {
  final int id;
  final bool ancCardAvaliable;
  final int gestationalAge;
  final int antenatalVists;
  final int pregnancyIndicator;
  final int parity;
  final int gravida;
  final int complications;
  final int ttAdvised;
  final String ttAdvisedDateTime;
  final bool referredHigherTierFacility;
  final String deliveryPlanning;
  final int deliveryType;
  final int deliveryMode;
  final int familyPlanningService;
  final int postPartum;

  ApiOBGYNModel({
    required this.id,
    required this.ancCardAvaliable,
    required this.gestationalAge,
    required this.antenatalVists,
    required this.pregnancyIndicator,
    required this.parity,
    required this.gravida,
    required this.complications,
    required this.ttAdvised,
    required this.ttAdvisedDateTime,
    required this.referredHigherTierFacility,
    required this.deliveryPlanning,
    required this.deliveryType,
    required this.deliveryMode,
    required this.familyPlanningService,
    required this.postPartum,
  });

  factory ApiOBGYNModel.fromJson(Map<String, dynamic> json) {
    return ApiOBGYNModel(
      id: json['id'] ?? 0,
      ancCardAvaliable: json['ancCardAvaliable'] ?? false,
      gestationalAge: json['gestationalAge'] ?? 0,
      antenatalVists: json['antenatalVists'] ?? 0,
      pregnancyIndicator: json['pregnancyIndicator'] ?? 0,
      parity: json['parity'] ?? 0,
      gravida: json['gravida'] ?? 0,
      complications: json['complications'] ?? 0,
      ttAdvised: json['ttAdvised'] ?? 0,
      ttAdvisedDateTime: json['ttAdvisedDateTime'] ?? '',
      referredHigherTierFacility: json['referredHigherTierFacility'] ?? false,
      deliveryPlanning: json['deliveryPlanning'] ?? '',
      deliveryType: json['deliveryType'] ?? 0,
      deliveryMode: json['deliveryMode'] ?? 0,
      familyPlanningService: json['familyPlanningService'] ?? 0,
      postPartum: json['postPartum'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ancCardAvaliable': ancCardAvaliable,
      'gestationalAge': gestationalAge,
      'antenatalVists': antenatalVists,
      'pregnancyIndicator': pregnancyIndicator,
      'parity': parity,
      'gravida': gravida,
      'complications': complications,
      'ttAdvised': ttAdvised,
      'ttAdvisedDateTime': ttAdvisedDateTime,
      'referredHigherTierFacility': referredHigherTierFacility,
      'deliveryPlanning': deliveryPlanning,
      'deliveryType': deliveryType,
      'deliveryMode': deliveryMode,
      'familyPlanningService': familyPlanningService,
      'postPartum': postPartum,
    };
  }
}
