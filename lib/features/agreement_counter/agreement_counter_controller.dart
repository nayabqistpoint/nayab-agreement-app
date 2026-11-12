import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/constants/box_names.dart';
import '../../core/database/hive_box_manager.dart';
import '../../core/models/customer_deal_model.dart';
import '../../core/models/document_template_model.dart';
import '../../core/utils/smart_payload_parser.dart';
import 'services/counter_bundle_engine_service.dart';
import 'services/counter_deal_recorder_service.dart';
import 'services/counter_media_picker_service.dart';
import 'services/counter_payload_builder.dart';
import 'services/counter_render_service.dart';
import 'services/counter_storage_handler_service.dart';

class AgreementCounterController extends ChangeNotifier {
  List<String> selectedTemplates = [];
  String paperSize = 'Legal';
  double fontSize = 13.5;
  double topMargin = 320.0;
  double subsequentTopMargin = 65.0;
  double bottomMargin = 270.0;
  double sideMargin = 40.0;

  Map<String, Uint8List> customTemplateStamps = {};
  Map<String, String> currentFieldValues = {};
  List<String> availableTemplates = [];
  Map<String, DocumentTemplateModel> templateModelsMap = {};
  
  List<BundlePageMeta> bundlePages = [];
  List<String> requiredFields = [];
  bool isRenderingStamp = false;

  CustomerDealModel? activeDeal;

  int get legalPagesCount => bundlePages.where((p) => p.originalPaperSize.toLowerCase().contains('legal')).length;
  int get a4PagesCount => bundlePages.where((p) => !p.originalPaperSize.toLowerCase().contains('legal')).length;

  void init() {
    loadDraft();
    loadTemplates();
  }

  void loadTemplates() {
    final all = CounterStorageHandlerService.getAllTemplates();
    availableTemplates = all.keys.toList();
    templateModelsMap.clear();

    for (var entry in all.entries) {
      templateModelsMap[entry.key] = DocumentTemplateModel.fromMap(entry.value);
    }

    if (availableTemplates.isNotEmpty && selectedTemplates.isEmpty) {
      selectedTemplates = [availableTemplates.first];
    }
    recalculateBundle();
    notifyListeners();
  }

  void loadDraft() {
    final draft = CounterStorageHandlerService.getDraft();
    if (draft.containsKey('fieldValues') && draft['fieldValues'] is Map) {
      currentFieldValues = Map<String, String>.from(draft['fieldValues']);
    }
    if (draft.containsKey('selected_templates_bundle') && draft['selected_templates_bundle'] is List) {
      final savedBundle = List<String>.from(draft['selected_templates_bundle']);
      if (savedBundle.isNotEmpty) {
        selectedTemplates = savedBundle;
      }
    }
  }

  void toggleTemplateSelection(String title) {
    if (selectedTemplates.contains(title)) {
      if (selectedTemplates.length > 1) {
        selectedTemplates.remove(title);
      }
    } else {
      selectedTemplates.add(title);
    }
    recalculateBundle();
    persistState();
    notifyListeners();
  }

  void selectAllTemplates() {
    selectedTemplates = List.from(availableTemplates);
    recalculateBundle();
    persistState();
    notifyListeners();
  }

  void clearAllSelectedTemplates() {
    if (availableTemplates.isNotEmpty) {
      selectedTemplates = [availableTemplates.first];
    }
    recalculateBundle();
    persistState();
    notifyListeners();
  }

  Future<void> attachStampToTemplate(String templateTitle) async {
    final file = await CounterRenderService.pickStampFile();
    if (file != null && file.bytes != null) {
      customTemplateStamps[templateTitle] = file.bytes!;
      await recalculateBundle();
      notifyListeners();
    }
  }

  Future<void> recalculateBundle() async {
    isRenderingStamp = true;
    notifyListeners();

    final result = await CounterBundleEngineService.processBundle(
      selectedTitles: selectedTemplates,
      fieldValues: currentFieldValues,
      fontSize: fontSize,
      fallbackTop: topMargin,
      fallbackSubTop: subsequentTopMargin,
      fallbackBottom: bottomMargin,
      fallbackSide: sideMargin,
      paperSize: paperSize,
      customTemplateStamps: customTemplateStamps,
    );

    bundlePages = result.bundlePages;
    requiredFields = result.combinedRequiredFields;

    // ٹیمپلیٹ سے آئی ہوئی تمام فیلڈز کو ہمیشہ یقینی بنائیں
    for (var field in requiredFields) {
      if (!currentFieldValues.containsKey(field)) {
        currentFieldValues[field] = '';
      }
    }

    isRenderingStamp = false;
    persistState();
    notifyListeners();
  }

  void applyScannedData(String rawScan) {
    final parsedMap = SmartPayloadParser.parseScannedInput(rawScan);
    if (parsedMap.isNotEmpty) {
      currentFieldValues.addAll(parsedMap);

      if (parsedMap.containsKey('شناختی کارڈ')) {
        final cnic = parsedMap['شناختی کارڈ']!;
        final box = HiveBoxManager.getBox(BoxNames.customersBox);
        final rawCust = box.get(cnic);
        if (rawCust is Map) {
          if (!currentFieldValues.containsKey('کسٹمر کا نام') || currentFieldValues['کسٹمر کا نام']!.isEmpty) {
            currentFieldValues['کسٹمر کا نام'] = rawCust['fullName']?.toString() ?? '';
          }
          if (!currentFieldValues.containsKey('ولدیت') || currentFieldValues['ولدیت']!.isEmpty) {
            currentFieldValues['ولدیت'] = rawCust['fatherName']?.toString() ?? '';
          }
          if (!currentFieldValues.containsKey('رابطہ نمبر') || currentFieldValues['رابطہ نمبر']!.isEmpty) {
            currentFieldValues['رابطہ نمبر'] = rawCust['phone']?.toString() ?? '';
          }
          if (!currentFieldValues.containsKey('مستقل پتہ') || currentFieldValues['مستقل پتہ']!.isEmpty) {
            currentFieldValues['مستقل پتہ'] = rawCust['address']?.toString() ?? '';
          }
        }
      }

      recalculateBundle();
      persistState();
      notifyListeners();
    }
  }

  Future<CustomerDealModel> commitDeal() async {
    final deal = await CounterDealRecorderService.recordDeal(
      bundledTemplates: selectedTemplates,
      fieldValues: currentFieldValues,
      deliveryPhotoPath: activeDeal?.deliveryPhotoPath,
      signedDocPhotoPath: activeDeal?.signedDocPhotoPath,
    );
    activeDeal = deal;
    notifyListeners();
    return deal;
  }

  Future<void> captureDeliveryPhoto() async {
    if (activeDeal == null) {
      await commitDeal();
    }
    final path = await CounterMediaPickerService.capturePhoto(prefixName: 'delivery_${activeDeal!.id}');
    if (path != null) {
      await CounterDealRecorderService.updateDealMedia(
        dealId: activeDeal!.id,
        deliveryPhotoPath: path,
      );
      activeDeal = activeDeal!.copyWith(deliveryPhotoPath: path);
      notifyListeners();
    }
  }

  Future<void> captureSignedDocPhoto() async {
    if (activeDeal == null) {
      await commitDeal();
    }
    final path = await CounterMediaPickerService.capturePhoto(prefixName: 'signed_${activeDeal!.id}');
    if (path != null) {
      await CounterDealRecorderService.updateDealMedia(
        dealId: activeDeal!.id,
        signedDocPhotoPath: path,
      );
      activeDeal = activeDeal!.copyWith(signedDocPhotoPath: path);
      notifyListeners();
    }
  }

  void persistState() {
    final payload = CounterPayloadBuilder.buildDraftPayload(
      templateTitle: selectedTemplates.isNotEmpty ? selectedTemplates.first : '',
      paperSize: paperSize,
      fontSize: fontSize,
      fieldValues: currentFieldValues,
    );
    payload['selected_templates_bundle'] = selectedTemplates;
    CounterStorageHandlerService.saveDraftBatch(payload);
  }
}