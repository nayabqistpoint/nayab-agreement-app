import 'package:flutter/material.dart';
import 'stamp_paragraph_service.dart';

class StampAlignmentService {
  /// ایم-اسپیس داخل کرنا
  static void insertEmSpace(TextEditingController controller) {
    final sel = controller.selection;
    final int start = sel.start.clamp(0, controller.text.length);
    final int end = sel.end.clamp(0, controller.text.length);

    const emSpace = '\u2003\u2003';
    final currentText = controller.text;

    final newText = currentText.replaceRange(start, end, emSpace);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + emSpace.length),
    );
  }

  /// منتخب سطر کو سینٹر، لیفٹ یا رائٹ الائن کرنا
  static void alignLine(TextEditingController controller, TextAlign alignment) {
    final sel = controller.selection;
    final int cursorPos = sel.start < 0 ? controller.text.length : sel.start;
    final text = controller.text;

    final lineInfo = StampParagraphService.getLineAtCursor(text, cursorPos);
    var line = lineInfo.currentLine;

    // پچھلی تمام اسپیسز اور ٹیگز کو صاف کریں
    line = line.replaceFirst(RegExp(r'^[\u2003\s]+'), '');
    line = line.replaceAll(RegExp(r'^\[(C|L|R)\]'), '');

    String updatedLine;
    if (alignment == TextAlign.center) {
      updatedLine = '\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003$line';
    } else if (alignment == TextAlign.left) {
      updatedLine = '\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003$line';
    } else {
      updatedLine = line;
    }

    final newFullText = text.replaceRange(lineInfo.lineStart, lineInfo.lineEnd, updatedLine);
    controller.value = TextEditingValue(
      text: newFullText,
      selection: TextSelection.collapsed(offset: lineInfo.lineStart + updatedLine.length),
    );
  }
}