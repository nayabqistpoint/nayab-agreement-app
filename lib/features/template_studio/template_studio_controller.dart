import 'package:flutter/material.dart';
import '../../shared_services/agreement_storage_handler_service.dart';
import '../../shared_services/payload_builders/agreement_payload_builder.dart';
import '../../shared_services/template_service.dart';
import '../../shared_models/agreement_template_model.dart';

class TemplateStudioController extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  String paperSize = 'A4';
  double topMargin = 0.0;

  List<String> availableTags = [
    'کسٹمر کا نام',
    'ولدیت',
    'شناختی کارڈ',
    'موبائل ماڈل',
    'IMEI نمبر',
    'ایڈوانس رقم',
    'ماہانہ قسط',
    'ٹوٹل رقم',
    'مدت',
  ];

  void insertTag(String tagName) {
    final text = bodyController.text;
    final selection = bodyController.selection;
    final tagToInsert = '{{$tagName}}';
    if (selection.start >= 0) {
      final newText = text.replaceRange(selection.start, selection.end, tagToInsert);
      bodyController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + tagToInsert.length),
      );
    } else {
      bodyController.text += tagToInsert;
    }
    notifyListeners();
  }

  Future<void> saveTemplatePermanently(BuildContext context) async {
    final title = titleController.text.trim();
    final content = bodyController.text.trim();
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('عنوان اور تحریر دونوں لازمی ہیں!')),
      );
      return;
    }

    final template = AgreementTemplateModel(
      id: title,
      title: title,
      content: content,
      paperSize: paperSize,
      topMargin: topMargin,
      fields: TemplateService.extractFields(content),
      createdAt: '',
      updatedAt: '',
    );

    final payload = AgreementPayloadBuilder.buildTemplatePayload(template);
    await AgreementStorageHandlerService.saveTemplate(payload);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ ٹیمپلیٹ مستقل محفوظ ہو گیا!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }
}