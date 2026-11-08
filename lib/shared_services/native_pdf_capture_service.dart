import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class NativePdfCaptureService {
  /// گلوبل کیز کی مدد سے اسکرین کے ہر صفحے کو 300 DPI تصویر بنا کر اصلی PDF میں بدلنا
  static Future<Uint8List> generatePdfFromBoundaries({
    required List<GlobalKey> pageKeys,
    required String paperSize,
    required String docTitle,
  }) async {
    final pdfDocument = pw.Document(title: docTitle);

    // سائز کی درست قانونی پیمائش
    final PdfPageFormat format = (paperSize.toLowerCase() == 'a4')
        ? PdfPageFormat.a4
        : PdfPageFormat.legal;

    for (int i = 0; i < pageKeys.length; i++) {
      final key = pageKeys[i];
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) continue;

      // 3.0 پکسل ریشو یعنی بالکل پرنٹ پریس جیسی ایچ ڈی شفافیت
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) continue;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final pw.MemoryImage pdfImage = pw.MemoryImage(pngBytes);

      pdfDocument.addPage(
        pw.Page(
          pageFormat: format,
          margin: pw.EdgeInsets.zero, // مارجن صفر تاکہ اسکرین کا کینوس سو فیصد بیٹھے
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

  /// پی ڈی ایف سکرین پر کھولنے اور محفوظ / پرنٹ کرنے کا براہ راست ونڈو
  static Future<void> previewAndSavePdf({
    required BuildContext context,
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    await Printing.layoutPdf(
      name: fileName,
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }
}