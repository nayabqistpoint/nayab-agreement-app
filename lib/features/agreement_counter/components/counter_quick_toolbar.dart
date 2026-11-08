import 'package:flutter/material.dart';
import '../../../core/models/document_template_model.dart';

class CounterQuickToolbar extends StatelessWidget {
  final DocumentMode currentMode;
  final double fontSize;
  final Function(double) onFontSizeChanged;
  final VoidCallback onPickCustomerStamp;
  final String? stampFileName;
  final int totalPages;

  const CounterQuickToolbar({
    super.key,
    required this.currentMode,
    required this.fontSize,
    required this.onFontSizeChanged,
    required this.onPickCustomerStamp,
    required this.stampFileName,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 20, color: Colors.teal),
              tooltip: 'فونٹ بڑا کریں',
              onPressed: () => onFontSizeChanged(fontSize + 0.5),
            ),
            Text(
              'pt ${fontSize.toStringAsFixed(1)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.teal),
              tooltip: 'فونٹ چھوٹا کریں',
              onPressed: () => onFontSizeChanged(fontSize - 0.5),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'صفحات: $totalPages',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onPickCustomerStamp,
              icon: const Icon(Icons.upload_file, size: 15),
              label: Text(
                stampFileName ?? 'اسٹامپ چنیں',
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}