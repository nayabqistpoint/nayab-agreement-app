import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/stamp_overlay_field_model.dart';
import 'canvas_parts/stamp_draggable_box_ui.dart';

class StampOverlayCanvasLayerUi extends StatelessWidget {
  final int pageIndex;
  final double sheetWidth;
  final double sheetHeight;
  final List<StampOverlayFieldModel> fields;
  final String? selectedFieldId;
  final double toolbarScale;
  final bool isPlacementActive;
  final Function(Offset localPos) onCanvasTap;
  final VoidCallback onDismissSelection;
  final Function(String id) onSelectField;
  final Function(String id, double dx, double dy) onDragField;
  final Function(String id) onDeleteField;
  final Function(String id, double newSize) onFontSizeChange;
  final Function(String id) onToggleBold;
  final Function(String id) onToggleUnderline;
  final Function(String id, String newText) onTextEdited;
  final Function(double delta) onAdjustToolbarScale;

  const StampOverlayCanvasLayerUi({
    super.key,
    required this.pageIndex,
    required this.sheetWidth,
    required this.sheetHeight,
    required this.fields,
    required this.selectedFieldId,
    required this.toolbarScale,
    required this.isPlacementActive,
    required this.onCanvasTap,
    required this.onDismissSelection,
    required this.onSelectField,
    required this.onDragField,
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
    final pageFields = fields.where((f) => f.pageIndex == pageIndex).toList();

    StampOverlayFieldModel? selectedField;
    if (selectedFieldId != null) {
      final idx = pageFields.indexWhere((f) => f.id == selectedFieldId);
      if (idx != -1) selectedField = pageFields[idx];
    }

    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. خالی کینوس پر کلک کا محافظ: اگر ٹول بار کھلا ہو تو فوراً بند کرے، اگر اوورلے ایکٹو ہو تو نئی تحریر لگائے
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapUp: (details) {
                if (isPlacementActive) {
                  onCanvasTap(details.localPosition);
                } else if (selectedFieldId != null) {
                  onDismissSelection();
                }
              },
              child: isPlacementActive
                  ? Container(
                      color: AppColors.primaryEmerald.withAlpha(20),
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6)],
                        ),
                        child: const Text(
                          'کسی بھی جگہ کلک کر کے نئی تحریر لگائیں (باہر کلک سے کینسل)',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'JameelNoori', fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  : const SizedBox.expand(),
            ),
          ),

          // 2. فلوٹنگ باکسز
          ...pageFields.map((f) => StampDraggableBoxUi(
            field: f,
            isSelected: f.id == selectedFieldId,
            onSelect: () => onSelectField(f.id),
            onDrag: (dx, dy) => onDragField(f.id, dx, dy),
            onTextEdited: (newText) => onTextEdited(f.id, newText),
          )),

          // 3. ٹول بار پاپ اپ (موبائل فرینڈلی، نمایاں بٹنز اور اسکیل زوم کے ساتھ)
          if (selectedField != null)
            Positioned(
              left: selectedField.x.clamp(8.0, (sheetWidth - (310.0 * toolbarScale)).clamp(10.0, sheetWidth)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Colors.black54, blurRadius: 10, spreadRadius: 1, offset: Offset(0, 4)),
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
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
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
                        Container(height: 18, width: 1.2, color: Colors.white30),
                        const SizedBox(width: 4),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onFontSizeChange(selectedField!.id, selectedField.fontSize - 1),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                            child: Icon(Icons.remove_circle_outline, size: 21, color: Colors.white),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            '${selectedField.fontSize.round()}',
                            style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onFontSizeChange(selectedField!.id, selectedField.fontSize + 1),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                            child: Icon(Icons.add_circle_outline, size: 21, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(height: 18, width: 1.2, color: Colors.white30),
                        const SizedBox(width: 4),
                        // ٹول بار سائز بڑھانے / گھٹانے کے مخصوص موبائل ہینڈلز
                        Tooltip(
                          message: 'ٹول بار چھوٹا کریں',
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onAdjustToolbarScale(-0.2),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              child: Text('T-', style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12.5)),
                            ),
                          ),
                        ),
                        Tooltip(
                          message: 'ٹول بار بڑا کریں',
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onAdjustToolbarScale(0.2),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              child: Text('T+', style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(height: 18, width: 1.2, color: Colors.white30),
                        const SizedBox(width: 4),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onDeleteField(selectedField!.id),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                            child: Icon(Icons.delete_forever, size: 23, color: Colors.redAccent),
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
    );
  }
}