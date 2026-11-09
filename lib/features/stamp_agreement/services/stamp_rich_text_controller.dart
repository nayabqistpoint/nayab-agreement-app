// lib/features/stamp_agreement/services/stamp_rich_text_controller.dart
import 'package:flutter/material.dart';

class StampSpanStyle {
  int start;
  int end;
  bool isBold;
  bool isUnderline;
  double? fontSize;

  StampSpanStyle({
    required this.start,
    required this.end,
    this.isBold = false,
    this.isUnderline = false,
    this.fontSize,
  });

  Map<String, dynamic> toJson() => {
        'start': start,
        'end': end,
        'isBold': isBold,
        'isUnderline': isUnderline,
        'fontSize': fontSize,
      };

  factory StampSpanStyle.fromJson(Map<String, dynamic> json) => StampSpanStyle(
        start: json['start'] as int,
        end: json['end'] as int,
        isBold: json['isBold'] as bool? ?? false,
        isUnderline: json['isUnderline'] as bool? ?? false,
        fontSize: (json['fontSize'] as num?)?.toDouble(),
      );
}

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

  void setAlignment(TextAlign newAlign) {
    textAlign = newAlign;
    notifyListeners();
  }

  @override
  set value(TextEditingValue newValue) {
    final oldText = _previousText;
    final newText = newValue.text;
    if (oldText != newText && formattingSpans.isNotEmpty) {
      _adjustSpansOnTextChange(oldText, newText);
    }
    _previousText = newText;
    super.value = newValue;
  }

  void _adjustSpansOnTextChange(String oldText, String newText) {
    int diffIndex = 0;
    final minLen = oldText.length < newText.length ? oldText.length : newText.length;
    while (diffIndex < minLen && oldText[diffIndex] == newText[diffIndex]) {
      diffIndex++;
    }
    final diffLength = newText.length - oldText.length;

    for (int i = formattingSpans.length - 1; i >= 0; i--) {
      final s = formattingSpans[i];
      if (diffIndex <= s.start) {
        s.start += diffLength;
        s.end += diffLength;
      } else if (diffIndex > s.start && diffIndex <= s.end) {
        s.end += diffLength;
      }
      if (s.start < 0) s.start = 0;
      if (s.end > newText.length) s.end = newText.length;
      if (s.start >= s.end) {
        formattingSpans.removeAt(i);
      }
    }
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

  void applyFontSizeToRange(int start, int end, double size) {
    if (start >= end) return;
    _toggleOrApplyStyle(start, end, targetFontSize: size);
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

    final rawText = text;
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

    final List<int> sortedBoundaries = boundaries.toList()..sort();
    final List<InlineSpan> spans = [];

    for (int i = 0; i < sortedBoundaries.length - 1; i++) {
      final segStart = sortedBoundaries[i];
      final segEnd = sortedBoundaries[i + 1];
      if (segStart >= segEnd) continue;

      final segText = rawText.substring(segStart, segEnd);
      var segStyle = baseStyle;

      if (segText == '[C]' || segText == '[L]' || segText == '[R]') {
        spans.add(TextSpan(
          text: segText,
          style: baseStyle.copyWith(
            fontSize: 0.01,
            color: Colors.transparent,
            letterSpacing: -1.0,
          ),
        ));
        continue;
      }

      for (final s in formattingSpans) {
        if (segStart >= s.start && segEnd <= s.end) {
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

      if (segText.startsWith('{{') && segText.endsWith('}}')) {
        segStyle = segStyle.copyWith(
          color: Colors.blue.shade900,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.blue.shade50,
        );
      }

      spans.add(TextSpan(text: segText, style: segStyle));
    }

    return TextSpan(style: baseStyle, children: spans);
  }
}