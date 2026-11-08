import 'package:flutter/material.dart';

class AgreementPaginationService {
  static List<String> paginate({
    required String fullText,
    required double fontSize,
    required double p1TopMargin,
    required double subsequentTopMargin,
    required double bottomMargin,
    required double sideMargin,
    String paperSize = 'Legal',
  }) {
    if (fullText.trim().isEmpty) return [""];

    final bool isA4 = paperSize.toUpperCase() == 'A4';
    const double sheetWidth = 390.0;
    final double sheetHeight = isA4 ? 552.0 : 642.0;
    final double totalHeightPoints = isA4 ? 842.0 : 1008.0;
    final double scale = sheetHeight / totalHeightPoints;

    final double boxW = (sheetWidth - ((sideMargin * scale).clamp(8.0, 45.0) * 2)).clamp(100.0, sheetWidth);
    final double p1BoxH = (sheetHeight - (p1TopMargin * scale) - (bottomMargin * scale)).clamp(40.0, sheetHeight);
    final double subBoxH = (sheetHeight - (subsequentTopMargin * scale) - (bottomMargin * scale)).clamp(40.0, sheetHeight);

    final baseStyle = TextStyle(
      fontFamily: 'JameelNoori',
      fontSize: fontSize * 0.95,
      height: 1.6,
      fontWeight: FontWeight.w600,
    );

    List<String> pages = [];
    String remainingText = fullText.trim();
    bool isFirstPage = true;

    while (remainingText.isNotEmpty) {
      final double targetH = isFirstPage ? p1BoxH : subBoxH;

      final textPainter = TextPainter(
        text: _parseStyledSpans(remainingText, baseStyle),
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
      );

      textPainter.layout(maxWidth: boxW - 8);
      final lines = textPainter.computeLineMetrics();

      if (lines.isEmpty) {
        pages.add(remainingText);
        break;
      }

      double currentHeight = 0;
      int fittedLinesCount = 0;

      for (var line in lines) {
        if (currentHeight + line.height <= targetH) {
          currentHeight += line.height;
          fittedLinesCount++;
        } else {
          break;
        }
      }

      if (fittedLinesCount == 0) fittedLinesCount = 1;

      if (fittedLinesCount >= lines.length) {
        pages.add(remainingText);
        break;
      } else {
        // آخری ممکنہ لائن کے اختتام کا درست تخمینہ
        final pos = textPainter.getPositionForOffset(Offset(boxW - 10, currentHeight - 4));
        int cutIndex = pos.offset;

        if (cutIndex <= 0 || cutIndex >= remainingText.length) {
          cutIndex = (remainingText.length * (fittedLinesCount / lines.length)).round();
        }

        // لفظ کو بیچ سے کٹنے سے بچانا
        while (cutIndex > 0 && cutIndex < remainingText.length && remainingText[cutIndex] != ' ' && remainingText[cutIndex] != '\n') {
          cutIndex--;
        }

        if (cutIndex <= 0) {
          cutIndex = pos.offset.clamp(1, remainingText.length);
        }

        pages.add(remainingText.substring(0, cutIndex).trim());
        remainingText = remainingText.substring(cutIndex).trim();
      }

      isFirstPage = false;
    }

    return pages.isEmpty ? [""] : pages;
  }

  /// <b> اور <u> کے ٹیگز کو اصل ریچ اسٹائل میں تبدیل کرنے کا ہیلپر
  static TextSpan _parseStyledSpans(String text, TextStyle base) {
    final List<InlineSpan> spans = [];
    final regex = RegExp(r'(<b>.*?<\/b>|<u>.*?<\/u>)', dotAll: true);
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start), style: base));
      }
      final matchedText = match.group(0)!;
      if (matchedText.startsWith('<b>')) {
        final content = matchedText.substring(3, matchedText.length - 4);
        spans.add(TextSpan(text: content, style: base.copyWith(fontWeight: FontWeight.bold)));
      } else if (matchedText.startsWith('<u>')) {
        final content = matchedText.substring(3, matchedText.length - 4);
        spans.add(TextSpan(text: content, style: base.copyWith(decoration: TextDecoration.underline)));
      }
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: base));
    }

    return TextSpan(children: spans);
  }
}