import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StampStudioAppBarUi extends StatelessWidget implements PreferredSizeWidget {
  final String paperSize;
  final Function(String) onPaperSizeChanged;
  final VoidCallback onSave;

  const StampStudioAppBarUi({
    super.key,
    required this.paperSize,
    required this.onPaperSizeChanged,
    required this.onSave,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryEmerald,
      foregroundColor: Colors.white,
      elevation: 1,
      titleSpacing: 10,
      title: Row(
        children: [
          // محفوظ کریں بٹن
          ElevatedButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.check, size: 16),
            label: const Text(
              'محفوظ کریں',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const Spacer(),

          // پیپر سائز سلیکٹر (A4 / لیگل)
          Container(
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white38),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSizeOption('A4 (سادہ)', paperSize == 'A4'),
                _buildSizeOption('لیگل (اسٹامپ)', paperSize == 'Legal'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeOption(String label, bool isSelected) {
    return InkWell(
      onTap: () => onPaperSizeChanged(label.contains('A4') ? 'A4' : 'Legal'),
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.primaryEmerald : Colors.white,
          ),
        ),
      ),
    );
  }
}