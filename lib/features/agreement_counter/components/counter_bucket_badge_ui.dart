import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CounterBucketBadgeUi extends StatelessWidget {
  final int filledCount;
  final int totalCount;
  final VoidCallback onTap;

  const CounterBucketBadgeUi({
    super.key,
    required this.filledCount,
    required this.totalCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final int remainingCount = totalCount > filledCount ? (totalCount - filledCount) : 0;
    final bool isAllFilled = totalCount > 0 && remainingCount == 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4), // نرم اور ہلکا پھلکا پس منظر
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAllFilled ? AppColors.successGreen : const Color(0xFFCBD5E1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            // آئیکن
            Icon(
              isAllFilled ? Icons.check_circle_outline : Icons.assignment_outlined,
              size: 20,
              color: isAllFilled ? AppColors.successGreen : AppColors.primaryEmerald,
            ),
            const SizedBox(width: 12),

            // 1. کل فیلڈز
            _buildStatItem('کل فیلڈز:', '$totalCount', Colors.black87),
            _buildDivider(),

            // 2. مکمل فیلڈز
            _buildStatItem('مکمل:', '$filledCount', AppColors.successGreen),
            _buildDivider(),

            // 3. باقی فیلڈز
            _buildStatItem(
              'باقی:',
              '$remainingCount',
              remainingCount > 0 ? Colors.red.shade700 : AppColors.successGreen,
            ),

            const Spacer(),

            // ایکشن ایرو
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'تفصیل دیکھیں',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryEmerald,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 13,
                  color: AppColors.primaryEmerald,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: 14,
      width: 1,
      color: Colors.grey.shade300,
    );
  }
}