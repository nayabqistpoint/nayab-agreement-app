import 'package:flutter/material.dart';
import '../../stamp_agreement/components/stamp_canvas_sheet.dart';
import '../plain_doc_controller.dart';

class PlainDocCanvasViewportUi extends StatelessWidget {
  final PlainDocController controller;
  final TransformationController zoomController;
  final VoidCallback onStateChange;

  const PlainDocCanvasViewportUi({
    super.key,
    required this.controller,
    required this.zoomController,
    required this.onStateChange,
  });

  @override
  Widget build(BuildContext context) {
    const double sheetW = 390.0;
    const double sheetH = 552.0; // A4 تناسب
    const double scale = sheetH / 842.0;
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
              return Column(
                children: [
                  StampCanvasSheet(
                    sheetWidth: sheetW,
                    sheetHeight: sheetH,
                    scaledTop: controller.topMargin * scale,
                    scaledBottom: controller.bottomMargin * scale,
                    scaledSide: controller.sideMargin * scale,
                    bgImage: null,
                    pageLabel: "صفحہ نمبر ${index + 1} (A4 سادہ)",
                    isFirstPage: index == 0,
                    textContent: pages[index],
                    fontSize: controller.fontSize,
                    bodyController: index == 0 ? controller.bodyController : null,
                    onTextChanged: (_) => onStateChange(),
                    onTopDrag: (delta) => controller.setTopMargin(controller.topMargin + (delta / scale)),
                    onBottomDrag: (delta) => controller.setBottomMargin(controller.bottomMargin - (delta / scale)),
                    onSideDrag: (delta) => controller.setSideMargin(controller.sideMargin - (delta / scale)),
                  ),
                  const SizedBox(height: 30),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}