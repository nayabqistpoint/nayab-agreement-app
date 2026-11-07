import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared_services/agreement_storage_handler_service.dart';
import '../../shared_services/payload_builders/agreement_payload_builder.dart';
import '../../shared_services/pdf_render_service.dart';
import '../../shared_services/qr_scanner_service.dart';
import '../../shared_services/cnic_ocr_scanner_service.dart';
import '../../shared_services/template_service.dart';

class AgreementCounterController extends ChangeNotifier {
  String selectedTemplateTitle = '';
  String templateContent = '';
  String paperSize = 'A4';
  bool isEStamp = false;
  double topMargin = 220.0;
  double subsequentTopMargin = 45.0;
  double bottomMargin = 75.0;
  double sideMargin = 35.0;

  List<String> requiredFields = [];
  Map<String, String> currentFieldValues = {};
  Map<String, dynamic> qrSourceData = {};
  Uint8List? selectedStampPdfBytes;
  String? selectedStampFileName;

  List<String> get availableTemplates {
    final hiveTemplates = AgreementStorageHandlerService.getAllTemplates();
    if (hiveTemplates.isNotEmpty) {
      return hiveTemplates.keys.toList();
    }
    return TemplateService.defaultPresets.keys.toList();
  }

  void switchTemplate(String title) {
    final hiveTemplates = AgreementStorageHandlerService.getAllTemplates();
    if (hiveTemplates.containsKey(title)) {
      final t = hiveTemplates[title]!;
      selectedTemplateTitle = title;
      templateContent = t['content']?.toString() ?? '';
      paperSize = t['paperSize']?.toString() ?? 'A4';
      isEStamp = t['isEStamp'] as bool? ?? false;
      topMargin = (t['topMargin'] as num?)?.toDouble() ?? 220.0;
      subsequentTopMargin = (t['subsequentTopMargin'] as num?)?.toDouble() ?? 45.0;
      bottomMargin = (t['bottomMargin'] as num?)?.toDouble() ?? 75.0;
      sideMargin = (t['sideMargin'] as num?)?.toDouble() ?? 35.0;
      _initFields();
    } else if (TemplateService.defaultPresets.containsKey(title)) {
      selectedTemplateTitle = title;
      templateContent = TemplateService.defaultPresets[title]!;
      paperSize = 'A4';
      isEStamp = false;
      topMargin = 45.0;
      subsequentTopMargin = 45.0;
      bottomMargin = 40.0;
      sideMargin = 35.0;
      _initFields();
    }
  }

  void _initFields() {
    requiredFields = TemplateService.extractFields(templateContent);
    currentFieldValues.clear();
    for (var f in requiredFields) {
      if (qrSourceData.containsKey(f)) {
        currentFieldValues[f] = qrSourceData[f].toString();
      }
    }
    _autoSaveToHive();
    notifyListeners();
  }

  Future<void> loadDraftFromHive() async {
    final hiveTemplates = AgreementStorageHandlerService.getAllTemplates();
    final draft = AgreementStorageHandlerService.getCurrentDraft();

    if (draft != null) {
      selectedTemplateTitle = draft['templateId']?.toString() ?? '';

      // اگر ٹیمپلیٹ اسٹوڈیو میں ایڈٹ ہوا ہے تو تازہ ترین ترتیبات Hive ٹیمپلیٹ سے اٹھائیں
      if (hiveTemplates.containsKey(selectedTemplateTitle)) {
        final t = hiveTemplates[selectedTemplateTitle]!;
        templateContent = t['content']?.toString() ?? '';
        paperSize = t['paperSize']?.toString() ?? 'A4';
        isEStamp = t['isEStamp'] as bool? ?? false;
        topMargin = (t['topMargin'] as num?)?.toDouble() ?? 220.0;
        subsequentTopMargin = (t['subsequentTopMargin'] as num?)?.toDouble() ?? 45.0;
        bottomMargin = (t['bottomMargin'] as num?)?.toDouble() ?? 75.0;
        sideMargin = (t['sideMargin'] as num?)?.toDouble() ?? 35.0;
      } else {
        templateContent = draft['templateText']?.toString() ?? '';
        paperSize = draft['paperSize']?.toString() ?? 'A4';
        isEStamp = draft['isEStamp'] as bool? ?? false;
        topMargin = (draft['topMargin'] as num?)?.toDouble() ?? 220.0;
        subsequentTopMargin = (draft['subsequentTopMargin'] as num?)?.toDouble() ?? 45.0;
        bottomMargin = (draft['bottomMargin'] as num?)?.toDouble() ?? 75.0;
        sideMargin = (draft['sideMargin'] as num?)?.toDouble() ?? 35.0;
      }

      qrSourceData = Map<String, dynamic>.from(draft['qrSourceData'] ?? {});
      currentFieldValues = Map<String, String>.from(
        (draft['fieldValues'] as Map?)?.map((k, v) => MapEntry(k.toString(), v.toString())) ?? {},
      );
      requiredFields = TemplateService.extractFields(templateContent);
    } else {
      final firstTitle = availableTemplates.first;
      switchTemplate(firstTitle);
    }
    notifyListeners();
  }

  void _autoSaveToHive() {
    final draft = AgreementPayloadBuilder.buildDraftPayload(
      templateId: selectedTemplateTitle,
      templateText: templateContent,
      paperSize: paperSize,
      isEStamp: isEStamp,
      topMargin: topMargin,
      subsequentTopMargin: subsequentTopMargin,
      bottomMargin: bottomMargin,
      sideMargin: sideMargin,
      fieldValues: currentFieldValues,
      qrSourceData: qrSourceData,
    );
    AgreementStorageHandlerService.saveCurrentDraft(draft);
  }

  Future<void> scanProduct(BuildContext context) async {
    final rawData = await QrScannerService.scanQrCode(context);
    if (!context.mounted || rawData == null || rawData.isEmpty) return;
    try {
      final Map<String, dynamic> data = jsonDecode(rawData);
      qrSourceData.addAll(data);
      data.forEach((k, v) {
        currentFieldValues[k.toString()] = v.toString();
      });
      _autoSaveToHive();
      notifyListeners();
      _showSnack(context, '✅ پروڈکٹ کی تفصیلات بکٹ میں شامل ہو گئیں!');
    } catch (_) {
      _showSnack(context, 'کیو آر کوڈ میں درست ڈیٹا موجود نہیں تھا!', isError: true);
    }
  }

  Future<void> scanCnic(BuildContext context) async {
    final dynamic data = await CnicOcrScannerService.scanCnic(context);
    if (!context.mounted) return;
    if (data != null && data is Map) {
      data.forEach((k, v) {
        currentFieldValues[k.toString()] = v.toString();
        qrSourceData[k.toString()] = v.toString();
      });
      _autoSaveToHive();
      notifyListeners();
      _showSnack(context, '✅ شناختی کارڈ نمبر شامل ہو گیا!');
    } else {
      _showSnack(context, 'شناختی کارڈ سے ڈیٹا نہیں پڑھا جا سکا!', isError: true);
    }
  }

  int get totalFieldsCount => requiredFields.length;
  int get filledFieldsCount => requiredFields.where((f) => (currentFieldValues[f]?.trim().isNotEmpty ?? false)).length;

  Future<void> printAgreement(BuildContext context) async {
    if (templateContent.isEmpty) {
      _showSnack(context, 'کوئی معاہدہ منتخب نہیں ہے!', isError: true);
      return;
    }
    await PdfRenderService.generateAndPrintAgreement(
      rawContent: templateContent,
      fieldValues: currentFieldValues,
      paperSize: paperSize,
      isEStamp: isEStamp,
      topMargin: topMargin,
      subsequentTopMargin: subsequentTopMargin,
      bottomMargin: bottomMargin,
      sideMargin: sideMargin,
      originalStampPdfBytes: selectedStampPdfBytes,
    );
  }

  void copyAgreementText(BuildContext context) {
    final finalText = TemplateService.replaceTags(templateContent, currentFieldValues);
    Clipboard.setData(ClipboardData(text: finalText));
    _showSnack(context, '✅ مکمل معاہدے کا متن کلپ بورڈ پر کاپی ہو گیا!');
  }

  Future<void> resetCounter(BuildContext context) async {
    currentFieldValues.clear();
    qrSourceData.clear();
    selectedStampPdfBytes = null;
    selectedStampFileName = null;
    await AgreementStorageHandlerService.clearCurrentDraft();
    notifyListeners();
    if (context.mounted) {
      _showSnack(context, 'کاؤنٹر فارم صاف کر دیا گیا ہے۔');
    }
  }

  void _showSnack(BuildContext context, String text, {bool isError = false}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, textDirection: TextDirection.rtl),
        backgroundColor: isError ? Colors.red.shade700 : Colors.teal.shade700,
      ),
    );
  }
}