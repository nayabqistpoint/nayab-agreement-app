import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

  static Future<void> printSelectivePages({
    required List<GlobalKey> allKeys,
    required List<int> pageIndexesToPrint,
    required String docTitle,
    required PdfPageFormat targetFormat,
  }) async {
    if (pageIndexesToPrint.isEmpty) return;

    final pdfDocument = pw.Document(title: docTitle);

    for (final index in pageIndexesToPrint) {
      if (index >= allKeys.length) continue;
      final key = allKeys[index];
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) continue;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.5);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) continue;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final pw.MemoryImage pdfImage = pw.MemoryImage(pngBytes);

      pdfDocument.addPage(
        pw.Page(
          pageFormat: targetFormat,
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

    final Uint8List generatedPdf = await pdfDocument.save();
    await Printing.layoutPdf(
      name: '$docTitle.pdf',
      onLayout: (PdfPageFormat format) async => generatedPdf,
    );
  }
}