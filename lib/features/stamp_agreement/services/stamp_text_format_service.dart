import 'package:flutter/material.dart';

class StampTextFormatService {
  /// کرسر کی موجودہ جگہ پر محفوظ طریقے سے متن داخل کرنے اور فوکس برقرار رکھنے کا ہیلپر
  static void insertAtCursor(
    TextEditingController controller,
    String textToInsert, {
    int cursorOffsetInside = 0,
  }) {
    final text = controller.text;
    final selection = controller.selection;

    int start = selection.start;
    int end = selection.end;

    if (start < 0 || end < 0) {
      start = text.length;
      end = text.length;
    }

    final newText = text.replaceRange(start, end, textToInsert);
    final int newCursorPos = (cursorOffsetInside > 0)
        ? (start + cursorOffsetInside)
        : (start + textToInsert.length);

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }

  /// ٹیگ داخل کرنا (جیسے {{نام}})
  static void insertTag(TextEditingController controller, String tag) {
    insertAtCursor(controller, '{{$tag}} ');
  }

  /// خالی عارضی ٹیگ داخل کرنا اور کرسر کو بریکٹس کے بیچ بلنک کروانا
  static void insertEmptyTag(TextEditingController controller) {
    insertAtCursor(controller, '{{}}', cursorOffsetInside: 2);
  }

  /// کمپیوٹر جیسا قدرتی ان-سین اسپیس (فورسڈ اسپیس)
  static void insertForcedSpace(TextEditingController controller) {
    insertAtCursor(controller, '\u00A0\u00A0\u00A0\u00A0');
  }

  /// پچھلے کمپیٹیبلٹی کے لیے اسپیسر میتھڈ (اگر کہیں کال ہو رہا ہو)
  static void insertSpacer(TextEditingController controller, [int? points]) {
    insertForcedSpace(controller);
  }

  /// پیراگراف کو نارملائز کرنا (فالتو خالی لائنیں اور غیر ضروری وقفے صاف کرنا)
  static void normalizeParagraphs(TextEditingController controller) {
    final text = controller.text;
    if (text.isEmpty) return;

    // دو سے زیادہ خالی لائنوں کو ایک لائن میں بدلنا اور اضافی اسپیسز صاف کرنا
    final normalized = text
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
        .trim();

    controller.value = TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );
  }

  /// بولڈ یا انڈر لائن وغیرہ
  static void insertFormatting(TextEditingController controller, String format) {
    final text = controller.text;
    final selection = controller.selection;

    if (!selection.isValid || selection.isCollapsed) {
      insertAtCursor(controller, '<$format></$format>', cursorOffsetInside: format.length + 2);
      return;
    }

    final selectedText = text.substring(selection.start, selection.end);
    final formatted = '<$format>$selectedText</$format>';
    insertAtCursor(controller, formatted);
  }
}