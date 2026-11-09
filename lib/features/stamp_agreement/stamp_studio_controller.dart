import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/utils/paper_pagination_helper.dart';
import 'models/document_line_model.dart';
import 'services/stamp_file_service.dart';
import 'services/stamp_paragraph_service.dart';
import 'services/stamp_payload_builder.dart';
import 'services/stamp_rich_text_controller.dart';
import 'services/stamp_storage_handler_service.dart';
import 'services/stamp_text_format_service.dart';

class StampStudioController extends ChangeNotifier {
  final TextEditingController titleController =
      TextEditingController(text: 'پنجاب ای-اسٹامپ معاہدہ');
  late final StampRichTextController bodyController;

  TextSelection activeSelection = const TextSelection.collapsed(offset: 0);

  List<DocumentLine> documentLines = [];
  int selectedLineIndex = 0;

  String paperSize = 'Legal';
  double topMargin = 320.0,
      subsequentTopMargin = 65.0,
      bottomMargin = 270.0,
      sideMargin = 40.0;
  double fontSize = 14.0;

  Uint8List? stampPdfBytes;
  List<Uint8List?> cachedStampPages = [];
  String? loadedPdfFileName;
  bool isLoadingPdf = false;

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

  StampStudioController() {
    bodyController = StampRichTextController(defaultFontSize: fontSize);
    _syncLinesFromText(bodyController.text);

    bodyController.addListener(() {
      if (bodyController.selection.isValid) {
        activeSelection = bodyController.selection;
      }
    });
  }

  TextSelection get effectiveSelection {
    if (bodyController.selection.isValid && bodyController.selection.start >= 0) {
      return bodyController.selection;
    }
    if (activeSelection.isValid && activeSelection.start >= 0) {
      return activeSelection;
    }
    return TextSelection.collapsed(offset: bodyController.text.length);
  }

  double get currentActiveFontSize {
    final sel = effectiveSelection;
    if (sel.isValid && !sel.isCollapsed) {
      return bodyController.getSelectedFontSize(sel.start, sel.end);
    }
    return fontSize;
  }

  void _syncLinesFromText(String text) {
    if (text.isEmpty) {
      documentLines = [DocumentLine(text: '', fontSize: fontSize)];
    } else {
      documentLines = text.split('\n').map((lineText) {
        TextAlign align = TextAlign.right;
        String clean = lineText;

        if (clean.startsWith('[C]')) {
          align = TextAlign.center;
          clean = clean.substring(3);
        } else if (clean.startsWith('[L]')) {
          align = TextAlign.left;
          clean = clean.substring(3);
        } else if (clean.startsWith('[R]')) {
          align = TextAlign.right;
          clean = clean.substring(3);
        }

        return DocumentLine(
          text: clean,
          alignment: align,
          fontSize: fontSize,
        );
      }).toList();
    }
  }

  void _syncTextFromLines() {
    final buffer = StringBuffer();
    for (int i = 0; i < documentLines.length; i++) {
      final line = documentLines[i];
      String prefix = '';
      if (line.alignment == TextAlign.center) {
        prefix = '[C]';
      } else if (line.alignment == TextAlign.left) {
        prefix = '[L]';
      } else if (line.alignment == TextAlign.right) {
        prefix = '[R]';
      }
      buffer.write('$prefix${line.text}');
      if (i < documentLines.length - 1) buffer.write('\n');
    }
    bodyController.text = buffer.toString();
  }

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
    fontSize = doc.fontSize.roundToDouble();
    bodyController.defaultFontSize = fontSize;
    loadedPdfFileName = doc.stampFileName;

    _syncLinesFromText(doc.content);

    if (doc.base64Pdf != null && doc.base64Pdf!.isNotEmpty) {
      try {
        stampPdfBytes = base64Decode(doc.base64Pdf!);
        _renderPdf(stampPdfBytes!);
      } catch (_) {}
    }
    notifyListeners();
  }

  void updateSelection(TextSelection sel) {
    if (sel.isValid) {
      activeSelection = sel;
    }
  }

  void updateLineText(int index, String newText) {
    if (index >= 0 && index < documentLines.length) {
      documentLines[index].text = newText;
      _syncTextFromLines();
      notifyListeners();
    }
  }

  void selectLine(int index) {
    if (index >= 0 && index < documentLines.length) {
      selectedLineIndex = index;
      notifyListeners();
    }
  }

  void insertLineAfter(int index, [String text = '']) {
    final newLine = DocumentLine(
      text: text,
      fontSize: fontSize,
      alignment: index >= 0 && index < documentLines.length
          ? documentLines[index].alignment
          : TextAlign.right,
    );
    if (index >= 0 && index < documentLines.length) {
      documentLines.insert(index + 1, newLine);
      selectedLineIndex = index + 1;
    } else {
      documentLines.add(newLine);
      selectedLineIndex = documentLines.length - 1;
    }
    _syncTextFromLines();
    notifyListeners();
  }

  void removeLineAt(int index) {
    if (documentLines.length > 1 && index >= 0 && index < documentLines.length) {
      documentLines.removeAt(index);
      selectedLineIndex = (index - 1).clamp(0, documentLines.length - 1);
      _syncTextFromLines();
      notifyListeners();
    }
  }

  void insertEmptyTag() {
    final sel = effectiveSelection;
    final int start = sel.start.clamp(0, bodyController.text.length);
    final int end = sel.end.clamp(0, bodyController.text.length);

    final currentText = bodyController.text;
    const tagWrapper = '{{}}';

    final newText = currentText.replaceRange(start, end, tagWrapper);
    bodyController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + 2),
    );
    activeSelection = bodyController.selection;
    _syncLinesFromText(bodyController.text);
    notifyListeners();
  }

  /// پچھلی آزمودہ اور مضبوط ایم-اسپیس (Unicode Em-Space)
  void insertEmSpace() {
    final sel = effectiveSelection;
    final int start = sel.start.clamp(0, bodyController.text.length);
    final int end = sel.end.clamp(0, bodyController.text.length);

    const emSpace = '\u2003\u2003';
    final currentText = bodyController.text;

    final newText = currentText.replaceRange(start, end, emSpace);
    bodyController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + emSpace.length),
    );
    activeSelection = bodyController.selection;
    _syncLinesFromText(bodyController.text);
    notifyListeners();
  }

  void insertTagAtCursor(String tagText) {
    final sel = effectiveSelection;
    final int start = sel.start.clamp(0, bodyController.text.length);
    final int end = sel.end.clamp(0, bodyController.text.length);

    final cleanTag = tagText.replaceAll('{{', '').replaceAll('}}', '').trim();
    final toInsert = '{{$cleanTag}} ';
    final currentText = bodyController.text;

    final newText = currentText.replaceRange(start, end, toInsert);
    bodyController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + toInsert.length),
    );
    activeSelection = bodyController.selection;
    _syncLinesFromText(bodyController.text);
    notifyListeners();
  }

  void increaseFontSize() {
    final sel = effectiveSelection;
    if (sel.isValid && !sel.isCollapsed) {
      bodyController.incrementFontSizeInRange(sel.start, sel.end, 1.0);
      activeSelection = bodyController.selection;
    } else {
      fontSize = (fontSize + 1.0).clamp(10.0, 32.0);
      bodyController.defaultFontSize = fontSize;
      for (var line in documentLines) {
        line.fontSize = fontSize;
      }
    }
    _syncLinesFromText(bodyController.text);
    notifyListeners();
  }

  void decreaseFontSize() {
    final sel = effectiveSelection;
    if (sel.isValid && !sel.isCollapsed) {
      bodyController.incrementFontSizeInRange(sel.start, sel.end, -1.0);
      activeSelection = bodyController.selection;
    } else {
      fontSize = (fontSize - 1.0).clamp(10.0, 32.0);
      bodyController.defaultFontSize = fontSize;
      for (var line in documentLines) {
        line.fontSize = fontSize;
      }
    }
    _syncLinesFromText(bodyController.text);
    notifyListeners();
  }

  void setFontSize(double size) {
    final targetSize = size.roundToDouble().clamp(10.0, 32.0);
    final sel = effectiveSelection;

    if (sel.isValid && !sel.isCollapsed) {
      final current = bodyController.getSelectedFontSize(sel.start, sel.end);
      final delta = targetSize - current;
      bodyController.incrementFontSizeInRange(sel.start, sel.end, delta);
      activeSelection = bodyController.selection;
    } else {
      fontSize = targetSize;
      bodyController.defaultFontSize = targetSize;
      for (var line in documentLines) {
        line.fontSize = targetSize;
      }
    }
    _syncLinesFromText(bodyController.text);
    notifyListeners();
  }

  /// ایم-اسپیس کے ذریعے لائیو الائنمنٹ (سینٹر اور بائیں طرف کے لیے)
  void alignSelectedLine(TextAlign alignment) {
    final sel = effectiveSelection;
    final int cursorPos = sel.start < 0 ? bodyController.text.length : sel.start;
    final text = bodyController.text;

    final lineInfo = StampParagraphService.getLineAtCursor(text, cursorPos);
    var line = lineInfo.currentLine;

    // پچھلی تمام ایم-اسپیسز اور عام اسپیسز کو سطر کے شروع سے صاف کریں
    line = line.replaceFirst(RegExp(r'^[\u2003\s]+'), '');
    line = line.replaceAll(RegExp(r'^\[(C|L|R)\]'), '');

    String updatedLine;
    if (alignment == TextAlign.center) {
      // سطر کو کینوس کے عین درمیان لانے کے لیے ایم-اسپیسز
      updatedLine = '\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003$line';
    } else if (alignment == TextAlign.left) {
      // دستخط یا تاریخ کو انتہائی بائیں کونے میں لانے کے لیے ایم-اسپیسز
      updatedLine = '\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003\u2003$line';
    } else {
      // عام اردو دائیں طرف
      updatedLine = line;
    }

    final newFullText = text.replaceRange(lineInfo.lineStart, lineInfo.lineEnd, updatedLine);
    bodyController.value = TextEditingValue(
      text: newFullText,
      selection: TextSelection.collapsed(offset: lineInfo.lineStart + updatedLine.length),
    );

    activeSelection = bodyController.selection;
    _syncLinesFromText(bodyController.text);
    notifyListeners();
  }

  void toggleBullet() {
    final sel = effectiveSelection;
    bodyController.selection = sel;
    StampParagraphService.toggleBullet(bodyController);
    activeSelection = bodyController.selection;
    _syncLinesFromText(bodyController.text);
    notifyListeners();
  }

  void applyFormatToSelection(String format) {
    final sel = effectiveSelection;
    if (sel.isValid && !sel.isCollapsed) {
      bodyController.selection = sel;
    }
    StampTextFormatService.insertFormatting(bodyController, format);
    activeSelection = bodyController.selection;
    _syncLinesFromText(bodyController.text);
    notifyListeners();
  }

  void addCustomTag(String tag) {
    if (tag.trim().isNotEmpty && !pinnedTags.contains(tag.trim())) {
      pinnedTags.add(tag.trim());
      notifyListeners();
    }
  }

  void removeTag(String tag) {
    pinnedTags.remove(tag);
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

  void setTopMargin(double val) {
    topMargin = val.clamp(30.0, 700.0);
    notifyListeners();
  }

  void setSubsequentTopMargin(double val) {
    subsequentTopMargin = val.clamp(30.0, 400.0);
    notifyListeners();
  }

  void setBottomMargin(double val) {
    bottomMargin = val.clamp(30.0, 500.0);
    notifyListeners();
  }

  void setSideMargin(double val) {
    sideMargin = val.clamp(15.0, 150.0);
    notifyListeners();
  }

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
    StampTextFormatService.normalizeParagraphs(bodyController);
    _syncLinesFromText(bodyController.text);
    notifyListeners();
  }

  List<String> paginateText() => AgreementPaginationService.paginate(
        fullText: bodyController.text,
        fontSize: fontSize,
        p1TopMargin: topMargin,
        subsequentTopMargin: subsequentTopMargin,
        bottomMargin: bottomMargin,
        sideMargin: sideMargin,
        paperSize: paperSize,
      );

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