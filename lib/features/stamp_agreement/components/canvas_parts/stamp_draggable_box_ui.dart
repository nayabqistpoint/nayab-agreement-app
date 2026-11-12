import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/stamp_overlay_field_model.dart';

class StampDraggableBoxUi extends StatefulWidget {
  final StampOverlayFieldModel field;
  final bool isSelected;
  final VoidCallback onSelect;
  final Function(double dx, double dy) onDrag;
  final Function(String newText)? onTextEdited;

  const StampDraggableBoxUi({
    super.key,
    required this.field,
    required this.isSelected,
    required this.onSelect,
    required this.onDrag,
    this.onTextEdited,
  });

  @override
  State<StampDraggableBoxUi> createState() => _StampDraggableBoxUiState();
}

class _StampDraggableBoxUiState extends State<StampDraggableBoxUi> {
  late final TextEditingController _editCtrl;

  @override
  void initState() {
    super.initState();
    _editCtrl = TextEditingController(text: widget.field.tag);
  }

  @override
  void didUpdateWidget(covariant StampDraggableBoxUi oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.field.tag != widget.field.tag) {
      if (_editCtrl.text != widget.field.tag) {
        _editCtrl.text = widget.field.tag;
      }
    }
  }

  @override
  void dispose() {
    _editCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.field;
    final bool isTag = f.tag.startsWith('{{') && f.tag.endsWith('}}');

    final textStyle = TextStyle(
      fontFamily: f.fontType.isNotEmpty ? f.fontType : 'JameelNoori',
      fontSize: f.fontSize,
      fontWeight: f.isBold || isTag ? FontWeight.bold : FontWeight.normal,
      decoration: f.isUnderline ? TextDecoration.underline : TextDecoration.none,
      decorationThickness: f.isBold ? 2.5 : 1.2,
      color: isTag ? Colors.blue.shade900 : AppColors.primaryEmerald,
      height: 1.8,
    );

    return Positioned(
      left: f.x,
      top: f.y,
      child: MouseRegion(
        cursor: SystemMouseCursors.move,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onSelect,
          onPanUpdate: (details) => widget.onDrag(details.delta.dx, details.delta.dy),
          child: Container(
            constraints: const BoxConstraints(minWidth: 40, maxWidth: 450),
            padding: EdgeInsets.symmetric(
              horizontal: widget.isSelected ? 8 : 4,
              vertical: widget.isSelected ? 4 : 2,
            ),
            decoration: BoxDecoration(
              color: isTag
                  ? Colors.blue.shade50
                  : (widget.isSelected ? AppColors.primaryEmerald.withAlpha(25) : Colors.transparent),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.primaryEmerald
                    : (isTag ? Colors.blue.shade300 : Colors.transparent),
                width: widget.isSelected ? 1.8 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.isSelected)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.drag_indicator,
                      size: 20,
                      color: AppColors.primaryEmerald,
                    ),
                  ),
                if (widget.isSelected)
                  Flexible(
                    child: IntrinsicWidth(
                      child: TextField(
                        controller: _editCtrl,
                        style: textStyle,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          border: InputBorder.none,
                          hintText: 'تحریر یا {{ٹیگ}} لکھیں...',
                          hintStyle: TextStyle(
                            color: Colors.black38,
                            fontSize: f.fontSize,
                            fontFamily: 'JameelNoori',
                          ),
                        ),
                        onChanged: (val) {
                          widget.onTextEdited?.call(val);
                        },
                      ),
                    ),
                  )
                else
                  Text(
                    f.tag.isEmpty ? 'خالی تحریر' : f.tag,
                    textDirection: TextDirection.rtl,
                    style: f.tag.isEmpty
                        ? textStyle.copyWith(color: Colors.black26, fontStyle: FontStyle.italic)
                        : textStyle,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}