import 'package:flutter/material.dart';

class AgreementPaginationService {
  /// فلٹر کے اصل TextPainter انجن سے بغیر کسی بفر کے سچی پیجینیشن
  static List<String> paginate({
    required String fullText,
    required double fontSize,
    required double p1TopMargin,
    required double subsequentTopMargin,
    required double bottomMargin,
    required double sideMargin,
  }) {
    if (fullText.trim().isEmpty) return [""];

    const double sheetWidth = 390.0;
    const double sheetHeight = 642.0;
    const double scale = sheetHeight / 1008.0;

    // ریڈ باکس کی اصل اسکرین چوڑائی (پکسلز میں)
    final double boxW = (sheetWidth - ((sideMargin * scale).clamp(8.0, 45.0) * 2)).clamp(100.0, sheetWidth);

    // صفحہ 1 کی اصل باکس اونچائی
    final double p1BoxH = (sheetHeight - (p1TopMargin * scale) - (bottomMargin * scale)).clamp(40.0, sheetHeight);

    // بقیہ صفحات کی اصل باکس اونچائی
    final double subBoxH = (sheetHeight - (subsequentTopMargin * scale) - (bottomMargin * scale)).clamp(40.0, sheetHeight);

    final textStyle = TextStyle(
      fontFamily: 'JameelNoori',
      fontSize: fontSize * 0.95,
      height: 1.85,
      fontWeight: FontWeight.w600,
    );

    List<String> pages = [];
    String remainingText = fullText.trim();
    bool isFirstPage = true;

    while (remainingText.isNotEmpty) {
      final double targetH = isFirstPage ? p1BoxH : subBoxH;

      // TextPainter کے ذریعے ایک ایک سطر کی پیمائش
      final textPainter = TextPainter(
        text: TextSpan(text: remainingText, style: textStyle),
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
      );

      textPainter.layout(maxWidth: boxW - 12); // 12 پکسل اندرونی پیڈنگ

      final lines = textPainter.computeLineMetrics();

      if (lines.isEmpty) {
        pages.add(remainingText);
        break;
      }

      double currentHeight = 0;
      int fittedLinesCount = 0;

      for (var line in lines) {
        if (currentHeight + line.height <= targetH - 6) {
          currentHeight += line.height;
          fittedLinesCount++;
        } else {
          break; // جو سطر 1 پکسل بھی باکس سے نیچے جائے گی، یہیں کٹ لگے گا
        }
      }

      // اگر باکس اتنا چھوٹا ہو کہ ایک سطر بھی نہ سما سکے تو کم از کم ایک سطر لیں تاکہ انفینائٹ لوپ نہ بنے
      if (fittedLinesCount == 0) fittedLinesCount = 1;

      if (fittedLinesCount >= lines.length) {
        pages.add(remainingText);
        break;
      } else {
        // آخری فِٹ ہونے والی سطر کا آخری حرف معلوم کرنا
        final lineEndOffset = textPainter.getLineBoundary(
          textPainter.getPositionForOffset(Offset(boxW - 14, currentHeight - 2)),
        );

        int cutIndex = lineEndOffset.end;
        if (cutIndex <= 0 || cutIndex >= remainingText.length) {
          // محفوظ فال بیک
          cutIndex = (remainingText.length * (fittedLinesCount / lines.length)).round();
        }

        // لفظ کو ادھورا کٹنے سے بچانا
        while (cutIndex > 0 && cutIndex < remainingText.length && remainingText[cutIndex] != ' ' && remainingText[cutIndex] != '\n') {
          cutIndex--;
        }

        if (cutIndex <= 0) {
          cutIndex = lineEndOffset.end.clamp(1, remainingText.length);
        }

        pages.add(remainingText.substring(0, cutIndex).trim());
        remainingText = remainingText.substring(cutIndex).trim();
      }

      isFirstPage = false;
    }

    return pages.isEmpty ? [""] : pages;
  }
}