import 'dart:typed_data';
import 'package:flutter/material.dart';

class StampCounterPreview extends StatelessWidget {
  final double topMargin;
  final double bottomMargin;
  final double sideMargin;
  final String textContent;
  final Uint8List? bgImage;
  final bool isFirstPage;
  final double fontSize;

  const StampCounterPreview({
    super.key,
    required this.topMargin,
    required this.bottomMargin,
    required this.sideMargin,
    required this.textContent,
    required this.bgImage,
    required this.isFirstPage,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    const double sheetWidth = 390.0;
    const double sheetHeight = 642.0;
    const double scale = sheetHeight / 1008.0;

    final scaledTop = topMargin * scale;
    final scaledBot = bottomMargin * scale;
    final scaledSide = (sideMargin * scale).clamp(8.0, 45.0);
    final boxW = (sheetWidth - (scaledSide * 2)).clamp(100.0, sheetWidth);
    final boxH = (sheetHeight - scaledTop - scaledBot).clamp(40.0, sheetHeight);

    return Container(
      width: sheetWidth,
      height: sheetHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // پس منظر اسٹامپ
          if (bgImage != null)
            Positioned.fill(
              child: Image.memory(
                bgImage!,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              ),
            )
          else
            Center(
              child: Opacity(
                opacity: 0.08,
                child: Text(
                  isFirstPage ? "سرکاری ای-اسٹامپ پیپر" : "اضافی سادہ ورق",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          // پرنٹ تحریر (بغیر کسی ریڈ بارڈر کے)
          Positioned(
            top: scaledTop,
            left: scaledSide,
            width: boxW,
            height: boxH,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Text(
                  textContent,
                  textAlign: TextAlign.justify,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'JameelNoori',
                    fontSize: fontSize * 0.95,
                    height: 1.85,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111111),
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