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
    final cached = controller.cachedStampPages;

    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(40.0),
      minScale: 0.6,
      maxScale: 3.0,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(pages.length, (i) {
              final bg = (i < cached.length) ? cached[i] : null;
              final isFirst = i == 0;
              final scaledTop = isFirst ? controller.topMargin : controller.subsequentTopMargin;
              final scaledBot = controller.bottomMargin;
              final scaledSide = controller.sideMargin;

              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: StampCanvasSheetUi(
                  controller: controller,
                  sheetWidth: sheetW,
                  sheetHeight: sheetH,
                  scaledTop: scaledTop,
                  scaledBottom: scaledBot,
                  scaledSide: scaledSide,
                  bgImage: bg,
                  pageLabel: 'صفحہ ${i + 1} از ${pages.length}',
                  isFirstPage: isFirst,
                  pageIndex: i,
                  textContent: pages[i],
                  fontSize: controller.fontSize,
                  bodyController: controller.bodyController,
                  onModified: onStateChange,
                  onTopDrag: (dy) {
                    controller.updateMargins(top: controller.topMargin + dy);
                    onStateChange();
                  },
                  onBottomDrag: (dy) {
                    controller.updateMargins(bottom: controller.bottomMargin - dy);
                    onStateChange();
                  },
                  onSideDrag: (dx) {
                    controller.updateMargins(side: controller.sideMargin + dx);
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