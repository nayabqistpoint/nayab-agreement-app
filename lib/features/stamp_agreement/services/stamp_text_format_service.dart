import 'package:flutter/material.dart';

class StampTextFormatService {
  static void insertTag(TextEditingController controller, String tagName) {
    final text = controller.text;
    final sel = controller.selection;
    final tag = '{{$tagName}}';
    if (sel.start >= 0) {
      final updated = text.replaceRange(sel.start, sel.end, tag);
      controller.value = TextEditingValue(
        text: updated,
        selection: TextSelection.collapsed(offset: sel.start + tag.length),
      );
    } else {
      controller.text += tag;
    }
  }

  static void insertFormatting(TextEditingController controller, String type) {
    final text = controller.text;
    final sel = controller.selection;
    if (sel.start >= 0 && sel.end > sel.start) {
      final selected = text.substring(sel.start, sel.end);
      final replaced = type == 'B' ? '**$selected**' : '<u>$selected</u>';
      controller.text = text.replaceRange(sel.start, sel.end, replaced);
    } else {
      insertTag(controller, type == 'B' ? 'بولڈ' : 'انڈر_لائن');
    }
  }

  static void insertSpacer(TextEditingController controller, int points) {
    final tag = '\n[space:$points]\n';
    final text = controller.text;
    final sel = controller.selection;
    if (sel.start >= 0) {
      controller.text = text.replaceRange(sel.start, sel.end, tag);
    } else {
      controller.text += tag;
    }
  }

  static String normalizeParagraphs(String raw) {
    if (raw.trim().isEmpty) return '';
    final paras = raw.split(RegExp(r'\n\s*\n'));
    List<String> cleaned = [];
    for (var p in paras) {
      var lines = p.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty);
      cleaned.add(lines.join(' '));
    }
    return cleaned.join('\n\n');
  }
}