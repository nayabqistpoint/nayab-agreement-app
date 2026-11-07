import 'package:flutter/material.dart';

class StudioDraggableBox extends StatelessWidget {
  final double top;
  final double bottom;
  final double side;
  final double sheetWidth;
  final double sheetHeight;
  final String textContent;
  final double fontSize;
  final Function(double) onTopDrag;
  final Function(double) onBottomDrag;
  final Function(double) onSideDrag;
  final VoidCallback onDoubleTap;

  const StudioDraggableBox({
    super.key,
    required this.top,
    required this.bottom,
    required this.side,
    required this.sheetWidth,
    required this.sheetHeight,
    required this.textContent,
    required this.fontSize,
    required this.onTopDrag,
    required this.onBottomDrag,
    required this.onSideDrag,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final double boxW = (sheetWidth - (side * 2)).clamp(100.0, sheetWidth);
    final double boxH = (sheetHeight - top - bottom).clamp(40.0, sheetHeight);

    return Positioned(
      top: top,
      left: side,
      width: boxW,
      height: boxH,
      child: InkWell(
        onDoubleTap: onDoubleTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red.shade700, width: 2.2),
            color: Colors.white.withAlpha(170),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                child: Text(
                  textContent,
                  textAlign: TextAlign.justify,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'JameelNoori',
                    fontSize: fontSize,
                    height: 1.85,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111111),
                  ),
                ),
              ),

              // اوپر کا موٹا ڈریگ بار
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 16,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onVerticalDragUpdate: (d) => onTopDrag(d.delta.dy),
                  child: Container(
                    color: Colors.red.withAlpha(85),
                    alignment: Alignment.center,
                    child: const Icon(Icons.drag_handle, size: 14, color: Colors.white),
                  ),
                ),
              ),

              // نیچے کا موٹا ڈریگ بار
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 16,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onVerticalDragUpdate: (d) => onBottomDrag(d.delta.dy),
                  child: Container(
                    color: Colors.red.withAlpha(85),
                    alignment: Alignment.center,
                    child: const Icon(Icons.drag_handle, size: 14, color: Colors.white),
                  ),
                ),
              ),

              // دائیں طرف کا موٹا سائیڈ ہینڈل
              Positioned(
                top: 16,
                bottom: 16,
                right: 0,
                width: 14,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragUpdate: (d) => onSideDrag(d.delta.dx),
                  child: Container(
                    color: Colors.red.withAlpha(60),
                    alignment: Alignment.center,
                    child: const Icon(Icons.more_vert, size: 12, color: Colors.white),
                  ),
                ),
              ),

              // بائیں طرف کا موٹا سائیڈ ہینڈل
              Positioned(
                top: 16,
                bottom: 16,
                left: 0,
                width: 14,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragUpdate: (d) => onSideDrag(-d.delta.dx),
                  child: Container(
                    color: Colors.red.withAlpha(60),
                    alignment: Alignment.center,
                    child: const Icon(Icons.more_vert, size: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}