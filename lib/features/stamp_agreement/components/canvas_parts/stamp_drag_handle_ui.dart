import 'package:flutter/material.dart';

class StampDragHandlesGroupUi extends StatelessWidget {
  final double top;
  final double bottom;
  final double side;
  final Function(double) onTopDrag;
  final Function(double) onBottomDrag;
  final Function(double) onSideDrag;

  const StampDragHandlesGroupUi({
    super.key,
    required this.top,
    required this.bottom,
    required this.side,
    required this.onTopDrag,
    required this.onBottomDrag,
    required this.onSideDrag,
  });

  Widget _buildCircle(Function(DragUpdateDetails) onPan) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: onPan,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.blue.shade700,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: const Icon(Icons.open_with, size: 14, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: top - 13,
          right: side - 13,
          child: _buildCircle((d) {
            onTopDrag(d.delta.dy);
            onSideDrag(d.delta.dx);
          }),
        ),
        Positioned(
          top: top - 13,
          left: side - 13,
          child: _buildCircle((d) {
            onTopDrag(d.delta.dy);
            onSideDrag(-d.delta.dx);
          }),
        ),
        Positioned(
          bottom: bottom - 13,
          right: side - 13,
          child: _buildCircle((d) {
            onBottomDrag(d.delta.dy);
            onSideDrag(d.delta.dx);
          }),
        ),
        Positioned(
          bottom: bottom - 13,
          left: side - 13,
          child: _buildCircle((d) {
            onBottomDrag(d.delta.dy);
            onSideDrag(-d.delta.dx);
          }),
        ),
      ],
    );
  }
}