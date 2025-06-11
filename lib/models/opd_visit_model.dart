import 'dart:convert';

class OpdVisitModel {
  final String opdTicketNo;
  final String patientId;
  final DateTime visitDateTime;
  final bool reasonForVisit; // true for General OPD, false for OBGYN
  final bool isFollowUp;
  final List<int> diagnosisIds;     // Store IDs
  final List<String> diagnosisNames; // Store names for display
  final List<Map<String, dynamic>> prescriptions;
  final List<int> labTestIds;       // Store IDs
  final List<String> labTestNames;  // Store names for display
  final bool isReferred;
  final bool followUpAdvised;
  final int? followUpDays;
  final bool fpAdvised;
  final List<int> fpIds;           // Store IDs
  final List<String> fpNames;      // Store names for display
  final String? obgynData;
  final int? pregnancyIndicatorId;
  final int? postpartumStatusId;
  
  OpdVisitModel({
    required this.opdTicketNo,
    required this.patientId,
    required this.visitDateTime,
    required this.reasonForVisit,
    required this.isFollowUp,
    required this.diagnosisIds,
    required this.diagnosisNames,
    required this.prescriptions,
    required this.labTestIds,
    required this.labTestNames,
    required this.isReferred,
    required this.followUpAdvised,
    this.followUpDays,
    required this.fpAdvised,
    required this.fpIds,
    required this.fpNames,
    this.obgynData,
    this.pregnancyIndicatorId,
    this.postpartumStatusId,
  });

  Map<String, dynamic> toMap() {
    return {
      'opdTicketNo': opdTicketNo,
      'patientId': patientId,
      'visitDateTime': visitDateTime.toIso8601String(),
      'reasonForVisit': reasonForVisit,
      'isFollowUp': isFollowUp ? 1 : 0,
      'diagnosis': diagnosisIds.join(','),
      'prescriptions': jsonEncode(prescriptions), // Encode prescriptions as JSON
      'labTests': labTestIds.join(','),
      'isReferred': isReferred ? 1 : 0,
      'followUpAdvised': followUpAdvised ? 1 : 0,
      'followUpDays': followUpDays,
      'fpAdvised': fpAdvised ? 1 : 0,
      'fpList': fpIds.join(','),
      'obgynData': obgynData,
      'pregnancy_indicator_id': pregnancyIndicatorId,
      'postpartum_status_id': postpartumStatusId,
    };
  }

  factory OpdVisitModel.fromMap(Map<String, dynamic> map) {
    List<int> diagnosisIds = [];
    List<String> diagnosisNames = [];
    List<int> labTestIds = [];
    List<String> labTestNames = [];
    List<int> fpIds = [];
    List<String> fpNames = [];
    List<Map<String, dynamic>> prescriptions = [];
    
    // Parse diagnosis IDs from JSON
    if (map['diagnosis'] != null) {
      try {
        final List<dynamic> diagnosisList = json.decode(map['diagnosis']);
        diagnosisIds = diagnosisList.map((id) => id as int).toList();
      } catch (e) {
        print('Error parsing diagnosis IDs: $e');
      }
    }
    
    // Parse diagnosis names
    if (map['diagnosis_names'] != null) {
      diagnosisNames = (map['diagnosis_names'] as String).split(',')
          .where((name) => name.isNotEmpty)
          .toList();
    }
    
    // Parse lab test IDs from JSON
    if (map['lab_tests'] != null) {
      try {
        final List<dynamic> labTestsList = json.decode(map['lab_tests']);
        labTestIds = labTestsList.map((id) => id as int).toList();
      } catch (e) {
        print('Error parsing lab test IDs: $e');
      }
    }
    
    // Parse lab test names
    if (map['lab_test_names'] != null) {
      labTestNames = (map['lab_test_names'] as String).split(',')
          .where((name) => name.isNotEmpty)
          .toList();
    }
    
    // Parse FP IDs from JSON
    if (map['fp_list'] != null) {
      try {
        final List<dynamic> fpList = json.decode(map['fp_list']);
        fpIds = fpList.map((id) => id as int).toList();
      } catch (e) {
        print('Error parsing FP IDs: $e');
      }
    }
    
    // Parse FP names
    if (map['fp_names'] != null) {
      fpNames = (map['fp_names'] as String).split(',')
          .where((name) => name.isNotEmpty)
          .toList();
    }
    
    // Parse prescriptions
    if (map['treatment'] != null) {
      try {
        final List<dynamic> prescList = json.decode(map['treatment']);
        prescriptions = prescList.map((p) => p as Map<String, dynamic>).toList();
      } catch (e) {
        print('Error parsing prescriptions: $e');
        prescriptions = [];
      }
    }
    
    return OpdVisitModel(
      opdTicketNo: map['opdTicketNo'] ?? '',
      patientId: map['patient_id'] ?? '',
      visitDateTime: map['visit_date'] != null 
          ? DateTime.parse(map['visit_date']) 
          : DateTime.now(),
      reasonForVisit: map['chief_complaint'] == 1,
      isFollowUp: map['is_follow_up'] == 1,
      diagnosisIds: diagnosisIds,
      diagnosisNames: diagnosisNames,
      prescriptions: prescriptions,
      labTestIds: labTestIds,
      labTestNames: labTestNames,
      isReferred: map['is_referred'] == 1,
      followUpAdvised: map['follow_up_advised'] == 1,
      followUpDays: map['follow_up_days'],
      fpAdvised: map['fp_advised'] == 1,
      fpIds: fpIds,
      fpNames: fpNames,
      obgynData: map['obgyn_data'],
      pregnancyIndicatorId: map['pregnancy_indicator_id'],
      postpartumStatusId: map['postpartum_status_id'],
    );
  }
}
