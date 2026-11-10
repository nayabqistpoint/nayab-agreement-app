import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'models/pdf_overlay_field_model.dart';
import 'services/pdf_box_style_service.dart';
import 'services/pdf_editor_storage_service.dart';
import 'services/pdf_render_helper.dart';
import 'services/pdf_scanner_service.dart';

class PdfEditorController extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController();

  String paperSize = 'A4';
  String? loadedFileName;
  Uint8List? pdfRawBytes;
  List<Uint8List> renderedPages = [];

  final List<PdfOverlayFieldModel> fields = [];
  String? selectedFieldId;

  String? pendingStampTag;
  bool isPendingStatic = false;

  double get currentToolbarScale => PdfBoxStyleService.toolbarScale;

  final List<String> availableTags = [
    '{{کسٹمر کا نام}}',
    '{{شناختی کارڈ}}',
    '{{موبائل نمبر}}',
    '{{پتہ}}',
    '{{فون ماڈل}}',
    '{{کل رقم}}',
    '{{پیشگی ادائیگی}}',
    '{{ماہانہ قسط}}',
    '{{تاریخ}}',
    '{{گارنٹر نام}}',
  ];

  void setPaperSize(String size) {
    paperSize = size;
    notifyListeners();
  }

  void selectField(String? id) {
    selectedFieldId = id;
    notifyListeners();
  }

  void setPendingStamp(String tag, {bool isStatic = false}) {
    if (pendingStampTag == tag && isPendingStatic == isStatic) {
      pendingStampTag = null;
    } else {
      pendingStampTag = tag;
      isPendingStatic = isStatic;
      selectedFieldId = null;
    }
    notifyListeners();
  }

  void clearPendingStamp() {
    pendingStampTag = null;
    isPendingStatic = false;
    notifyListeners();
  }

  void addFieldAtPosition(String tag, double x, double y, {bool isStatic = false}) {
    final cleanTag = isStatic ? tag : (tag.isEmpty ? '' : '{{${tag.replaceAll('{{', '').replaceAll('}}', '').trim()}}}');
    
    final newField = PdfBoxStyleService.createField(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      tag: cleanTag,
      x: x.clamp(10.0, 500.0),
      y: y.clamp(10.0, 750.0),
      isStaticText: isStatic,
    );

    fields.add(newField);
    selectedFieldId = newField.id;
    pendingStampTag = null;
    notifyListeners();
  }

  void adjustToolbarScale(double delta) {
    final newScale = (PdfBoxStyleService.toolbarScale + delta).clamp(0.8, 1.6);
    PdfBoxStyleService.rememberStyle(newToolbarScale: newScale);
    notifyListeners();
  }

  void addCustomTag(String tagName) {
    final clean = tagName.replaceAll('{{', '').replaceAll('}}', '').trim();
    if (clean.isEmpty) return;
    final fullTag = '{{$clean}}';
    if (!availableTags.contains(fullTag)) {
      availableTags.add(fullTag);
      notifyListeners();
    }
  }

  void removeCustomTag(String tag) {
    availableTags.remove(tag);
    if (pendingStampTag == tag) pendingStampTag = null;
    notifyListeners();
  }

  void reorderTags(int oldIndex, int newIndex) {
    final item = availableTags.removeAt(oldIndex);
    availableTags.insert(newIndex, item);
    notifyListeners();
  }

  void updateFieldPosition(String id, double dx, double dy) {
    final index = fields.indexWhere((f) => f.id == id);
    if (index != -1) {
      fields[index].x += dx;
      fields[index].y += dy;
      notifyListeners();
    }
  }

  void updateFieldFontSize(String id, double newSize) {
    final index = fields.indexWhere((f) => f.id == id);
    if (index != -1) {
      final clampedSize = newSize.clamp(9.0, 36.0);
      fields[index].fontSize = clampedSize;
      PdfBoxStyleService.rememberStyle(fontSize: clampedSize);
      notifyListeners();
    }
  }

  void toggleBold(String id) {
    final index = fields.indexWhere((f) => f.id == id);
    if (index != -1) {
      final newState = !fields[index].isBold;
      fields[index].isBold = newState;
      PdfBoxStyleService.rememberStyle(isBold: newState);
      notifyListeners();
    }
  }

  void toggleUnderline(String id) {
    final index = fields.indexWhere((f) => f.id == id);
    if (index != -1) {
      final newState = !fields[index].isUnderline;
      fields[index].isUnderline = newState;
      PdfBoxStyleService.rememberStyle(isUnderline: newState);
      notifyListeners();
    }
  }

  void updateFieldText(String id, String text) {
    final index = fields.indexWhere((f) => f.id == id);
    if (index != -1) {
      fields[index].tag = text;
      notifyListeners();
    }
  }

  void removeField(String id) {
    fields.removeWhere((f) => f.id == id);
    if (selectedFieldId == id) selectedFieldId = null;
    notifyListeners();
  }

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        pdfRawBytes = file.bytes;
        loadedFileName = file.name;
        renderedPages = await PdfRenderHelper.renderPdfPages(file.bytes!);
        notifyListeners();
      }
    }
  }

  /// کیمرہ سکینر کے ذریعے تصویر لینا اور کینوس پر لگانا
  Future<void> scanDocumentFromCamera() async {
    final imageBytes = await PdfScannerService.scanDocument();
    if (imageBytes != null) {
      // 1. کینوس پر براہ راست تصویر بچھا دیں
      renderedPages = [imageBytes];
      loadedFileName = 'کیمرہ سکین شدہ دستاویز (${DateTime.now().hour}:${DateTime.now().minute})';

      // 2. ہائیو اسٹوریج اور پرنٹ پائپ لائن کے لیے اس تصویر سے شفاف PDF بائٹس بنانا
      final doc = pw.Document();
      final pageFormat = paperSize == 'A4' ? PdfPageFormat.a4 : PdfPageFormat.legal;
      doc.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: pw.EdgeInsets.zero,
          build: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Image(pw.MemoryImage(imageBytes), fit: pw.BoxFit.fill),
          ),
        ),
      );
      pdfRawBytes = await doc.save();
      notifyListeners();
    }
  }

  Future<bool> saveTemplate() async {
    if (titleController.text.trim().isEmpty) return false;
    await PdfEditorStorageService.saveTemplate(
      title: titleController.text.trim(),
      paperSize: paperSize,
      pdfBytes: pdfRawBytes,
      fileName: loadedFileName,
      fields: fields,
    );
    return true;
  }

  Future<void> loadTemplate(String title) async {
    final data = await PdfEditorStorageService.loadTemplate(title);
    if (data != null) {
      titleController.text = data.title;
      paperSize = data.paperSize;
      loadedFileName = data.fileName;
      pdfRawBytes = data.pdfBytes;
      fields.clear();
      fields.addAll(data.fields);
      PdfBoxStyleService.syncFromFields(fields);
      if (pdfRawBytes != null) {
        renderedPages = await PdfRenderHelper.renderPdfPages(pdfRawBytes!);
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }
}