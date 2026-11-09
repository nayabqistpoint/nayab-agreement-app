import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'services/stamp_margin_service.dart';
import 'services/stamp_pdf_state_service.dart';
import 'services/stamp_rich_text_controller.dart';
import 'services/stamp_tag_service.dart';
import 'services/stamp_template_service.dart';

class StampStudioController extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController(text: 'پنجاب ای-اسٹامپ معاہدہ');
  late final StampRichTextController bodyController;
  final StampPdfStateService pdfService = StampPdfStateService();
  final List<String> pinnedTags = List.from(StampTagService.defaultTags);

  TextSelection activeSelection = const TextSelection.collapsed(offset: 0);
  String paperSize = 'Legal';
  double topMargin = 320.0, subsequentTopMargin = 65.0, bottomMargin = 270.0, sideMargin = 40.0;
  double fontSize = 14.0;

  StampStudioController() {
    bodyController = StampRichTextController(defaultFontSize: fontSize);
    bodyController.addListener(() {
      if (bodyController.selection.isValid) activeSelection = bodyController.selection;
    });
  }

  // اسٹیٹ ریڈرز
  List<Uint8List?> get cachedStampPages => pdfService.cachedStampPages;
  String? get loadedPdfFileName => pdfService.loadedPdfFileName;
  TextSelection get effectiveSelection => (bodyController.selection.isValid && bodyController.selection.start >= 0)
      ? bodyController.selection
      : (activeSelection.isValid && activeSelection.start >= 0)
          ? activeSelection
          : TextSelection.collapsed(offset: bodyController.text.length);

  double get currentActiveFontSize => (effectiveSelection.isValid && !effectiveSelection.isCollapsed)
      ? bodyController.getSelectedFontSize(effectiveSelection.start, effectiveSelection.end)
      : fontSize;

  // ڈیٹا لوڈنگ
  void initFromTemplate(String? title) async {
    if (title == null || title.isEmpty) return;
    final data = StampTemplateService.load(title);
    if (data == null) return;

    titleController.text = data.title;
    bodyController.text = data.content;
    paperSize = data.paperSize;
    topMargin = data.top;
    subsequentTopMargin = data.subTop;
    bottomMargin = data.bottom;
    sideMargin = data.side;
    fontSize = data.fontSize;
    bodyController.defaultFontSize = fontSize;

    if (data.pdfBytes != null) {
      pdfService.setLoadedPdf(data.pdfBytes!, data.fileName);
      await pdfService.renderPages(data.pdfBytes!);
    }
    notifyListeners();
  }

  // مارجنز اور فونٹ سیٹنگ
  void updateMargins({double? top, double? subTop, double? bottom, double? side}) {
    if (top != null) topMargin = StampMarginService.clampTop(top);
    if (subTop != null) subsequentTopMargin = StampMarginService.clampSubTop(subTop);
    if (bottom != null) bottomMargin = StampMarginService.clampBottom(bottom);
    if (side != null) sideMargin = StampMarginService.clampSide(side);
    notifyListeners();
  }

  void setPaperSize(String size) {
    paperSize = size;
    final m = StampMarginService.getDefaults(size);
    updateMargins(top: m.top, subTop: m.subTop, bottom: m.bottom, side: m.side);
  }

  void updateFontSize(double size) {
    final target = StampMarginService.clampFontSize(size);
    final sel = effectiveSelection;
    if (sel.isValid && !sel.isCollapsed) {
      final current = bodyController.getSelectedFontSize(sel.start, sel.end);
      bodyController.incrementFontSizeInRange(sel.start, sel.end, target - current);
      activeSelection = bodyController.selection;
    } else {
      fontSize = target;
      bodyController.defaultFontSize = target;
    }
    notifyListeners();
  }

  // عمومی نوٹیفائر (UI ٹولز سروس کال کے بعد اسے پکاریں گے)
  void notify() => notifyListeners();

  List<String> paginateText() => StampTemplateService.paginate(
        text: bodyController.text,
        fontSize: fontSize,
        top: topMargin,
        subTop: subsequentTopMargin,
        bottom: bottomMargin,
        side: sideMargin,
        paperSize: paperSize,
      );

  Future<bool> saveTemplate() async => await StampTemplateService.save(
        title: titleController.text,
        content: bodyController.text,
        paperSize: paperSize,
        top: topMargin,
        subTop: subsequentTopMargin,
        bottom: bottomMargin,
        side: sideMargin,
        fontSize: fontSize,
        pdfBytes: pdfService.stampPdfBytes,
        fileName: pdfService.loadedPdfFileName,
        pages: paginateText(),
      );

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }
}