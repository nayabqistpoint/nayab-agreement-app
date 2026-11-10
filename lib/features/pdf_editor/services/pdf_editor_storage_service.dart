import 'dart:convert';
import 'dart:typed_data';
import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../../core/models/document_template_model.dart';
import '../../../core/models/overlay_box_model.dart';
import '../models/pdf_overlay_field_model.dart';

class PdfEditorStorageService {
  static Future<void> saveTemplate({
    required String title,
    required String paperSize,
    required Uint8List? pdfBytes,
    required String? fileName,
    required List<PdfOverlayFieldModel> fields,
  }) async {
    final box = HiveBoxManager.getBox(BoxNames.templatesBox);
    final String? b64 = pdfBytes != null ? base64Encode(pdfBytes) : null;

    final List<OverlayBoxModel> floatingBoxes = fields.map((f) {
      return OverlayBoxModel(
        id: f.id,
        tag: f.tag,
        x: f.x,
        y: f.y,
        width: 140.0,
        height: 32.0,
        fontSize: f.fontSize,
      );
    }).toList();

    final List<String> extractedTags = fields.map((f) {
      return f.tag.replaceAll('{{', '').replaceAll('}}', '').trim();
    }).toSet().toList();

    final docModel = DocumentTemplateModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      content: '',
      mode: DocumentMode.formFiller,
      paperSize: paperSize,
      topMargin: 0.0,
      subsequentTopMargin: 0.0,
      bottomMargin: 0.0,
      sideMargin: 0.0,
      fontSize: 13.5,
      base64Pdf: b64,
      stampFileName: fileName,
      floatingBoxes: floatingBoxes,
      fields: extractedTags,
      pages: const [],
    );

    await box.put(title.trim(), docModel.toMap());
  }

  static Future<({
    String title,
    String paperSize,
    String? fileName,
    Uint8List? pdfBytes,
    List<PdfOverlayFieldModel> fields,
  })?> loadTemplate(String title) async {
    final box = HiveBoxManager.getBox(BoxNames.templatesBox);
    final raw = box.get(title.trim());
    if (raw == null) return null;

    final map = Map<String, dynamic>.from(raw is Map ? raw : {});
    final doc = DocumentTemplateModel.fromMap(map);

    Uint8List? bytes;
    if (doc.base64Pdf != null && doc.base64Pdf!.isNotEmpty) {
      try {
        bytes = base64Decode(doc.base64Pdf!);
      } catch (_) {}
    }

    final fieldsList = doc.floatingBoxes.map((b) {
      return PdfOverlayFieldModel(
        id: b.id,
        tag: b.tag,
        x: b.x,
        y: b.y,
        fontSize: b.fontSize,
      );
    }).toList();

    return (
      title: doc.title,
      paperSize: doc.paperSize,
      fileName: doc.stampFileName,
      pdfBytes: bytes,
      fields: fieldsList,
    );
  }
}