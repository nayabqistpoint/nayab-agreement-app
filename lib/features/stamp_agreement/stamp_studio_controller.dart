import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'models/stamp_overlay_field_model.dart';
import 'services/stamp_box_style_service.dart';
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

  // آزاد اوورلے فیلڈز (مونوگرام، محفوظ زون اور تمام صفحات کے لیے)
  final List<StampOverlayFieldModel> overlayFields = [];
  String? selectedOverlayFieldId;
  bool isOverlayPlacementActive = false;

  double get currentToolbarScale => StampBoxStyleService.toolbarScale;

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

  // فلوٹنگ اوورلے پاپ اپ ایکشنز
  void toggleOverlayPlacementMode() {
    isOverlayPlacementActive = !isOverlayPlacementActive;
    if (isOverlayPlacementActive) {
      selectedOverlayFieldId = null;
    }
    notifyListeners();
  }

  void addOverlayFieldAtPosition(double x, double y, {int pageIndex = 0, String text = ''}) {
    final newField = StampBoxStyleService.createField(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      tag: text,
      x: x.clamp(10.0, 500.0),
      y: y.clamp(10.0, 950.0),
      pageIndex: pageIndex,
      isStaticText: true,
    );
    overlayFields.add(newField);
    selectedOverlayFieldId = newField.id;
    isOverlayPlacementActive = false;
    notifyListeners();
  }

  void selectOverlayField(String? id) {
    selectedOverlayFieldId = id;
    notifyListeners();
  }

  void updateOverlayFieldPosition(String id, double dx, double dy) {
    final idx = overlayFields.indexWhere((f) => f.id == id);
    if (idx != -1) {
      overlayFields[idx].x += dx;
      overlayFields[idx].y += dy;
      notifyListeners();
    }
  }

  void updateOverlayFieldFontSize(String id, double newSize) {
    final idx = overlayFields.indexWhere((f) => f.id == id);
    if (idx != -1) {
      final clamped = newSize.clamp(9.0, 36.0);
      overlayFields[idx].fontSize = clamped;
      StampBoxStyleService.rememberStyle(fontSize: clamped);
      notifyListeners();
    }
  }

  void toggleOverlayBold(String id) {
    final idx = overlayFields.indexWhere((f) => f.id == id);
    if (idx != -1) {
      final newState = !overlayFields[idx].isBold;
      overlayFields[idx].isBold = newState;
      StampBoxStyleService.rememberStyle(isBold: newState);
      notifyListeners();
    }
  }

  void toggleOverlayUnderline(String id) {
    final idx = overlayFields.indexWhere((f) => f.id == id);
    if (idx != -1) {
      final newState = !overlayFields[idx].isUnderline;
      overlayFields[idx].isUnderline = newState;
      StampBoxStyleService.rememberStyle(isUnderline: newState);
      notifyListeners();
    }
  }

  void updateOverlayFieldText(String id, String newText) {
    final idx = overlayFields.indexWhere((f) => f.id == id);
    if (idx != -1) {
      overlayFields[idx].tag = newText;
      notifyListeners();
    }
  }

  void removeOverlayField(String id) {
    overlayFields.removeWhere((f) => f.id == id);
    if (selectedOverlayFieldId == id) selectedOverlayFieldId = null;
    notifyListeners();
  }

  void adjustToolbarScale(double delta) {
    final newScale = (StampBoxStyleService.toolbarScale + delta).clamp(0.8, 1.6);
    StampBoxStyleService.rememberStyle(newToolbarScale: newScale);
    notifyListeners();
  }

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