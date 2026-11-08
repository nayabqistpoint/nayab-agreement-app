import 'package:flutter/foundation.dart';
import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';

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

  // ٹیمپلیٹس باکس سے براہ راست پڑھنا
  static Map<String, Map<String, dynamic>> getAllTemplates() {
    try {
      final box = HiveBoxManager.getBox(BoxNames.templatesBox);
      final Map<String, Map<String, dynamic>> map = {};
      for (var key in box.keys) {
        final val = box.get(key);
        if (val is Map) {
          map[key.toString()] = Map<String, dynamic>.from(val);
        }
      }
      return map;
    } catch (_) {
      return {};
    }
  }
}