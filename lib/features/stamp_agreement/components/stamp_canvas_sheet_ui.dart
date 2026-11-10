import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/stamp_rich_text_controller.dart';
import '../stamp_studio_controller.dart';
import 'canvas_parts/stamp_canvas_borders_ui.dart';
import 'canvas_parts/stamp_safe_zone_overlay_ui.dart';
import 'stamp_overlay_canvas_layer_ui.dart';

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
  final StampStudioController controller;

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
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final double boxW = (sheetWidth - (scaledSide * 2)).clamp(50.0, sheetWidth);
    final double boxH = (sheetHeight - scaledTop - scaledBottom).clamp(40.0, sheetHeight);

    final textStyle = TextStyle(
      fontFamily: 'JameelNoori',
      fontSize: fontSize,
      height: 1.85,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF111111),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Container(
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
                  // 1. بیک گراؤنڈ
                  if (bgImage != null)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Image.memory(bgImage!, fit: BoxFit.fill, filterQuality: FilterQuality.high),
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

                  // 2. محفوظ مونوگرام ایریا
                  StampSafeZoneOverlayUi(
                    topHeight: scaledTop,
                    bottomHeight: scaledBottom,
                    isFirstPage: isFirstPage,
                  ),

                  // 3. تحریری ایریا
                  Positioned(
                    top: scaledTop,
                    left: scaledSide,
                    width: boxW,
                    height: boxH,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                      child: isFirstPage
                          ? TextField(
                              controller: bodyController,
                              maxLines: null,
                              expands: true,
                              scrollPhysics: const NeverScrollableScrollPhysics(),
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              cursorColor: Colors.teal.shade800,
                              cursorWidth: 2.5,
                              style: textStyle,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                hintText: 'یہاں تحریر لکھیں یا پیسٹ کریں...',
                                hintStyle: TextStyle(
                                  fontFamily: 'JameelNoori',
                                  fontSize: (fontSize + 3.0).clamp(16.0, 26.0),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black38,
                                ),
                              ),
                              onChanged: (_) => onModified(),
                            )
                          : ClipRect(
                              child: Text(
                                textContent,
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                style: textStyle,
                              ),
                            ),
                    ),
                  ),

                  // 4. مارجن ڈریگ بارڈرز
                  StampCanvasBordersUi(
                    top: scaledTop,
                    bottom: scaledBottom,
                    side: scaledSide,
                    width: boxW,
                    height: boxH,
                    onTopDrag: onTopDrag,
                    onBottomDrag: onBottomDrag,
                    onSideDrag: onSideDrag,
                  ),

                  // 5. آزاد اوورلے لیئر (خالی کلک پر ٹول بار بند، گرپ ہینڈل، اور بڑا ٹول بار)
                  StampOverlayCanvasLayerUi(
                    pageIndex: pageIndex,
                    sheetWidth: sheetWidth,
                    sheetHeight: sheetHeight,
                    fields: controller.overlayFields,
                    selectedFieldId: controller.selectedOverlayFieldId,
                    toolbarScale: controller.currentToolbarScale,
                    isPlacementActive: controller.isOverlayPlacementActive,
                    onCanvasTap: (pos) => controller.addOverlayFieldAtPosition(pos.dx, pos.dy, pageIndex: pageIndex),
                    onDismissSelection: () {
                      controller.selectOverlayField(null);
                      if (controller.isOverlayPlacementActive) {
                        controller.toggleOverlayPlacementMode();
                      }
                    },
                    onSelectField: controller.selectOverlayField,
                    onDragField: controller.updateOverlayFieldPosition,
                    onDeleteField: controller.removeOverlayField,
                    onFontSizeChange: controller.updateOverlayFieldFontSize,
                    onToggleBold: controller.toggleOverlayBold,
                    onToggleUnderline: controller.toggleOverlayUnderline,
                    onTextEdited: controller.updateOverlayFieldText,
                    onAdjustToolbarScale: controller.adjustToolbarScale,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}