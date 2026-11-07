import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../core/models/document_template_model.dart';
import '../../core/models/overlay_box_model.dart';
import '../../shared_services/agreement_storage_handler_service.dart';
import '../../shared_services/template_service.dart';

class TemplateStudioController extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController(text: 'نیا معاہدہ');
  final TextEditingController bodyController = TextEditingController();

  DocumentMode currentMode = DocumentMode.stampOverlay;
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

  List<OverlayBoxModel> floatingBoxes = [];

  final List<String> pinnedTags = [
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

  void initFromTemplate(String? existingTitle) {
    if (existingTitle == null || existingTitle.isEmpty) return;

    final all = AgreementStorageHandlerService.getAllTemplates();
    if (all.containsKey(existingTitle)) {
      final map = all[existingTitle]!;
      final doc = DocumentTemplateModel.fromMap(map);

      titleController.text = doc.title;
      bodyController.text = doc.content;
      currentMode = doc.mode;
      paperSize = doc.paperSize;
      topMargin = doc.topMargin;
      subsequentTopMargin = doc.subsequentTopMargin;
      bottomMargin = doc.bottomMargin;
      sideMargin = doc.sideMargin;
      fontSize = doc.fontSize;
      loadedPdfFileName = doc.stampFileName;
      floatingBoxes = List.from(doc.floatingBoxes);

      if (doc.base64Pdf != null && doc.base64Pdf!.isNotEmpty) {
        try {
          final bytes = base64Decode(doc.base64Pdf!);
          stampPdfBytes = bytes;
          renderStampBytes(bytes);
        } catch (_) {}
      }
      notifyListeners();
    }
  }

  void setMode(DocumentMode mode) {
    currentMode = mode;
    if (mode == DocumentMode.plainDocument) {
      paperSize = 'A4';
      topMargin = 45.0;
      subsequentTopMargin = 45.0;
      bottomMargin = 40.0;
      sideMargin = 35.0;
      stampPdfBytes = null;
      cachedStampPages.clear();
      loadedPdfFileName = null;
    } else if (mode == DocumentMode.stampOverlay) {
      paperSize = 'Legal';
      topMargin = 320.0;
      subsequentTopMargin = 65.0;
      bottomMargin = 270.0;
      sideMargin = 40.0;
    }
    notifyListeners();
  }

  void setFontSize(double size) {
    fontSize = size.clamp(10.0, 22.0);
    notifyListeners();
  }

  void setTopMargin(double val) {
    topMargin = val.clamp(100.0, 700.0);
    notifyListeners();
  }

  void setSubsequentTopMargin(double val) {
    subsequentTopMargin = val.clamp(30.0, 400.0);
    notifyListeners();
  }

  void setBottomMargin(double val) {
    bottomMargin = val.clamp(50.0, 500.0);
    notifyListeners();
  }

  void setSideMargin(double val) {
    sideMargin = val.clamp(15.0, 150.0);
    notifyListeners();
  }

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      stampPdfBytes = result.files.single.bytes!;
      loadedPdfFileName = result.files.single.name;
      await renderStampBytes(stampPdfBytes!);
      notifyListeners();
    }
  }

  Future<void> renderStampBytes(Uint8List bytes) async {
    isLoadingPdf = true;
    notifyListeners();
    List<Uint8List?> pages = [];
    try {
      await for (final page in Printing.raster(bytes, dpi: 110)) {
        pages.add(await page.toPng());
      }
    } catch (_) {}
    cachedStampPages = pages;
    isLoadingPdf = false;
    notifyListeners();
  }

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

  void normalizeParagraphs() {
    final raw = bodyController.text;
    if (raw.trim().isEmpty) return;

    final paras = raw.split(RegExp(r'\n\s*\n'));
    List<String> cleaned = [];
    for (var p in paras) {
      var lines = p.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty);
      cleaned.add(lines.join(' '));
    }
    bodyController.text = cleaned.join('\n\n');
    notifyListeners();
  }

  void addFloatingField(Offset point) {
    final newBox = OverlayBoxModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tag: '{{فیلڈ_${floatingBoxes.length + 1}}}',
      x: point.dx,
      y: point.dy,
      width: 140.0,
      height: 32.0,
      fontSize: fontSize,
    );
    floatingBoxes.add(newBox);
    notifyListeners();
  }

  void updateFloatingField(OverlayBoxModel updated) {
    final index = floatingBoxes.indexWhere((b) => b.id == updated.id);
    if (index != -1) {
      floatingBoxes[index] = updated;
      notifyListeners();
    }
  }

  void deleteFloatingField(String id) {
    floatingBoxes.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  List<String> paginateText() {
    final fullText = bodyController.text;
    if (fullText.trim().isEmpty) return [""];

    const double totalPoints = 1008.0;
    final double lineH = fontSize * 1.95;

    final double p1H = (totalPoints - topMargin - bottomMargin).clamp(100.0, totalPoints);
    final int p1MaxLines = (p1H / lineH).floor();

    final double subH = (totalPoints - subsequentTopMargin - bottomMargin).clamp(100.0, totalPoints);
    final int subMaxLines = (subH / lineH).floor();

    final double availableWidth = 612.0 - (sideMargin * 2);
    final int charsPerLine = (availableWidth / (fontSize * 0.44)).floor().clamp(65, 110);

    final rawLines = fullText.split('\n');
    List<String> visualLines = [];

    for (var r in rawLines) {
      if (r.trim().isEmpty) {
        visualLines.add("");
        continue;
      }
      final words = r.split(' ');
      String current = "";
      for (var w in words) {
        if ((current + w).length > charsPerLine) {
          visualLines.add(current.trim());
          current = "$w ";
        } else {
          current += "$w ";
        }
      }
      if (current.isNotEmpty) visualLines.add(current.trim());
    }

    List<String> pages = [];
    int lineIndex = 0;

    int linesForP1 = visualLines.length > p1MaxLines ? p1MaxLines : visualLines.length;
    pages.add(visualLines.sublist(0, linesForP1).join('\n'));
    lineIndex = linesForP1;

    while (lineIndex < visualLines.length) {
      int remaining = visualLines.length - lineIndex;
      int take = remaining > subMaxLines ? subMaxLines : remaining;
      pages.add(visualLines.sublist(lineIndex, lineIndex + take).join('\n'));
      lineIndex += take;
    }

    return pages;
  }

  Future<bool> saveTemplate() async {
    final title = titleController.text.trim();
    if (title.isEmpty) return false;

    String? b64;
    if (stampPdfBytes != null) {
      b64 = base64Encode(stampPdfBytes!);
    }

    final doc = DocumentTemplateModel(
      id: title,
      title: title,
      content: bodyController.text.trim(),
      mode: currentMode,
      paperSize: paperSize,
      topMargin: topMargin,
      subsequentTopMargin: subsequentTopMargin,
      bottomMargin: bottomMargin,
      sideMargin: sideMargin,
      fontSize: fontSize,
      base64Pdf: b64,
      stampFileName: loadedPdfFileName,
      floatingBoxes: floatingBoxes,
      fields: TemplateService.extractFields(bodyController.text),
    );

    await AgreementStorageHandlerService.saveTemplate(doc.toMap());
    return true;
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }
}