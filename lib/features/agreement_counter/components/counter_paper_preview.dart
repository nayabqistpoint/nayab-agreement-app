import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/models/document_template_model.dart';
import '../../../../core/models/overlay_box_model.dart';

class CounterPaperPreview extends StatelessWidget {
  final double topMargin;
  final double bottomMargin;
  final double sideMargin;
  final String textContent;
  final Uint8List? bgImage;
  final bool isFirstPage;
  final double fontSize;
  final DocumentMode mode;
  final List<OverlayBoxModel> floatingBoxes;
  final Map<String, String> bucketValues;
  final Function(double) onTopDrag;
  final Function(double) onBottomDrag;
  final Function(double) onSideDrag;

  const CounterPaperPreview({
    super.key,
    required this.topMargin,
    required this.bottomMargin,
    required this.sideMargin,
    required this.textContent,
    required this.bgImage,
    required this.isFirstPage,
    required this.fontSize,
    required this.mode,
    this.floatingBoxes = const [],
    this.bucketValues = const {},
    required this.onTopDrag,
    required this.onBottomDrag,
    required this.onSideDrag,
  });

  @override
  Widget build(BuildContext context) {
    const double sheetWidth = 360.0;
    const double sheetHeight = 593.0;
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
          BoxShadow(color: Colors.black38, blurRadius: 10, spreadRadius: 2, offset: Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          // پس منظر: اگر اسٹامپ موجود ہو تو وہ، ورنہ سفید واٹر مارک
          if (bgImage != null)
            Positioned.fill(
              child: Image.memory(bgImage!, fit: BoxFit.fill),
            )
          else
            Center(
              child: Opacity(
                opacity: 0.10,
                child: Text(
                  mode == DocumentMode.stampOverlay
                      ? (isFirstPage ? "سرکاری ای-اسٹامپ پیپر" : "اضافی سادہ ورق")
                      : "سادہ دستاویزی کاغذ (A4)",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          // موڈ 1: ای-اسٹامپ اوورلے اور عام پیراگراف ٹیکسٹ
          if (mode != DocumentMode.formFiller)
            Positioned(
              top: scaledTop,
              left: scaledSide,
              width: boxW,
              height: boxH,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: mode == DocumentMode.stampOverlay ? Colors.red.shade700 : Colors.transparent,
                    width: 1.5,
                  ),
                  color: mode == DocumentMode.stampOverlay ? Colors.white.withAlpha(140) : Colors.transparent,
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                      child: Text(
                        textContent,
                        textAlign: TextAlign.justify,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'JameelNoori',
                          fontSize: fontSize * 0.88,
                          height: 1.85,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111111),
                        ),
                      ),
                    ),

                    if (mode == DocumentMode.stampOverlay) ...[
                      // اوپر کا ڈریگ ہینڈل
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 12,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onVerticalDragUpdate: (d) => onTopDrag(d.delta.dy),
                          child: Container(
                            color: Colors.red.withAlpha(80),
                            alignment: Alignment.center,
                            child: const Icon(Icons.drag_handle, size: 10, color: Colors.white),
                          ),
                        ),
                      ),

                      // نیچے کا ڈریگ ہینڈل
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 12,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onVerticalDragUpdate: (d) => onBottomDrag(d.delta.dy),
                          child: Container(
                            color: Colors.red.withAlpha(80),
                            alignment: Alignment.center,
                            child: const Icon(Icons.drag_handle, size: 10, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // موڈ 2: فارم فلر فلوٹنگ فیلڈز
          if (mode == DocumentMode.formFiller)
            ...floatingBoxes.map((b) {
              final rawTag = b.tag.replaceAll('{{', '').replaceAll('}}', '').trim();
              final val = bucketValues[rawTag] ?? b.tag;

              return Positioned(
                left: b.x * scale,
                top: b.y * scale,
                width: b.width * scale,
                height: b.height * scale,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  alignment: Alignment.centerRight,
                  child: Text(
                    val,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'JameelNoori',
                      fontSize: b.fontSize * scale * 1.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}