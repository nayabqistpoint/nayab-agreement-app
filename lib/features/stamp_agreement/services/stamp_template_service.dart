import 'dart:convert';
import 'dart:typed_data';
import '../../../core/utils/paper_pagination_helper.dart';
import '../models/stamp_overlay_field_model.dart';
import 'stamp_payload_builder.dart';
import 'stamp_storage_handler_service.dart';

class StampTemplateService {
  static ({
    String title,
    String content,
    String paperSize,
    double top,
    double subTop,
    double bottom,
    double subBottom,
    double side,
    double fontSize,
    String? fileName,
    Uint8List? pdfBytes,
    List<StampOverlayFieldModel> overlayFields,
  })? load(String title) {
    final doc = StampStorageHandlerService.fetchTemplate(title);
    if (doc == null) return null;
    Uint8List? bytes;
    if (doc.base64Pdf != null && doc.base64Pdf!.isNotEmpty) {
      try {
        bytes = base64Decode(doc.base64Pdf!);
      } catch (_) {}
    }
    final tagCheckRegex = RegExp(r'\{\{([^{}]*?)\}\}');
    final fields = doc.floatingBoxes.map((b) {
      final isTag = tagCheckRegex.hasMatch(b.tag);
      return StampOverlayFieldModel(
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
      content: doc.content,
      paperSize: doc.paperSize.isNotEmpty ? doc.paperSize : 'Legal',
      top: doc.topMargin,
      subTop: doc.subsequentTopMargin,
      bottom: doc.bottomMargin,
      subBottom: doc.subsequentBottomMargin,
      side: doc.sideMargin,
      fontSize: doc.fontSize.roundToDouble(),
      fileName: doc.stampFileName,
      pdfBytes: bytes,
      overlayFields: fields,
    );
  }

  static List<String> paginate({
    required String text,
    required double fontSize,
    required double top,
    required double subTop,
    required double bottom,
    required double subBottom,
    required double side,
    required String paperSize,
  }) {
    return AgreementPaginationService.paginate(
      fullText: text,
      fontSize: fontSize,
      p1TopMargin: top,
      subsequentTopMargin: subTop,
      bottomMargin: bottom,
      subsequentBottomMargin: subBottom,
      sideMargin: side,
      paperSize: paperSize,
    );
  }

  static Future<bool> save({
    required String title,
    required String content,
    required String paperSize,
    required double top,
    required double subTop,
    required double bottom,
    required double subBottom,
    required double side,
    required double fontSize,
    required Uint8List? pdfBytes,
    required String? fileName,
    required List<String> pages,
    required List<StampOverlayFieldModel> overlayFields,
  }) async {
    if (title.trim().isEmpty) return false;
    final b64 = pdfBytes != null ? base64Encode(pdfBytes) : null;
    final payload = StampPayloadBuilder.build(
      title: title.trim(),
      content: content,
      paperSize: paperSize,
      topMargin: top,
      subsequentTopMargin: subTop,
      bottomMargin: bottom,
      subsequentBottomMargin: subBottom,
      sideMargin: side,
      fontSize: fontSize,
      base64Pdf: b64,
      stampFileName: fileName,
      pages: pages,
      overlayFields: overlayFields,
    );
    await StampStorageHandlerService.saveTemplate(payload);
    return true;
  }
}