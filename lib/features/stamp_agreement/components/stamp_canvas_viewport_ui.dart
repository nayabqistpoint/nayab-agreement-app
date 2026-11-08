import 'package:flutter/material.dart';
import '../stamp_studio_controller.dart';
import 'stamp_canvas_sheet.dart';

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
    if (controller.isLoadingPdf) {
      return const Center(child: CircularProgressIndicator());
    }

    final bool isA4 = controller.paperSize.toUpperCase() == 'A4';
    final pages = controller.paginateText();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final double sheetW = (availableWidth - 24).clamp(240.0, 420.0);
        final double aspectRatio = isA4 ? (842.0 / 595.0) : (1008.0 / 612.0);
        final double sheetH = sheetW * aspectRatio;
        final double scale = sheetH / (isA4 ? 842.0 : 1008.0);

        return InteractiveViewer(
          minScale: 0.5,
          maxScale: 3.0,
          boundaryMargin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          constrained: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(pages.length, (index) {
                  final isP1 = (index == 0);
                  final scaledTop = (isP1 ? controller.topMargin : controller.subsequentTopMargin) * scale;
                  final scaledBot = controller.bottomMargin * scale;
                  final scaledSide = controller.sideMargin * scale;
                  final bgImg = (index < controller.cachedStampPages.length)
                      ? controller.cachedStampPages[index]
                      : null;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: StampCanvasSheet(
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
                      // تمام صفحات کو ایڈیٹر سے جوڑیں تاکہ کسی بھی پیج پر لکھنے سے تحریر ٹوٹے نہیں
                      bodyController: controller.bodyController,
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
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}