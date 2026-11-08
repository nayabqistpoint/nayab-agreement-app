import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/models/document_template_model.dart';
import '../../../../core/models/overlay_box_model.dart';
import 'studio_floating_field.dart';

class StudioCanvasSheet extends StatelessWidget {
  final double sheetWidth;
  final double sheetHeight;
  final double scaledTop;
  final double scaledBottom;
  final double scaledSide;
  final Uint8List? bgImage;
  final String pageLabel;
  final bool isFirstPage;
  final String textContent;
  final double fontSize;
  final DocumentMode mode;
  final List<OverlayBoxModel> floatingBoxes;
  final TextEditingController? bodyController;
  final Function(String)? onTextChanged;
  final Function(double) onTopDrag;
  final Function(double) onBottomDrag;
  final Function(double) onSideDrag;
  final Function(Offset) onCanvasTap;
  final Function(OverlayBoxModel) onUpdateBox;
  final Function(String) onDeleteBox;

  const StudioCanvasSheet({
    super.key,
    required this.sheetWidth,
    required this.sheetHeight,
    required this.scaledTop,
    required this.scaledBottom,
    required this.scaledSide,
    required this.bgImage,
    required this.pageLabel,
    required this.isFirstPage,
    required this.textContent,
    required this.fontSize,
    required this.mode,
    required this.floatingBoxes,
    this.bodyController,
    this.onTextChanged,
    required this.onTopDrag,
    required this.onBottomDrag,
    required this.onSideDrag,
    required this.onCanvasTap,
    required this.onUpdateBox,
    required this.onDeleteBox,
  });

  @override
  Widget build(BuildContext context) {
    final double scale = sheetHeight / 1008.0;
    final double boxW = (sheetWidth - (scaledSide * 2)).clamp(100.0, sheetWidth);
    final double boxH = (sheetHeight - scaledTop - scaledBottom).clamp(40.0, sheetHeight);

    return Column(
      children: [
        Text(
          pageLabel,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTapUp: (details) {
            if (mode == DocumentMode.formFiller) {
              onCanvasTap(details.localPosition / scale);
            }
          },
          child: Container(
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
              clipBehavior: Clip.hardEdge,
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
                        mode == DocumentMode.stampOverlay
                            ? (isFirstPage ? "سرکاری ای-اسٹامپ پیپر" : "اضافی سادہ ورق")
                            : "سادہ دستاویزی کاغذ (A4)",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                // محفوظ بلائنڈ باؤنڈریز
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: scaledTop,
                  child: Container(color: Colors.black.withAlpha(12)),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: scaledBottom,
                  child: Container(color: Colors.black.withAlpha(12)),
                ),

                // ریڈ باکس: سکرولر کے بغیر براہِ راست لکھائی والا کینوس
                if (mode != DocumentMode.formFiller)
                  Positioned(
                    top: scaledTop,
                    left: scaledSide,
                    width: boxW,
                    height: boxH,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red.shade700, width: 2.0),
                        color: Colors.white.withAlpha(165),
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                            child: isFirstPage && bodyController != null
                                ? TextField(
                                    controller: bodyController,
                                    maxLines: null,
                                    // سکرولر کو جڑ سے اکھاڑ دیا گیا ہے
                                    scrollPhysics: const NeverScrollableScrollPhysics(),
                                    textAlign: TextAlign.justify,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      fontFamily: 'JameelNoori',
                                      fontSize: fontSize * 0.95,
                                      height: 1.85,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF111111),
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      hintText: 'یہاں ریڈ باکس میں براہِ راست کلک کر کے معاہدہ لکھیں...',
                                    ),
                                    onChanged: (val) {
                                      if (onTextChanged != null) onTextChanged!(val);
                                    },
                                  )
                                : SizedBox(
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

                          // اوپر کا ہینڈل
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 14,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onVerticalDragUpdate: (d) => onTopDrag(d.delta.dy),
                              child: Container(
                                color: Colors.red.withAlpha(90),
                                alignment: Alignment.center,
                                child: const Icon(Icons.drag_handle, size: 12, color: Colors.white),
                              ),
                            ),
                          ),

                          // نیچے کا ہینڈل
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 14,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onVerticalDragUpdate: (d) => onBottomDrag(d.delta.dy),
                              child: Container(
                                color: Colors.red.withAlpha(90),
                                alignment: Alignment.center,
                                child: const Icon(Icons.drag_handle, size: 12, color: Colors.white),
                              ),
                            ),
                          ),

                          // سائیڈ ہینڈلز
                          Positioned(
                            top: 14,
                            bottom: 14,
                            right: 0,
                            width: 12,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onHorizontalDragUpdate: (d) => onSideDrag(d.delta.dx),
                              child: Container(color: Colors.red.withAlpha(60)),
                            ),
                          ),
                          Positioned(
                            top: 14,
                            bottom: 14,
                            left: 0,
                            width: 12,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onHorizontalDragUpdate: (d) => onSideDrag(-d.delta.dx),
                              child: Container(color: Colors.red.withAlpha(60)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // فارم فلر
                if (mode == DocumentMode.formFiller)
                  ...floatingBoxes.map(
                    (b) => StudioFloatingField(
                      box: b,
                      scale: scale,
                      onUpdate: onUpdateBox,
                      deleteField: () => onDeleteBox(b.id),
                      onDelete: () => onDeleteBox(b.id),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}