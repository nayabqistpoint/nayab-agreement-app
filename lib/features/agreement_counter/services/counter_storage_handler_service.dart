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

  /// ہائیو ٹیمپلیٹس باکس کا رئیل ٹائم لسنر
  static ValueListenable listenToTemplates() {
    return HiveBoxManager.listenToBox(BoxNames.templatesBox);
  }

  // ٹیمپلیٹس باکس سے فوری ڈیٹا پڑھنا
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

  /// ٹیمپلیٹ کو ہائیو سے ڈیلیٹ کرنا (اور ڈرافٹ میں اگر سلیکٹڈ ہو تو کلیئر کرنا)
  static Future<bool> deleteTemplate(String title) async {
    try {
      final box = HiveBoxManager.getBox(BoxNames.templatesBox);
      await box.delete(title.trim());

      // اگر یہی ٹیمپلیٹ ڈرافٹ میں ایکٹو تھا تو ڈرافٹ سے بھی سلیکشن ہٹا دیں
      final draftBox = HiveBoxManager.getBox(BoxNames.agreementDraftBox);
      if (draftBox.get('selected_template') == title.trim()) {
        await draftBox.delete('selected_template');
      }
      return true;
    } catch (e) {
      debugPrint('CounterStorageHandlerService deleteTemplate Error: $e');
      return false;
    }
  }
}