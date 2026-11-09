import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:printing/printing.dart';

class StampFileService {
  static Future<PlatformFile?> pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      return result.files.single;
    }
    return null;
  }

  /// ای-اسٹامپ کے مونوگرام اور کیو آر کوڈ کو بغیر کسی بلر کے کرسٹل کلیئر رینڈر کرنا
  static Future<List<Uint8List?>> rasterizePdf(Uint8List bytes) async {
    List<Uint8List?> pages = [];
    try {
      // 300 DPI پر مونوگرام کے باریک نشانات اور واٹر مارک محفوظ رہتے ہیں
      await for (final page in Printing.raster(bytes, dpi: 300.0)) {
        final pngBytes = await page.toPng();
        pages.add(pngBytes);
      }
    } catch (_) {}
    return pages;
  }
}