import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/stamp_overlay_field_model.dart';

class StampDraggableBoxUi extends StatefulWidget {
  final StampOverlayFieldModel field;
  final bool isSelected;
  final VoidCallback onSelect;
  final Function(double dx, double dy) onDrag;
  final Function(double newWidth)? onResizeWidth;
  final Function(String newText)? onTextEdited;

  const StampDraggableBoxUi({
    super.key,
    required this.field,
    required this.isSelected,
    required this.onSelect,
    required this.onDrag,
    this.onResizeWidth,
    this.onTextEdited,
  });

  @override
  State<StampDraggableBoxUi> createState() => _StampDraggableBoxUiState();
}

class _StampDraggableBoxUiState extends State<StampDraggableBoxUi> {
  late final TextEditingController _editCtrl;
  late final FocusNode _focusNode;

  bool get _isTagBox =>
      !widget.field.isStaticText &&
      widget.field.tag.trim().startsWith('{{') &&
      widget.field.tag.trim().endsWith('}}');

  bool get _isEmptyTemplateTag {
    if (!_isTagBox) return false;
    final inner = widget.field.tag
        .replaceAll('{{', '')
        .replaceAll('}}', '')
        .trim();
    return inner.isEmpty;
  }

  @override
  void initState() {
    super.initState();
    _editCtrl = TextEditingController(text: widget.field.tag);
    _focusNode = FocusNode();

    if (widget.isSelected &&
        (widget.field.isStaticText || _isEmptyTemplateTag)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _focusNode.requestFocus();
        if (_isEmptyTemplateTag && _editCtrl.text.length >= 3) {
          _editCtrl.selection = const TextSelection.collapsed(offset: 3);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant StampDraggableBoxUi oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.field.tag != widget.field.tag &&
        _editCtrl.text != widget.field.tag) {
      _editCtrl.text = widget.field.tag;
    }
    if (!oldWidget.isSelected &&
        widget.isSelected &&
        (widget.field.isStaticText || _isEmptyTemplateTag)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _focusNode.requestFocus();
        if (_isEmptyTemplateTag && _editCtrl.text.length >= 3) {
          _editCtrl.selection = const TextSelection.collapsed(offset: 3);
        }
      });
    }
  }

  @override
  void dispose() {
    _editCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.field;
    final bool isTag = _isTagBox;
    final bool showInlineEditor =
        widget.isSelected && (f.isStaticText || _isEmptyTemplateTag);

    final Color textColor =
        isTag ? Colors.blue.shade900 : AppColors.primaryEmerald;

    final textStyle = TextStyle(
      fontFamily: f.fontType.isNotEmpty ? f.fontType : 'JameelNoori',
      fontSize: f.fontSize,
      fontWeight: (f.isBold || isTag) ? FontWeight.bold : FontWeight.normal,
      decoration: f.isUnderline ? TextDecoration.underline : TextDecoration.none,
      decorationThickness: f.isBold ? 2.5 : 1.2,
      color: textColor,
      height: 1.8,
      shadows: f.isBold
          ? [
              Shadow(offset: const Offset(0.35, 0), color: textColor),
              Shadow(offset: const Offset(-0.35, 0), color: textColor),
              Shadow(offset: const Offset(0, 0.35), color: textColor),
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
          onPanUpdate: (details) =>
              widget.onDrag(details.delta.dx, details.delta.dy),
          child: Container(
            width: f.width.clamp(60.0, 520.0),
            padding: EdgeInsets.symmetric(
              horizontal: (widget.isSelected || isTag) ? 6 : 4,
              vertical: (widget.isSelected || isTag) ? 3 : 2,
            ),
            decoration: BoxDecoration(
              color: isTag
                  ? Colors.blue.shade50.withAlpha(210)
                  : (widget.isSelected
                      ? AppColors.primaryEmerald.withAlpha(25)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.primaryEmerald
                    : (isTag ? Colors.blue.shade300 : Colors.transparent),
                width: widget.isSelected ? 1.8 : 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.isSelected)
                  Tooltip(
                    message: 'باکس کی چوڑائی کم یا زیادہ کریں',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: (d) {
                        final newW = (f.width - d.delta.dx).clamp(60.0, 520.0);
                        widget.onResizeWidth?.call(newW);
                        widget.onDrag(d.delta.dx, 0);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 3,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade700,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.swap_horiz,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: showInlineEditor
                      ? TextField(
                          controller: _editCtrl,
                          focusNode: _focusNode,
                          style: textStyle,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            border: InputBorder.none,
                            hintText: f.isStaticText
                                ? 'یہاں تحریر لکھیں...'
                                : '{{   }}',
                            hintStyle: TextStyle(
                              color: Colors.black38,
                              fontSize: f.fontSize,
                              fontFamily: 'JameelNoori',
                            ),
                          ),
                          onChanged: (val) {
                            widget.onTextEdited?.call(val);
                          },
                        )
                      : Text(
                          f.tag.trim().isEmpty
                              ? (f.isStaticText ? 'خالی تحریر' : '{{   }}')
                              : f.tag,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          overflow: TextOverflow.ellipsis,
                          style: f.tag.trim().isEmpty
                              ? textStyle.copyWith(
                                  color: Colors.black38,
                                  fontStyle: FontStyle.italic,
                                )
                              : textStyle,
                        ),
                ),
                if (widget.isSelected)
                  const Padding(
                    padding: EdgeInsets.only(right: 2),
                    child: Icon(
                      Icons.drag_indicator,
                      size: 18,
                      color: AppColors.primaryEmerald,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}