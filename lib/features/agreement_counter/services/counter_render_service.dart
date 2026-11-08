import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../stamp_agreement/services/stamp_pdf_capture_service.dart';

class CounterRenderService {
  static Future<List<Uint8List?>> renderPdfPages(Uint8List? pdfBytes) async {
    if (pdfBytes == null) return [];
    List<Uint8List?> pages = [];
    try {
      await for (final page in Printing.raster(pdfBytes, dpi: 300)) {
        pages.add(await page.toPng());
      }
    } catch (_) {}
    return pages;
  }

  static Future<PlatformFile?> pickStampFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (res != null && res.files.isNotEmpty) {
      return res.files.single;
    }
    return null;
  }

  static Future<void> printDocument(List<GlobalKey> keys, String title) async {
    final bytes = await StampPdfCaptureService.generateStampPdf(pageKeys: keys, docTitle: title);
    await StampPdfCaptureService.printOrSavePdf(pdfBytes: bytes, fileName: '$title.pdf');
  }
}