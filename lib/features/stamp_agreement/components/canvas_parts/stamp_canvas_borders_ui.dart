import 'package:flutter/material.dart';

class StampCanvasBordersUi extends StatelessWidget {
  final double top;
  final double bottom;
  final double side;
  final double width;
  final double height;
  final Function(double) onTopDrag;
  final Function(double) onBottomDrag;
  final Function(double) onSideDrag;

  const StampCanvasBordersUi({
    super.key,
    required this.top,
    required this.bottom,
    required this.side,
    required this.width,
    required this.height,
    required this.onTopDrag,
    required this.onBottomDrag,
    required this.onSideDrag,
  });

  static const double _thickness = 24.0;
  static const Color _solidColor = Color(0xFFD32F2F);

  Widget _buildBand({
    required bool isVertical,
    required Border border,
    required Alignment begin,
    required Alignment end,
    required Function(DragUpdateDetails) onDrag,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: isVertical ? onDrag : null,
      onHorizontalDragUpdate: !isVertical ? onDrag : null,
      child: Container(
        decoration: BoxDecoration(
          border: border,
          gradient: LinearGradient(
            begin: begin,
            end: end,
            colors: [
              Colors.red.shade700.withAlpha(15),
              Colors.red.shade700.withAlpha(65),
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Container(
          width: isVertical ? 36 : 4,
          height: isVertical ? 4 : 36,
          decoration: BoxDecoration(
            color: _solidColor.withAlpha(190),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double fullW = width + (_thickness * 2);
    final double fullH = height + (_thickness * 2);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // اوپری بارڈر (نیچے کھینچنے سے مارجن بڑھے گا)
        Positioned(
          top: top - _thickness,
          left: side - _thickness,
          width: fullW,
          height: _thickness,
          child: _buildBand(
            isVertical: true,
            border: const Border(bottom: BorderSide(color: _solidColor, width: 2.0)),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            onDrag: (d) => onTopDrag(d.delta.dy),
          ),
        ),

        // نچلا بارڈر (اوپر کھینچنے سے مارجن بڑھے گا)
        Positioned(
          bottom: bottom - _thickness,
          left: side - _thickness,
          width: fullW,
          height: _thickness,
          child: _buildBand(
            isVertical: true,
            border: const Border(top: BorderSide(color: _solidColor, width: 2.0)),
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            onDrag: (d) => onBottomDrag(d.delta.dy),
          ),
        ),

        // دایاں بارڈر (اندر یعنی بائیں طرف کھینچنے سے sideMargin بڑھے گا، باہر کھینچنے سے کم ہوگا)
        Positioned(
          top: top - _thickness,
          right: side - _thickness,
          width: _thickness,
          height: fullH,
          child: _buildBand(
            isVertical: false,
            border: const Border(left: BorderSide(color: _solidColor, width: 2.0)),
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            onDrag: (d) => onSideDrag(-d.delta.dx),
          ),
        ),

        // بایاں بارڈر (اندر یعنی دائیں طرف کھینچنے سے sideMargin بڑھے گا، باہر کھینچنے سے کم ہوگا)
        Positioned(
          top: top - _thickness,
          left: side - _thickness,
          width: _thickness,
          height: fullH,
          child: _buildBand(
            isVertical: false,
            border: const Border(right: BorderSide(color: _solidColor, width: 2.0)),
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            onDrag: (d) => onSideDrag(d.delta.dx),
          ),
        ),
      ],
    );
  }
}