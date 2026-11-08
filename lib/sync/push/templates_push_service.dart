import 'package:flutter/foundation.dart';
import '../../core/constants/box_names.dart';
import '../../core/database/hive_box_manager.dart';

class TemplatesPushService {
  static Future<void> pushUnsynced() async {
    try {
      final box = HiveBoxManager.getBox(BoxNames.templatesBox);
      for (var key in box.keys) {
        final raw = box.get(key);
        if (raw is Map) {
          final data = Map<String, dynamic>.from(raw);
          if (data['isSynced'] == false) {
            // مقامی ہائیو میں محفوظ نشان زد کریں
            data['isSynced'] = true;
            await box.put(key, data);
          }
        }
      }
    } catch (e) {
      debugPrint('TemplatesPushService Error: $e');
    }
  }
}