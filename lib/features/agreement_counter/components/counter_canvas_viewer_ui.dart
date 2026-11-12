import 'package:flutter/material.dart';
import '../../stamp_agreement/components/stamp_counter_preview.dart';
import '../services/counter_bundle_engine_service.dart';

class CounterCanvasViewerUi extends StatelessWidget {
  final bool isLoading;
  final List<BundlePageMeta> pages;
  final List<GlobalKey> pageBoundaryKeys;
  final double fontSize;

  const CounterCanvasViewerUi({
    super.key,
    required this.isLoading,
    required this.pages,
    required this.pageBoundaryKeys,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(6),
      ),
      child: isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.teal),
                  SizedBox(height: 10),
                  Text(
                    'صفحات ہائی ڈیفینیشن رینڈر ہو رہے ہیں...',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            )
          : InteractiveViewer(
              minScale: 0.8,
              maxScale: 3.5,
              boundaryMargin: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                child: Center(
                  child: Column(
                    children: List.generate(pages.length, (i) {
                      final page = pages[i];
                      return RepaintBoundary(
                        key: (i < pageBoundaryKeys.length) ? pageBoundaryKeys[i] : null,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: StampCounterPreview(
                            topMargin: page.topMargin,
                            bottomMargin: page.bottomMargin,
                            sideMargin: page.sideMargin,
                            textContent: page.text,
                            bgImage: page.stampBg,
                            isFirstPage: page.isFirstPageOfDoc,
                            fontSize: page.fontSize,
                            paperSize: page.originalPaperSize,
                            floatingBoxes: page.floatingBoxes,
                            fieldValues: page.fieldValues,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
    );
  }
}