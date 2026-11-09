import 'package:flutter/material.dart';
import '../models/stamp_span_style_model.dart';

class StampSpanParserService {
  static TextSpan buildFormattedTextSpan({
    required String rawText,
    required TextStyle baseStyle,
    required List<StampSpanStyle> formattingSpans,
  }) {
    if (rawText.isEmpty) return TextSpan(style: baseStyle, text: '');

    final tagRegex = RegExp(r'\{\{.*?\}\}');
    final alignRegex = RegExp(r'^\[(C|L|R)\]', multiLine: true);

    final Set<int> boundaries = {0, rawText.length};
    for (final s in formattingSpans) {
      if (s.start >= 0 && s.start <= rawText.length) boundaries.add(s.start);
      if (s.end >= 0 && s.end <= rawText.length) boundaries.add(s.end);
    }
    for (final m in tagRegex.allMatches(rawText)) {
      boundaries.add(m.start);
      boundaries.add(m.end);
    }
    for (final m in alignRegex.allMatches(rawText)) {
      boundaries.add(m.start);
      boundaries.add(m.end);
    }

    final List<int> sorted = boundaries.toList()..sort();
    final List<InlineSpan> spans = [];

    for (int i = 0; i < sorted.length - 1; i++) {
      final start = sorted[i];
      final end = sorted[i + 1];
      if (start >= end) continue;

      final seg = rawText.substring(start, end);
      var segStyle = baseStyle;

      if (seg == '[C]' || seg == '[L]' || seg == '[R]') {
        spans.add(TextSpan(
          text: seg,
          style: baseStyle.copyWith(
            fontSize: 0.01,
            color: Colors.transparent,
            letterSpacing: -1.0,
          ),
        ));
        continue;
      }

      for (final s in formattingSpans) {
        if (start >= s.start && end <= s.end) {
          if (s.isBold) {
            segStyle = segStyle.copyWith(
              fontWeight: FontWeight.w900,
              shadows: const [
                Shadow(color: Color(0xFF111111), offset: Offset(0.3, 0)),
                Shadow(color: Color(0xFF111111), offset: Offset(-0.3, 0)),
              ],
            );
          }
          if (s.isUnderline) {
            segStyle = segStyle.copyWith(
              decoration: TextDecoration.underline,
              decorationThickness: 1.5,
            );
          }
          if (s.fontSize != null) {
            segStyle = segStyle.copyWith(fontSize: s.fontSize);
          }
        }
      }

      if (seg.startsWith('{{') && seg.endsWith('}}')) {
        segStyle = segStyle.copyWith(
          color: Colors.blue.shade900,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.blue.shade50,
        );
      }

      spans.add(TextSpan(text: seg, style: segStyle));
    }

    return TextSpan(style: baseStyle, children: spans);
  }

  static void adjustSpansOnTextChange({
    required List<StampSpanStyle> spans,
    required String oldText,
    required String newText,
  }) {
    int diffIndex = 0;
    final minLen = oldText.length < newText.length ? oldText.length : newText.length;
    while (diffIndex < minLen && oldText[diffIndex] == newText[diffIndex]) {
      diffIndex++;
    }
    final diffLength = newText.length - oldText.length;

    for (int i = spans.length - 1; i >= 0; i--) {
      final s = spans[i];
      if (diffIndex <= s.start) {
        s.start += diffLength;
        s.end += diffLength;
      } else if (diffIndex > s.start && diffIndex <= s.end) {
        s.end += diffLength;
      }
      if (s.start < 0) s.start = 0;
      if (s.end > newText.length) s.end = newText.length;
      if (s.start >= s.end) {
        spans.removeAt(i);
      }
    }
  }
}