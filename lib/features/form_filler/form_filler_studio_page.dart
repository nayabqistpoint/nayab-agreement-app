import 'package:flutter/material.dart';
import 'components/form_filler_app_bar_ui.dart';
import 'components/form_filler_canvas_viewport_ui.dart';
import 'components/form_filler_toolbar_ui.dart';
import 'form_filler_controller.dart';

class FormFillerStudioPage extends StatefulWidget {
  final String? initialTitle;
  const FormFillerStudioPage({super.key, this.initialTitle});

  @override
  State<FormFillerStudioPage> createState() => _FormFillerStudioPageState();
}

class _FormFillerStudioPageState extends State<FormFillerStudioPage> {
  late final FormFillerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FormFillerController();
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
        backgroundColor: const Color(0xFFE5E7EB),
        appBar: FormFillerAppBarUi(
          onSave: () async {
            final ok = await _controller.saveTemplate();
            if (!context.mounted) return;
            if (ok) Navigator.pop(context, true);
          },
        ),
        body: Column(
          children: [
            FormFillerToolbarUi(
              titleController: _controller.titleController,
              loadedFileName: _controller.loadedFileName,
              onPickFile: () => _controller.pickFormFile(),
            ),
            Expanded(
              child: FormFillerCanvasViewportUi(controller: _controller),
            ),
          ],
        ),
      ),
    );
  }
}