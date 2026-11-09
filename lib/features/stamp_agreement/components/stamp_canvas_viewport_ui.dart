import 'package:flutter/material.dart';
import '../stamp_studio_controller.dart';
import 'stamp_canvas_sheet_ui.dart';

class StampCanvasViewportUi extends StatelessWidget {
  final StampStudioController controller;
  final VoidCallback onStateChange;

  const StampCanvasViewportUi({
    super.key,
    required this.controller,
    required this.onStateChange,
  });

  @override
  Widget build(BuildContext context) {
    final isA4 = controller.paperSize == 'A4';
    final double sheetW = isA4 ? 595.0 : 612.0;
    final double sheetH = isA4 ? 842.0 : 1008.0;
    final pages = controller.paginateText();

    return Container(
      color: const Color(0xFFDCDCDC),
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Center(
          child: Column(
            children: List.generate(pages.length, (index) {
              final isFirst = index == 0;
              final currentTop = isFirst ? controller.topMargin : controller.subsequentTopMargin;
              final bg = (index < controller.cachedStampPages.length)
                  ? controller.cachedStampPages[index]
                  : null;

              return Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: StampCanvasSheetUi(
                  sheetWidth: sheetW,
                  sheetHeight: sheetH,
                  scaledTop: currentTop,
                  scaledBottom: controller.bottomMargin,
                  scaledSide: controller.sideMargin,
                  bgImage: bg,
                  pageLabel: "صفحہ نمبر ${index + 1} از ${pages.length} (${controller.paperSize})",
                  isFirstPage: isFirst,
                  pageIndex: index,
                  textContent: pages[index],
                  fontSize: controller.fontSize,
                  bodyController: controller.bodyController,
                  onModified: onStateChange,
                  onTopDrag: (dy) {
                    if (isFirst) {
                      controller.setTopMargin(controller.topMargin + dy);
                    } else {
                      controller.setSubsequentTopMargin(controller.subsequentTopMargin + dy);
                    }
                    onStateChange();
                  },
                  onBottomDrag: (dy) {
                    controller.setBottomMargin(controller.bottomMargin - dy);
                    onStateChange();
                  },
                  onSideDrag: (dx) {
                    controller.setSideMargin(controller.sideMargin - dx);
                    onStateChange();
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}