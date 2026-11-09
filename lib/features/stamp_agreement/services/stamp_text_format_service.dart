import 'package:flutter/material.dart';
import 'stamp_rich_text_controller.dart';

class StampTextFormatService {
  static void insertAtCursor(
    TextEditingController controller,
    String textToInsert, {
    int cursorOffsetInside = 0,
    FocusNode? focusNode,
  }) {
    final text = controller.text;
    final selection = controller.selection;

    int start = selection.start;
    int end = selection.end;

    if (start < 0 || end < 0) {
      start = text.length;
      end = text.length;
    }

    if (start > end) {
      final temp = start;
      start = end;
      end = temp;
    }

    start = start.clamp(0, text.length);
    end = end.clamp(0, text.length);

    final newText = text.replaceRange(start, end, textToInsert);
    final int newCursorPos = (cursorOffsetInside > 0)
        ? (start + cursorOffsetInside)
        : (start + textToInsert.length);

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos.clamp(0, newText.length)),
    );

    if (focusNode != null && !focusNode.hasFocus) {
      focusNode.requestFocus();
    }
  }

  static void insertForcedSpace(TextEditingController controller, [FocusNode? focusNode]) {
    insertAtCursor(controller, '\u00A0\u00A0\u00A0\u00A0', focusNode: focusNode);
  }

  static void insertTag(TextEditingController controller, String tag, [FocusNode? focusNode]) {
    final clean = tag.replaceAll('{{', '').replaceAll('}}', '').trim();
    insertAtCursor(controller, '{{$clean}} ', focusNode: focusNode);
  }

  static void insertEmptyTag(TextEditingController controller, [FocusNode? focusNode]) {
    insertAtCursor(controller, '{{}}', cursorOffsetInside: 2, focusNode: focusNode);
  }

  static void insertFormatting(TextEditingController controller, String format, [FocusNode? focusNode]) {
    final selection = controller.selection;
    if (!selection.isValid || selection.isCollapsed) return;

    int start = selection.start;
    int end = selection.end;
    if (start > end) {
      final temp = start;
      start = end;
      end = temp;
    }

    if (controller is StampRichTextController) {
      if (format.toLowerCase() == 'b') {
        controller.applyBoldToRange(start, end);
      } else if (format.toLowerCase() == 'u') {
        controller.applyUnderlineToRange(start, end);
      }
    }

    if (focusNode != null && !focusNode.hasFocus) {
      focusNode.requestFocus();
    }
  }

  static void applyFontSizeToSelection(TextEditingController controller, double size, [FocusNode? focusNode]) {
    final selection = controller.selection;
    if (!selection.isValid || selection.isCollapsed) return;

    int start = selection.start;
    int end = selection.end;
    if (start > end) {
      final temp = start;
      start = end;
      end = temp;
    }

    if (controller is StampRichTextController) {
      final currentSize = controller.getSelectedFontSize(start, end);
      final double delta = (size - currentSize).toDouble();
      controller.incrementFontSizeInRange(start, end, delta);
    }

    if (focusNode != null && !focusNode.hasFocus) {
      focusNode.requestFocus();
    }
  }

  static void insertSpacer(TextEditingController controller, [int? points, FocusNode? focusNode]) {
    insertForcedSpace(controller, focusNode);
  }

  static void normalizeParagraphs(TextEditingController controller) {
    final text = controller.text;
    if (text.isEmpty) return;

    final normalized = text
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();

    controller.value = TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );
  }
}