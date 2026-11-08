import 'package:flutter/material.dart';
import '../stamp_studio_controller.dart';
import 'stamp_canvas_sheet.dart';

class StampCanvasViewportUi extends StatelessWidget {
  final StampStudioController controller;
  final TransformationController zoomController;
  final VoidCallback onStateChange;

  const StampCanvasViewportUi({
    super.key,
    required this.controller,
    required this.zoomController,
    required this.onStateChange,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingPdf) {
      return const Center(child: CircularProgressIndicator());
    }

    final bool isA4 = controller.paperSize.toUpperCase() == 'A4';
    const double sheetW = 390.0;
    final double sheetH = isA4 ? 552.0 : 642.0;
    final double scale = sheetH / (isA4 ? 842.0 : 1008.0);
    final pages = controller.paginateText();

    return InteractiveViewer(
      transformationController: zoomController,
      minScale: 0.3,
      maxScale: 2.5,
      boundaryMargin: const EdgeInsets.all(400),
      constrained: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: List.generate(pages.length, (index) {
              final isP1 = (index == 0);
              final scaledTop = (isP1 ? controller.topMargin : controller.subsequentTopMargin) * scale;
              final scaledBot = controller.bottomMargin * scale;
              final scaledSide = controller.sideMargin * scale;
              final bgImg = (index < controller.cachedStampPages.length)
                  ? controller.cachedStampPages[index]
                  : null;

              return Column(
                children: [
                  StampCanvasSheet(
                    sheetWidth: sheetW,
                    sheetHeight: sheetH,
                    scaledTop: scaledTop,
                    scaledBottom: scaledBot,
                    scaledSide: scaledSide,
                    bgImage: bgImg,
                    pageLabel: isP1
                        ? "صفحہ نمبر 1 (${controller.paperSize})"
                        : "صفحہ نمبر ${index + 1} (${controller.paperSize})",
                    isFirstPage: isP1,
                    textContent: pages.isNotEmpty ? pages[index] : "",
                    fontSize: controller.fontSize,
                    bodyController: isP1 ? controller.bodyController : null,
                    onTextChanged: (_) => onStateChange(),
                    onTopDrag: (delta) {
                      if (isP1) {
                        controller.setTopMargin(controller.topMargin + (delta / scale));
                      } else {
                        controller.setSubsequentTopMargin(controller.subsequentTopMargin + (delta / scale));
                      }
                    },
                    onBottomDrag: (delta) => controller.setBottomMargin(controller.bottomMargin - (delta / scale)),
                    onSideDrag: (delta) => controller.setSideMargin(controller.sideMargin - (delta / scale)),
                  ),
                  const SizedBox(height: 35),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}