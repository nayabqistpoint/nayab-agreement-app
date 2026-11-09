import 'package:flutter/material.dart';

class StampParagraphService {
  static ({int lineStart, int lineEnd, String currentLine}) getLineAtCursor(
    String fullText,
    int cursorPos,
  ) {
    if (fullText.isEmpty) {
      return (lineStart: 0, lineEnd: 0, currentLine: '');
    }

    final safePos = cursorPos.clamp(0, fullText.length);

    int start = fullText.lastIndexOf('\n', safePos > 0 ? safePos - 1 : 0);
    start = (start == -1) ? 0 : start + 1;

    int end = fullText.indexOf('\n', safePos);
    end = (end == -1) ? fullText.length : end;

    return (
      lineStart: start,
      lineEnd: end,
      currentLine: fullText.substring(start, end),
    );
  }

  static void toggleBullet(TextEditingController controller, {String bullet = '★ '}) {
    final text = controller.text;
    final sel = controller.selection;
    final pos = sel.isValid ? sel.baseOffset : text.length;

    final lineInfo = getLineAtCursor(text, pos);
    final current = lineInfo.currentLine;

    String updatedLine;
    int cursorShift;

    if (current.trimLeft().startsWith(bullet.trim())) {
      updatedLine = current.replaceFirst(bullet, '');
      cursorShift = -bullet.length;
    } else {
      updatedLine = '$bullet$current';
      cursorShift = bullet.length;
    }

    final newFullText = text.replaceRange(lineInfo.lineStart, lineInfo.lineEnd, updatedLine);
    final newPos = (pos + cursorShift).clamp(0, newFullText.length);

    controller.value = TextEditingValue(
      text: newFullText,
      selection: TextSelection.collapsed(offset: newPos),
    );
  }

  static void alignCurrentLine(TextEditingController controller, TextAlign alignment) {
    final text = controller.text;
    final sel = controller.selection;
    final pos = sel.isValid ? sel.baseOffset : text.length;

    final lineInfo = getLineAtCursor(text, pos);
    var line = lineInfo.currentLine.trimLeft();

    // پرانے الائنمنٹ ٹیگز صاف کریں
    line = line.replaceAll(RegExp(r'^\[(C|L|R)\]'), '');

    String prefix = '';
    if (alignment == TextAlign.center) {
      prefix = '[C]';
    } else if (alignment == TextAlign.left) {
      prefix = '[L]';
    } else {
      prefix = ''; // دائیں طرف کے لیے سادہ لائن
    }

    final updatedLine = '$prefix$line';
    final newFullText = text.replaceRange(lineInfo.lineStart, lineInfo.lineEnd, updatedLine);

    controller.value = TextEditingValue(
      text: newFullText,
      selection: TextSelection.collapsed(
        offset: (lineInfo.lineStart + updatedLine.length).clamp(0, newFullText.length),
      ),
    );
  }
}