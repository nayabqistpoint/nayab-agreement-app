import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nayab_agreement_app/core/constants/app_colors.dart';
import '../models/pdf_overlay_field_model.dart';
import 'pdf_draggable_box_ui.dart';

class PdfEditorCanvasSheetUi extends StatelessWidget {
  final double sheetWidth;
  final double sheetHeight;
  final Uint8List? bgImage;
  final List<PdfOverlayFieldModel> fields;
  final String? selectedFieldId;
  final double toolbarScale;
  final Function(Offset localPosition) onCanvasTapWithPos;
  final Function(String id) onSelectField;
  final Function(String id, double dx, double dy) onDragField;
  final Function(String id, double newWidth) onResizeFieldWidth;
  final Function(String id) onDeleteField;
  final Function(String id, double newSize) onFontSizeChange;
  final Function(String id) onToggleBold;
  final Function(String id) onToggleUnderline;
  final Function(String id, String newText) onTextEdited;
  final Function(double delta) onAdjustToolbarScale;

  const PdfEditorCanvasSheetUi({
    super.key,
    required this.sheetWidth,
    required this.sheetHeight,
    required this.bgImage,
    required this.fields,
    required this.selectedFieldId,
    required this.toolbarScale,
    required this.onCanvasTapWithPos,
    required this.onSelectField,
    required this.onDragField,
    required this.onResizeFieldWidth,
    required this.onDeleteField,
    required this.onFontSizeChange,
    required this.onToggleBold,
    required this.onToggleUnderline,
    required this.onTextEdited,
    required this.onAdjustToolbarScale,
  });

  Widget _buildToolbarBtn({
    required Widget child,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryEmerald : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    PdfOverlayFieldModel? selectedField;
    if (selectedFieldId != null) {
      final idx = fields.indexWhere((f) => f.id == selectedFieldId);
      if (idx != -1) {
        selectedField = fields[idx];
      }
    }

    return FittedBox(
      fit: BoxFit.contain,
      child: Container(
        width: sheetWidth,
        height: sheetHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) => onCanvasTapWithPos(details.localPosition),
                child: bgImage != null
                    ? Image.memory(
                        bgImage!,
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.high,
                      )
                    : Center(
                        child: Opacity(
                          opacity: 0.1,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.picture_as_pdf, size: 70),
                              SizedBox(height: 8),
                              Text(
                                'اوپر سے اپنی رسید یا انوائس PDF اپلوڈ کریں',
                                style: TextStyle(
                                  fontFamily: 'JameelNoori',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
            ...fields.map(
              (f) => PdfDraggableBoxUi(
                field: f,
                isSelected: f.id == selectedFieldId,
                onSelect: () => onSelectField(f.id),
                onDrag: (dx, dy) => onDragField(f.id, dx, dy),
                onResizeWidth: (newW) => onResizeFieldWidth(f.id, newW),
                onTextEdited: (newText) => onTextEdited(f.id, newText),
              ),
            ),
            if (selectedField != null)
              Positioned(
                left: selectedField.x.clamp(
                  8.0,
                  (sheetWidth - (310.0 * toolbarScale)).clamp(10.0, sheetWidth),
                ),
                top: (selectedField.y - (62.0 * toolbarScale)) < 5.0
                    ? (selectedField.y + 50.0)
                    : (selectedField.y - (62.0 * toolbarScale)),
                child: Transform.scale(
                  scale: toolbarScale,
                  alignment: Alignment.bottomLeft,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildToolbarBtn(
                            onTap: () => onToggleBold(selectedField!.id),
                            isActive: selectedField.isBold,
                            child: const Text(
                              'B',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          _buildToolbarBtn(
                            onTap: () => onToggleUnderline(selectedField!.id),
                            isActive: selectedField.isUnderline,
                            child: const Text(
                              'U',
                              style: TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            height: 18,
                            width: 1.2,
                            color: Colors.white30,
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onFontSizeChange(
                              selectedField!.id,
                              selectedField.fontSize - 1,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 5,
                              ),
                              child: Icon(
                                Icons.remove_circle_outline,
                                size: 21,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              '${selectedField.fontSize.round()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onFontSizeChange(
                              selectedField!.id,
                              selectedField.fontSize + 1,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 5,
                              ),
                              child: Icon(
                                Icons.add_circle_outline,
                                size: 21,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            height: 18,
                            width: 1.2,
                            color: Colors.white30,
                          ),
                          const SizedBox(width: 4),
                          Tooltip(
                            message: 'ٹول بار چھوٹا کریں',
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => onAdjustToolbarScale(-0.2),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 5,
                                ),
                                child: Text(
                                  'T-',
                                  style: TextStyle(
                                    color: Colors.amberAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Tooltip(
                            message: 'ٹول بار بڑا کریں',
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => onAdjustToolbarScale(0.2),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 5,
                                ),
                                child: Text(
                                  'T+',
                                  style: TextStyle(
                                    color: Colors.amberAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            height: 18,
                            width: 1.2,
                            color: Colors.white30,
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onDeleteField(selectedField!.id),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 5,
                              ),
                              child: Icon(
                                Icons.delete_forever,
                                size: 23,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}