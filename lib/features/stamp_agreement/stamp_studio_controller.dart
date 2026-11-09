import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/utils/paper_pagination_helper.dart';
import 'services/stamp_alignment_service.dart';
import 'services/stamp_file_service.dart';
import 'services/stamp_margin_service.dart';
import 'services/stamp_paragraph_service.dart';
import 'services/stamp_payload_builder.dart';
import 'services/stamp_rich_text_controller.dart';
import 'services/stamp_storage_handler_service.dart';
import 'services/stamp_text_format_service.dart';

class StampStudioController extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController(text: 'پنجاب ای-اسٹامپ معاہدہ');
  late final StampRichTextController bodyController;
  TextSelection activeSelection = const TextSelection.collapsed(offset: 0);

  String paperSize = 'Legal';
  double topMargin = 320.0, subsequentTopMargin = 65.0, bottomMargin = 270.0, sideMargin = 40.0;
  double fontSize = 14.0;
  Uint8List? stampPdfBytes;
  List<Uint8List?> cachedStampPages = [];
  String? loadedPdfFileName;
  bool isLoadingPdf = false;

  final List<String> pinnedTags = [
    'کسٹمر کا نام', 'ولدیت', 'شناختی کارڈ', 'موبائل ماڈل',
    'IMEI نمبر', 'ایڈوانس رقم', 'ماہانہ قسط', 'ٹوٹل رقم', 'مدت',
  ];

  StampStudioController() {
    bodyController = StampRichTextController(defaultFontSize: fontSize);
    bodyController.addListener(() {
      if (bodyController.selection.isValid) activeSelection = bodyController.selection;
    });
  }

  TextSelection get effectiveSelection =>
      (bodyController.selection.isValid && bodyController.selection.start >= 0)
          ? bodyController.selection
          : (activeSelection.isValid && activeSelection.start >= 0)
              ? activeSelection
              : TextSelection.collapsed(offset: bodyController.text.length);

  double get currentActiveFontSize => (effectiveSelection.isValid && !effectiveSelection.isCollapsed)
      ? bodyController.getSelectedFontSize(effectiveSelection.start, effectiveSelection.end)
      : fontSize;

  void initFromTemplate(String? existingTitle) {
    if (existingTitle == null || existingTitle.isEmpty) return;
    final doc = StampStorageHandlerService.fetchTemplate(existingTitle);
    if (doc == null) return;

    titleController.text = doc.title;
    bodyController.text = doc.content;
    paperSize = doc.paperSize.isNotEmpty ? doc.paperSize : 'Legal';
    topMargin = doc.topMargin;
    subsequentTopMargin = doc.subsequentTopMargin;
    bottomMargin = doc.bottomMargin;
    sideMargin = doc.sideMargin;
    fontSize = doc.fontSize.roundToDouble();
    bodyController.defaultFontSize = fontSize;
    loadedPdfFileName = doc.stampFileName;

    if (doc.base64Pdf != null && doc.base64Pdf!.isNotEmpty) {
      try {
        stampPdfBytes = base64Decode(doc.base64Pdf!);
        _renderPdf(stampPdfBytes!);
      } catch (_) {}
    }
    notifyListeners();
  }

  void insertEmptyTag() {
    bodyController.selection = effectiveSelection;
    StampTextFormatService.insertEmptyTag(bodyController);
    activeSelection = bodyController.selection;
    notifyListeners();
  }

  void insertEmSpace() {
    bodyController.selection = effectiveSelection;
    StampAlignmentService.insertEmSpace(bodyController);
    activeSelection = bodyController.selection;
    notifyListeners();
  }

  void insertTagAtCursor(String tagText) {
    bodyController.selection = effectiveSelection;
    StampTextFormatService.insertTag(bodyController, tagText);
    activeSelection = bodyController.selection;
    notifyListeners();
  }

  void increaseFontSize() => setFontSize(currentActiveFontSize + 1.0);
  void decreaseFontSize() => setFontSize(currentActiveFontSize - 1.0);

  void setFontSize(double size) {
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

  void alignSelectedLine(TextAlign alignment) {
    bodyController.selection = effectiveSelection;
    StampAlignmentService.alignLine(bodyController, alignment);
    activeSelection = bodyController.selection;
    notifyListeners();
  }

  void toggleBullet() {
    bodyController.selection = effectiveSelection;
    StampParagraphService.toggleBullet(bodyController);
    activeSelection = bodyController.selection;
    notifyListeners();
  }

  void applyFormatToSelection(String format) {
    final sel = effectiveSelection;
    if (sel.isValid && !sel.isCollapsed) bodyController.selection = sel;
    StampTextFormatService.insertFormatting(bodyController, format);
    activeSelection = bodyController.selection;
    notifyListeners();
  }

  void addCustomTag(String tag) {
    if (tag.trim().isNotEmpty && !pinnedTags.contains(tag.trim())) {
      pinnedTags.add(tag.trim());
      notifyListeners();
    }
  }

  void removeTag(String tag) {
    pinnedTags.remove(tag);
    notifyListeners();
  }

  void setPaperSize(String size) {
    paperSize = size;
    final margins = StampMarginService.getDefaults(size);
    topMargin = margins.top;
    subsequentTopMargin = margins.subTop;
    bottomMargin = margins.bottom;
    sideMargin = margins.side;
    notifyListeners();
  }

  void setTopMargin(double val) { topMargin = StampMarginService.clampTop(val); notifyListeners(); }
  void setSubsequentTopMargin(double val) { subsequentTopMargin = StampMarginService.clampSubTop(val); notifyListeners(); }
  void setBottomMargin(double val) { bottomMargin = StampMarginService.clampBottom(val); notifyListeners(); }
  void setSideMargin(double val) { sideMargin = StampMarginService.clampSide(val); notifyListeners(); }

  Future<void> pickPdf() async {
    final file = await StampFileService.pickPdfFile();
    if (file != null && file.bytes != null) {
      stampPdfBytes = file.bytes!;
      loadedPdfFileName = file.name;
      await _renderPdf(stampPdfBytes!);
    }
  }

  Future<void> _renderPdf(Uint8List bytes) async {
    isLoadingPdf = true;
    notifyListeners();
    cachedStampPages = await StampFileService.rasterizePdf(bytes);
    isLoadingPdf = false;
    notifyListeners();
  }

  void normalizeBodyText() {
    StampTextFormatService.normalizeParagraphs(bodyController);
    notifyListeners();
  }

  List<String> paginateText() => AgreementPaginationService.paginate(
        fullText: bodyController.text,
        fontSize: fontSize,
        p1TopMargin: topMargin,
        subsequentTopMargin: subsequentTopMargin,
        bottomMargin: bottomMargin,
        sideMargin: sideMargin,
        paperSize: paperSize,
      );

  Future<bool> saveTemplate() async {
    if (titleController.text.trim().isEmpty) return false;
    final b64 = stampPdfBytes != null ? base64Encode(stampPdfBytes!) : null;
    final payload = StampPayloadBuilder.build(
      title: titleController.text.trim(),
      content: bodyController.text,
      paperSize: paperSize,
      topMargin: topMargin,
      subsequentTopMargin: subsequentTopMargin,
      bottomMargin: bottomMargin,
      sideMargin: sideMargin,
      fontSize: fontSize,
      base64Pdf: b64,
      stampFileName: loadedPdfFileName,
      pages: paginateText(),
    );
    await StampStorageHandlerService.saveTemplate(payload);
    return true;
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }
}