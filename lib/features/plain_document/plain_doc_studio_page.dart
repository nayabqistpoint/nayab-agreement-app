import 'package:flutter/material.dart';
import 'components/plain_doc_app_bar_ui.dart';
import 'components/plain_doc_canvas_viewport_ui.dart';
import 'components/plain_doc_header_toolbar_ui.dart';
import 'plain_doc_controller.dart';

class PlainDocStudioPage extends StatefulWidget {
  final String? initialTitle;
  const PlainDocStudioPage({super.key, this.initialTitle});

  @override
  State<PlainDocStudioPage> createState() => _PlainDocStudioPageState();
}

class _PlainDocStudioPageState extends State<PlainDocStudioPage> {
  late final PlainDocController _controller;
  final TransformationController _zoomController = TransformationController();
  bool _isZoomFit = false;

  @override
  void initState() {
    super.initState();
    _controller = PlainDocController();
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
        appBar: PlainDocAppBarUi(
          isZoomFit: _isZoomFit,
          onToggleZoom: _toggleZoom,
          onSave: () async {
            final ok = await _controller.saveTemplate();
            if (!context.mounted) return;
            if (ok) Navigator.pop(context, true);
          },
        ),
        body: Column(
          children: [
            PlainDocHeaderToolbarUi(
              titleController: _controller.titleController,
              fontSize: _controller.fontSize,
              onFontSizeChanged: (s) => _controller.setFontSize(s),
            ),
            Expanded(
              child: PlainDocCanvasViewportUi(
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