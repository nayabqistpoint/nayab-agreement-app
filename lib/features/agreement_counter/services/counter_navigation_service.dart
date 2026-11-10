import 'package:flutter/material.dart';
import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../../core/models/document_template_model.dart';
import '../../pdf_editor/pdf_editor_page.dart';
import '../../stamp_agreement/stamp_studio_page.dart';

class CounterNavigationService {
  static Future<T?> openStudio<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  static Future<T?> openEditor<T>(BuildContext context, String templateTitle) async {
    bool isOverlay = false;
    try {
      final box = HiveBoxManager.getBox(BoxNames.templatesBox);
      final raw = box.get(templateTitle.trim());
      if (raw is Map) {
        final doc = DocumentTemplateModel.fromMap(Map<String, dynamic>.from(raw));
        if (doc.mode == DocumentMode.formFiller) {
          isOverlay = true;
        }
      }
    } catch (_) {}

    if (isOverlay) {
      return Navigator.push<T>(
        context,
        MaterialPageRoute(
          builder: (_) => PdfEditorPage(initialTitle: templateTitle),
        ),
      );
    } else {
      return Navigator.push<T>(
        context,
        MaterialPageRoute(
          builder: (_) => StampStudioPage(initialTitle: templateTitle),
        ),
      );
    }
  }

  static Future<T?> openPdfEditor<T>(BuildContext context, {String? initialTitle}) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (_) => PdfEditorPage(initialTitle: initialTitle),
      ),
    );
  }
}