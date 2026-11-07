import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CounterBucketSummary extends StatelessWidget {
  final int totalFields;
  final int filledFields;
  final VoidCallback onViewDetails;
  final VoidCallback onResetBucket;

  const CounterBucketSummary({
    super.key,
    required this.totalFields,
    required this.filledFields,
    required this.onViewDetails,
    required this.onResetBucket,
  });

  @override
  Widget build(BuildContext context) {
    final int remaining = (totalFields - filledFields).clamp(0, totalFields);
    final bool isAllFilled = totalFields > 0 && remaining == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isAllFilled ? const Color(0xFFE8F5E9) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAllFilled ? AppColors.successGreen : AppColors.borderLight,
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isAllFilled ? Icons.check_circle : Icons.inventory_2_outlined,
                color: isAllFilled ? AppColors.successGreen : AppColors.primaryEmerald,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'ڈیٹا بکٹ میٹر:',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isAllFilled ? AppColors.successGreen : Colors.orange.shade800,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isAllFilled ? 'تمام فیلڈز مکمل ($filledFields/$totalFields)' : '$remaining باقی ($filledFields/$totalFields مکمل)',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: onViewDetails,
                icon: const Icon(Icons.list_alt, size: 14),
                label: const Text('بکٹ دیکھیں / ایڈٹ کریں', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryEmerald,
                  foregroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18, color: Colors.grey),
                tooltip: 'بکٹ صاف کریں',
                onPressed: onResetBucket,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}