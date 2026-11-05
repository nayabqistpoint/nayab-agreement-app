import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared_services/agreement_storage_handler_service.dart';
import '../../shared_services/payload_builders/agreement_payload_builder.dart';
import '../../shared_services/pdf_render_service.dart';
import '../../shared_services/qr_scanner_service.dart';
import '../../shared_services/cnic_ocr_scanner_service.dart';
import '../../shared_services/template_service.dart';
import '../../shared_models/agreement_template_model.dart';

class AgreementCounterController extends ChangeNotifier {
  String selectedTemplateTitle = '';
  String templateContent = '';
  String paperSize = 'A4';
  double topMargin = 0.0;

  List<String> requiredFields = [];
  Map<String, String> currentFieldValues = {};
  Map<String, dynamic> qrSourceData = {};

  /// ہائیو اور ڈیفالٹ میں موجود تمام معاہدوں کی فہرست
  List<String> get availableTemplates {
    final hiveTemplates = AgreementStorageHandlerService.getAllTemplates();
    if (hiveTemplates.isNotEmpty) {
      return hiveTemplates.keys.toList();
    }
    return TemplateService.defaultPresets.keys.toList();
  }

  /// ڈراپ ڈاؤن سے معاہدہ تبدیل کرنے کا فنکشن
  void switchTemplate(String title) {
    final hiveTemplates = AgreementStorageHandlerService.getAllTemplates();
    if (hiveTemplates.containsKey(title)) {
      final content = hiveTemplates[title]!['content']?.toString() ?? '';
      selectTemplate(title, content);
    } else if (TemplateService.defaultPresets.containsKey(title)) {
      selectTemplate(title, TemplateService.defaultPresets[title]!);
    }
  }

  Future<void> loadDraftFromHive() async {
    final savedTemplates = AgreementStorageHandlerService.getAllTemplates();
    if (savedTemplates.isEmpty) {
      for (var entry in TemplateService.defaultPresets.entries) {
        final payload = AgreementPayloadBuilder.buildTemplatePayload(
          AgreementTemplateModel(
            id: entry.key,
            title: entry.key,
            content: entry.value,
            fields: TemplateService.extractFields(entry.value),
            createdAt: '',
            updatedAt: '',
          ),
        );
        await AgreementStorageHandlerService.saveTemplate(payload);
      }
    }

    final draft = AgreementStorageHandlerService.getCurrentDraft();
    if (draft != null) {
      selectedTemplateTitle = draft['templateId']?.toString() ?? '';
      templateContent = draft['templateText']?.toString() ?? '';
      paperSize = draft['paperSize']?.toString() ?? 'A4';
      topMargin = (draft['topMargin'] as num?)?.toDouble() ?? 0.0;
      qrSourceData = Map<String, dynamic>.from(draft['qrSourceData'] ?? {});
      currentFieldValues = Map<String, String>.from(
        (draft['fieldValues'] as Map?)?.map((k, v) => MapEntry(k.toString(), v.toString())) ?? {},
      );
      requiredFields = TemplateService.extractFields(templateContent);
    } else {
      final firstTitle = TemplateService.defaultPresets.keys.first;
      selectTemplate(firstTitle, TemplateService.defaultPresets[firstTitle]!);
    }
    notifyListeners();
  }

  void selectTemplate(String title, String content) {
    selectedTemplateTitle = title;
    templateContent = content;
    requiredFields = TemplateService.extractFields(content);
    currentFieldValues.clear();
    for (var f in requiredFields) {
      if (qrSourceData.containsKey(f)) {
        currentFieldValues[f] = qrSourceData[f].toString();
      }
    }
    _autoSaveToHive();
    notifyListeners();
  }

  void _autoSaveToHive() {
    final draft = AgreementPayloadBuilder.buildDraftPayload(
      templateId: selectedTemplateTitle,
      templateText: templateContent,
      paperSize: paperSize,
      topMargin: topMargin,
      fieldValues: currentFieldValues,
      qrSourceData: qrSourceData,
    );
    AgreementStorageHandlerService.saveCurrentDraft(draft);
  }

  Future<void> scanProduct(BuildContext context) async {
    final rawData = await QrScannerService.scanQrCode(context);
    if (!context.mounted) return;
    if (rawData == null || rawData.isEmpty) return;

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
      _showSnack(context, 'کیو آر کوڈ میں درست JSON موجود نہیں تھا!', isError: true);
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

  Future<void> resetCounter(BuildContext context) async {
    currentFieldValues.clear();
    qrSourceData.clear();
    await AgreementStorageHandlerService.clearCurrentDraft();
    notifyListeners();
    if (context.mounted) {
      _showSnack(context, 'کاؤنٹر فارم صاف کر دیا گیا ہے۔');
    }
  }

  Future<void> printAgreement(BuildContext context) async {
    if (templateContent.isEmpty) {
      _showSnack(context, 'کوئی معاہدہ منتخب نہیں ہے!', isError: true);
      return;
    }
    await PdfRenderService.generateAndPrintAgreement(
      rawContent: templateContent,
      fieldValues: currentFieldValues,
      paperSize: paperSize,
      topMargin: topMargin,
    );
  }

  void copyAgreementText(BuildContext context) {
    final finalText = TemplateService.replaceTags(templateContent, currentFieldValues);
    Clipboard.setData(ClipboardData(text: finalText));
    _showSnack(context, '✅ مکمل معاہدے کا متن کلپ بورڈ پر کاپی ہو گیا!');
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