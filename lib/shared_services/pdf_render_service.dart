import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfRenderService {
  /// غیر معیاری اور مسنگ گلفس کو صاف کر کے عام اردو میں بدلنے کا فنکشن
  static String _cleanAndNormalizeUrduText(String input) {
    // 1. پریزنٹیشن فارمز اور مسنگ گلفس کو معیاری اردو حروف سے بدلنا
    var text = input
        .replaceAll('\uFB88', 'ز') // U+FB88 (ز کی پریزنٹیشن فارم)
        .replaceAll('\uFB8A', 'ژ')
        .replaceAll('\uFB8E', 'ک')
        .replaceAll('\uFB90', 'گ')
        .replaceAll('\uFBAE', 'ے')
        .replaceAll('\uFBAF', 'ے')
        .replaceAll('\uFB56', 'پ')
        .replaceAll('\uFB66', 'ٹ')
        .replaceAll('\uFB7A', 'چ')
        .replaceAll('\uFB9E', 'گ')
        .replaceAll('\uFB84', 'ڈ')
        .replaceAll('\uFB8C', 'ڑ')
        .replaceAll('\uFBA6', 'ہ')
        .replaceAll('\uFBA7', 'ہ')
        .replaceAll('\uFBA8', 'ہ')
        .replaceAll('\uFBA9', 'ہ')
        .replaceAll('\uFBAA', 'ہ')
        .replaceAll('\uFBAB', 'ہ')
        .replaceAll('\uFBAC', 'ہ')
        .replaceAll('\uFBAD', 'ہ');

    // 2. دیگر غیر ضروری پوشیدہ کنٹرول کوڈز کی صفائی (Zero-Width اور غیراصولی اسپیسز)
    text = text.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '');

    return text;
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
    // 1. فیلڈز اور ٹیگز کو ڈیٹا بکٹ کی ویلیوز سے تبدیل کرنا
    String processed = rawContent;
    fieldValues.forEach((key, val) {
      final safeVal = val.trim().isEmpty ? '________________' : val.trim();
      processed = processed.replaceAll('{{$key}}', safeVal);
    });

    // 2. فونٹ کے مسنگ گلفس کی خرابی سے بچنے کے لیے ٹیکسٹ صاف کرنا
    processed = _cleanAndNormalizeUrduText(processed);

    final fontData = await rootBundle.load('assets/fonts/jameel.ttf');
    final ttf = pw.Font.ttf(fontData);

    final pageFormat = (isEStamp || paperSize == 'Legal')
        ? PdfPageFormat.legal
        : PdfPageFormat.a4;

    final pdf = pw.Document();

    // گاہک کے اصل ای-اسٹامپ کے پہلے صفحے کا راسٹر امیج بنانا
    pw.MemoryImage? backgroundUnderlay;
    if (isEStamp && originalStampPdfBytes != null && originalStampPdfBytes.isNotEmpty) {
      try {
        await for (final page in Printing.raster(originalStampPdfBytes, pages: [0], dpi: 200)) {
          final pngBytes = await page.toPng();
          backgroundUnderlay = pw.MemoryImage(pngBytes);
          break;
        }
      } catch (_) {}
    }

    // تمام پیراگراف اور بلاکس کی فہرست
    final contentWidgets = _buildPdfElements(processed, ttf);

    // ملٹی پیج رینڈرنگ
    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: pageFormat,
          theme: pw.ThemeData.withFont(base: ttf),
          margin: pw.EdgeInsets.only(
            left: sideMargin,
            right: sideMargin,
            bottom: bottomMargin,
          ),
          buildBackground: (pw.Context context) {
            if (context.pageNumber == 1 && backgroundUnderlay != null) {
              return pw.FullPage(
                ignoreMargins: true,
                child: pw.Image(
                  backgroundUnderlay,
                  fit: pw.BoxFit.fill,
                ),
              );
            }
            return pw.Container();
          },
        ),
        header: (pw.Context context) {
          final double h = (context.pageNumber == 1) ? topMargin : subsequentTopMargin;
          return pw.SizedBox(height: h);
        },
        build: (pw.Context context) {
          return [
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: contentWidgets,
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Agreement_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  static List<pw.Widget> _buildPdfElements(String content, pw.Font ttf) {
    final List<pw.Widget> widgets = [];
    final lines = content.split('\n');

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(pw.SizedBox(height: 5));
        continue;
      }

      if (trimmed.startsWith('[space:') && trimmed.endsWith(']')) {
        final heightStr = trimmed.replaceAll('[space:', '').replaceAll(']', '').trim();
        final h = double.tryParse(heightStr) ?? 15.0;
        widgets.add(pw.SizedBox(height: h));
        continue;
      }

      if (trimmed.startsWith('[signatures:') && trimmed.endsWith(']')) {
        final rawSigns = trimmed.replaceAll('[signatures:', '').replaceAll(']', '').trim();
        final signs = rawSigns.split('|').map((s) => s.trim()).toList();
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 10),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: signs.map((sign) {
                return pw.Expanded(
                  child: pw.Column(
                    children: [
                      pw.Container(
                        height: 1,
                        margin: const pw.EdgeInsets.symmetric(horizontal: 8),
                        color: PdfColors.grey800,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        sign,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(font: ttf, fontSize: 12),
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

      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
          child: pw.Text(
            trimmed,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              font: ttf,
              fontSize: 13.0,
              lineSpacing: 1.8,
              color: PdfColors.black,
            ),
          ),
        ),
      );
    }
    return widgets;
  }
}