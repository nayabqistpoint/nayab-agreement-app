import '../../core/constants/box_names.dart';
import '../../core/database/hive_box_manager.dart';
import 'agreement_payload_service.dart';

class AgreementStorageHandlerService {
  static Future<void> saveCurrentDraft(Map<String, dynamic> draftPayload) async {
    final batch = AgreementPayloadService.wrapIntoBatchMap([draftPayload]);
    await HiveBoxManager.putBatch(
      boxName: BoxNames.agreementDraftBox,
      entries: batch,
    );
  }

  static Map<String, dynamic>? getCurrentDraft() {
    final box = HiveBoxManager.getBox(BoxNames.agreementDraftBox);
    final raw = box.get('active_draft');
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw as Map);
  }

  static Future<void> clearCurrentDraft() async {
    await HiveBoxManager.deleteKey(
      boxName: BoxNames.agreementDraftBox,
      key: 'active_draft',
    );
  }

  static Future<void> saveTemplate(Map<String, dynamic> templatePayload) async {
    final batch = AgreementPayloadService.wrapIntoBatchMap([templatePayload]);
    await HiveBoxManager.putBatch(
      boxName: BoxNames.templatesBox,
      entries: batch,
    );
  }

  static Future<void> deleteTemplatePermanently(String templateId) async {
    await HiveBoxManager.deleteKey(
      boxName: BoxNames.templatesBox,
      key: templateId,
    );
  }

  static Map<String, Map<String, dynamic>> getAllTemplates() {
    final box = HiveBoxManager.getBox(BoxNames.templatesBox);
    final Map<String, Map<String, dynamic>> result = {};
    for (var key in box.keys) {
      final val = box.get(key);
      if (val is Map && (val['isDeleted'] != true)) {
        result[key.toString()] = Map<String, dynamic>.from(val);
      }
    }
    return result;
  }

  static Future<void> saveCustomerProfile(Map<String, dynamic> profilePayload) async {
    final batch = AgreementPayloadService.wrapIntoBatchMap([profilePayload]);
    await HiveBoxManager.putBatch(
      boxName: BoxNames.customerProfilesBox,
      entries: batch,
    );
  }
}