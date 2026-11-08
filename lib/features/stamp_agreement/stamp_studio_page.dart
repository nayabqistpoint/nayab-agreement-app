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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFD4D4D4),
        appBar: StampStudioAppBarUi(
          paperSize: _controller.paperSize,
          onPaperSizeChanged: (s) => _controller.setPaperSize(s),
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
              onInsertForcedSpace: () {
                StampTextFormatService.insertForcedSpace(_controller.bodyController);
                setState(() {});
              },
              onInsertEmptyTag: () {
                StampTextFormatService.insertEmptyTag(_controller.bodyController);
                setState(() {});
              },
              onShowAddCustomTag: () => StampCustomTagDialogUi.show(context, (t) {
                _controller.addCustomTag(t);
                StampTextFormatService.insertTag(_controller.bodyController, t);
                setState(() {});
              }),
              onInsertTag: (t) {
                StampTextFormatService.insertTag(_controller.bodyController, t);
                setState(() {});
              },
              onReorderTags: (oldIndex, newIndex) {
                setState(() {
                  final item = _controller.pinnedTags.removeAt(oldIndex);
                  _controller.pinnedTags.insert(newIndex, item);
                });
              },
              onDeleteTag: (t) {
                setState(() => _controller.removeTag(t));
              },
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