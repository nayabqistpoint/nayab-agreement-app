import 'package:flutter/material.dart';

class StampMarginSheetUi extends StatelessWidget {
  final double topMargin;
  final double bottomMargin;
  final double sideMargin;
  final Function(double) onTopChanged;
  final Function(double) onBottomChanged;
  final Function(double) onSideChanged;

  const StampMarginSheetUi({
    super.key,
    required this.topMargin,
    required this.bottomMargin,
    required this.sideMargin,
    required this.onTopChanged,
    required this.onBottomChanged,
    required this.onSideChanged,
  });

  static void show({
    required BuildContext context,
    required double top,
    required double bottom,
    required double side,
    required Function(double) onTop,
    required Function(double) onBottom,
    required Function(double) onSide,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StampMarginSheetUi(
        topMargin: top,
        bottomMargin: bottom,
        sideMargin: side,
        onTopChanged: onTop,
        onBottomChanged: onBottom,
        onSideChanged: onSide,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (ctx, setMState) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('اسٹامپ مارجن پوائنٹس', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Text('اوپر کا مارجن (مونوگرام حد): ${topMargin.toInt()} pt'),
              Slider(
                value: topMargin,
                min: 40,
                max: 700,
                onChanged: (v) {
                  onTopChanged(v);
                  setMState(() {});
                },
              ),
              Text('نیچے کا مارجن (کیو آر کوڈ حد): ${bottomMargin.toInt()} pt'),
              Slider(
                value: bottomMargin,
                min: 40,
                max: 500,
                onChanged: (v) {
                  onBottomChanged(v);
                  setMState(() {});
                },
              ),
              Text('دائیں بائیں حاشیہ: ${sideMargin.toInt()} pt'),
              Slider(
                value: sideMargin,
                min: 15,
                max: 150,
                onChanged: (v) {
                  onSideChanged(v);
                  setMState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}