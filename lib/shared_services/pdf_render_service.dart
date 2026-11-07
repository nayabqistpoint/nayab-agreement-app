import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfRenderService {
  static const double legalWidth = 612.0;
  static const double legalHeight = 1008.0;

  static String _cleanText(String input) {
    return input
        .replaceAll('\u200B', '')
        .replaceAll('\u200C', '')
        .replaceAll('\u200D', '')
        .replaceAll('\uFEFF', '');
  }

  static Future<void> generateAndPrintAgreement({
    required String rawContent,
    required Map<String, String> fieldValues,
    String paperSize = 'A4',
    bool isEStamp = false,
    required double topMargin,
    required double subsequentTopMargin,
    required double bottomMargin,
    required double sideMargin,
    Uint8List? originalStampPdfBytes,
  }) async {
    String processed = rawContent;
    fieldValues.forEach((key, val) {
      final safeVal = val.trim().isEmpty ? '________________' : val.trim();
      processed = processed.replaceAll('{{$key}}', safeVal);
    });
    processed = _cleanText(processed);

    final fontData = await rootBundle.load('assets/fonts/jameel.ttf');
    final ttf = pw.Font.ttf(fontData);

    final pdf = pw.Document();

    pw.MemoryImage? bgP1;
    pw.MemoryImage? bgP2;

    if (isEStamp && originalStampPdfBytes != null && originalStampPdfBytes.isNotEmpty) {
      try {
        int idx = 0;
        await for (final page in Printing.raster(originalStampPdfBytes, pages: [0, 1], dpi: 150)) {
          final pngBytes = await page.toPng();
          if (idx == 0) bgP1 = pw.MemoryImage(pngBytes);
          if (idx == 1) bgP2 = pw.MemoryImage(pngBytes);
          idx++;
        }
      } catch (_) {}
    }

    const double fontSize = 11.0;
    const double lineSpacing = 18.0;

    final double p1Height = (legalHeight - topMargin - bottomMargin).clamp(100.0, legalHeight);
    final double p2Height = (legalHeight - subsequentTopMargin - bottomMargin).clamp(100.0, legalHeight);

    final int p1MaxLines = (p1Height / lineSpacing).floor();
    final int p2MaxLines = (p2Height / lineSpacing).floor();

    final rawLines = processed.split('\n');
    final List<String> allLines = [];

    for (var l in rawLines) {
      final t = l.trim();
      if (t.isEmpty) {
        allLines.add("");
        continue;
      }
      final words = t.split(' ');
      String currentLine = "";
      for (var w in words) {
        if ((currentLine + w).length > 48) {
          allLines.add(currentLine.trim());
          currentLine = "$w ";
        } else {
          currentLine += "$w ";
        }
      }
      if (currentLine.isNotEmpty) {
        allLines.add(currentLine.trim());
      }
    }

    final List<String> page1Lines = [];
    final List<String> page2Lines = [];

    for (int i = 0; i < allLines.length; i++) {
      if (i < p1MaxLines) {
        page1Lines.add(allLines[i]);
      } else if (i < (p1MaxLines + p2MaxLines)) {
        page2Lines.add(allLines[i]);
      }
    }

    // صفحہ 1
    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(legalWidth, legalHeight),
        margin: pw.EdgeInsets.zero,
        theme: pw.ThemeData.withFont(base: ttf),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              if (bgP1 != null)
                pw.Positioned.fill(
                  child: pw.Image(bgP1, fit: pw.BoxFit.fill),
                ),
              pw.Positioned(
                top: topMargin,
                bottom: bottomMargin,
                left: sideMargin,
                right: sideMargin,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: page1Lines.map((line) {
                    if (line.isEmpty) return pw.SizedBox(height: 6);
                    return pw.Text(
                      line,
                      textDirection: pw.TextDirection.rtl,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: fontSize,
                        lineSpacing: 1.5,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );

    // صفحہ 2
    if (page2Lines.isNotEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: const PdfPageFormat(legalWidth, legalHeight),
          margin: pw.EdgeInsets.zero,
          theme: pw.ThemeData.withFont(base: ttf),
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                if (bgP2 != null)
                  pw.Positioned.fill(
                    child: pw.Image(bgP2, fit: pw.BoxFit.fill),
                  ),
                pw.Positioned(
                  top: subsequentTopMargin,
                  bottom: bottomMargin,
                  left: sideMargin,
                  right: sideMargin,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: page2Lines.map((line) {
                      if (line.isEmpty) return pw.SizedBox(height: 6);
                      return pw.Text(
                        line,
                        textDirection: pw.TextDirection.rtl,
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: fontSize,
                          lineSpacing: 1.5,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Nayab_Agreement_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }
}