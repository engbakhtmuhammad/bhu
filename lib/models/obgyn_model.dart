class ObgynModel {
  final String visitType; // Pre-Delivery, Delivery, Post-Delivery
  
  // Pre-Delivery fields
  final bool? ancCardAvailable;
  final int? gestationalAge;
  final String? antenatalVisits;
  final int? fundalHeight;
  final bool? ultrasoundReports;
  final String? highRiskIndicators;
  final int? parity;
  final int? gravida;
  final String? complications;
  final DateTime? expectedDeliveryDate;
  final String? deliveryFacility;
  final bool? referredToHigherTier;
  final bool? ttAdvised;
  
  // Delivery fields
  final String? deliveryMode;
  
  // Post-Delivery fields
  final String? postpartumFollowup;
  final List<String> familyPlanningServices;

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
  });

  Map<String, dynamic> toMap() {
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
      'familyPlanningServices': familyPlanningServices.join(','),
    };
  }

  factory ObgynModel.fromMap(Map<String, dynamic> map) {
    return ObgynModel(
      visitType: map['visitType'] ?? '',
      ancCardAvailable: map['ancCardAvailable'],
      gestationalAge: map['gestationalAge'],
      antenatalVisits: map['antenatalVisits'],
      fundalHeight: map['fundalHeight'],
      ultrasoundReports: map['ultrasoundReports'],
      highRiskIndicators: map['highRiskIndicators'],
      parity: map['parity'],
      gravida: map['gravida'],
      complications: map['complications'],
      expectedDeliveryDate: map['expectedDeliveryDate'] != null 
          ? DateTime.parse(map['expectedDeliveryDate']) 
          : null,
      deliveryFacility: map['deliveryFacility'],
      referredToHigherTier: map['referredToHigherTier'],
      ttAdvised: map['ttAdvised'],
      deliveryMode: map['deliveryMode'],
      postpartumFollowup: map['postpartumFollowup'],
      familyPlanningServices: map['familyPlanningServices']?.split(',') ?? [],
    );
  }
}