import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/box_names.dart';
import '../../core/database/hive_box_manager.dart';
import '../../core/models/document_template_model.dart';
import 'services/bucket_payload_builder.dart';
import 'services/bucket_storage_handler_service.dart';

class BucketViewController extends ChangeNotifier {
  final TextEditingController phoneController = TextEditingController();
  final Map<String, TextEditingController> controllers = {};
  List<String> fields = [];
  String? qrSourceData;
  String selectedTemplateTitle = '';
  List<String> selectedTemplatesBundle = [];
  String paperSize = 'Legal';
  double fontSize = 13.5;
  String? stampFileName;
  bool isLoading = false;

  void init() {
    loadFromDraft();
  }

  void loadFromDraft() {
    isLoading = true;
    notifyListeners();

    final draft = BucketStorageHandlerService.getDraft();
    selectedTemplateTitle = draft['selectedTemplateTitle']?.toString() ?? '';
    paperSize = draft['paperSize']?.toString() ?? 'Legal';
    fontSize = (draft['fontSize'] as num?)?.toDouble() ?? 13.5;
    stampFileName = draft['stampFileName']?.toString();
    qrSourceData = draft['qrSourceData']?.toString();

    if (draft.containsKey('selected_templates_bundle') && draft['selected_templates_bundle'] is List) {
      selectedTemplatesBundle = List<String>.from(draft['selected_templates_bundle']);
    } else if (selectedTemplateTitle.isNotEmpty) {
      selectedTemplatesBundle = [selectedTemplateTitle];
    }

    // تمام منتخب کردہ ٹیمپلیٹس کے تازہ ترین ٹیگز نکالیں
    final Set<String> templateRequiredFields = {};
    final templatesBox = HiveBoxManager.getBox(BoxNames.templatesBox);
    for (final title in selectedTemplatesBundle) {
      final raw = templatesBox.get(title);
      if (raw != null && raw is Map) {
        final doc = DocumentTemplateModel.fromMap(Map<String, dynamic>.from(raw));
        for (final f in doc.fields) {
          if (f.trim().isNotEmpty) {
            templateRequiredFields.add(f.trim());
          }
        }
      }
    }

    final Map<String, String> existingValues = {};
    if (draft.containsKey('fieldValues') && draft['fieldValues'] is Map) {
      final Map rawFields = draft['fieldValues'] as Map;
      for (var entry in rawFields.entries) {
        existingValues[entry.key.toString()] = entry.value?.toString() ?? '';
      }
    }

    controllers.clear();
    fields.clear();

    // اگر ٹیمپلیٹس سے فیلڈز مل گئی ہیں تو وہ پہلی ترجیح ہوں گی
    final List<String> allKeys = templateRequiredFields.isNotEmpty
        ? templateRequiredFields.toList()
        : existingValues.keys.toList();

    for (var key in allKeys) {
      fields.add(key);
      final val = existingValues[key] ?? '';
      controllers[key] = TextEditingController(text: val);
    }

    if (draft.containsKey('phone')) {
      phoneController.text = draft['phone'].toString();
    }

    isLoading = false;
    notifyListeners();
  }

  void updateField(String key, String value) {
    if (!controllers.containsKey(key)) {
      controllers[key] = TextEditingController(text: value);
      if (!fields.contains(key)) fields.add(key);
    } else {
      controllers[key]!.text = value;
    }
    persistDraft();
    notifyListeners();
  }

  void removeField(String key) {
    fields.remove(key);
    controllers[key]?.dispose();
    controllers.remove(key);
    persistDraft();
    notifyListeners();
  }

  void clearAllFields() {
    for (var c in controllers.values) {
      c.clear();
    }
    persistDraft();
    notifyListeners();
  }

  Map<String, String> get currentFieldValues {
    final Map<String, String> map = {};
    for (var entry in controllers.entries) {
      map[entry.key] = entry.value.text.trim();
    }
    return map;
  }

  void persistDraft() {
    final payload = BucketPayloadBuilder.buildDraft(
      fieldValues: currentFieldValues,
      templateTitle: selectedTemplateTitle,
      paperSize: paperSize,
      fontSize: fontSize,
      stampFileName: stampFileName,
    );
    if (selectedTemplatesBundle.isNotEmpty) {
      payload['selected_templates_bundle'] = selectedTemplatesBundle;
    }
    if (phoneController.text.trim().isNotEmpty) {
      payload['phone'] = phoneController.text.trim();
    }
    if (qrSourceData != null) {
      payload['qrSourceData'] = qrSourceData;
    }
    BucketStorageHandlerService.saveDraftBatch(payload);
  }

  Future<void> sendQuestionsOnWhatsapp() async {
    final phone = phoneController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.isEmpty) return;
    final formattedPhone = phone.startsWith('0') ? '92${phone.substring(1)}' : phone;
    final buffer = StringBuffer('السلام علیکم! برائے مہربانی درج ذیل معلومات فراہم کریں:\n\n');
    for (var f in fields) {
      final val = controllers[f]?.text.trim() ?? '';
      buffer.writeln('$f: ${val.isNotEmpty ? val : "______"}');
    }
    final url = Uri.parse('https://wa.me/$formattedPhone?text=${Uri.encodeComponent(buffer.toString())}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> pasteAndParseFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data == null || data.text == null || data.text!.trim().isEmpty) return;
    final lines = data.text!.split('\n');
    for (var line in lines) {
      if (line.contains(':') || line.contains('-')) {
        final parts = line.split(RegExp(r'[:\-]'));
        if (parts.length >= 2) {
          final k = parts[0].trim();
          final v = parts.sublist(1).join(':').trim();
          if (k.isNotEmpty && v.isNotEmpty && v != "______") {
            updateField(k, v);
          }
        }
      }
    }
    persistDraft();
    notifyListeners();
  }

  @override
  void dispose() {
    phoneController.dispose();
    for (var c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }
}