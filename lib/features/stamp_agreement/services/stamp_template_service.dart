import 'dart:convert';
import 'dart:typed_data';
import '../../../core/utils/paper_pagination_helper.dart';
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
    double side,
    double fontSize,
    String? fileName,
    Uint8List? pdfBytes,
  })? load(String title) {
    final doc = StampStorageHandlerService.fetchTemplate(title);
    if (doc == null) return null;

    Uint8List? bytes;
    if (doc.base64Pdf != null && doc.base64Pdf!.isNotEmpty) {
      try {
        bytes = base64Decode(doc.base64Pdf!);
      } catch (_) {}
    }

    return (
      title: doc.title,
      content: doc.content,
      paperSize: doc.paperSize.isNotEmpty ? doc.paperSize : 'Legal',
      top: doc.topMargin,
      subTop: doc.subsequentTopMargin,
      bottom: doc.bottomMargin,
      side: doc.sideMargin,
      fontSize: doc.fontSize.roundToDouble(),
      fileName: doc.stampFileName,
      pdfBytes: bytes,
    );
  }

  static List<String> paginate({
    required String text,
    required double fontSize,
    required double top,
    required double subTop,
    required double bottom,
    required double side,
    required String paperSize,
  }) {
    return AgreementPaginationService.paginate(
      fullText: text,
      fontSize: fontSize,
      p1TopMargin: top,
      subsequentTopMargin: subTop,
      bottomMargin: bottom,
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
    required double side,
    required double fontSize,
    required Uint8List? pdfBytes,
    required String? fileName,
    required List<String> pages,
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
      sideMargin: side,
      fontSize: fontSize,
      base64Pdf: b64,
      stampFileName: fileName,
      pages: pages,
    );
    await StampStorageHandlerService.saveTemplate(payload);
    return true;
  }
}