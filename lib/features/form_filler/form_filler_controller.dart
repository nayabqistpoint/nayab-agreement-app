import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'services/form_filler_file_service.dart';
import 'services/form_filler_payload_builder.dart';
import 'services/form_filler_storage_handler_service.dart';

class FormFillerController extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController(text: 'اسکول داخلہ فارم');
  Uint8List? rawFileBytes;
  String? loadedFileName;
  List<Uint8List?> renderedPages = [];
  bool isLoading = false;
  List<String> detectedFields = [];

  void initFromTemplate(String? existingTitle) {
    if (existingTitle == null || existingTitle.isEmpty) return;
    final doc = FormFillerStorageHandlerService.fetchTemplate(existingTitle);
    if (doc == null) return;

    titleController.text = doc.title;
    loadedFileName = doc.stampFileName;
    detectedFields = List<String>.from(doc.fields);

    if (doc.base64Pdf != null && doc.base64Pdf!.isNotEmpty) {
      try {
        rawFileBytes = base64Decode(doc.base64Pdf!);
        _renderPages(rawFileBytes!);
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> pickFormFile() async {
    final file = await FormFillerFileService.pickFormFile();
    if (file != null && file.bytes != null) {
      rawFileBytes = file.bytes!;
      loadedFileName = file.name;
      await _renderPages(rawFileBytes!);
    }
  }

  Future<void> _renderPages(Uint8List bytes) async {
    isLoading = true;
    notifyListeners();
    renderedPages = await FormFillerFileService.rasterizePdf(bytes);
    isLoading = false;
    notifyListeners();
  }

  Future<bool> saveTemplate() async {
    final title = titleController.text.trim();
    if (title.isEmpty) return false;

    final b64 = rawFileBytes != null ? base64Encode(rawFileBytes!) : null;
    final payload = FormFillerPayloadBuilder.build(
      title: title,
      base64Pdf: b64,
      fileName: loadedFileName,
      fields: detectedFields,
    );

    await FormFillerStorageHandlerService.saveTemplate(payload);
    return true;
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }
}