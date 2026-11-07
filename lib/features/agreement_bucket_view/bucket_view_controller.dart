import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared_services/agreement_storage_handler_service.dart';
import '../../shared_services/payload_builders/agreement_payload_builder.dart';
import '../../shared_services/template_service.dart';

class BucketViewController extends ChangeNotifier {
  String templateId = '';
  String templateText = '';
  String paperSize = 'A4';
  bool isEStamp = false;
  double topMargin = 0.0;
  double subsequentTopMargin = 45.0;
  double bottomMargin = 0.0;
  double sideMargin = 20.0;
  final Map<String, TextEditingController> controllers = {};
  List<String> fields = [];
  Map<String, dynamic> qrSourceData = {};
  final TextEditingController phoneController = TextEditingController();

  void loadFromDraft() {
    final draft = AgreementStorageHandlerService.getCurrentDraft();
    if (draft != null) {
      templateId = draft['templateId']?.toString() ?? '';
      templateText = draft['templateText']?.toString() ?? '';
      paperSize = draft['paperSize']?.toString() ?? 'A4';
      isEStamp = draft['isEStamp'] as bool? ?? false;
      topMargin = (draft['topMargin'] as num?)?.toDouble() ?? 0.0;
      subsequentTopMargin = (draft['subsequentTopMargin'] as num?)?.toDouble() ?? 45.0;
      bottomMargin = (draft['bottomMargin'] as num?)?.toDouble() ?? 0.0;
      sideMargin = (draft['sideMargin'] as num?)?.toDouble() ?? 20.0;
      qrSourceData = Map<String, dynamic>.from(draft['qrSourceData'] ?? {});
      final savedFieldValues = Map<String, dynamic>.from(draft['fieldValues'] ?? {});
      fields = TemplateService.extractFields(templateText);
      _setupControllers(savedFieldValues);
    }
    notifyListeners();
  }

  void _setupControllers(Map<String, dynamic> savedValues) {
    for (var c in controllers.values) {
      c.dispose();
    }
    controllers.clear();
    for (var f in fields) {
      final initial = savedValues[f]?.toString() ?? qrSourceData[f]?.toString() ?? '';
      final c = TextEditingController(text: initial);
      c.addListener(_persistDraft);
      controllers[f] = c;
    }
  }

  void _persistDraft() {
    final values = controllers.map((k, v) => MapEntry(k, v.text));
    final draft = AgreementPayloadBuilder.buildDraftPayload(
      templateId: templateId,
      templateText: templateText,
      paperSize: paperSize,
      isEStamp: isEStamp,
      topMargin: topMargin,
      subsequentTopMargin: subsequentTopMargin,
      bottomMargin: bottomMargin,
      sideMargin: sideMargin,
      fieldValues: values,
      qrSourceData: qrSourceData,
    );
    AgreementStorageHandlerService.saveCurrentDraft(draft);
  }

  List<String> get pendingFields =>
      fields.where((f) => (controllers[f]?.text.trim().isEmpty ?? true)).toList();

  Future<void> sendQuestionsOnWhatsapp(BuildContext context) async {
    final missing = pendingFields;
    if (missing.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمام فیلڈز پہلے ہی مکمل ہیں!')),
      );
      return;
    }
    final buffer = StringBuffer();
    buffer.writeln('محترم گاہک! نایاب قسط پوائنٹ پر آپ کا معاہدہ تیار کیا جا رہا ہے۔');
    buffer.writeln('براہِ کرم درج ذیل خالی کوائف لکھ کر بھیجیں:\n');
    for (int i = 0; i < missing.length; i++) {
      buffer.writeln('${i + 1}. ${missing[i]}: ');
    }
    final message = buffer.toString();
    String phone = phoneController.text.trim().replaceAll(' ', '').replaceAll('-', '');
    if (phone.startsWith('03')) phone = '92${phone.substring(1)}';
    if (phone.isNotEmpty) {
      final url = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        return;
      }
    }
    Clipboard.setData(ClipboardData(text: message));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سوالنامہ کلپ بورڈ پر کاپی ہو گیا!')),
      );
    }
  }

  Future<void> pasteAndParseFromClipboard(BuildContext context) async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text ?? '';
    if (text.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('کلپ بورڈ خالی ہے!')),
        );
      }
      return;
    }
    int matchCount = 0;
    final lines = text.split('\n');
    for (var line in lines) {
      if (line.contains(':')) {
        final parts = line.split(':');
        String key = parts[0].replaceAll(RegExp(r'^[0-9]+[\.\-\s]+'), '').trim();
        String val = parts.sublist(1).join(':').trim();
        if (controllers.containsKey(key) && val.isNotEmpty) {
          controllers[key]!.text = val;
          matchCount++;
        }
      }
    }
    _persistDraft();
    notifyListeners();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ $matchCount معلومات خودکار طریقے سے درج ہو گئیں!'),
          backgroundColor: Colors.teal,
        ),
      );
    }
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