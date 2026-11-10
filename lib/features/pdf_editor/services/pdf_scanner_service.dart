import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

class PdfScannerService {
  /// کیمرہ کھول کر دستاویز سکین کرنا (موبائل پر اصل ML Kit، اور ویب پر امیج پکر فال بیک)
  static Future<Uint8List?> scanDocument() async {
    // 1. اگر ڈیسک ٹاپ کروم براؤزر ہے تو امیج فائل پکر چلا کر ٹیسٹ کروائیں
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        return result.files.first.bytes;
      }
      return null;
    }

    // 2. اصل اینڈرائیڈ / موبائل پر گوگل کا ریئل ٹائم کیم سکینر چلے گا
    try {
      final options = DocumentScannerOptions(
        documentFormats: {DocumentFormat.jpeg},
        mode: ScannerMode.filter,
        pageLimit: 1,
        isGalleryImport: true,
      );

      final scanner = DocumentScanner(options: options);
      final DocumentScanningResult result = await scanner.scanDocument();

      final images = result.images;
      if (images != null && images.isNotEmpty) {
        final imagePath = images.first;
        final file = File(imagePath);
        if (await file.exists()) {
          return await file.readAsBytes();
        }
      }
    } catch (_) {}
    return null;
  }
}