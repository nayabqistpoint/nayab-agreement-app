import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CounterQuickToolbar extends StatelessWidget {
  final int selectedDocsCount;
  final int totalPages;
  final int legalPagesCount;
  final int a4PagesCount;

  const CounterQuickToolbar({
    super.key,
    required this.selectedDocsCount,
    required this.totalPages,
    required this.legalPagesCount,
    required this.a4PagesCount,
  });

  Widget _buildBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      margin: const EdgeInsets.only(left: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Icon(Icons.analytics_outlined, size: 16, color: Colors.blueGrey),
            const SizedBox(width: 6),
            _buildBadge('دستاویزات:', '$selectedDocsCount', const Color(0xFF1E293B)),
            _buildBadge('کل صفحات:', '$totalPages', AppColors.primaryEmerald),
            _buildBadge('لیگل پیپرز (اسٹامپ):', '$legalPagesCount', Colors.brown.shade800),
            _buildBadge('A4 پیپرز (رسیدیں):', '$a4PagesCount', Colors.teal.shade800),
            const SizedBox(width: 8),
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.zoom_in, size: 15, color: Colors.black45),
                SizedBox(width: 4),
                Text(
                  '(چٹکی بھر کر زوم کریں)',
                  style: TextStyle(fontSize: 10.5, color: Colors.black45),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}