import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../stamp_agreement/components/stamp_counter_preview.dart';

class CounterCanvasViewerUi extends StatelessWidget {
  final bool isLoading;
  final List<String> pages;
  final List<Uint8List?> cachedStampPages;
  final List<GlobalKey> pageBoundaryKeys;
  final double topMargin;
  final double subsequentTopMargin;
  final double bottomMargin;
  final double sideMargin;
  final double fontSize;

  const CounterCanvasViewerUi({
    super.key,
    required this.isLoading,
    required this.pages,
    required this.cachedStampPages,
    required this.pageBoundaryKeys,
    required this.topMargin,
    required this.subsequentTopMargin,
    required this.bottomMargin,
    required this.sideMargin,
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
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Column(
                  children: List.generate(pages.length, (i) {
                    final bg = (i < cachedStampPages.length) ? cachedStampPages[i] : null;
                    return RepaintBoundary(
                      key: pageBoundaryKeys[i],
                      child: StampCounterPreview(
                        topMargin: i == 0 ? topMargin : subsequentTopMargin,
                        bottomMargin: bottomMargin,
                        sideMargin: sideMargin,
                        textContent: pages[i],
                        bgImage: bg,
                        isFirstPage: i == 0,
                        fontSize: fontSize,
                      ),
                    );
                  }),
                ),
              ),
            ),
    );
  }
}