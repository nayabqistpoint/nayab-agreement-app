import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CounterPrintActionUi extends StatelessWidget {
  final VoidCallback onPrint;
  final VoidCallback onCopyText;

  const CounterPrintActionUi({
    super.key,
    required this.onPrint,
    required this.onCopyText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: ElevatedButton.icon(
            onPressed: onPrint,
            icon: const Icon(Icons.print, size: 24),
            label: const Text(
              'معاہدہ پرنٹ / PDF',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 4,
          child: OutlinedButton.icon(
            onPressed: onCopyText,
            icon: const Icon(Icons.copy_all, size: 20),
            label: const Text('ٹیکسٹ کاپی', style: TextStyle(fontSize: 14)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textDark,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}