import 'dart:typed_data';
import '../../stamp_agreement/services/stamp_file_service.dart';

class PdfRenderHelper {
  static Future<List<Uint8List>> renderPdfPages(Uint8List pdfBytes) async {
    final List<Uint8List> validPages = [];
    try {
      final List<Uint8List?> pages = await StampFileService.rasterizePdf(pdfBytes);
      for (final p in pages) {
        if (p != null) {
          validPages.add(p);
        }
      }
    } catch (_) {}
    return validPages;
  }
}