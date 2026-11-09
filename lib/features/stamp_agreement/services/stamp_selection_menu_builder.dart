import 'package:flutter/material.dart';
import 'stamp_rich_text_controller.dart';

class StampSelectionMenuBuilder {
  static Widget build({
    required BuildContext context,
    required EditableTextState editableTextState,
    required TextEditingController controller,
    required double baseFontSize,
    required VoidCallback onModified,
  }) {
    final endpoints = editableTextState.renderEditable.getEndpointsForSelection(
      controller.selection,
    );
    if (endpoints.isEmpty) {
      return const SizedBox.shrink();
    }
    final midpoint = editableTextState.renderEditable.localToGlobal(
      Offset(
        (endpoints.first.point.dx + endpoints.last.point.dx) / 2,
        endpoints.first.point.dy - 10,
      ),
    );

    return Stack(
      children: [
        Positioned(
          top: (midpoint.dy - 50).clamp(40.0, MediaQuery.of(context).size.height - 100),
          left: (midpoint.dx - 110).clamp(10.0, MediaQuery.of(context).size.width - 240),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFF1E293B),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _btn('بولڈ (B)', () {
                    editableTextState.hideToolbar();
                    if (controller is StampRichTextController) {
                      final sel = controller.selection;
                      if (sel.isValid && !sel.isCollapsed) {
                        controller.applyBoldToRange(sel.start, sel.end);
                      }
                    }
                    onModified();
                  }),
                  _divider(),
                  _btn('انڈر لائن (U)', () {
                    editableTextState.hideToolbar();
                    if (controller is StampRichTextController) {
                      final sel = controller.selection;
                      if (sel.isValid && !sel.isCollapsed) {
                        controller.applyUnderlineToRange(sel.start, sel.end);
                      }
                    }
                    onModified();
                  }),
                  _divider(),
                  _btn('بڑا (+)', () {
                    editableTextState.hideToolbar();
                    if (controller is StampRichTextController) {
                      final sel = controller.selection;
                      if (sel.isValid && !sel.isCollapsed) {
                        controller.incrementFontSizeInRange(sel.start, sel.end, 2.0);
                      }
                    }
                    onModified();
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _btn(String label, VoidCallback tap) => InkWell(
        onTap: tap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      );

  static Widget _divider() => Container(
        height: 16,
        width: 1,
        color: Colors.white24,
        margin: const EdgeInsets.symmetric(horizontal: 2),
      );
}