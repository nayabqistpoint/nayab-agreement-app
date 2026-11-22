import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
class StockFieldEyeToggleUi extends StatelessWidget {
  final bool isVisibleOnCard;
  final VoidCallback onToggle;
  const StockFieldEyeToggleUi({
    super.key,
    required this.isVisibleOnCard,
    required this.onToggle,
  });
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isVisibleOnCard
          ? '👁️ POS کارڈ پر نظر آئے گی (خفیہ کرنے کیلئے دبائیں)'
          : '🙈 POS کارڈ سے خفیہ / صرف معاہدے کیلئے (دکھانے کیلئے دبائیں)',
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          width: 40,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isVisibleOnCard
                ? AppColors.warmTintEmerald
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: isVisibleOnCard
                  ? AppColors.primaryEmerald
                  : const Color(0xFFCBD5E1),
              width: 1.3,
            ),
          ),
          child: Icon(
            isVisibleOnCard
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            size: 19,
            color: isVisibleOnCard
                ? AppColors.primaryEmerald
                : Colors.blueGrey.shade600,
          ),
        ),
      ),
    );
  }
}