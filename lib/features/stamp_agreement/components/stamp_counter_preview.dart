import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/models/overlay_box_model.dart';
import '../../../../core/utils/tag_extraction_helper.dart';

class StampCounterPreview extends StatelessWidget {
  final double topMargin;
  final double bottomMargin;
  final double sideMargin;
  final String textContent;
  final Uint8List? bgImage;
  final bool isFirstPage;
  final double fontSize;
  final String paperSize;
  final List<OverlayBoxModel> floatingBoxes;
  final Map<String, String> fieldValues;

  const StampCounterPreview({
    super.key,
    required this.topMargin,
    required this.bottomMargin,
    required this.sideMargin,
    required this.textContent,
    required this.bgImage,
    required this.isFirstPage,
    required this.fontSize,
    this.paperSize = 'Legal',
    this.floatingBoxes = const [],
    this.fieldValues = const {},
  });

  String _resolveFloatingText(String rawText) {
    if (rawText.trim().isEmpty) return '';
    return TemplateService.replaceTags(rawText, fieldValues);
  }

  @override
  Widget build(BuildContext context) {
    final bool isA4 = paperSize.toUpperCase() == 'A4';
    final double sheetWidth = isA4 ? 595.0 : 612.0;
    final double sheetHeight = isA4 ? 842.0 : 1008.0;
    final double boxW = (sheetWidth - (sideMargin * 2)).clamp(50.0, sheetWidth);
    final double boxH =
        (sheetHeight - topMargin - bottomMargin).clamp(40.0, sheetHeight);

    return FittedBox(
      fit: BoxFit.contain,
      child: Container(
        width: sheetWidth,
        height: sheetHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
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
                  opacity: 0.05,
                  child: Text(
                    isFirstPage ? "سرکاری ای-اسٹامپ پیپر" : "اضافی سادہ ورق",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: topMargin,
              left: sideMargin,
              width: boxW,
              height: boxH,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: ClipRect(
                  child: Text(
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
            ...floatingBoxes.map((box) {
              final resolvedText = _resolveFloatingText(box.tag);
              final double maxAllowedWidth =
                  (sheetWidth - box.x - 12.0).clamp(60.0, sheetWidth);

              return Positioned(
                left: box.x,
                top: box.y,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 20,
                    maxWidth: maxAllowedWidth,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Text(
                        resolvedText,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'JameelNoori',
                          fontSize: box.fontSize,
                          height: 1.8,
                          fontWeight:
                              box.isBold ? FontWeight.w900 : FontWeight.w600,
                          decoration: box.isUnderline
                              ? TextDecoration.underline
                              : TextDecoration.none,
                          decorationThickness: box.isBold ? 2.2 : 1.3,
                          color: const Color(0xFF111111),
                          shadows: box.isBold
                              ? const [
                                  Shadow(
                                    color: Color(0xFF111111),
                                    offset: Offset(0.35, 0),
                                  ),
                                  Shadow(
                                    color: Color(0xFF111111),
                                    offset: Offset(-0.35, 0),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}