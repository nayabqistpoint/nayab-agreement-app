import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/stamp_rich_text_controller.dart';

class StampCanvasSheetUi extends StatelessWidget {
  final double sheetWidth;
  final double sheetHeight;
  final double scaledTop;
  final double scaledBottom;
  final double scaledSide;
  final Uint8List? bgImage;
  final String pageLabel;
  final bool isFirstPage;
  final int pageIndex;
  final String textContent;
  final double fontSize;
  final StampRichTextController bodyController;
  final VoidCallback onModified;
  final Function(double) onTopDrag;
  final Function(double) onBottomDrag;
  final Function(double) onSideDrag;

  const StampCanvasSheetUi({
    super.key,
    required this.sheetWidth,
    required this.sheetHeight,
    required this.scaledTop,
    required this.scaledBottom,
    required this.scaledSide,
    required this.bgImage,
    required this.pageLabel,
    required this.isFirstPage,
    required this.pageIndex,
    required this.textContent,
    required this.fontSize,
    required this.bodyController,
    required this.onModified,
    required this.onTopDrag,
    required this.onBottomDrag,
    required this.onSideDrag,
  });

  @override
  Widget build(BuildContext context) {
    final double boxW = (sheetWidth - (scaledSide * 2)).clamp(50.0, sheetWidth);
    final double boxH = (sheetHeight - scaledTop - scaledBottom).clamp(40.0, sheetHeight);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade800,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            pageLabel,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: sheetWidth,
          height: sheetHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2, offset: Offset(0, 4)),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (bgImage != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Image.memory(
                      bgImage!,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                )
              else
                Center(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.05,
                      child: Text(
                        isFirstPage ? "سرکاری ای-اسٹامپ پیپر" : "اضافی سادہ ورق",
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: scaledTop,
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
                height: scaledBottom,
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
              Positioned(
                top: scaledTop,
                left: scaledSide,
                width: boxW,
                height: boxH,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  child: isFirstPage
                      ? TextField(
                          controller: bodyController,
                          maxLines: null,
                          expands: true,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          cursorColor: Colors.teal.shade800,
                          cursorWidth: 2.5,
                          style: TextStyle(
                            fontFamily: 'JameelNoori',
                            fontSize: fontSize,
                            height: 1.85,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111111),
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'یہاں تحریر لکھیں یا پیسٹ کریں...',
                          ),
                          onChanged: (_) => onModified(),
                        )
                      : SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: SelectableText(
                            textContent,
                            textAlign: TextAlign.right,
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
                ),
              ),
              Positioned(
                top: scaledTop,
                left: scaledSide,
                width: boxW,
                child: IgnorePointer(child: Container(height: 1.5, color: Colors.blue.shade600)),
              ),
              Positioned(
                bottom: scaledBottom,
                left: scaledSide,
                width: boxW,
                child: IgnorePointer(child: Container(height: 1.5, color: Colors.blue.shade600)),
              ),
              Positioned(
                top: scaledTop,
                right: scaledSide,
                height: boxH,
                child: IgnorePointer(child: Container(width: 1.5, color: Colors.blue.shade600)),
              ),
              Positioned(
                top: scaledTop,
                left: scaledSide,
                height: boxH,
                child: IgnorePointer(child: Container(width: 1.5, color: Colors.blue.shade600)),
              ),
              Positioned(
                top: scaledTop - 13,
                right: scaledSide - 13,
                child: _buildHandle((d) {
                  onTopDrag(d.delta.dy);
                  onSideDrag(d.delta.dx);
                }),
              ),
              Positioned(
                top: scaledTop - 13,
                left: scaledSide - 13,
                child: _buildHandle((d) {
                  onTopDrag(d.delta.dy);
                  onSideDrag(-d.delta.dx);
                }),
              ),
              Positioned(
                bottom: scaledBottom - 13,
                right: scaledSide - 13,
                child: _buildHandle((d) {
                  onBottomDrag(d.delta.dy);
                  onSideDrag(d.delta.dx);
                }),
              ),
              Positioned(
                bottom: scaledBottom - 13,
                left: scaledSide - 13,
                child: _buildHandle((d) {
                  onBottomDrag(d.delta.dy);
                  onSideDrag(-d.delta.dx);
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHandle(Function(DragUpdateDetails) onPan) {
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
}