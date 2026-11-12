import 'package:flutter/material.dart';

class AgreementPaginationService {
  static List<String> paginate({
    required String fullText,
    required double fontSize,
    required double p1TopMargin,
    required double subsequentTopMargin,
    required double bottomMargin,
    double? subsequentBottomMargin,
    required double sideMargin,
    String paperSize = 'Legal',
  }) {
    if (fullText.trim().isEmpty) return [""];

    final bool isA4 = paperSize.toUpperCase() == 'A4';
    final double sheetWidth = isA4 ? 595.0 : 612.0;
    final double sheetHeight = isA4 ? 842.0 : 1008.0;

    final double effectiveSubBottom = subsequentBottomMargin ?? 65.0;

    const double innerHorizontalPadding = 24.0;
    const double innerVerticalPadding = 16.0;

    final double boxW = (sheetWidth - (sideMargin * 2) - innerHorizontalPadding).clamp(80.0, sheetWidth);
    final double p1BoxH = (sheetHeight - p1TopMargin - bottomMargin - innerVerticalPadding).clamp(40.0, sheetHeight);
    final double subBoxH = (sheetHeight - subsequentTopMargin - effectiveSubBottom - innerVerticalPadding).clamp(40.0, sheetHeight);

    final baseStyle = TextStyle(
      fontFamily: 'JameelNoori',
      fontSize: fontSize,
      height: 1.85,
      fontWeight: FontWeight.w600,
    );

    final paragraphs = fullText.split('\n');
    final List<String> pages = [];
    StringBuffer currentPageBuffer = StringBuffer();
    double currentHeight = 0.0;
    bool isFirstPage = true;

    for (int pIdx = 0; pIdx < paragraphs.length; pIdx++) {
      final para = paragraphs[pIdx];
      final double targetH = isFirstPage ? p1BoxH : subBoxH;

      if (para.trim().isEmpty) {
        const double emptyLineH = 24.0;
        if (currentHeight + emptyLineH <= targetH || currentPageBuffer.isEmpty) {
          if (currentPageBuffer.isNotEmpty) currentPageBuffer.write('\n');
          currentPageBuffer.write('');
          currentHeight += emptyLineH;
        } else {
          pages.add(currentPageBuffer.toString());
          currentPageBuffer.clear();
          currentHeight = emptyLineH;
          isFirstPage = false;
        }
        continue;
      }

      final textPainter = TextPainter(
        text: TextSpan(text: para, style: baseStyle),
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
      );
      textPainter.layout(maxWidth: boxW);

      if (currentHeight + textPainter.height <= targetH || currentPageBuffer.isEmpty) {
        if (currentPageBuffer.isNotEmpty) currentPageBuffer.write('\n');
        currentPageBuffer.write(para);
        currentHeight += textPainter.height;
      } else {
        final words = para.split(' ');
        StringBuffer currentParaBuffer = StringBuffer();

        for (int wIdx = 0; wIdx < words.length; wIdx++) {
          final testText = currentParaBuffer.isEmpty
              ? words[wIdx]
              : '${currentParaBuffer.toString()} ${words[wIdx]}';

          final testPainter = TextPainter(
            text: TextSpan(text: testText, style: baseStyle),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          );
          testPainter.layout(maxWidth: boxW);

          if (currentHeight + testPainter.height <= targetH || currentPageBuffer.isEmpty) {
            currentParaBuffer.clear();
            currentParaBuffer.write(testText);
          } else {
            if (currentPageBuffer.isNotEmpty) currentPageBuffer.write('\n');
            currentPageBuffer.write(currentParaBuffer.toString());
            pages.add(currentPageBuffer.toString());

            currentPageBuffer.clear();
            currentParaBuffer.clear();
            currentParaBuffer.write(words[wIdx]);

            isFirstPage = false;

            final nextPainter = TextPainter(
              text: TextSpan(text: words[wIdx], style: baseStyle),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            );
            nextPainter.layout(maxWidth: boxW);
            currentHeight = nextPainter.height;
          }
        }

        if (currentParaBuffer.isNotEmpty) {
          if (currentPageBuffer.isNotEmpty) currentPageBuffer.write('\n');
          currentPageBuffer.write(currentParaBuffer.toString());
          final finalPainter = TextPainter(
            text: TextSpan(text: currentParaBuffer.toString(), style: baseStyle),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          );
          finalPainter.layout(maxWidth: boxW);
          currentHeight += finalPainter.height;
        }
      }
    }

    if (currentPageBuffer.isNotEmpty) {
      pages.add(currentPageBuffer.toString());
    }

    return pages.isEmpty ? [""] : pages;
  }
}