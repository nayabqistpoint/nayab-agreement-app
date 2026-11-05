import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfRenderService {
  /// پی ڈی ایف تیار کر کے پرنٹ اور شیئر ڈائیلاگ دکھانا
  static Future<void> generateAndPrintAgreement({
    required String rawContent,
    required Map<String, String> fieldValues,
    String paperSize = 'A4',
    double topMargin = 0.0,
  }) async {
    // 1. پیپر سائز کا تعین
    final pageFormat = paperSize == 'Legal' ? PdfPageFormat.legal : PdfPageFormat.a4;

    // 2. ٹیگز تبدیل کرنا
    String processed = rawContent;
    fieldValues.forEach((key, val) {
      final safeVal = val.trim().isEmpty ? '________________' : val.trim();
      processed = processed.replaceAll('{{$key}}', safeVal);
    });

    // 3. نستعلیق فونٹ لوڈ کرنا
    final fontData = await rootBundle.load('assets/fonts/jameel.ttf');
    final ttf = pw.Font.ttf(fontData);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        theme: pw.ThemeData.withFont(base: ttf),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Padding(
              padding: pw.EdgeInsets.only(
                top: topMargin,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: _buildPdfElements(processed, ttf),
              ),
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Agreement_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  /// بلاک ٹیگز کو PDF وجٹس میں تبدیل کرنا
  static List<pw.Widget> _buildPdfElements(String content, pw.Font ttf) {
    final List<pw.Widget> widgets = [];
    final lines = content.split('\n');

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(pw.SizedBox(height: 6));
        continue;
      }

      // [space: XX] ہینڈلر
      if (trimmed.startsWith('[space:') && trimmed.endsWith(']')) {
        final heightStr = trimmed.replaceAll('[space:', '').replaceAll(']', '').trim();
        final h = double.tryParse(heightStr) ?? 15.0;
        widgets.add(pw.SizedBox(height: h));
        continue;
      }

      // [signatures: a | b | c] ہینڈلر
      if (trimmed.startsWith('[signatures:') && trimmed.endsWith(']')) {
        final rawSigns = trimmed.replaceAll('[signatures:', '').replaceAll(']', '').trim();
        final signs = rawSigns.split('|').map((s) => s.trim()).toList();
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 12),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: signs.map((sign) {
                return pw.Expanded(
                  child: pw.Column(
                    children: [
                      pw.Container(
                        height: 1,
                        margin: const pw.EdgeInsets.symmetric(horizontal: 10),
                        color: PdfColors.grey700,
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        sign,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(font: ttf, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
        continue;
      }

      // [center] ہینڈلر
      bool isCenter = false;
      String cleanLine = trimmed;
      if (cleanLine.startsWith('[center]') && cleanLine.endsWith('[/center]')) {
        isCenter = true;
        cleanLine = cleanLine.replaceAll('[center]', '').replaceAll('[/center]', '').trim();
      }

      // ہیڈنگز
      if (cleanLine.startsWith('# ')) {
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Text(
              cleanLine.replaceFirst('# ', ''),
              textAlign: isCenter ? pw.TextAlign.center : pw.TextAlign.right,
              style: pw.TextStyle(font: ttf, fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
        );
      } else if (cleanLine.startsWith('## ')) {
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Text(
              cleanLine.replaceFirst('## ', ''),
              textAlign: isCenter ? pw.TextAlign.center : pw.TextAlign.right,
              style: pw.TextStyle(font: ttf, fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
        );
      } else {
        // عام پیراگراف
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 2),
            child: pw.Text(
              cleanLine.replaceAll('**', ''),
              textAlign: isCenter ? pw.TextAlign.center : pw.TextAlign.right,
              style: pw.TextStyle(font: ttf, fontSize: 14, lineSpacing: 2.0),
            ),
          ),
        );
      }
    }

    return widgets;
  }
}