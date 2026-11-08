import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../shared_services/agreement_pagination_service.dart';
import 'services/stamp_file_service.dart';
import 'services/stamp_payload_builder.dart';
import 'services/stamp_storage_handler_service.dart';
import 'services/stamp_text_format_service.dart';

class StampStudioController extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController(text: 'پنجاب ای-اسٹامپ معاہدہ');
  final TextEditingController bodyController = TextEditingController();

  String paperSize = 'Legal';
  double topMargin = 320.0;
  double subsequentTopMargin = 65.0;
  double bottomMargin = 270.0;
  double sideMargin = 40.0;
  double fontSize = 13.5;

  Uint8List? stampPdfBytes;
  List<Uint8List?> cachedStampPages = [];
  String? loadedPdfFileName;
  bool isLoadingPdf = false;

  final List<String> pinnedTags = [
    'کسٹمر کا نام', 'ولدیت', 'شناختی کارڈ', 'موبائل ماڈل',
    'IMEI نمبر', 'ایڈوانس رقم', 'ماہانہ قسط', 'ٹوٹل رقم', 'مدت',
  ];

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
    fontSize = doc.fontSize;
    loadedPdfFileName = doc.stampFileName;

    if (doc.base64Pdf != null && doc.base64Pdf!.isNotEmpty) {
      try {
        stampPdfBytes = base64Decode(doc.base64Pdf!);
        _renderPdf(stampPdfBytes!);
      } catch (_) {}
    }
    notifyListeners();
  }

  void setPaperSize(String size) {
    paperSize = size;
    final isA4 = size == 'A4';
    topMargin = isA4 ? 45.0 : 320.0;
    subsequentTopMargin = isA4 ? 45.0 : 65.0;
    bottomMargin = isA4 ? 45.0 : 270.0;
    sideMargin = isA4 ? 35.0 : 40.0;
    notifyListeners();
  }

  void setFontSize(double size) { fontSize = size.clamp(10.0, 22.0); notifyListeners(); }
  void setTopMargin(double val) { topMargin = val.clamp(40.0, 700.0); notifyListeners(); }
  void setSubsequentTopMargin(double val) { subsequentTopMargin = val.clamp(30.0, 400.0); notifyListeners(); }
  void setBottomMargin(double val) { bottomMargin = val.clamp(40.0, 500.0); notifyListeners(); }
  void setSideMargin(double val) { sideMargin = val.clamp(15.0, 150.0); notifyListeners(); }

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
    bodyController.text = StampTextFormatService.normalizeParagraphs(bodyController.text);
    notifyListeners();
  }

  List<String> paginateText() {
    return AgreementPaginationService.paginate(
      fullText: bodyController.text,
      fontSize: fontSize,
      p1TopMargin: topMargin,
      subsequentTopMargin: subsequentTopMargin,
      bottomMargin: bottomMargin,
      sideMargin: sideMargin,
      paperSize: paperSize,
    );
  }

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