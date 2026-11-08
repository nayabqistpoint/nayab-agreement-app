import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class StampPdfCaptureService {
  /// لیگل اسٹامپ کے صفحات کو 300 DPI پر لاک شدہ PDF میں کیپچر کرنا
  static Future<Uint8List> generateStampPdf({
    required List<GlobalKey> pageKeys,
    required String docTitle,
  }) async {
    final pdfDocument = pw.Document(title: docTitle);
    const PdfPageFormat format = PdfPageFormat.legal;

    for (int i = 0; i < pageKeys.length; i++) {
      final key = pageKeys[i];
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) continue;

      // 4.0 الٹرا ایچ ڈی پکسل کوالٹی
      final ui.Image image = await boundary.toImage(pixelRatio: 4.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) continue;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final pw.MemoryImage pdfImage = pw.MemoryImage(pngBytes);

      pdfDocument.addPage(
        pw.Page(
          pageFormat: format,
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Image(pdfImage, fit: pw.BoxFit.fill),
            );
          },
        ),
      );
    }

    return await pdfDocument.save();
  }

  static Future<void> printOrSavePdf({
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    await Printing.layoutPdf(
      name: fileName,
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }
}