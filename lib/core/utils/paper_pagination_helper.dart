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

      final textPainter = TextPainter(
        text: TextSpan(text: remainingText, style: textStyle),
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
      );

      textPainter.layout(maxWidth: boxW - 12);
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
          break;
        }
      }

      if (fittedLinesCount == 0) fittedLinesCount = 1;

      if (fittedLinesCount >= lines.length) {
        pages.add(remainingText);
        break;
      } else {
        final lineEndOffset = textPainter.getLineBoundary(
          textPainter.getPositionForOffset(Offset(boxW - 14, currentHeight - 2)),
        );

        int cutIndex = lineEndOffset.end;
        if (cutIndex <= 0 || cutIndex >= remainingText.length) {
          cutIndex = (remainingText.length * (fittedLinesCount / lines.length)).round();
        }

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