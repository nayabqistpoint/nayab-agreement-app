import 'package:flutter/material.dart';
import 'components/stamp_canvas_viewport_ui.dart';
import 'components/stamp_custom_tag_dialog_ui.dart';
import 'components/stamp_editing_toolbar_ui.dart';
import 'components/stamp_header_toolbar_ui.dart';
import 'components/stamp_margin_sheet_ui.dart';
import 'components/stamp_studio_app_bar_ui.dart';
import 'components/stamp_tags_toolbar_ui.dart';
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
        backgroundColor: const Color(0xFFD4D8DC),
        appBar: StampStudioAppBarUi(
          paperSize: _controller.paperSize,
          onPaperSizeChanged: _controller.setPaperSize,
          onSave: () async {
            final ok = await _controller.saveTemplate();
            if (!context.mounted) return;
            if (ok) {
              Navigator.pop(context, true);
            }
          },
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
              onPickPdf: _controller.pickPdf,
              onNormalizeParagraphs: _controller.normalizeBodyText,
              onFontSizeChanged: _controller.setFontSize,
              onShowMargins: () => StampMarginSheetUi.show(
                context: context,
                top: _controller.topMargin,
                bottom: _controller.bottomMargin,
                side: _controller.sideMargin,
                onTop: _controller.setTopMargin,
                onBottom: _controller.setBottomMargin,
                onSide: _controller.setSideMargin,
              ),
            ),
            StampEditingToolbarUi(
              onAlignRight: () => _controller.alignSelectedLine(TextAlign.right),
              onAlignCenter: () => _controller.alignSelectedLine(TextAlign.center),
              onAlignLeft: () => _controller.alignSelectedLine(TextAlign.left),
              onInsertBullet: _controller.toggleBullet,
            ),
            StampTagsToolbarUi(
              pinnedTags: _controller.pinnedTags,
              onBold: () => _controller.applyFormatToSelection('b'),
              onUnderline: () => _controller.applyFormatToSelection('u'),
              onInsertEmSpace: _controller.insertEmSpace,
              onInsertEmptyTag: _controller.insertEmptyTag,
              onInsertTag: _controller.insertTagAtCursor,
              onDeleteTag: _controller.removeTag,
              onShowAddCustomTag: () => StampCustomTagDialogUi.show(context, (t) {
                _controller.addCustomTag(t);
                _controller.insertTagAtCursor(t);
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