import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class BucketStatsHeaderUi extends StatelessWidget {
  final int totalCount;
  final int filledCount;
  final int missingCount;

  const BucketStatsHeaderUi({
    super.key,
    required this.totalCount,
    required this.filledCount,
    required this.missingCount,
  });

  Widget _buildStatBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          _buildStatBox('کل ضروری فیلڈز', '$totalCount', const Color(0xFF1E293B)),
          const SizedBox(width: 8),
          _buildStatBox('خودکار بھری ہوئی', '$filledCount', AppColors.successGreen),
          const SizedBox(width: 8),
          _buildStatBox('باقی خالی فیلڈز', '$missingCount', missingCount > 0 ? Colors.red.shade700 : AppColors.successGreen),
        ],
      ),
    );
  }
}