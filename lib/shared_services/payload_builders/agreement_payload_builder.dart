import '../../core/time/time_status_service.dart';
import '../../shared_models/agreement_template_model.dart';
import '../../shared_models/customer_profile_model.dart';

class AgreementPayloadBuilder {
  static Map<String, dynamic> buildDraftPayload({
    required String templateId,
    required String templateText,
    required String paperSize,
    required double topMargin,
    required Map<String, String> fieldValues,
    required Map<String, dynamic> qrSourceData,
  }) {
    final now = TimeStatusService.currentTimestamp;
    return {
      'id': 'active_draft',
      'templateId': templateId,
      'templateText': templateText,
      'paperSize': paperSize,
      'topMargin': topMargin,
      'fieldValues': fieldValues,
      'qrSourceData': qrSourceData,
      'isSynced': false,
      'updatedAt': now,
      'createdAt': now,
      'isDeleted': false,
    };
  }

  static Map<String, dynamic> buildTemplatePayload(AgreementTemplateModel template) {
    final now = TimeStatusService.currentTimestamp;
    final map = template.toMap();
    map['isSynced'] = false;
    map['updatedAt'] = now;
    if (map['createdAt'] == null || map['createdAt'].toString().isEmpty) {
      map['createdAt'] = now;
    }
    return map;
  }

  static Map<String, dynamic> buildProfilePayload(CustomerProfileModel profile) {
    final now = TimeStatusService.currentTimestamp;
    final map = profile.toMap();
    map['isSynced'] = false;
    map['updatedAt'] = now;
    if (map['createdAt'] == null || map['createdAt'].toString().isEmpty) {
      map['createdAt'] = now;
    }
    return map;
  }
}