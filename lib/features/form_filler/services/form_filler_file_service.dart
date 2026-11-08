import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:printing/printing.dart';

class FormFillerFileService {
  static Future<PlatformFile?> pickFormFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      return result.files.single;
    }
    return null;
  }

  static Future<List<Uint8List?>> rasterizePdf(Uint8List bytes) async {
    List<Uint8List?> pages = [];
    try {
      await for (final page in Printing.raster(bytes, dpi: 200)) {
        pages.add(await page.toPng());
      }
    } catch (_) {}
    return pages;
  }
}