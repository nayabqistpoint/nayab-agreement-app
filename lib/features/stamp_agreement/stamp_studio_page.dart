import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'components/stamp_canvas_sheet.dart';
import 'stamp_studio_controller.dart';

class StampStudioPage extends StatefulWidget {
  final String? initialTitle;
  const StampStudioPage({super.key, this.initialTitle});

  @override
  State<StampStudioPage> createState() => _StampStudioPageState();
}

class _StampStudioPageState extends State<StampStudioPage> {
  late final StampStudioController _controller;
  final TransformationController _zoomController = TransformationController();
  final TextEditingController _customTagController = TextEditingController();
  bool _isZoomFit = false;

  @override
  void initState() {
    super.initState();
    _controller = StampStudioController();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _controller.initFromTemplate(widget.initialTitle);
  }

  @override
  void dispose() {
    _zoomController.dispose();
    _customTagController.dispose();
    _controller.dispose();
    super.dispose();
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

  void _insertFormatting(String tag) {
    final text = _controller.bodyController.text;
    final selection = _controller.bodyController.selection;
    if (selection.start >= 0 && selection.end > selection.start) {
      final selected = text.substring(selection.start, selection.end);
      final replaced = tag == 'B' ? '**$selected**' : '<u>$selected</u>';
      _controller.bodyController.text = text.replaceRange(selection.start, selection.end, replaced);
    } else {
      _controller.insertTag(tag == 'B' ? 'بولڈ' : 'انڈر_لائن');
    }
    setState(() {});
  }

  void _insertFixedSpacer(int points) {
    final tag = '\n[space:$points]\n';
    final text = _controller.bodyController.text;
    final selection = _controller.bodyController.selection;
    if (selection.start >= 0) {
      _controller.bodyController.text = text.replaceRange(selection.start, selection.end, tag);
    } else {
      _controller.bodyController.text += tag;
    }
    setState(() {});
  }

  void _showAddCustomTagDialog() {
    _customTagController.clear();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('نیا کسٹم ٹیگ بنائیں', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: TextField(
            controller: _customTagController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'مثلاً: گواہ کا نام، بقایا رقم وغیرہ',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('منسوخ')),
            ElevatedButton(
              onPressed: () {
                final val = _customTagController.text.trim();
                if (val.isNotEmpty) {
                  _controller.insertTag(val);
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryEmerald),
              child: const Text('ٹیگ لگائیں', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSaveTemplate() async {
    final bool isSaved = await _controller.saveTemplate();
    if (!mounted) return;

    if (isSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ ای-اسٹامپ ٹیمپلیٹ کامیابی سے محفوظ ہو گیا!'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isA4 = _controller.paperSize.toUpperCase() == 'A4';
    const double sheetW = 390.0;
    final double sheetH = isA4 ? 552.0 : 642.0;
    final double totalHeightPoints = isA4 ? 842.0 : 1008.0;
    final double scale = sheetH / totalHeightPoints;

    final pages = _controller.paginateText();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFD4D4D4),
        appBar: AppBar(
          title: const Text('پنجاب ای-اسٹامپ اسٹوڈیو', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          backgroundColor: AppColors.primaryEmerald,
          foregroundColor: Colors.white,
          actions: [
            // پیپر ٹوگل بٹن (Legal / A4)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white70),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => _controller.setPaperSize('Legal'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: !isA4 ? Colors.white : Colors.transparent,
                        borderRadius: const BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
                      ),
                      child: Text(
                        'Legal (اسٹامپ)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: !isA4 ? AppColors.primaryEmerald : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _controller.setPaperSize('A4'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isA4 ? Colors.white : Colors.transparent,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                      ),
                      child: Text(
                        'A4 (سادہ)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isA4 ? AppColors.primaryEmerald : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(_isZoomFit ? Icons.zoom_in : Icons.zoom_out_map),
              tooltip: _isZoomFit ? 'اصل سائز' : 'پورا صفحہ سکرین پر لائیں',
              onPressed: _toggleZoom,
            ),
            ElevatedButton.icon(
              onPressed: _handleSaveTemplate,
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
                        controller: _controller.titleController,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: 'معاہدے کا عنوان',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _controller.pickPdf(),
                      icon: const Icon(Icons.upload_file, size: 15),
                      label: Text(_controller.loadedPdfFileName ?? 'ای-اسٹامپ PDF چنیں', style: const TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.brown.shade700, foregroundColor: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _controller.normalizeParagraphs(),
                      icon: const Icon(Icons.format_align_justify, size: 15),
                      label: const Text('سطریں ہموار کریں', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade700, foregroundColor: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => _controller.setFontSize(_controller.fontSize - 0.5),
                            child: const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Icon(Icons.remove, size: 15, color: Colors.teal)),
                          ),
                          Text('${_controller.fontSize} pt', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          InkWell(
                            onTap: () => _controller.setFontSize(_controller.fontSize + 0.5),
                            child: const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Icon(Icons.add, size: 15, color: Colors.teal)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _showMarginModal(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'مارجنز: T:${_controller.topMargin.toInt()} B:${_controller.bottomMargin.toInt()} S:${_controller.sideMargin.toInt()}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: Colors.grey.shade200,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.format_bold, size: 18),
                      tooltip: 'بولڈ',
                      onPressed: () => _insertFormatting('B'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.format_underlined, size: 18),
                      tooltip: 'انڈر لائن',
                      onPressed: () => _insertFormatting('U'),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton.icon(
                      onPressed: () => _insertFixedSpacer(72),
                      icon: const Icon(Icons.space_bar, size: 14),
                      label: const Text('1 انچ جگہ', style: TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black87),
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton.icon(
                      onPressed: () => _insertFixedSpacer(36),
                      icon: const Icon(Icons.space_bar, size: 14),
                      label: const Text('آدھا انچ جگہ', style: TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black87),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _showAddCustomTagDialog,
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text('+ نیا ٹیگ', style: TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, foregroundColor: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    ..._controller.pinnedTags.map(
                      (tag) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: ActionChip(
                          label: Text(tag, style: const TextStyle(fontSize: 11)),
                          backgroundColor: Colors.white,
                          onPressed: () => _controller.insertTag(tag),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _controller.isLoadingPdf
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
                            children: List.generate(
                              pages.length,
                              (index) {
                                final isP1 = (index == 0);
                                final scaledTop = (isP1 ? _controller.topMargin : _controller.subsequentTopMargin) * scale;
                                final scaledBot = _controller.bottomMargin * scale;
                                final scaledSide = _controller.sideMargin * scale;
                                final bgImg = (index < _controller.cachedStampPages.length)
                                    ? _controller.cachedStampPages[index]
                                    : null;

                                return Column(
                                  children: [
                                    StampCanvasSheet(
                                      sheetWidth: sheetW,
                                      sheetHeight: sheetH,
                                      scaledTop: scaledTop,
                                      scaledBottom: scaledBot,
                                      scaledSide: scaledSide,
                                      bgImage: bgImg,
                                      pageLabel: isP1
                                          ? "صفحہ نمبر 1 (${_controller.paperSize})"
                                          : "صفحہ نمبر ${index + 1} (${_controller.paperSize})",
                                      isFirstPage: isP1,
                                      textContent: pages.isNotEmpty ? pages[index] : "",
                                      fontSize: _controller.fontSize,
                                      bodyController: isP1 ? _controller.bodyController : null,
                                      onTextChanged: (val) => setState(() {}),
                                      onTopDrag: (delta) {
                                        if (isP1) {
                                          _controller.setTopMargin(_controller.topMargin + (delta / scale));
                                        } else {
                                          _controller.setSubsequentTopMargin(_controller.subsequentTopMargin + (delta / scale));
                                        }
                                      },
                                      onBottomDrag: (delta) => _controller.setBottomMargin(_controller.bottomMargin - (delta / scale)),
                                      onSideDrag: (delta) => _controller.setSideMargin(_controller.sideMargin - (delta / scale)),
                                    ),
                                    const SizedBox(height: 35),
                                  ],
                                );
                              },
                            ),
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
                const Text('اسٹامپ مارجن پوائنٹس', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                Text('اوپر کا مارجن (مونوگرام حد): ${_controller.topMargin.toInt()} pt'),
                Slider(
                  value: _controller.topMargin,
                  min: 40,
                  max: 700,
                  onChanged: (v) {
                    setMState(() => _controller.setTopMargin(v));
                  },
                ),
                Text('نیچے کا مارجن (کیو آر کوڈ حد): ${_controller.bottomMargin.toInt()} pt'),
                Slider(
                  value: _controller.bottomMargin,
                  min: 40,
                  max: 500,
                  onChanged: (v) {
                    setMState(() => _controller.setBottomMargin(v));
                  },
                ),
                Text('دائیں بائیں حاشیہ: ${_controller.sideMargin.toInt()} pt'),
                Slider(
                  value: _controller.sideMargin,
                  min: 15,
                  max: 150,
                  onChanged: (v) {
                    setMState(() => _controller.setSideMargin(v));
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