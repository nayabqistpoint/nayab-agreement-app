import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CounterScannerBarUi extends StatelessWidget {
  final VoidCallback onScanProduct;
  final VoidCallback onScanCnic;

  const CounterScannerBarUi({
    super.key,
    required this.onScanProduct,
    required this.onScanCnic,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: ElevatedButton.icon(
            onPressed: onScanProduct,
            icon: const Icon(Icons.qr_code_scanner, size: 24),
            label: const Text('پروڈکٹ QR اسکین', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryEmerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: OutlinedButton.icon(
            onPressed: onScanCnic,
            icon: const Icon(Icons.badge_outlined, size: 22),
            label: const Text('شناختی کارڈ', style: TextStyle(fontSize: 15)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryEmerald,
              side: const BorderSide(color: AppColors.primaryEmerald, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}