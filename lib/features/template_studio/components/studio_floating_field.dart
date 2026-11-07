import 'package:flutter/material.dart';
import '../../../../core/models/overlay_box_model.dart';

class StudioFloatingField extends StatefulWidget {
  final OverlayBoxModel box;
  final double scale;
  final Function(OverlayBoxModel) onUpdate;
  final VoidCallback onDelete;

  const StudioFloatingField({
    super.key,
    required this.box,
    required this.scale,
    required this.onUpdate,
    required this.deleteField,
    required this.onDelete,
  });

  final VoidCallback deleteField;

  @override
  State<StudioFloatingField> createState() => _StudioFloatingFieldState();
}

class _StudioFloatingFieldState extends State<StudioFloatingField> {
  late final TextEditingController _textCtrl;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(text: widget.box.tag);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.box.x * widget.scale;
    final top = widget.box.y * widget.scale;
    final width = widget.box.width * widget.scale;
    final height = widget.box.height * widget.scale;

    return Positioned(
      left: left,
      top: top,
      width: width.clamp(80.0, 450.0),
      height: height.clamp(30.0, 250.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(220),
          border: Border.all(color: Colors.teal.shade800, width: 1.5),
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: Row(
          children: [
            // ڈریگ ہینڈل
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanUpdate: (d) {
                final newX = widget.box.x + (d.delta.dx / widget.scale);
                final newY = widget.box.y + (d.delta.dy / widget.scale);
                widget.onUpdate(widget.box.copyWith(x: newX, y: newY));
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: Icon(Icons.drag_indicator, size: 16, color: Colors.teal),
              ),
            ),
            // براہِ راست ٹیکسٹ فیلڈ
            Expanded(
              child: TextField(
                controller: _textCtrl,
                style: TextStyle(fontFamily: 'JameelNoori', fontSize: widget.box.fontSize, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: '{{ٹیگ درج کریں}}',
                ),
                onChanged: (v) {
                  widget.onUpdate(widget.box.copyWith(tag: v.trim()));
                },
              ),
            ),
            // ڈیلیٹ بٹن
            InkWell(
              onTap: widget.onDelete,
              child: const Icon(Icons.close, size: 14, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}