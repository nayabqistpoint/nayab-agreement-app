import 'package:flutter/material.dart';
import '../../../../core/models/document_template_model.dart';

class StudioToolbar extends StatelessWidget {
  final TextEditingController titleController;
  final DocumentMode currentMode;
  final String? loadedPdfName;
  final double fontSize;
  final double topMargin;
  final double bottomMargin;
  final double sideMargin;
  final Function(DocumentMode) onModeChanged;
  final VoidCallback onPickPdf;
  final VoidCallback onEditText;
  final VoidCallback onNormalizeText;
  final Function(double) onFontSizeChanged;
  final VoidCallback onOpenMarginModal;

  const StudioToolbar({
    super.key,
    required this.titleController,
    required this.currentMode,
    required this.loadedPdfName,
    required this.fontSize,
    required this.topMargin,
    required this.bottomMargin,
    required this.sideMargin,
    required this.onModeChanged,
    required this.onPickPdf,
    required this.onEditText,
    required this.onNormalizeText,
    required this.onFontSizeChanged,
    required this.onOpenMarginModal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: 150,
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

            // موڈ کا انتخاب
            DropdownButton<DocumentMode>(
              value: currentMode,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: DocumentMode.stampOverlay, child: Text('پنجاب ای-اسٹامپ (اوورلے)')),
                DropdownMenuItem(value: DocumentMode.formFiller, child: Text('فارم فلر (اسکول و چالان)')),
                DropdownMenuItem(value: DocumentMode.plainDocument, child: Text('سادہ A4 دستاویزی کاغذ')),
              ],
              onChanged: (m) {
                if (m != null) onModeChanged(m);
              },
            ),
            const SizedBox(width: 8),

            if (currentMode != DocumentMode.plainDocument) ...[
              ElevatedButton.icon(
                onPressed: onPickPdf,
                icon: const Icon(Icons.upload_file, size: 15),
                label: Text(loadedPdfName ?? 'PDF فارم چنیں', style: const TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
            ],

            if (currentMode == DocumentMode.stampOverlay) ...[
              ElevatedButton.icon(
                onPressed: onEditText,
                icon: const Icon(Icons.edit_note, size: 16),
                label: const Text('تحریر لکھیں', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: onNormalizeText,
                icon: const Icon(Icons.format_align_justify, size: 15),
                label: const Text('سطریں ہموار کریں', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
            ],

            // فونٹ سائز کنٹرولر
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
                    onTap: () => onFontSizeChanged(fontSize - 0.5),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.remove, size: 15, color: Colors.teal),
                    ),
                  ),
                  Text('$fontSize pt', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  InkWell(
                    onTap: () => onFontSizeChanged(fontSize + 0.5),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.add, size: 15, color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            if (currentMode == DocumentMode.stampOverlay)
              InkWell(
                onTap: onOpenMarginModal,
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