import 'package:flutter/material.dart';

class StampSafeZoneOverlayUi extends StatelessWidget {
  final double topHeight;
  final double bottomHeight;
  final bool isFirstPage;

  const StampSafeZoneOverlayUi({
    super.key,
    required this.topHeight,
    required this.bottomHeight,
    required this.isFirstPage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: topHeight,
          child: IgnorePointer(
            child: Container(
              color: Colors.amber.withAlpha(15),
              alignment: Alignment.center,
              child: Opacity(
                opacity: 0.35,
                child: Text(
                  isFirstPage ? "حاشیہ برائے سرکاری مونوگرام و چالان" : "اوپری حاشیہ",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: bottomHeight,
          child: IgnorePointer(
            child: Container(
              color: Colors.amber.withAlpha(15),
              alignment: Alignment.center,
              child: Opacity(
                opacity: 0.35,
                child: Text(
                  isFirstPage ? "حاشیہ برائے کیو آر کوڈ و ویریفیکیشن" : "نچلا حاشیہ",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}