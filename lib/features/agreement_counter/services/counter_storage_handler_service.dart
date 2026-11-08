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
      debugPrint('Error saving draft batch: $e');
    }
  }

  static ValueListenable listenToDraft() {
    return HiveBoxManager.listenToBox(BoxNames.agreementDraftBox);
  }
}