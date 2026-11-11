import 'package:flutter/material.dart';
import 'package:nayab_agreement_app/core/constants/app_colors.dart';
import 'package:nayab_agreement_app/features/pdf_editor/models/pdf_overlay_field_model.dart';

class PdfDraggableBoxUi extends StatefulWidget {
  final PdfOverlayFieldModel field;
  final bool isSelected;
  final VoidCallback onSelect;
  final Function(double dx, double dy) onDrag;
  final Function(String newText)? onTextEdited;

  const PdfDraggableBoxUi({
    super.key,
    required this.field,
    required this.isSelected,
    required this.onSelect,
    required this.onDrag,
    this.onTextEdited,
  });

  @override
  State<PdfDraggableBoxUi> createState() => _PdfDraggableBoxUiState();
}

class _PdfDraggableBoxUiState extends State<PdfDraggableBoxUi> {
  late final TextEditingController _editCtrl;

  @override
  void initState() {
    super.initState();
    _editCtrl = TextEditingController(text: _getEditableValue(widget.field.tag));
  }

  @override
  void didUpdateWidget(covariant PdfDraggableBoxUi oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.field.tag != widget.field.tag) {
      final currentExpected = _getEditableValue(widget.field.tag);
      if (_editCtrl.text != currentExpected) {
        _editCtrl.text = currentExpected;
      }
    }
  }

  @override
  void dispose() {
    _editCtrl.dispose();
    super.dispose();
  }

  String _getEditableValue(String raw) {
    if (widget.field.isStaticText) return raw;
    return raw.replaceAll('{{', '').replaceAll('}}', '').trim();
  }

  String _getDisplayText(String raw) {
    if (widget.isSelected) {
      return widget.field.isStaticText ? raw : '{{${raw.replaceAll('{{', '').replaceAll('}}', '').trim()}}}';
    }
    return raw.replaceAll('{{', '').replaceAll('}}', '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.field;

    final textStyle = TextStyle(
      fontFamily: f.fontType.isNotEmpty ? f.fontType : 'JameelNoori',
      fontSize: f.fontSize,
      fontWeight: f.isBold ? FontWeight.bold : FontWeight.normal,
      decoration: f.isUnderline ? TextDecoration.underline : TextDecoration.none,
      decorationThickness: f.isBold ? 2.5 : 1.2,
      color: AppColors.primaryEmerald,
      height: 1.8,
      shadows: f.isBold
          ? [
              const Shadow(offset: Offset(0.35, 0), color: AppColors.primaryEmerald),
              const Shadow(offset: Offset(-0.35, 0), color: AppColors.primaryEmerald),
              const Shadow(offset: Offset(0, 0.35), color: AppColors.primaryEmerald),
            ]
          : null,
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
              color: widget.isSelected
                  ? AppColors.primaryEmerald.withAlpha(25)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: widget.isSelected
                  ? Border.all(color: AppColors.primaryEmerald, width: 1.8)
                  : Border.all(color: Colors.transparent, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.isSelected)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.drag_indicator, size: 20, color: AppColors.primaryEmerald),
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
                          hintText: f.isStaticText ? 'یہاں تحریر لکھیں...' : 'ٹیگ کا نام لکھیں...',
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
                    _getDisplayText(f.tag).isEmpty
                        ? (f.isStaticText ? 'خالی تحریر' : 'خالی ٹیگ')
                        : _getDisplayText(f.tag),
                    textDirection: TextDirection.rtl,
                    style: _getDisplayText(f.tag).isEmpty
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