// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared_models/agreement_template_model.dart';
import '../../shared_services/agreement_storage_handler_service.dart';
import '../../shared_services/payload_builders/agreement_payload_builder.dart';
import '../../shared_services/template_service.dart';
import 'args/template_studio_args.dart';

class MovableBox {
  Offset position;
  final TextEditingController controller;
  bool isEditing;

  MovableBox({
    required this.position,
    required this.controller,
    this.isEditing = true,
  });
}

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
  double _topMargin = 0.0;
  double _currentFontSize = 16.0;
  bool _isBold = false;
  bool _isUnderline = false;
  TextAlign _alignment = TextAlign.right;
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

  final List<MovableBox> _movableBoxes = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.args?.templateTitle ?? '');
    
    // تمام فالتو مارک ڈاؤن ٹیگز صاف کرنا
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
    _topMargin = widget.args?.topMargin ?? 0.0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _bodyFocusNode.dispose();
    _zoomController.dispose();
    for (var b in _movableBoxes) {
      b.controller.dispose();
    }
    super.dispose();
  }

  /// زوم ٹوگل (ایک کلک پر فٹ ٹو اسکرین، دوسرے پر 100% نارمل)
  void _toggleZoom() {
    setState(() {
      if (_isZoomFit) {
        _zoomController.value = Matrix4.identity();
        _isZoomFit = false;
      } else {
        final matrix = Matrix4.identity()..scale(0.55, 0.55);
        _zoomController.value = matrix;
        _isZoomFit = true;
      }
    });
  }

  void _insertEmptyTagAtCursor() {
    final text = _bodyController.text;
    final selection = _bodyController.selection;
    const tag = '{{}}';

    int newOffset;
    if (selection.start >= 0) {
      final newText = text.replaceRange(selection.start, selection.end, tag);
      newOffset = selection.start + 2;
      _bodyController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newOffset),
      );
    } else {
      final newText = '$text$tag';
      newOffset = newText.length - 2;
      _bodyController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newOffset),
      );
    }
    _bodyFocusNode.requestFocus();
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

  void _insertBulletPoint() {
    const bullet = '\n•  ';
    final text = _bodyController.text;
    final selection = _bodyController.selection;
    if (selection.start >= 0) {
      final newText = text.replaceRange(selection.start, selection.end, bullet);
      _bodyController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + bullet.length),
      );
    } else {
      _bodyController.text += bullet;
    }
    _bodyFocusNode.requestFocus();
  }

  /// نیا آزاد ٹیکسٹ باکس جو باہر کلک کرنے پر کاغذ کا حصہ بن جائے
  void _addNewMovableBox() {
    setState(() {
      _movableBoxes.add(
        MovableBox(
          position: const Offset(60, 120),
          controller: TextEditingController(),
          isEditing: true,
        ),
      );
    });
  }

  /// بار بار استعمال ہونے والے کسٹم جملے یا ٹیگز شامل کرنا
  void _showAddCustomPhraseDialog() {
    final phraseCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('بار بار استعمال ہونے والا جملہ یا ٹیگ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          content: TextField(
            controller: phraseCtrl,
            maxLines: 2,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 16),
            decoration: const InputDecoration(
              labelText: 'جملہ یا ٹیگ کا نام لکھیں',
              hintText: 'مثلاً: گواہ شد یا {{ضامن کا فون}}',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('منسوخ'),
            ),
            ElevatedButton(
              onPressed: () {
                final phrase = phraseCtrl.text.trim();
                if (phrase.isNotEmpty) {
                  setState(() {
                    if (!_pinnedTags.contains(phrase)) _pinnedTags.add(phrase);
                  });
                  _insertNamedTag(phrase.replaceAll('{{', '').replaceAll('}}', ''));
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryEmerald),
              child: const Text('شامل کریں', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTemplate() async {
    final title = _titleController.text.trim();
    String content = _bodyController.text.trim();

    // ٹیکسٹ باکسز کا متن بھی دستاویز کا حصہ بنانا
    for (var box in _movableBoxes) {
      final boxText = box.controller.text.trim();
      if (boxText.isNotEmpty) {
        content += '\n\n$boxText';
      }
    }

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
      topMargin: _topMargin,
      fields: TemplateService.extractFields(content),
      createdAt: '',
      updatedAt: '',
    );

    final payload = AgreementPayloadBuilder.buildTemplatePayload(template);
    await AgreementStorageHandlerService.saveTemplate(payload);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ معاہدہ کامیابی سے محفوظ ہو گیا!'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isA4 = _paperSize == 'A4';
    final double pageWidth = isA4 ? 620.0 : 640.0;
    final double pageHeight = isA4 ? 880.0 : 1050.0;

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
        body: GestureDetector(
          // کاغذ سے باہر کلک کرنے پر تمام ٹیکسٹ باکسز کا فریم غائب ہو جائے گا
          onTap: () {
            setState(() {
              for (var box in _movableBoxes) {
                box.isEditing = false;
              }
            });
          },
          child: Column(
            children: [
              // سیدھا اور صاف ٹول بار (صرف کام کے بٹنز)
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
                      DropdownButton<String>(
                        value: _paperSize,
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(value: 'A4', child: Text('A4 پیج')),
                          DropdownMenuItem(value: 'Legal', child: Text('لیگل اسٹامپ')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _paperSize = val);
                        },
                      ),
                      const SizedBox(width: 8),
                      // فونٹ سائز کنٹرول
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
                              tooltip: 'چھوٹا کریں',
                              onPressed: () {
                                if (_currentFontSize > 10.0) setState(() => _currentFontSize -= 1.0);
                              },
                            ),
                            Text('${_currentFontSize.toInt()} pt', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              tooltip: 'بڑا کریں',
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
                        tooltip: 'بولڈ',
                        onPressed: () => setState(() => _isBold = !_isBold),
                      ),
                      IconButton(
                        icon: Icon(Icons.format_underlined, color: _isUnderline ? AppColors.primaryEmerald : Colors.grey.shade700),
                        tooltip: 'انڈر لائن',
                        onPressed: () => setState(() => _isUnderline = !_isUnderline),
                      ),
                      const VerticalDivider(width: 12),
                      // صرف 3 سادہ الائنمنٹس
                      IconButton(
                        icon: Icon(Icons.format_align_right, color: _alignment == TextAlign.right ? AppColors.primaryEmerald : Colors.grey.shade700),
                        tooltip: 'دائیں طرف',
                        onPressed: () => setState(() => _alignment = TextAlign.right),
                      ),
                      IconButton(
                        icon: Icon(Icons.format_align_center, color: _alignment == TextAlign.center ? AppColors.primaryEmerald : Colors.grey.shade700),
                        tooltip: 'درمیان میں',
                        onPressed: () => setState(() => _alignment = TextAlign.center),
                      ),
                      IconButton(
                        icon: Icon(Icons.format_align_left, color: _alignment == TextAlign.left ? AppColors.primaryEmerald : Colors.grey.shade700),
                        tooltip: 'بائیں طرف',
                        onPressed: () => setState(() => _alignment = TextAlign.left),
                      ),
                      const VerticalDivider(width: 12),
                      IconButton(
                        icon: const Icon(Icons.format_list_bulleted, color: Colors.blueGrey),
                        tooltip: 'بلٹ پوائنٹ شامل کریں',
                        onPressed: _insertBulletPoint,
                      ),
                      IconButton(
                        icon: const Icon(Icons.post_add, color: Colors.deepPurple, size: 24),
                        tooltip: 'آزاد ٹیکسٹ باکس بنائیں (ڈریگ ایبل)',
                        onPressed: _addNewMovableBox,
                      ),
                    ],
                  ),
                ),
              ),

              // چپس اور بلاکس کی بار
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.grey.shade100,
                child: Row(
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.data_array, color: Colors.deepOrange, size: 20),
                      label: const Text('خالی ٹیگ {{ }}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange, fontSize: 13)),
                      backgroundColor: Colors.orange.shade50,
                      side: const BorderSide(color: Colors.deepOrange),
                      onPressed: _insertEmptyTagAtCursor,
                    ),
                    const SizedBox(width: 6),
                    ActionChip(
                      avatar: const Icon(Icons.add_comment_outlined, color: AppColors.primaryEmerald, size: 18),
                      label: const Text('+ نیا جملہ / ٹیگ', style: TextStyle(color: AppColors.primaryEmerald, fontWeight: FontWeight.bold, fontSize: 13)),
                      backgroundColor: Colors.teal.shade50,
                      onPressed: _showAddCustomPhraseDialog,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Theme(
                        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
                        child: ReorderableListView(
                          scrollDirection: Axis.horizontal,
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) newIndex -= 1;
                              final item = _pinnedTags.removeAt(oldIndex);
                              _pinnedTags.insert(newIndex, item);
                            });
                          },
                          children: _pinnedTags.map((tag) {
                            return Padding(
                              key: ValueKey(tag),
                              padding: const EdgeInsets.only(left: 6.0),
                              child: InputChip(
                                label: Text(tag, style: const TextStyle(fontSize: 13)),
                                backgroundColor: Colors.white,
                                onPressed: () => _insertNamedTag(tag),
                                deleteIcon: const Icon(Icons.close, size: 14),
                                onDeleted: () {
                                  setState(() => _pinnedTags.remove(tag));
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // مرکزی مکمل لچکدار کینوس (ماؤس اور ٹچ دونوں پر روانی سے حرکت کرنے والا)
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
                      padding: EdgeInsets.only(
                        top: _paperSize == 'Legal' ? (_topMargin > 0 ? _topMargin : 180.0) : 45.0,
                        left: 45.0,
                        right: 45.0,
                        bottom: 40.0,
                      ),
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
                        clipBehavior: Clip.none,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_paperSize == 'Legal')
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    border: Border.all(color: Colors.amber.shade300),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '↑ یہ اوپر والی جگہ سرکاری ای-اسٹامپ کے لیے خالی چھوڑی گئی ہے',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 11, color: Colors.brown, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              Expanded(
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
                                    hintText: 'یہاں کاغذ پر معاہدہ لکھیں...',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // متحرک آزاد باکسز (باہر کلک پر بارڈر غائب، ڈریگ پر آزاد حرکت)
                          ..._movableBoxes.asMap().entries.map((entry) {
                            final index = entry.key;
                            final box = entry.value;

                            return Positioned(
                              left: box.position.dx,
                              top: box.position.dy,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    box.isEditing = true;
                                  });
                                },
                                onPanUpdate: (details) {
                                  setState(() {
                                    box.position += details.delta;
                                  });
                                },
                                child: Container(
                                  width: 260,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: box.isEditing
                                        ? Border.all(color: AppColors.primaryEmerald, width: 1.5)
                                        : Border.all(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (box.isEditing)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                          color: Colors.teal.shade100,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Row(
                                                children: [
                                                  Icon(Icons.open_with, size: 14, color: AppColors.primaryEmerald),
                                                  SizedBox(width: 4),
                                                  Text('پکڑ کر گھمائیں', style: TextStyle(fontSize: 10, color: AppColors.primaryEmerald, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _movableBoxes.removeAt(index);
                                                  });
                                                },
                                                child: const Icon(Icons.close, size: 14, color: Colors.red),
                                              ),
                                            ],
                                          ),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: TextField(
                                          controller: box.controller,
                                          maxLines: null,
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontSize: _currentFontSize,
                                            height: 1.8,
                                            fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                                            color: const Color(0xFF1A1A1A),
                                          ),
                                          decoration: InputDecoration(
                                            hintText: box.isEditing ? 'یہاں لکھیں...' : '',
                                            isDense: true,
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}