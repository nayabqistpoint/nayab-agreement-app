import 'package:flutter/material.dart';
import '../models/stamp_span_style_model.dart';
import 'stamp_span_parser_service.dart';

class StampRichTextController extends TextEditingController {
  double defaultFontSize;
  TextAlign textAlign;
  List<StampSpanStyle> formattingSpans = [];
  String _previousText = '';

  StampRichTextController({
    super.text,
    this.defaultFontSize = 14.0,
    this.textAlign = TextAlign.right,
  }) {
    _previousText = text;
  }

  @override
  set value(TextEditingValue newValue) {
    final oldText = _previousText;
    final newText = newValue.text;
    if (oldText != newText && formattingSpans.isNotEmpty) {
      StampSpanParserService.adjustSpansOnTextChange(
        spans: formattingSpans,
        oldText: oldText,
        newText: newText,
      );
    }
    _previousText = newText;
    super.value = newValue;
  }

  double getSelectedFontSize(int start, int end) {
    for (final s in formattingSpans) {
      if (start >= s.start && end <= s.end && s.fontSize != null) {
        return s.fontSize!;
      }
    }
    return defaultFontSize;
  }

  void applyBoldToRange(int start, int end) {
    if (start >= end) return;
    _toggleOrApplyStyle(start, end, toggleBold: true);
    notifyListeners();
  }

  void applyUnderlineToRange(int start, int end) {
    if (start >= end) return;
    _toggleOrApplyStyle(start, end, toggleUnderline: true);
    notifyListeners();
  }

  void incrementFontSizeInRange(int start, int end, double delta) {
    if (start >= end) return;
    final currentSize = getSelectedFontSize(start, end);
    final targetSize = (currentSize + delta).clamp(10.0, 36.0);
    _toggleOrApplyStyle(start, end, targetFontSize: targetSize);
    notifyListeners();
  }

  void _toggleOrApplyStyle(
    int start,
    int end, {
    bool? toggleBold,
    bool? toggleUnderline,
    double? targetFontSize,
  }) {
    StampSpanStyle? found;
    for (final s in formattingSpans) {
      if (s.start == start && s.end == end) {
        found = s;
        break;
      }
    }

    if (found != null) {
      if (toggleBold == true) found.isBold = !found.isBold;
      if (toggleUnderline == true) found.isUnderline = !found.isUnderline;
      if (targetFontSize != null) found.fontSize = targetFontSize;
    } else {
      formattingSpans.add(StampSpanStyle(
        start: start,
        end: end,
        isBold: toggleBold ?? false,
        isUnderline: toggleUnderline ?? false,
        fontSize: targetFontSize,
      ));
    }

    formattingSpans.removeWhere(
      (s) => !s.isBold && !s.isUnderline && s.fontSize == null,
    );
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final baseStyle = style ??
        TextStyle(
          fontFamily: 'JameelNoori',
          fontSize: defaultFontSize,
          color: const Color(0xFF111111),
          height: 1.85,
        );

    return StampSpanParserService.buildFormattedTextSpan(
      rawText: text,
      baseStyle: baseStyle,
      formattingSpans: formattingSpans,
    );
  }
}