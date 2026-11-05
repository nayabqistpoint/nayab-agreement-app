import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CounterBucketBadgeUi extends StatelessWidget {
  final int totalFields;
  final int filledFields;
  final VoidCallback onViewBucketDetails;

  const CounterBucketBadgeUi({
    super.key,
    required this.totalFields,
    required this.filledFields,
    required this.onViewBucketDetails,
  });

  @override
  Widget build(BuildContext context) {
    final pending = totalFields - filledFields;
    final isComplete = totalFields > 0 && pending <= 0;

    return InkWell(
      onTap: onViewBucketDetails,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isComplete ? AppColors.successGreen : AppColors.pendingOrange,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  isComplete ? Icons.check_circle : Icons.pending_actions,
                  color: isComplete ? AppColors.successGreen : AppColors.pendingOrange,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isComplete ? 'ڈیٹا بکٹ مکمل ہے' : 'ڈیٹا بکٹ نامکمل ہے',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'کل ضروری: $totalFields | مکمل: $filledFields | باقی: $pending',
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
            const Row(
              children: [
                Text('تفصیل دیکھیں', style: TextStyle(fontSize: 13, color: AppColors.primaryEmerald)),
                Icon(Icons.arrow_back_ios_new, size: 14, color: AppColors.primaryEmerald),
              ],
            ),
          ],
        ),
      ),
    );
  }
}