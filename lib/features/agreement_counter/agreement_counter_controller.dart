import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/models/document_template_model.dart';
import '../../core/utils/paper_pagination_helper.dart';
import 'services/counter_payload_builder.dart';
import 'services/counter_render_service.dart';
import 'services/counter_storage_handler_service.dart';

class AgreementCounterController extends ChangeNotifier {
  String selectedTemplateTitle = '';
  DocumentMode currentDocMode = DocumentMode.stampOverlay;
  String paperSize = 'Legal';
  double fontSize = 13.5;
  double topMargin = 320.0;
  double subsequentTopMargin = 65.0;
  double bottomMargin = 270.0;
  double sideMargin = 40.0;

  String? selectedStampFileName;
  Uint8List? selectedStampPdfBytes;
  List<String> lockedStudioPages = [];
  Map<String, String> currentFieldValues = {};
  List<String> requiredFields = [];
  List<String> availableTemplates = [];

  List<Uint8List?> cachedStampPages = [];
  bool isRenderingStamp = false;

  void init() {
    loadTemplates();
    loadDraft();
  }

  void loadTemplates() {
    final all = CounterStorageHandlerService.getAllTemplates();
    availableTemplates = all.keys.toList();
    if (availableTemplates.isNotEmpty && selectedTemplateTitle.isEmpty) {
      switchTemplate(availableTemplates.first);
    }
    notifyListeners();
  }

  void loadDraft() {
    final draft = CounterStorageHandlerService.getDraft();
    if (draft.containsKey('fieldValues') && draft['fieldValues'] is Map) {
      currentFieldValues = Map<String, String>.from(draft['fieldValues']);
    }
    notifyListeners();
  }

  void switchTemplate(String title) {
    selectedTemplateTitle = title;
    final all = CounterStorageHandlerService.getAllTemplates();
    if (all.containsKey(title)) {
      final doc = DocumentTemplateModel.fromMap(all[title]!);
      currentDocMode = doc.mode;
      paperSize = doc.paperSize;
      fontSize = doc.fontSize;
      topMargin = doc.topMargin;
      subsequentTopMargin = doc.subsequentTopMargin;
      bottomMargin = doc.bottomMargin;
      sideMargin = doc.sideMargin;
      lockedStudioPages = List<String>.from(doc.pages);
      requiredFields = List<String>.from(doc.fields);

      if (doc.base64Pdf != null && doc.base64Pdf!.isNotEmpty) {
        try {
          selectedStampPdfBytes = base64Decode(doc.base64Pdf!);
          selectedStampFileName = doc.stampFileName ?? "ٹیمپلیٹ کا محفوظ اسٹامپ";
        } catch (_) {}
      } else {
        selectedStampPdfBytes = null;
        selectedStampFileName = null;
      }
    }
    refreshStampPages();
    persistState();
    notifyListeners();
  }

  Future<void> refreshStampPages() async {
    isRenderingStamp = true;
    notifyListeners();
    cachedStampPages = await CounterRenderService.renderPdfPages(selectedStampPdfBytes);
    isRenderingStamp = false;
    notifyListeners();
  }

  Future<void> handlePickStamp() async {
    final file = await CounterRenderService.pickStampFile();
    if (file != null && file.bytes != null) {
      selectedStampPdfBytes = file.bytes!;
      selectedStampFileName = file.name;
      await refreshStampPages();
      persistState();
      notifyListeners();
    }
  }

  List<String> getPages() {
    if (lockedStudioPages.isNotEmpty) return lockedStudioPages;
    return AgreementPaginationService.paginate(
      fullText: "ٹیمپلیٹ منتخب کریں",
      fontSize: fontSize,
      p1TopMargin: topMargin,
      subsequentTopMargin: subsequentTopMargin,
      bottomMargin: bottomMargin,
      sideMargin: sideMargin,
      paperSize: paperSize,
    );
  }

  void setFontSize(double size) {
    fontSize = size.clamp(10.0, 22.0);
    persistState();
    notifyListeners();
  }

  void persistState() {
    final payload = CounterPayloadBuilder.buildDraftPayload(
      templateTitle: selectedTemplateTitle,
      paperSize: paperSize,
      fontSize: fontSize,
      fieldValues: currentFieldValues,
      stampFileName: selectedStampFileName,
    );
    CounterStorageHandlerService.saveDraftBatch(payload);
  }
}