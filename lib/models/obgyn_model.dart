class ObgynModel {
  final String visitType; // Pre-Delivery, Delivery, Post-Delivery
  
  // Pre-Delivery fields
  final bool? ancCardAvailable;
  final int? gestationalAge;
  final String? antenatalVisits; // Now stores ID as string
  final int? fundalHeight;
  final bool? ultrasoundReports;
  final String? highRiskIndicators; // Now stores ID as string
  final int? parity;
  final int? gravida;
  final String? complications;
  final DateTime? expectedDeliveryDate;
  final String? deliveryFacility;
  final bool? referredToHigherTier;
  final String? ttAdvised; // Now stores ID as string instead of boolean
  
  // Delivery fields
  final String? deliveryMode; // Now stores ID as string
  
  // Post-Delivery fields
  final String? postpartumFollowup; // Now stores ID as string
  final List<String> familyPlanningServices;
  final String? babyGender; // Now stores ID as string
  final int? babyWeight;
  
  ObgynModel({
    required this.visitType,
    this.ancCardAvailable,
    this.gestationalAge,
    this.antenatalVisits,
    this.fundalHeight,
    this.ultrasoundReports,
    this.highRiskIndicators,
    this.parity,
    this.gravida,
    this.complications,
    this.expectedDeliveryDate,
    this.deliveryFacility,
    this.referredToHigherTier,
    this.ttAdvised,
    this.deliveryMode,
    this.postpartumFollowup,
    this.familyPlanningServices = const [],
    this.babyGender,
    this.babyWeight,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'visitType': visitType,
      'ancCardAvailable': ancCardAvailable,
      'gestationalAge': gestationalAge,
      'antenatalVisits': antenatalVisits,
      'fundalHeight': fundalHeight,
      'ultrasoundReports': ultrasoundReports,
      'highRiskIndicators': highRiskIndicators,
      'parity': parity,
      'gravida': gravida,
      'complications': complications,
      'expectedDeliveryDate': expectedDeliveryDate?.toIso8601String(),
      'deliveryFacility': deliveryFacility,
      'referredToHigherTier': referredToHigherTier,
      'ttAdvised': ttAdvised,
      'deliveryMode': deliveryMode,
      'postpartumFollowup': postpartumFollowup,
      'familyPlanningServices': familyPlanningServices,
      'babyGender': babyGender,
      'babyWeight': babyWeight,
    };
  }
  
  factory ObgynModel.fromJson(Map<String, dynamic> json) {
    return ObgynModel(
      visitType: json['visitType'] ?? 'Pre-Delivery',
      ancCardAvailable: json['ancCardAvailable'],
      gestationalAge: json['gestationalAge'],
      antenatalVisits: json['antenatalVisits'],
      fundalHeight: json['fundalHeight'],
      ultrasoundReports: json['ultrasoundReports'],
      highRiskIndicators: json['highRiskIndicators'],
      parity: json['parity'],
      gravida: json['gravida'],
      complications: json['complications'],
      expectedDeliveryDate: json['expectedDeliveryDate'] != null 
          ? DateTime.parse(json['expectedDeliveryDate']) 
          : null,
      deliveryFacility: json['deliveryFacility'],
      referredToHigherTier: json['referredToHigherTier'],
      ttAdvised: json['ttAdvised'],
      deliveryMode: json['deliveryMode'],
      postpartumFollowup: json['postpartumFollowup'],
      familyPlanningServices: json['familyPlanningServices'] != null 
          ? List<String>.from(json['familyPlanningServices']) 
          : [],
      babyGender: json['babyGender'],
      babyWeight: json['babyWeight'],
    );
  }
}
