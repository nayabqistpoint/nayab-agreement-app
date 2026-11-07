import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/document_template_model.dart';

class CounterQuickToolbar extends StatelessWidget {
  final DocumentMode currentMode;
  final String? stampFileName;
  final double fontSize;
  final int totalPages;
  final VoidCallback onPickCustomerStamp;
  final Function(double) onFontSizeChanged;

  const CounterQuickToolbar({
    super.key,
    required this.currentMode,
    required this.stampFileName,
    required this.fontSize,
    required this.totalPages,
    required this.onPickCustomerStamp,
    required this.onFontSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isStampMode = (currentMode == DocumentMode.stampOverlay);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'حقیقی پرنٹ پیشگی نظارہ (کل صفحات: $totalPages):',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryEmerald),
              ),
              if (isStampMode && stampFileName != null) ...[
                const SizedBox(width: 8),
                Text(
                  '($stampFileName)',
                  style: TextStyle(fontSize: 11, color: Colors.brown.shade800, fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
          Row(
            children: [
              if (isStampMode) ...[
                ElevatedButton.icon(
                  onPressed: onPickCustomerStamp,
                  icon: const Icon(Icons.picture_as_pdf, size: 14),
                  label: const Text('گاہک کا اصل اسٹامپ چنیں', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade700,
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              const Text('سائز: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 18, color: Colors.teal),
                tooltip: 'چھوٹا کریں',
                onPressed: () => onFontSizeChanged(fontSize - 0.5),
                visualDensity: VisualDensity.compact,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$fontSize pt',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.teal),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 18, color: Colors.teal),
                tooltip: 'بڑا کریں',
                onPressed: () => onFontSizeChanged(fontSize + 0.5),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}