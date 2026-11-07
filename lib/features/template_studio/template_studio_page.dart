import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
  final FocusNode _bodyFocusNode = FocusNode();
  final TransformationController _zoomController = TransformationController();

  String _paperSize = 'A4';
  bool _isEStamp = false;

  // مکمل رینج والے مارجنز
  double _topMargin = 220.0;
  double _subsequentTopMargin = 45.0;
  double _bottomMargin = 75.0;
  double _sideMargin = 35.0;

  double _currentFontSize = 16.0;
  bool _isBold = false;
  bool _isUnderline = false;
  final TextAlign _alignment = TextAlign.right;
  bool _isZoomFit = false;
  String? _loadedPdfFileName;

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
        .replaceAll(RegExp(r'^#\s+', multiLine: true), '')
        .replaceAll(RegExp(r'^##\s+', multiLine: true), '')
        .replaceAll(RegExp(r'\[signatures:.*?\]'), '')
        .replaceAll(RegExp(r'\[space:\s*\d+\]'), '\n');
    _bodyController = TextEditingController(text: cleanContent.trim());

    _paperSize = widget.args?.paperSize ?? 'A4';
    _isEStamp = widget.args?.isEStamp ?? (_paperSize == 'Legal');
    _topMargin = widget.args?.topMargin ?? (_isEStamp ? 220.0 : 45.0);
    _subsequentTopMargin = widget.args?.subsequentTopMargin ?? 45.0;
    _bottomMargin = widget.args?.bottomMargin ?? (_isEStamp ? 75.0 : 40.0);
    _sideMargin = widget.args?.sideMargin ?? (_isEStamp ? 35.0 : 45.0);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _bodyFocusNode.dispose();
    _zoomController.dispose();
    super.dispose();
  }

  Future<void> _pickEStampPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _isEStamp = true;
        _paperSize = 'Legal';
        _loadedPdfFileName = result.files.single.name;
        if (_topMargin < 150) _topMargin = 220.0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ای-اسٹامپ پی ڈی ایف منسلک ہو گیا: ${result.files.single.name}'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    }
  }

  void _openMarginSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'ای-اسٹامپ حاشیے (Margins) سیٹ کریں - مکمل رینج',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 14),

                    // صفحہ 1: مونوگرام کا فاصلہ (0 سے 850 پوائنٹس تک کھلا)
                    Text(
                      'صفحہ 1: مونوگرام کا محفوظ فاصلہ: ${_topMargin.toInt()} pt',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: _topMargin,
                      min: 0.0,
                      max: 850.0,
                      divisions: 170,
                      activeColor: AppColors.primaryEmerald,
                      onChanged: (val) {
                        setSheetState(() => _topMargin = val);
                        setState(() => _topMargin = val);
                      },
                    ),

                    // صفحہ 2 اور بعد کے صفحات: ٹاپ مارجن (0 سے 450 پوائنٹس تک)
                    Text(
                      'صفحہ 2 اور بعد کے صفحات: ٹاپ مارجن: ${_subsequentTopMargin.toInt()} pt',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: _subsequentTopMargin,
                      min: 0.0,
                      max: 450.0,
                      divisions: 90,
                      activeColor: Colors.teal,
                      onChanged: (val) {
                        setSheetState(() => _subsequentTopMargin = val);
                        setState(() => _subsequentTopMargin = val);
                      },
                    ),

                    // نیچے کا مارجن: کیو آر کوڈ سے فاصلہ (0 سے 550 پوائنٹس تک)
                    Text(
                      'نیچے کا مارجن (کیو آر کوڈ سے فاصلہ): ${_bottomMargin.toInt()} pt',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: _bottomMargin,
                      min: 0.0,
                      max: 550.0,
                      divisions: 110,
                      activeColor: Colors.deepOrange,
                      onChanged: (val) {
                        setSheetState(() => _bottomMargin = val);
                        setState(() => _bottomMargin = val);
                      },
                    ),

                    // دائیں اور بائیں کا حاشیہ (10 سے 200 پوائنٹس تک)
                    Text(
                      'دائیں اور بائیں کا حاشیہ: ${_sideMargin.toInt()} pt',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: _sideMargin,
                      min: 10.0,
                      max: 200.0,
                      divisions: 38,
                      activeColor: Colors.blueGrey,
                      onChanged: (val) {
                        setSheetState(() => _sideMargin = val);
                        setState(() => _sideMargin = val);
                      },
                    ),

                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryEmerald,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('مارجن لاگو کریں', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteTemplate() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('ٹیمپلیٹ ڈیلیٹ کریں؟'),
          content: Text('کیا آپ واقعی معاہدہ "$title" کو ہمیشہ کے لیے ختم کرنا چاہتے ہیں؟'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('منسوخ')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('ہاں، ڈیلیٹ کریں', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
    if (confirm == true) {
      await AgreementStorageHandlerService.deleteTemplatePermanently(title);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ٹیمپلیٹ ڈیلیٹ کر دیا گیا!'), backgroundColor: Colors.red),
        );
        Navigator.pop(context, true);
      }
    }
  }

  void _toggleZoom() {
    setState(() {
      if (_isZoomFit) {
        _zoomController.value = Matrix4.identity();
        _isZoomFit = false;
      } else {
        final matrix = Matrix4.identity();
        matrix.setEntry(0, 0, 0.55);
        matrix.setEntry(1, 1, 0.55);
        _zoomController.value = matrix;
        _isZoomFit = true;
      }
    });
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
    _bodyFocusNode.requestFocus();
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
      fields: TemplateService.extractFields(content),
      createdAt: '',
      updatedAt: '',
    );
    final payload = AgreementPayloadBuilder.buildTemplatePayload(template);
    await AgreementStorageHandlerService.saveTemplate(payload);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ معاہدہ بمعہ لائیو ای-اسٹامپ حدود محفوظ ہو گیا!'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLegal = _paperSize == 'Legal' || _isEStamp;
    final double pageWidth = isLegal ? 640.0 : 620.0;
    final double pageHeight = isLegal ? 1050.0 : 880.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFC7C7C7),
        appBar: AppBar(
          title: Text(
            widget.args?.templateTitle != null ? 'معاہدہ ایڈیٹر' : 'نیا معاہدہ اسٹوڈیو',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          backgroundColor: AppColors.primaryEmerald,
          foregroundColor: Colors.white,
          actions: [
            if (widget.args?.templateTitle != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                tooltip: 'ٹیمپلیٹ ڈیلیٹ کریں',
                onPressed: _deleteTemplate,
              ),
            IconButton(
              icon: Icon(_isZoomFit ? Icons.zoom_in : Icons.zoom_out_map),
              tooltip: _isZoomFit ? 'اصل سائز (100%)' : 'پورا صفحہ اسکرین پر لائیں (Fit)',
              onPressed: _toggleZoom,
            ),
            ElevatedButton.icon(
              onPressed: _saveTemplate,
              icon: const Icon(Icons.check, color: Colors.white, size: 20),
              label: const Text('محفوظ کریں', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
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
                      width: 170,
                      child: TextField(
                        controller: _titleController,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: 'معاہدے کا عنوان',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _pickEStampPdf,
                      icon: const Icon(Icons.upload_file, size: 18),
                      label: Text(_loadedPdfFileName != null ? 'تبدیل کریں' : 'ای-اسٹامپ PDF لوڈ کریں'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _openMarginSettingsSheet,
                      icon: const Icon(Icons.tune, size: 18),
                      label: const Text('مارجن سیٹ کریں'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: () {
                              if (_currentFontSize > 10.0) setState(() => _currentFontSize -= 1.0);
                            },
                          ),
                          Text('${_currentFontSize.toInt()} pt', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: () {
                              if (_currentFontSize < 36.0) setState(() => _currentFontSize += 1.0);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: Icon(Icons.format_bold, color: _isBold ? AppColors.primaryEmerald : Colors.grey.shade700),
                      onPressed: () => setState(() => _isBold = !_isBold),
                    ),
                    IconButton(
                      icon: Icon(Icons.format_underlined, color: _isUnderline ? AppColors.primaryEmerald : Colors.grey.shade700),
                      onPressed: () => setState(() => _isUnderline = !_isUnderline),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: Colors.grey.shade100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _pinnedTags.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final tag = _pinnedTags[index];
                  return ActionChip(
                    label: Text(tag, style: const TextStyle(fontSize: 13)),
                    backgroundColor: Colors.teal.shade50,
                    onPressed: () => _insertNamedTag(tag),
                  );
                },
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                transformationController: _zoomController,
                minScale: 0.3,
                maxScale: 3.0,
                boundaryMargin: const EdgeInsets.all(400),
                constrained: false,
                child: Center(
                  child: Container(
                    width: pageWidth,
                    height: pageHeight,
                    margin: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 15,
                          spreadRadius: 3,
                          offset: Offset(0, 6),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Stack(
                      children: [
                        if (_isEStamp)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: _topMargin,
                            child: Container(
                              color: Colors.amber.shade50.withAlpha(178),
                              child: Center(
                                child: Text(
                                  '↑ صفحہ 1: سرکاری مونوگرام کے لیے محفوظ جگہ (${_topMargin.toInt()} pt)',
                                  style: const TextStyle(fontSize: 12, color: Colors.brown, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        if (_isEStamp)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: _bottomMargin,
                            child: Container(
                              color: Colors.red.shade50.withAlpha(178),
                              child: Center(
                                child: Text(
                                  '↓ نیچے والی جگہ سرکاری کیو آر کوڈ کے لیے محفوظ ہے (${_bottomMargin.toInt()} pt)',
                                  style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          top: _isEStamp ? _topMargin : 45.0,
                          bottom: _isEStamp ? _bottomMargin : 40.0,
                          left: _isEStamp ? _sideMargin : 45.0,
                          right: _isEStamp ? _sideMargin : 45.0,
                          child: TextField(
                            controller: _bodyController,
                            focusNode: _bodyFocusNode,
                            maxLines: null,
                            expands: true,
                            textAlign: _alignment,
                            textAlignVertical: TextAlignVertical.top,
                            style: TextStyle(
                              fontSize: _currentFontSize,
                              height: 2.1,
                              fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                              decoration: _isUnderline ? TextDecoration.underline : TextDecoration.none,
                              color: const Color(0xFF1A1A1A),
                            ),
                            decoration: const InputDecoration(
                              hintText: 'یہاں معاہدے کی قانونی تحریر مع ٹیگز درج کریں...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
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
}