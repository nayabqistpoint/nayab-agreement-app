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
    // اشاریہ ختم: خالص مکمل گول اعداد (11, 12, 13, 14...)
    final int currentSize = fontSize.round().clamp(10, 26);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: 160,
              child: TextField(
                controller: titleController,
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
              onPressed: onPickPdf,
              icon: const Icon(Icons.upload_file, size: 15),
              label: Text(
                loadedPdfFileName ?? 'ای-اسٹامپ PDF چنیں',
                style: const TextStyle(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown.shade700,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onNormalizeParagraphs,
              icon: const Icon(Icons.format_align_justify, size: 15),
              label: const Text('سطریں ہموار کریں', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
              ),
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
                    onTap: () {
                      final newSize = (currentSize - 1).clamp(10, 26).toDouble();
                      onFontSizeChanged(newSize);
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.remove, size: 15, color: Colors.teal),
                    ),
                  ),
                  Text(
                    '$currentSize pt',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap: () {
                      final newSize = (currentSize + 1).clamp(10, 26).toDouble();
                      onFontSizeChanged(newSize);
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.add, size: 15, color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onShowMargins,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'مارجنز: T:${topMargin.toInt()} B:${bottomMargin.toInt()} S:${sideMargin.toInt()}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}