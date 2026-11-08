import 'package:flutter/foundation.dart';
import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';

class BucketStorageHandlerService {
  static Map<String, dynamic> getDraft() {
    try {
      final box = HiveBoxManager.getBox(BoxNames.agreementDraftBox);
      final Map<String, dynamic> draft = {};
      for (var key in box.keys) {
        final val = box.get(key);
        if (val is Map) {
          draft[key.toString()] = Map<String, dynamic>.from(val);
        } else {
          draft[key.toString()] = val;
        }
      }
      return draft;
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveDraftBatch(Map<String, dynamic> payload) async {
    try {
      final box = HiveBoxManager.getBox(BoxNames.agreementDraftBox);
      await box.putAll(payload);
    } catch (e) {
      debugPrint('Error saving bucket draft: $e');
    }
  }

  static ValueListenable listenToDraft() {
    return HiveBoxManager.listenToBox(BoxNames.agreementDraftBox);
  }
}