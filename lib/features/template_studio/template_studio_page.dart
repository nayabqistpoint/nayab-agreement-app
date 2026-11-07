import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../core/constants/app_colors.dart';
import '../../shared_models/agreement_template_model.dart';
import '../../shared_services/agreement_storage_handler_service.dart';
import '../../shared_services/payload_builders/agreement_payload_builder.dart';
import '../../shared_services/template_service.dart';
import 'args/template_studio_args.dart';

class TemplateStudioPage extends StatefulWidget {
  final TemplateStudioArgs? args;
  const TemplateStudioPage({super.key, this.args});

  @override
  State<TemplateStudioPage> createState() => _TemplateStudioPageState();
}

class _TemplateStudioPageState extends State<TemplateStudioPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  final TransformationController _zoomController = TransformationController();

  String _paperSize = 'Legal';
  bool _isEStamp = true;

  double _topMargin = 320.0;
  double _subsequentTopMargin = 65.0;
  double _bottomMargin = 270.0;
  double _sideMargin = 40.0;
  double _fontSize = 13.5;

  Uint8List? _stampPdfBytes;
  List<Uint8List?> _cachedStampPages = [];
  String? _loadedPdfFileName;
  bool _isLoadingPdf = false;
  bool _isZoomFit = false;

  final List<String> _pinnedTags = [
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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.args?.templateTitle ?? '');
    String cleanContent = (widget.args?.templateContent ?? '')
        .replaceAll('**', '')
        .replaceAll('[center]', '')
        .replaceAll('[/center]', '')
        .replaceAll(RegExp(r'^#+\s*', multiLine: true), '')
        .replaceAll(RegExp(r'\[signatures:.*?\]'), '')
        .replaceAll(RegExp(r'\[space:\s*\d+\]'), '\n');
    _bodyController = TextEditingController(text: cleanContent.trim());

    _paperSize = widget.args?.paperSize ?? 'Legal';
    _isEStamp = widget.args?.isEStamp ?? true;
    _topMargin = widget.args?.topMargin ?? 320.0;
    _subsequentTopMargin = widget.args?.subsequentTopMargin ?? 65.0;
    _bottomMargin = widget.args?.bottomMargin ?? 270.0;
    _sideMargin = widget.args?.sideMargin ?? 40.0;

    _loadExistingStampFromHive();
  }

  Future<void> _loadExistingStampFromHive() async {
    final title = widget.args?.templateTitle;
    if (title == null || title.isEmpty) return;

    final all = AgreementStorageHandlerService.getAllTemplates();
    if (all.containsKey(title)) {
      final t = all[title]!;
      final b64 = t['base64Pdf']?.toString();
      if (b64 != null && b64.isNotEmpty) {
        try {
          final bytes = base64Decode(b64);
          _stampPdfBytes = bytes;
          _loadedPdfFileName = "محفوظ شدہ اسٹامپ پیپر";
          await _renderStampBytesToImages(bytes);
        } catch (_) {}
      }
    }
  }

  Future<void> _renderStampBytesToImages(Uint8List bytes) async {
    setState(() => _isLoadingPdf = true);
    List<Uint8List?> pages = [];
    try {
      await for (final page in Printing.raster(bytes, dpi: 110)) {
        final png = await page.toPng();
        pages.add(png);
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _cachedStampPages = pages;
        _isLoadingPdf = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _zoomController.dispose();
    super.dispose();
  }

  Future<void> _pickStampPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final bytes = result.files.single.bytes!;
      _stampPdfBytes = bytes;
      _loadedPdfFileName = result.files.single.name;
      await _renderStampBytesToImages(bytes);
    }
  }

  void _insertNamedTag(String tagName) {
    final text = _bodyController.text;
    final selection = _bodyController.selection;
    final tagToInsert = '{{$tagName}}';
    if (selection.start >= 0) {
      final newText = text.replaceRange(selection.start, selection.end, tagToInsert);
      _bodyController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + tagToInsert.length),
      );
    } else {
      _bodyController.text += tagToInsert;
    }
    setState(() {});
  }

  void _cleanAndNormalizeParagraphs() {
    final raw = _bodyController.text;
    if (raw.trim().isEmpty) return;

    final paras = raw.split(RegExp(r'\n\s*\n'));
    List<String> cleanedParas = [];
    for (var p in paras) {
      var lines = p.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty);
      cleanedParas.add(lines.join(' '));
    }
    final normalized = cleanedParas.join('\n\n');

    setState(() {
      _bodyController.text = normalized;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ فالتو بریکس صاف ہو گئیں! تحریر بائیں کنارے تک ہموار ہو گئی ہے۔'),
        backgroundColor: AppColors.successGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleZoom() {
    setState(() {
      if (_isZoomFit) {
        _zoomController.value = Matrix4.identity();
        _isZoomFit = false;
      } else {
        final matrix = Matrix4.identity();
        matrix.setEntry(0, 0, 0.65);
        matrix.setEntry(1, 1, 0.65);
        _zoomController.value = matrix;
        _isZoomFit = true;
      }
    });
  }

  Future<void> _saveTemplate() async {
    final title = _titleController.text.trim();
    String content = _bodyController.text.trim();
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('عنوان اور تحریر درج کرنا لازمی ہے!')),
      );
      return;
    }

    String? b64;
    if (_stampPdfBytes != null) {
      b64 = base64Encode(_stampPdfBytes!);
    }

    final template = AgreementTemplateModel(
      id: title,
      title: title,
      content: content,
      paperSize: _paperSize,
      isEStamp: _isEStamp,
      topMargin: _topMargin,
      subsequentTopMargin: _subsequentTopMargin,
      bottomMargin: _bottomMargin,
      sideMargin: _sideMargin,
      base64Pdf: b64,
      fields: TemplateService.extractFields(content),
      createdAt: '',
      updatedAt: '',
    );

    final payload = AgreementPayloadBuilder.buildTemplatePayload(template);
    await AgreementStorageHandlerService.saveTemplate(payload);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ معاہدہ بمعہ اصل اسٹامپ اور ریڈ باکس حدود محفوظ ہو گیا!'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  List<String> _paginateText(String fullText) {
    if (fullText.trim().isEmpty) return [""];

    const double totalPoints = 1008.0;
    final double lineH = _fontSize * 1.95;

    final double p1H = (totalPoints - _topMargin - _bottomMargin).clamp(100.0, totalPoints);
    final int p1MaxLines = (p1H / lineH).floor();

    final double subH = (totalPoints - _subsequentTopMargin - _bottomMargin).clamp(100.0, totalPoints);
    final int subMaxLines = (subH / lineH).floor();

    final double availableWidth = 612.0 - (_sideMargin * 2);
    final int charsPerLine = (availableWidth / (_fontSize * 0.44)).floor().clamp(65, 110);

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

  void _openTextEditorDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('معاہدے کی مکمل تحریر درج / تبدیل کریں', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            _cleanAndNormalizeParagraphs();
                            Navigator.pop(ctx);
                            _openTextEditorDialog();
                          },
                          icon: const Icon(Icons.format_align_justify, size: 16),
                          label: const Text('سطریں ہموار کریں'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade700,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: TextField(
                    controller: _bodyController,
                    maxLines: null,
                    expands: true,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'JameelNoori',
                      fontSize: _fontSize,
                      height: 1.8,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'یہاں معاہدے کی تحریر پیسٹ کریں...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryEmerald,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(42),
                  ),
                  child: const Text('تبدیلی مکمل کریں اور صفحات پر دیکھیں', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double sheetW = 390.0;
    const double sheetH = 642.0;
    const double scale = sheetH / 1008.0;

    final pages = _paginateText(_bodyController.text);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFD4D4D4),
        appBar: AppBar(
          title: const Text('معاہدہ اسٹوڈیو - ریڈ باکس ایڈیٹر', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          backgroundColor: AppColors.primaryEmerald,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(_isZoomFit ? Icons.zoom_in : Icons.zoom_out_map),
              tooltip: _isZoomFit ? 'اصل سائز' : 'پورا صفحہ سکرین پر لائیں',
              onPressed: _toggleZoom,
            ),
            ElevatedButton.icon(
              onPressed: _saveTemplate,
              icon: const Icon(Icons.check, color: Colors.white, size: 18),
              label: const Text('محفوظ کریں', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: 160,
                      child: TextField(
                        controller: _titleController,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: 'معاہدے کا عنوان',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _pickStampPdf,
                      icon: const Icon(Icons.upload_file, size: 16),
                      label: Text(_loadedPdfFileName != null ? _loadedPdfFileName! : 'اسٹامپ PDF چنیں'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _openTextEditorDialog,
                      icon: const Icon(Icons.edit_note, size: 18),
                      label: const Text('تحریر لکھیں / تبدیل کریں'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryEmerald,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _cleanAndNormalizeParagraphs,
                      icon: const Icon(Icons.format_align_justify, size: 16),
                      label: const Text('سطریں ہموار کریں'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _fontSize = (_fontSize - 0.5).clamp(10.0, 22.0);
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(Icons.remove, size: 16, color: Colors.teal),
                            ),
                          ),
                          Text(
                            '$_fontSize pt',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _fontSize = (_fontSize + 0.5).clamp(10.0, 22.0);
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(Icons.add, size: 16, color: Colors.teal),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildMarginQuickTag('مونوگرام حد: ${_topMargin.toInt()} pt', () => _showMarginModal(context)),
                    const SizedBox(width: 6),
                    _buildMarginQuickTag('کیو آر حد: ${_bottomMargin.toInt()} pt', () => _showMarginModal(context)),
                    const SizedBox(width: 6),
                    _buildMarginQuickTag('حاشیہ: ${_sideMargin.toInt()} pt', () => _showMarginModal(context)),
                  ],
                ),
              ),
            ),
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              color: Colors.grey.shade100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _pinnedTags.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final tag = _pinnedTags[index];
                  return ActionChip(
                    label: Text(tag, style: const TextStyle(fontSize: 12)),
                    backgroundColor: Colors.teal.shade50,
                    onPressed: () => _insertNamedTag(tag),
                  );
                },
              ),
            ),
            Expanded(
              child: _isLoadingPdf
                  ? const Center(child: CircularProgressIndicator())
                  : InteractiveViewer(
                      transformationController: _zoomController,
                      minScale: 0.3,
                      maxScale: 2.5,
                      boundaryMargin: const EdgeInsets.all(400),
                      constrained: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Column(
                            children: List.generate(pages.length, (index) {
                              final isP1 = (index == 0);
                              final scaledTop = (isP1 ? _topMargin : _subsequentTopMargin) * scale;
                              final scaledBot = _bottomMargin * scale;
                              final scaledSide = _sideMargin * scale;
                              final bgImg = (index < _cachedStampPages.length) ? _cachedStampPages[index] : null;

                              return Column(
                                children: [
                                  _buildVisualStampSheet(
                                    sheetWidth: sheetW,
                                    sheetHeight: sheetH,
                                    scaledTop: scaledTop,
                                    scaledBottom: scaledBot,
                                    scaledSide: scaledSide,
                                    bgImage: bgImg,
                                    pageLabel: isP1
                                        ? "صفحہ نمبر 1 (اصل اسٹامپ مع ریڈ ٹیکسٹ باکس)"
                                        : (index < _cachedStampPages.length
                                            ? "صفحہ نمبر ${index + 1} (بقیہ تحریر)"
                                            : "صفحہ نمبر ${index + 1} (اضافی سادہ ورق)"),
                                    isFirstPage: isP1,
                                    textContent: pages[index],
                                    onTopDrag: (delta) {
                                      setState(() {
                                        if (isP1) {
                                          _topMargin = (_topMargin + (delta / scale)).clamp(100.0, 700.0);
                                        } else {
                                          _subsequentTopMargin = (_subsequentTopMargin + (delta / scale)).clamp(30.0, 400.0);
                                        }
                                      });
                                    },
                                    onBottomDrag: (delta) {
                                      setState(() {
                                        _bottomMargin = (_bottomMargin - (delta / scale)).clamp(80.0, 500.0);
                                      });
                                    },
                                    onSideDrag: (delta) {
                                      setState(() {
                                        _sideMargin = (_sideMargin - (delta / scale)).clamp(15.0, 150.0);
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 35),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarginQuickTag(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildVisualStampSheet({
    required double sheetWidth,
    required double sheetHeight,
    required double scaledTop,
    required double scaledBottom,
    required double scaledSide,
    required Uint8List? bgImage,
    required String pageLabel,
    required bool isFirstPage,
    required String textContent,
    required Function(double) onTopDrag,
    required Function(double) onBottomDrag,
    required Function(double) onSideDrag,
  }) {
    final double boxH = (sheetHeight - scaledTop - scaledBottom).clamp(50.0, sheetHeight);
    final double boxW = (sheetWidth - (scaledSide * 2)).clamp(100.0, sheetWidth);

    return Column(
      children: [
        Text(pageLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 6),
        Container(
          width: sheetWidth,
          height: sheetHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [
              BoxShadow(color: Colors.black38, blurRadius: 10, spreadRadius: 2, offset: Offset(0, 4)),
            ],
          ),
          child: Stack(
            children: [
              if (bgImage != null)
                Positioned.fill(
                  child: Image.memory(bgImage, fit: BoxFit.fill),
                )
              else
                Center(
                  child: Opacity(
                    opacity: 0.1,
                    child: Text(
                      isFirstPage ? "سرکاری ای-اسٹامپ پیپر" : "اضافی سادہ ورق",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: scaledTop,
                child: Container(color: Colors.black.withAlpha(10)),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: scaledBottom,
                child: Container(color: Colors.black.withAlpha(10)),
              ),
              Positioned(
                top: scaledTop,
                left: scaledSide,
                width: boxW,
                height: boxH,
                child: InkWell(
                  onDoubleTap: _openTextEditorDialog,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red.shade700, width: 2.0),
                      color: Colors.white.withAlpha(166),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                          child: Text(
                            textContent,
                            textAlign: TextAlign.justify,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: 'JameelNoori',
                              fontSize: _fontSize,
                              height: 1.85,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111111),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 14,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onVerticalDragUpdate: (details) => onTopDrag(details.delta.dy),
                            child: Container(
                              color: Colors.red.withAlpha(77),
                              alignment: Alignment.center,
                              child: const Icon(Icons.drag_handle, size: 12, color: Colors.white),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 14,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onVerticalDragUpdate: (details) => onBottomDrag(details.delta.dy),
                            child: Container(
                              color: Colors.red.withAlpha(77),
                              alignment: Alignment.center,
                              child: const Icon(Icons.drag_handle, size: 12, color: Colors.white),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 14,
                          bottom: 14,
                          right: 0,
                          width: 12,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onHorizontalDragUpdate: (details) => onSideDrag(details.delta.dx),
                            child: Container(color: Colors.red.withAlpha(51)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMarginModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setMState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('مارجن پوائنٹس کی ترتیب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                Text('مونوگرام محفوظ حد: ${_topMargin.toInt()} pt'),
                Slider(
                  value: _topMargin,
                  min: 100,
                  max: 700,
                  onChanged: (v) {
                    setMState(() => _topMargin = v);
                    setState(() => _topMargin = v);
                  },
                ),
                Text('کیو آر کوڈ محفوظ حد: ${_bottomMargin.toInt()} pt'),
                Slider(
                  value: _bottomMargin,
                  min: 50,
                  max: 500,
                  onChanged: (v) {
                    setMState(() => _bottomMargin = v);
                    setState(() => _bottomMargin = v);
                  },
                ),
                Text('دائیں بائیں حاشیہ: ${_sideMargin.toInt()} pt'),
                Slider(
                  value: _sideMargin,
                  min: 15,
                  max: 150,
                  onChanged: (v) {
                    setMState(() => _sideMargin = v);
                    setState(() => _sideMargin = v);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}