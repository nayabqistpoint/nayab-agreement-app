import 'package:flutter/foundation.dart';
import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../../core/models/document_template_model.dart';

class StampStorageHandlerService {
  static DocumentTemplateModel? fetchTemplate(String title) {
    try {
      final box = HiveBoxManager.getBox(BoxNames.templatesBox);
      final raw = box.get(title);
      if (raw is Map) {
        return DocumentTemplateModel.fromMap(Map<String, dynamic>.from(raw));
      }
    } catch (e) {
      debugPrint('StampStorageHandlerService fetch Error: $e');
    }
    return null;
  }

  static Future<void> saveTemplate(Map<String, dynamic> payload) async {
    try {
      final box = HiveBoxManager.getBox(BoxNames.templatesBox);
      final id = payload['title'] ?? payload['id'];
      if (id != null) {
        await box.put(id.toString(), payload);
      }
    } catch (e) {
      debugPrint('StampStorageHandlerService save Error: $e');
    }
  }
}