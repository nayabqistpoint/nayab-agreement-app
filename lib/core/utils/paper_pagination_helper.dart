// lib/core/utils/paper_pagination_helper.dart
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
    final double sheetWidth = isA4 ? 595.0 : 612.0;
    final double sheetHeight = isA4 ? 842.0 : 1008.0;

    final double boxW = (sheetWidth - (sideMargin * 2)).clamp(100.0, sheetWidth);
    final double p1BoxH = (sheetHeight - p1TopMargin - bottomMargin).clamp(50.0, sheetHeight);
    final double subBoxH = (sheetHeight - subsequentTopMargin - bottomMargin).clamp(50.0, sheetHeight);

    final baseStyle = TextStyle(
      fontFamily: 'JameelNoori',
      fontSize: fontSize,
      height: 1.85,
      fontWeight: FontWeight.w600,
    );

    final paragraphs = fullText.split('\n');
    List<String> pages = [];
    StringBuffer currentPageBuffer = StringBuffer();
    double currentHeight = 0;
    bool isFirstPage = true;

    for (int i = 0; i < paragraphs.length; i++) {
      final para = paragraphs[i];
      final targetH = isFirstPage ? p1BoxH : subBoxH;

      // پیراگراف کی اصل ہائٹ معلوم کریں
      final textPainter = TextPainter(
        text: _parseStyledSpans(para.isEmpty ? ' ' : para, baseStyle),
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
      );
      textPainter.layout(maxWidth: boxW - 14);
      final paraH = textPainter.height;

      // اگر نیا پیراگراف موجودہ صفحے میں سما سکتا ہے
      if (currentHeight + paraH <= targetH || currentPageBuffer.isEmpty) {
        if (currentPageBuffer.isNotEmpty) currentPageBuffer.write('\n');
        currentPageBuffer.write(para);
        currentHeight += paraH;
      } else {
        // صفحہ مکمل ہو گیا، نیا صفحہ شروع کریں
        pages.add(currentPageBuffer.toString());
        currentPageBuffer.clear();
        currentPageBuffer.write(para);
        currentHeight = paraH;
        isFirstPage = false;
      }
    }

    if (currentPageBuffer.isNotEmpty) {
      pages.add(currentPageBuffer.toString());
    }

    return pages.isEmpty ? [""] : pages;
  }

  static TextSpan _parseStyledSpans(String text, TextStyle base) {
    final List<InlineSpan> spans = [];
    final tagRegex = RegExp(r'\{\{.*?\}\}');
    int lastEnd = 0;

    for (final match in tagRegex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start), style: base));
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: base.copyWith(
            color: Colors.blue.shade900,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: base));
    }
    return TextSpan(children: spans);
  }
}