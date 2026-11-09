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

  static void insertTag(TextEditingController controller, String tag, [FocusNode? focusNode]) {
    final clean = tag.replaceAll('{{', '').replaceAll('}}', '').trim();
    insertAtCursor(controller, '{{$clean}} ', focusNode: focusNode);
  }

  /// خالی ٹیگ کشادہ جگہ کے ساتھ اور کرسر خود بخود عین درمیان میں
  static void insertEmptyTag(TextEditingController controller, [FocusNode? focusNode]) {
    const template = '{{   }}'; // اندر 3 سپیسز کی کشادگی
    insertAtCursor(
      controller,
      template,
      cursorOffsetInside: 3, // کرسر کو دونوں بریکٹس کے عین بیچ میں ٹھہرائے گا
      focusNode: focusNode,
    );
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

  /// سطریں ہموار کریں: غیر ضروری اینٹرز، پوشیدہ بریکس اور کاپی پیسٹ کی خرابیاں ختم کر کے مسلسل متن بنانا
  static void normalizeParagraphs(TextEditingController controller) {
    final text = controller.text;
    if (text.trim().isEmpty) return;

    // تمام اضافی لائن بریکس، پوشیدہ کیرج ریٹرنز اور ٹیبز کو ختم کر کے سطروں کو جوڑنا
    String normalized = text
        .replaceAll('\r\n', ' ')
        .replaceAll('\r', ' ')
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'[ \t]{2,}'), ' ') // اضافی درمیانی خالی جگہیں ایک کرنا
        .trim();

    controller.value = TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );
  }
}