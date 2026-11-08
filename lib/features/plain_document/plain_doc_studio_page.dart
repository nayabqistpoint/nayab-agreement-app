import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../stamp_agreement/stamp_studio_controller.dart';
import '../stamp_agreement/components/stamp_canvas_sheet.dart';

class PlainDocStudioPage extends StatefulWidget {
  final String? initialTitle;
  const PlainDocStudioPage({super.key, this.initialTitle});

  @override
  State<PlainDocStudioPage> createState() => _PlainDocStudioPageState();
}

class _PlainDocStudioPageState extends State<PlainDocStudioPage> {
  late final StampStudioController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StampStudioController();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _controller.initFromTemplate(widget.initialTitle);
    _controller.setPaperSize('A4');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double sheetW = 390.0;
    const double sheetH = 552.0;
    const double scale = sheetH / 842.0;
    final pages = _controller.paginateText();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFD4D4D4),
        appBar: AppBar(
          title: const Text('سادہ رسید و دستاویزی اسٹوڈیو (A4)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          backgroundColor: Colors.teal.shade800,
          foregroundColor: Colors.white,
          actions: [
            ElevatedButton.icon(
              onPressed: () async {
                final isSaved = await _controller.saveTemplate();
                if (!context.mounted) return;
                if (isSaved) {
                  Navigator.pop(context, true);
                }
              },
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _controller.titleController,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(labelText: 'رسید / دستاویز کا نام', isDense: true, border: OutlineInputBorder()),
                    ),
                  ),
                  const Spacer(),
                  const Text('کاغذ کا سائز: A4 (8.27 x 11.69 انچ)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: List.generate(pages.length, (index) {
                      return Column(
                        children: [
                          StampCanvasSheet(
                            sheetWidth: sheetW,
                            sheetHeight: sheetH,
                            scaledTop: _controller.topMargin * scale,
                            scaledBottom: _controller.bottomMargin * scale,
                            scaledSide: _controller.sideMargin * scale,
                            bgImage: null,
                            pageLabel: "صفحہ نمبر ${index + 1} (A4 سادہ)",
                            isFirstPage: index == 0,
                            textContent: pages[index],
                            fontSize: _controller.fontSize,
                            bodyController: index == 0 ? _controller.bodyController : null,
                            onTextChanged: (_) => setState(() {}),
                            onTopDrag: (d) => _controller.setTopMargin(_controller.topMargin + (d / scale)),
                            onBottomDrag: (d) => _controller.setBottomMargin(_controller.bottomMargin - (d / scale)),
                            onSideDrag: (d) => _controller.setSideMargin(_controller.sideMargin - (d / scale)),
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }),
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