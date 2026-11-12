import 'package:flutter/material.dart';
import 'components/stamp_canvas_viewport_ui.dart';
import 'components/stamp_custom_tag_dialog_ui.dart';
import 'components/stamp_editing_toolbar_ui.dart';
import 'components/stamp_header_toolbar_ui.dart';
import 'components/stamp_margin_sheet_ui.dart';
import 'components/stamp_studio_app_bar_ui.dart';
import 'components/stamp_tags_toolbar_ui.dart';
import 'services/stamp_alignment_service.dart';
import 'services/stamp_paragraph_service.dart';
import 'services/stamp_tag_service.dart';
import 'services/stamp_text_format_service.dart';
import 'stamp_studio_controller.dart';

class StampStudioPage extends StatefulWidget {
  final String? initialTitle;
  const StampStudioPage({super.key, this.initialTitle});

  @override
  State<StampStudioPage> createState() => _StampStudioPageState();
}

class _StampStudioPageState extends State<StampStudioPage> {
  late final StampStudioController _controller;

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
    _controller.dispose();
    super.dispose();
  }

  void _syncSelection() {
    _controller.bodyController.selection = _controller.effectiveSelection;
  }

  Future<void> _handleSave() async {
    final navigator = Navigator.of(context);
    final ok = await _controller.saveTemplate();
    if (!mounted) return;
    if (ok) navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFD4D8DC),
        appBar: StampStudioAppBarUi(
          paperSize: _controller.paperSize,
          onPaperSizeChanged: _controller.setPaperSize,
          onSave: _handleSave,
        ),
        body: Column(
          children: [
            StampHeaderToolbarUi(
              titleController: _controller.titleController,
              loadedPdfFileName: _controller.loadedPdfFileName,
              fontSize: _controller.currentActiveFontSize,
              topMargin: _controller.topMargin,
              bottomMargin: _controller.bottomMargin,
              sideMargin: _controller.sideMargin,
              onPickPdf: () async {
                final ok = await _controller.pdfService.pickAndLoadPdf();
                if (ok) _controller.notify();
              },
              onNormalizeParagraphs: () {
                StampTextFormatService.normalizeParagraphs(
                  _controller.bodyController,
                );
                _controller.notify();
              },
              onFontSizeChanged: _controller.updateFontSize,
              onShowMargins: () => StampMarginSheetUi.show(
                context: context,
                top: _controller.topMargin,
                bottom: _controller.bottomMargin,
                side: _controller.sideMargin,
                onTop: (v) => _controller.updateMargins(top: v),
                onBottom: (v) => _controller.updateMargins(bottom: v),
                onSide: (v) => _controller.updateMargins(side: v),
              ),
            ),
            StampEditingToolbarUi(
              isOverlayActive: _controller.isOverlayPlacementActive,
              onToggleOverlayMode: _controller.toggleOverlayPlacementMode,
              onAlignRight: () {
                _syncSelection();
                StampAlignmentService.alignLine(
                  _controller.bodyController,
                  TextAlign.right,
                );
                _controller.notify();
              },
              onAlignCenter: () {
                _syncSelection();
                StampAlignmentService.alignLine(
                  _controller.bodyController,
                  TextAlign.center,
                );
                _controller.notify();
              },
              onAlignLeft: () {
                _syncSelection();
                StampAlignmentService.alignLine(
                  _controller.bodyController,
                  TextAlign.left,
                );
                _controller.notify();
              },
              onInsertBullet: () {
                _syncSelection();
                StampParagraphService.toggleBullet(_controller.bodyController);
                _controller.notify();
              },
            ),
            StampTagsToolbarUi(
              pinnedTags: _controller.pinnedTags,
              activePendingTag: _controller.pendingOverlayTag,
              isPendingStatic: _controller.isPendingOverlayStatic,
              onSelectStaticToStamp: () =>
                  _controller.setPendingOverlay('', isStatic: true),
              onSelectEmptyTagToStamp: () => _controller.setPendingOverlay(
                '__empty_tag__',
                isStatic: false,
              ),
              onSelectTagToStamp: (t) =>
                  _controller.setPendingOverlay(t, isStatic: false),
              onInsertTagInText: (t) {
                _syncSelection();
                StampTextFormatService.insertTag(_controller.bodyController, t);
                _controller.notify();
              },
              onDeleteTag: (t) {
                StampTagService.removeTag(_controller.pinnedTags, t);
                _controller.notify();
              },
              onShowAddCustomTag: () => StampCustomTagDialogUi.show(context, (t) {
                StampTagService.addTag(_controller.pinnedTags, t);
                _controller.setPendingOverlay(t, isStatic: false);
              }),
            ),
            Expanded(
              child: StampCanvasViewportUi(
                controller: _controller,
                onStateChange: () => setState(() {}),
              ),
            ),
          ],
        ),
      ),
    );
  }
}