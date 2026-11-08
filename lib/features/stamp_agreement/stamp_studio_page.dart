import 'package:flutter/material.dart';
import 'components/stamp_canvas_viewport_ui.dart';
import 'components/stamp_custom_tag_dialog_ui.dart';
import 'components/stamp_header_toolbar_ui.dart';
import 'components/stamp_margin_sheet_ui.dart';
import 'components/stamp_studio_app_bar_ui.dart';
import 'components/stamp_tags_toolbar_ui.dart';
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
  final TransformationController _zoomController = TransformationController();
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
    _controller.dispose();
    super.dispose();
  }

  void _toggleZoom() {
    setState(() {
      _isZoomFit = !_isZoomFit;
      final m = Matrix4.identity();
      if (_isZoomFit) {
        m.setEntry(0, 0, 0.65);
        m.setEntry(1, 1, 0.65);
      }
      _zoomController.value = m;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFD4D4D4),
        appBar: StampStudioAppBarUi(
          paperSize: _controller.paperSize,
          isZoomFit: _isZoomFit,
          onPaperSizeChanged: (s) => _controller.setPaperSize(s),
          onToggleZoom: _toggleZoom,
          onSave: () async {
            final ok = await _controller.saveTemplate();
            if (!context.mounted) return;
            if (ok) Navigator.pop(context, true);
          },
        ),
        body: Column(
          children: [
            StampHeaderToolbarUi(
              titleController: _controller.titleController,
              loadedPdfFileName: _controller.loadedPdfFileName,
              fontSize: _controller.fontSize,
              topMargin: _controller.topMargin,
              bottomMargin: _controller.bottomMargin,
              sideMargin: _controller.sideMargin,
              onPickPdf: () => _controller.pickPdf(),
              onNormalizeParagraphs: () => _controller.normalizeBodyText(),
              onFontSizeChanged: (s) => _controller.setFontSize(s),
              onShowMargins: () => StampMarginSheetUi.show(
                context: context,
                top: _controller.topMargin,
                bottom: _controller.bottomMargin,
                side: _controller.sideMargin,
                onTop: (v) => _controller.setTopMargin(v),
                onBottom: (v) => _controller.setBottomMargin(v),
                onSide: (v) => _controller.setSideMargin(v),
              ),
            ),
            StampTagsToolbarUi(
              pinnedTags: _controller.pinnedTags,
              onInsertFormatting: (f) {
                StampTextFormatService.insertFormatting(_controller.bodyController, f);
                setState(() {});
              },
              onInsertSpacer: (p) {
                StampTextFormatService.insertSpacer(_controller.bodyController, p);
                setState(() {});
              },
              onShowAddCustomTag: () => StampCustomTagDialogUi.show(context, (t) {
                StampTextFormatService.insertTag(_controller.bodyController, t);
                setState(() {});
              }),
              onInsertTag: (t) {
                StampTextFormatService.insertTag(_controller.bodyController, t);
                setState(() {});
              },
            ),
            Expanded(
              child: StampCanvasViewportUi(
                controller: _controller,
                zoomController: _zoomController,
                onStateChange: () => setState(() {}),
              ),
            ),
          ],
        ),
      ),
    );
  }
}