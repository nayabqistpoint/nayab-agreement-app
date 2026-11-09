import 'package:flutter/material.dart';

class StampHeaderToolbarUi extends StatelessWidget {
  final TextEditingController titleController;
  final String? loadedPdfFileName;
  final double fontSize;
  final double topMargin;
  final double bottomMargin;
  final double sideMargin;
  final VoidCallback onPickPdf;
  final VoidCallback onNormalizeParagraphs;
  final Function(double) onFontSizeChanged;
  final VoidCallback onShowMargins;

  const StampHeaderToolbarUi({
    super.key,
    required this.titleController,
    required this.loadedPdfFileName,
    required this.fontSize,
    required this.topMargin,
    required this.bottomMargin,
    required this.sideMargin,
    required this.onPickPdf,
    required this.onNormalizeParagraphs,
    required this.onFontSizeChanged,
    required this.onShowMargins,
  });

  @override
  Widget build(BuildContext context) {
    final int currentSize = fontSize.round().clamp(10, 32);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: 155,
              child: TextField(
                controller: titleController,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: 'معاہدے کا عنوان',
                  isDense: true,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 6),
            ElevatedButton.icon(
              onPressed: onPickPdf,
              icon: const Icon(Icons.upload_file, size: 15),
              label: Text(
                loadedPdfFileName ?? 'ای-اسٹامپ PDF',
                style: const TextStyle(fontSize: 11.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
            const SizedBox(width: 6),
            ElevatedButton.icon(
              onPressed: onNormalizeParagraphs,
              icon: const Icon(Icons.format_align_justify, size: 15),
              label: const Text('سطریں ہموار کریں', style: TextStyle(fontSize: 11.5)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => onFontSizeChanged((currentSize - 1).clamp(10, 32).toDouble()),
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Icon(Icons.remove, size: 17, color: Colors.teal),
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 26),
                    alignment: Alignment.center,
                    child: Text(
                      '$currentSize',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                    ),
                  ),
                  InkWell(
                    onTap: () => onFontSizeChanged((currentSize + 1).clamp(10, 32).toDouble()),
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Icon(Icons.add, size: 17, color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}