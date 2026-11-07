import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';

class PdfRenderService {
  static const String serverBaseUrl = kIsWeb
      ? 'http://localhost:8000'
      : 'http://192.168.1.5:8000';

  static Future<void> generateAndPrintAgreement({
    required String rawContent,
    required Map<String, String> fieldValues,
    double fontSize = 13.5,
    double lineHeight = 2.0,
    String paperSize = 'Legal',
    bool isEStamp = true,
    required double topMargin,
    required double subsequentTopMargin,
    required double bottomMargin,
    required double sideMargin,
    Uint8List? originalStampPdfBytes,
  }) async {
    String processed = rawContent;

    // فیلڈز تبدیل کریں
    fieldValues.forEach((key, val) {
      final safeVal = val.trim().isEmpty ? '________________' : val.trim();
      processed = processed.replaceAll('{{$key}}', safeVal);
    });
    processed = processed.replaceAll(RegExp(r'\{\{.*?\}\}'), '________________');

    // مارک ڈاؤن کو HTML میں بدلیں (Bold, Center, Headings)
    final lines = processed.split('\n');
    final htmlBuffer = StringBuffer();

    for (var line in lines) {
      String l = line.trim();
      if (l.isEmpty) {
        htmlBuffer.writeln("<div class='spacer'></div>");
        continue;
      }

      // بولڈ ٹیکسٹ
      l = l.replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (m) => '<b>${m[1]}</b>');
      l = l.replaceAllMapped(RegExp(r'\*(.*?)\*'), (m) => '<b>${m[1]}</b>');

      // سنٹر ٹیکسٹ
      if (l.contains('[center]') && l.contains('[/center]')) {
        l = l.replaceAll('[center]', '<div style="text-align: center;"><b>').replaceAll('[/center]', '</b></div>');
      }

      // سرخیاں
      if (l.startsWith('# ')) {
        l = '<h3>${l.substring(2)}</h3>';
      } else {
        l = '<p>$l</p>';
      }

      htmlBuffer.writeln(l);
    }

    String? stampBase64;
    if (originalStampPdfBytes != null && originalStampPdfBytes.isNotEmpty) {
      stampBase64 = base64Encode(originalStampPdfBytes);
    }

    try {
      final url = Uri.parse('$serverBaseUrl/generate-pdf');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'body_html': htmlBuffer.toString(),
          'font_size': fontSize,
          'line_height': lineHeight,
          'paper_size': paperSize,
          'top_margin': topMargin,
          'subsequent_top_margin': subsequentTopMargin,
          'bottom_margin': bottomMargin,
          'side_margin': sideMargin,
          'stamp_pdf_base64': stampBase64,
        }),
      );

      if (response.statusCode == 200) {
        final pdfBytes = response.bodyBytes;
        await Printing.layoutPdf(
          onLayout: (_) async => pdfBytes,
          name: 'Nayab_Agreement_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
      } else {
        throw Exception('سرور کی طرف سے خرابی: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('پی ڈی ایف سروس رابطہ خامی: $e');
      rethrow;
    }
  }
}