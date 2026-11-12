import 'package:flutter/material.dart';
import 'components/pdf_editor_app_bar_ui.dart';
import 'components/pdf_editor_canvas_sheet_ui.dart';
import 'components/pdf_editor_tags_bar_ui.dart';
import 'pdf_editor_controller.dart';

class PdfEditorPage extends StatefulWidget {
  final String? initialTitle;
  const PdfEditorPage({super.key, this.initialTitle});

  @override
  State<PdfEditorPage> createState() => _PdfEditorPageState();
}

class _PdfEditorPageState extends State<PdfEditorPage> {
  late final PdfEditorController _controller;

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = PdfEditorController();
    _controller.addListener(_onControllerUpdate);
    if (widget.initialTitle != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.loadTemplate(widget.initialTitle!);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _showAddCustomTagDialog() {
    final textCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'نیا کسٹم ٹیگ شامل کریں',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            content: TextField(
              controller: textCtrl,
              autofocus: true,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                hintText: 'مثلاً: والد کا نام یا گواہ کا فون',
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
                  if (textCtrl.text.trim().isNotEmpty) {
                    _controller.addCustomTag(textCtrl.text.trim());
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('شامل کریں'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSave() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await _controller.saveTemplate();
    if (!mounted) return;
    if (ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('ٹیمپلیٹ کامیابی سے محفوظ ہو گیا!')),
      );
      navigator.pop(true);
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('براہ کرم ٹیمپلیٹ کا عنوان درج کریں!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isA4 = _controller.paperSize == 'A4';
    final double sheetW = isA4 ? 595.0 : 612.0;
    final double sheetH = isA4 ? 842.0 : 1008.0;
    final bg = _controller.renderedPages.isNotEmpty
        ? _controller.renderedPages.first
        : null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFD4D8DC),
        appBar: PdfEditorAppBarUi(
          paperSize: _controller.paperSize,
          onPaperSizeChanged: _controller.setPaperSize,
          onSave: _handleSave,
        ),
        body: Column(
          children: [
            PdfEditorTagsBarUi(
              titleController: _controller.titleController,
              loadedFileName: _controller.loadedFileName,
              onPickPdf: _controller.pickPdf,
              onScanCamera: _controller.scanDocumentFromCamera,
              availableTags: _controller.availableTags,
              activePendingTag: _controller.pendingStampTag,
              isPendingStatic: _controller.isPendingStatic,
              onSelectTagToStamp: (t) =>
                  _controller.setPendingStamp(t, isStatic: false),
              onDeleteTag: _controller.removeCustomTag,
              onReorderTags: _controller.reorderTags,
              onShowAddCustomTagDialog: _showAddCustomTagDialog,
              onSelectStaticToStamp: () =>
                  _controller.setPendingStamp('', isStatic: true),
              onSelectEmptyTagToStamp: () =>
                  _controller.setPendingStamp('__empty_tag__', isStatic: false),
            ),
            Expanded(
              child: Container(
                color: const Color(0xFFDCDCDC),
                width: double.infinity,
                height: double.infinity,
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(40.0),
                  minScale: 0.8,
                  maxScale: 3.0,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: PdfEditorCanvasSheetUi(
                        sheetWidth: sheetW,
                        sheetHeight: sheetH,
                        bgImage: bg,
                        fields: _controller.fields,
                        selectedFieldId: _controller.selectedFieldId,
                        toolbarScale: _controller.currentToolbarScale,
                        onCanvasTapWithPos: (pos) {
                          if (_controller.pendingStampTag != null ||
                              _controller.isPendingStatic) {
                            final tagToUse =
                                _controller.pendingStampTag == '__empty_tag__'
                                    ? ''
                                    : (_controller.pendingStampTag ?? '');
                            _controller.addFieldAtPosition(
                              tagToUse,
                              pos.dx,
                              pos.dy,
                              isStatic: _controller.isPendingStatic,
                            );
                          } else {
                            _controller.selectField(null);
                          }
                        },
                        onSelectField: _controller.selectField,
                        onDragField: _controller.updateFieldPosition,
                        onResizeFieldWidth: _controller.updateFieldWidth,
                        onDeleteField: _controller.removeField,
                        onFontSizeChange: _controller.updateFieldFontSize,
                        onToggleBold: _controller.toggleBold,
                        onToggleUnderline: _controller.toggleUnderline,
                        onTextEdited: _controller.updateFieldText,
                        onAdjustToolbarScale: _controller.adjustToolbarScale,
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
}