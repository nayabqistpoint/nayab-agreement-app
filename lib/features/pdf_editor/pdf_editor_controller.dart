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
  bool _isDisposed = false;

  double get currentToolbarScale => PdfBoxStyleService.toolbarScale;

  final List<String> availableTags = [
    '{{کسٹمر کا نام}}',
    '{{ولدیت}}',
    '{{شناختی کارڈ}}',
    '{{رابطہ نمبر}}',
    '{{مستقل پتہ}}',
    '{{موبائل ماڈل}}',
    '{{IMEI نمبر}}',
    '{{ٹوٹل رقم}}',
    '{{ایڈوانس رقم}}',
    '{{ماہانہ قسط}}',
    '{{مدت}}',
  ];

  void _safeNotify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void setPaperSize(String size) {
    paperSize = size;
    _safeNotify();
  }

  void selectField(String? id) {
    selectedFieldId = id;
    _safeNotify();
  }

  void setPendingStamp(String tag, {bool isStatic = false}) {
    if (pendingStampTag == tag && isPendingStatic == isStatic) {
      pendingStampTag = null;
      isPendingStatic = false;
    } else {
      pendingStampTag = tag;
      isPendingStatic = isStatic;
      selectedFieldId = null;
    }
    _safeNotify();
  }

  void clearPendingStamp() {
    pendingStampTag = null;
    isPendingStatic = false;
    _safeNotify();
  }

  void addFieldAtPosition(
    String tag,
    double x,
    double y, {
    bool isStatic = false,
  }) {
    final String formattedTag;
    if (isStatic) {
      formattedTag = tag;
    } else if (tag.trim().isEmpty) {
      formattedTag = '{{   }}';
    } else {
      final clean = tag.replaceAll('{{', '').replaceAll('}}', '').trim();
      formattedTag = '{{$clean}}';
    }

    final double maxX = paperSize == 'A4' ? 500.0 : 520.0;
    final double maxY = paperSize == 'A4' ? 780.0 : 940.0;

    final newField = PdfBoxStyleService.createField(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      tag: formattedTag,
      x: x.clamp(10.0, maxX),
      y: y.clamp(10.0, maxY),
      isStaticText: isStatic,
    );

    fields.add(newField);
    selectedFieldId = newField.id;
    pendingStampTag = null;
    isPendingStatic = false;
    _safeNotify();
  }

  void adjustToolbarScale(double delta) {
    final newScale = (PdfBoxStyleService.toolbarScale + delta).clamp(1.0, 2.4);
    PdfBoxStyleService.rememberStyle(newToolbarScale: newScale);
    _safeNotify();
  }

  void addCustomTag(String tagName) {
    final clean = tagName.replaceAll('{{', '').replaceAll('}}', '').trim();
    if (clean.isEmpty) return;
    final fullTag = '{{$clean}}';
    if (!availableTags.contains(fullTag)) {
      availableTags.add(fullTag);
    }
    pendingStampTag = fullTag;
    isPendingStatic = false;
    selectedFieldId = null;
    _safeNotify();
  }

  void removeCustomTag(String tag) {
    availableTags.remove(tag);
    if (pendingStampTag == tag) pendingStampTag = null;
    _safeNotify();
  }

  void reorderTags(int oldIndex, int newIndex) {
    final item = availableTags.removeAt(oldIndex);
    availableTags.insert(newIndex, item);
    _safeNotify();
  }

  void updateFieldPosition(String id, double dx, double dy) {
    final index = fields.indexWhere((f) => f.id == id);
    if (index != -1) {
      fields[index].x += dx;
      fields[index].y += dy;
      _safeNotify();
    }
  }

  void updateFieldWidth(String id, double newWidth) {
    final index = fields.indexWhere((f) => f.id == id);
    if (index != -1) {
      fields[index].width = newWidth.clamp(60.0, 520.0);
      _safeNotify();
    }
  }

  void updateFieldFontSize(String id, double newSize) {
    final index = fields.indexWhere((f) => f.id == id);
    if (index != -1) {
      final clampedSize = newSize.clamp(9.0, 36.0);
      fields[index].fontSize = clampedSize;
      PdfBoxStyleService.rememberStyle(fontSize: clampedSize);
      _safeNotify();
    }
  }

  void toggleBold(String id) {
    final index = fields.indexWhere((f) => f.id == id);
    if (index != -1) {
      final newState = !fields[index].isBold;
      fields[index].isBold = newState;
      PdfBoxStyleService.rememberStyle(isBold: newState);
      _safeNotify();
    }
  }

  void toggleUnderline(String id) {
    final index = fields.indexWhere((f) => f.id == id);
    if (index != -1) {
      final newState = !fields[index].isUnderline;
      fields[index].isUnderline = newState;
      PdfBoxStyleService.rememberStyle(isUnderline: newState);
      _safeNotify();
    }
  }

  void updateFieldText(String id, String text) {
    final index = fields.indexWhere((f) => f.id == id);
    if (index != -1) {
      fields[index].tag = text;
      final trimmed = text.trim();
      if (trimmed.startsWith('{{') && trimmed.endsWith('}}')) {
        fields[index].isStaticText = false;
      }
      _safeNotify();
    }
  }

  void removeField(String id) {
    fields.removeWhere((f) => f.id == id);
    if (selectedFieldId == id) selectedFieldId = null;
    _safeNotify();
  }

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (_isDisposed) return;
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        pdfRawBytes = file.bytes;
        loadedFileName = file.name;
        final pages = await PdfRenderHelper.renderPdfPages(file.bytes!);
        if (_isDisposed) return;
        renderedPages = pages;
        _safeNotify();
      }
    }
  }

  Future<void> scanDocumentFromCamera() async {
    final imageBytes = await PdfScannerService.scanDocument();
    if (_isDisposed) return;
    if (imageBytes != null) {
      renderedPages = [imageBytes];
      loadedFileName =
          'کیمرہ سکین شدہ دستاویز (${DateTime.now().hour}:${DateTime.now().minute})';
      final doc = pw.Document();
      final pageFormat =
          paperSize == 'A4' ? PdfPageFormat.a4 : PdfPageFormat.legal;
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
      if (_isDisposed) return;
      _safeNotify();
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
    if (_isDisposed || data == null) return;
    titleController.text = data.title;
    paperSize = data.paperSize;
    loadedFileName = data.fileName;
    pdfRawBytes = data.pdfBytes;
    fields.clear();
    fields.addAll(data.fields);
    PdfBoxStyleService.syncFromFields(fields);
    _safeNotify();
    if (pdfRawBytes != null) {
      final pages = await PdfRenderHelper.renderPdfPages(pdfRawBytes!);
      if (_isDisposed) return;
      renderedPages = pages;
      _safeNotify();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    titleController.dispose();
    super.dispose();
  }
}