import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CounterScannerBarUi extends StatelessWidget {
  final VoidCallback onScanProduct;
  final VoidCallback onScanCnic;
  final int activeIndex; // 0 = کوئی نہیں، 1 = پروڈکٹ، 2 = شناختی کارڈ

  const CounterScannerBarUi({
    super.key,
    required this.onScanProduct,
    required this.onScanCnic,
    this.activeIndex = 0,
  });

  Widget _buildScannerButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryEmerald.withAlpha(20) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primaryEmerald : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.primaryEmerald : const Color(0xFF475569),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? AppColors.primaryEmerald : const Color(0xFF334155),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          _buildScannerButton(
            label: 'پروڈکٹ QR اسکین',
            icon: Icons.qr_code_scanner,
            isSelected: activeIndex == 1,
            onTap: onScanProduct,
          ),
          const SizedBox(width: 8),
          _buildScannerButton(
            label: 'شناختی کارڈ اسکین',
            icon: Icons.badge_outlined,
            isSelected: activeIndex == 2,
            onTap: onScanCnic,
          ),
        ],
      ),
    );
  }
}