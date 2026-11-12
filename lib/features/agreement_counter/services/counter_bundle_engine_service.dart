import 'dart:convert';
import 'dart:typed_data';
import '../../../../core/constants/box_names.dart';
import '../../../../core/database/hive_box_manager.dart';
import '../../../../core/models/document_template_model.dart';
import '../../../../core/models/overlay_box_model.dart';
import '../../../../core/utils/paper_pagination_helper.dart';
import '../../../../core/utils/tag_extraction_helper.dart';
import 'counter_render_service.dart';

class BundlePageMeta {
  final String templateTitle;
  final DocumentMode mode;
  final String text;
  final Uint8List? stampBg;
  final double topMargin;
  final double bottomMargin;
  final double sideMargin;
  final double fontSize;
  final bool isFirstPageOfDoc;
  final String originalPaperSize;
  final List<OverlayBoxModel> floatingBoxes;
  final Map<String, String> fieldValues;

  BundlePageMeta({
    required this.templateTitle,
    required this.mode,
    required this.text,
    required this.stampBg,
    required this.topMargin,
    required this.bottomMargin,
    required this.sideMargin,
    required this.fontSize,
    required this.isFirstPageOfDoc,
    required this.originalPaperSize,
    required this.floatingBoxes,
    required this.fieldValues,
  });
}

class CounterBundleEngineService {
  static Future<({
    List<BundlePageMeta> bundlePages,
    List<String> combinedRequiredFields,
  })> processBundle({
    required List<String> selectedTitles,
    required Map<String, String> fieldValues,
    required double fontSize,
    required double fallbackTop,
    required double fallbackSubTop,
    required double fallbackBottom,
    required double fallbackSide,
    required String paperSize,
    Map<String, Uint8List>? customTemplateStamps,
  }) async {
    if (selectedTitles.isEmpty) {
      return (
        bundlePages: [
          BundlePageMeta(
            templateTitle: '',
            mode: DocumentMode.stampOverlay,
            text: "ٹیمپلیٹ منتخب کریں",
            stampBg: null,
            topMargin: fallbackTop,
            bottomMargin: fallbackBottom,
            sideMargin: fallbackSide,
            fontSize: fontSize,
            isFirstPageOfDoc: true,
            originalPaperSize: 'A4',
            floatingBoxes: const [],
            fieldValues: fieldValues,
          )
        ],
        combinedRequiredFields: <String>[],
      );
    }

    final box = HiveBoxManager.getBox(BoxNames.templatesBox);
    final List<BundlePageMeta> allPages = [];
    final Set<String> fieldSet = {};

    for (final title in selectedTitles) {
      final raw = box.get(title);
      if (raw == null || raw is! Map) continue;

      final doc = DocumentTemplateModel.fromMap(Map<String, dynamic>.from(raw));

      for (final f in doc.fields) {
        fieldSet.add(f.trim());
      }

      final String docPaperSize =
          doc.paperSize.isNotEmpty ? doc.paperSize : paperSize;
      final double docFontSize = (doc.fontSize > 6) ? doc.fontSize : fontSize;
      final double docP1Top = (doc.topMargin > 10) ? doc.topMargin : fallbackTop;
      final double docSubTop = (doc.subsequentTopMargin > 10)
          ? doc.subsequentTopMargin
          : fallbackSubTop;
      final double docBottom =
          (doc.bottomMargin > 10) ? doc.bottomMargin : fallbackBottom;
      final double docSubBottom =
          (doc.subsequentBottomMargin > 10) ? doc.subsequentBottomMargin : 65.0;
      final double docSide =
          (doc.sideMargin > 10) ? doc.sideMargin : fallbackSide;

      List<Uint8List?>? templateRasterizedPages;
      if (customTemplateStamps != null &&
          customTemplateStamps.containsKey(title)) {
        try {
          templateRasterizedPages = await CounterRenderService.renderPdfPages(
              customTemplateStamps[title]!);
        } catch (_) {}
      } else if (doc.base64Pdf != null && doc.base64Pdf!.isNotEmpty) {
        try {
          final decodedBytes = base64Decode(doc.base64Pdf!);
          templateRasterizedPages =
              await CounterRenderService.renderPdfPages(decodedBytes);
        } catch (_) {}
      }

      final replacedContent =
          TemplateService.replaceTags(doc.content, fieldValues);
      final docPages = AgreementPaginationService.paginate(
        fullText: replacedContent,
        fontSize: docFontSize,
        p1TopMargin: docP1Top,
        subsequentTopMargin: docSubTop,
        bottomMargin: docBottom,
        subsequentBottomMargin: docSubBottom,
        sideMargin: docSide,
        paperSize: docPaperSize,
      );

      for (int i = 0; i < docPages.length; i++) {
        final bool isFirst = i == 0;
        final double effectiveTop = isFirst ? docP1Top : docSubTop;
        final double effectiveBottom = isFirst ? docBottom : docSubBottom;

        Uint8List? bg;
        if (templateRasterizedPages != null &&
            templateRasterizedPages.isNotEmpty) {
          if (i < templateRasterizedPages.length) {
            bg = templateRasterizedPages[i];
          } else {
            bg = null;
          }
        }

        final pageFloating = doc.floatingBoxes.where((b) {
          return isFirst;
        }).toList();

        allPages.add(BundlePageMeta(
          templateTitle: title,
          mode: doc.mode,
          text: docPages[i],
          stampBg: bg,
          topMargin: effectiveTop,
          bottomMargin: effectiveBottom,
          sideMargin: docSide,
          fontSize: docFontSize,
          isFirstPageOfDoc: isFirst,
          originalPaperSize: docPaperSize,
          floatingBoxes: pageFloating,
          fieldValues: fieldValues,
        ));
      }
    }

    return (
      bundlePages: allPages.isEmpty
          ? [
              BundlePageMeta(
                templateTitle: '',
                mode: DocumentMode.stampOverlay,
                text: "ٹیمپلیٹ خالی ہے",
                stampBg: null,
                topMargin: fallbackTop,
                bottomMargin: fallbackBottom,
                sideMargin: fallbackSide,
                fontSize: fontSize,
                isFirstPageOfDoc: true,
                originalPaperSize: 'A4',
                floatingBoxes: const [],
                fieldValues: fieldValues,
              )
            ]
          : allPages,
      combinedRequiredFields: fieldSet.toList(),
    );
  }
}