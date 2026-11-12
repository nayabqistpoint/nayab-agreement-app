import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/models/overlay_box_model.dart';
import '../../../../core/utils/tag_extraction_helper.dart';

class PdfFormCounterPreview extends StatelessWidget {
  final Uint8List? bgImage;
  final String paperSize;
  final List<OverlayBoxModel> floatingBoxes;
  final Map<String, String> fieldValues;

  const PdfFormCounterPreview({
    super.key,
    required this.bgImage,
    this.paperSize = 'A4',
    this.floatingBoxes = const [],
    this.fieldValues = const {},
  });

  String _resolveBoxText(String rawText) {
    if (rawText.trim().isEmpty) return '';
    return TemplateService.replaceTags(rawText, fieldValues);
  }

  @override
  Widget build(BuildContext context) {
    final bool isA4 = paperSize.toUpperCase() == 'A4';
    final double sheetWidth = isA4 ? 595.0 : 612.0;
    final double sheetHeight = isA4 ? 842.0 : 1008.0;

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
                  opacity: 0.06,
                  child: Text(
                    isA4 ? "سادہ دستاویزی فارم (A4)" : "لیگل دستاویزی فارم",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ...floatingBoxes.map((box) {
              final resolvedText = _resolveBoxText(box.tag);
              final double boxMaxW = (box.width > 30 ? box.width : 180.0)
                  .clamp(40.0, (sheetWidth - box.x - 8.0).clamp(40.0, sheetWidth));

              return Positioned(
                left: box.x,
                top: box.y,
                width: boxMaxW,
                child: Align(
                  alignment: Alignment.centerRight,
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