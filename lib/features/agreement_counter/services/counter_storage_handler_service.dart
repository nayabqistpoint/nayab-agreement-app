import 'package:flutter/foundation.dart';
import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../../core/time/time_status_service.dart';

class CounterStorageHandlerService {
  static Map<dynamic, dynamic> getDraft() {
    try {
      final box = HiveBoxManager.getBox(BoxNames.agreementDraftBox);
      return box.toMap();
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveDraftBatch(Map<String, dynamic> payload) async {
    try {
      final box = HiveBoxManager.getBox(BoxNames.agreementDraftBox);
      await box.putAll(payload);
    } catch (e) {
      debugPrint('CounterStorageHandlerService saveDraft Error: $e');
    }
  }

  static ValueListenable listenToDraft() {
    return HiveBoxManager.listenToBox(BoxNames.agreementDraftBox);
  }

  static ValueListenable listenToTemplates() {
    return HiveBoxManager.listenToBox(BoxNames.templatesBox);
  }

  static Map<String, Map<String, dynamic>> getAllTemplates() {
    try {
      final box = HiveBoxManager.getBox(BoxNames.templatesBox);
      final Map<String, Map<String, dynamic>> map = {};
      for (var key in box.keys) {
        final val = box.get(key);
        if (val is Map && val['isDeleted'] != true) {
          map[key.toString()] = Map<String, dynamic>.from(val);
        }
      }
      return map;
    } catch (_) {
      return {};
    }
  }

  static Future<bool> deleteTemplate(String title) async {
    try {
      final cleanTitle = title.trim();
      final box = HiveBoxManager.getBox(BoxNames.templatesBox);
      final raw = box.get(cleanTitle);
      if (raw is Map) {
        final map = Map<String, dynamic>.from(raw);
        map['isDeleted'] = true;
        map['isSynced'] = false;
        map['updatedAt'] = TimeStatusService.nowUtcIso();
        await box.put(cleanTitle, map);
      } else {
        await box.delete(cleanTitle);
      }

      final draftBox = HiveBoxManager.getBox(BoxNames.agreementDraftBox);
      if (draftBox.get('selected_template') == cleanTitle) {
        await draftBox.delete('selected_template');
      }
      return true;
    } catch (e) {
      debugPrint('CounterStorageHandlerService deleteTemplate Error: $e');
      return false;
    }
  }
}