import 'dart:convert';
import 'dart:typed_data';
import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../../core/models/document_template_model.dart';
import '../../../core/models/overlay_box_model.dart';
import '../../../core/time/time_status_service.dart';
import '../../../core/utils/tag_extraction_helper.dart';
import '../models/pdf_overlay_field_model.dart';

class PdfEditorStorageService {
  static Future<void> saveTemplate({
    required String title,
    required String paperSize,
    required Uint8List? pdfBytes,
    required String? fileName,
    required List<PdfOverlayFieldModel> fields,
  }) async {
    final cleanTitle = title.trim();
    final now = TimeStatusService.nowUtcIso();
    final String? b64 = pdfBytes != null ? base64Encode(pdfBytes) : null;

    final List<OverlayBoxModel> floatingBoxes = [];
    final Set<String> extractedTags = {};

    for (final f in fields) {
      final rawText = f.tag.trim();
      if (rawText.isEmpty) continue;

      if (!f.isStaticText) {
        for (final key in TemplateService.extractFields(rawText)) {
          if (key.isNotEmpty) {
            extractedTags.add(key);
          }
        }
      }

      floatingBoxes.add(
        OverlayBoxModel(
          id: f.id,
          tag: rawText,
          x: f.x,
          y: f.y,
          width: f.width,
          height: 35.0,
          fontSize: f.fontSize,
          isBold: f.isBold,
          isUnderline: f.isUnderline,
          isMultiLine: false,
        ),
      );
    }

    final docModel = DocumentTemplateModel(
      id: cleanTitle,
      title: cleanTitle,
      content: '',
      mode: DocumentMode.formFiller,
      paperSize: paperSize.isNotEmpty ? paperSize : 'A4',
      topMargin: 0.0,
      subsequentTopMargin: 0.0,
      bottomMargin: 0.0,
      subsequentBottomMargin: 0.0,
      sideMargin: 0.0,
      fontSize: 13.5,
      base64Pdf: b64,
      stampFileName: fileName,
      floatingBoxes: floatingBoxes,
      fields: extractedTags.toList(),
      pages: const [''],
    );

    final payload = docModel.toMap();
    payload['isSynced'] = false;
    payload['updatedAt'] = now;
    payload['createdAt'] = now;
    payload['isDeleted'] = false;

    await HiveBoxManager.putBatch(
      boxName: BoxNames.templatesBox,
      entries: {cleanTitle: payload},
    );
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
    if (raw == null || raw is! Map) return null;

    final map = Map<String, dynamic>.from(raw);
    final doc = DocumentTemplateModel.fromMap(map);

    Uint8List? bytes;
    if (doc.base64Pdf != null && doc.base64Pdf!.isNotEmpty) {
      try {
        bytes = base64Decode(doc.base64Pdf!);
      } catch (_) {}
    }

    final tagCheckRegex = RegExp(r'\{\{([^{}]*?)\}\}');
    final fieldsList = doc.floatingBoxes.map((b) {
      final isTag = tagCheckRegex.hasMatch(b.tag);
      return PdfOverlayFieldModel(
        id: b.id,
        tag: b.tag,
        x: b.x,
        y: b.y,
        width: b.width > 30 ? b.width : 180.0,
        fontSize: b.fontSize,
        isBold: b.isBold,
        isUnderline: b.isUnderline,
        isStaticText: !isTag,
      );
    }).toList();

    return (
      title: doc.title,
      paperSize: doc.paperSize.isNotEmpty ? doc.paperSize : 'A4',
      fileName: doc.stampFileName,
      pdfBytes: bytes,
      fields: fieldsList,
    );
  }
}