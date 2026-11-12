import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CounterPrintActionUi extends StatelessWidget {
  final int legalPageCount;
  final int a4PageCount;
  final VoidCallback onPrintLegal;
  final VoidCallback onPrintA4;
  final VoidCallback onPrintAllAsA4;

  const CounterPrintActionUi({
    super.key,
    required this.legalPageCount,
    required this.a4PageCount,
    required this.onPrintLegal,
    required this.onPrintA4,
    required this.onPrintAllAsA4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // بٹن 1: سرکاری اسٹامپ پیپر (Legal)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: legalPageCount > 0 ? onPrintLegal : null,
                  icon: const Icon(Icons.print, size: 20),
                  label: Text(
                    'پرنٹ اسٹامپ ($legalPageCount Legal)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade800,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // بٹن 2: دکان کی رسیدیں اور واؤچر (A4)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: a4PageCount > 0 ? onPrintA4 : null,
                  icon: const Icon(Icons.receipt_long, size: 20),
                  label: Text(
                    'پرنٹ رسیدیں ($a4PageCount A4)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryEmerald,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // بٹن 3: تمام فائل ایک ساتھ A4 میں (گاہک کو واٹس ایپ یا سنگل پرنٹ کیلئے)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onPrintAllAsA4,
              icon: const Icon(Icons.share_outlined, size: 18, color: AppColors.primaryEmerald),
              label: const Text(
                'تمام صفحات مشترکہ A4 فائل (برائے گاہک / واٹس ایپ پی ڈی ایف)',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.primaryEmerald),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 11),
                side: const BorderSide(color: AppColors.primaryEmerald, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}