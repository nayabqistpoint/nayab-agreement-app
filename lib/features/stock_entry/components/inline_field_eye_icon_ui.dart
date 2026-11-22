import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
class InlineFieldEyeIconUi extends StatelessWidget {
  final bool isVisibleOnCard;
  final VoidCallback onToggle;
  const InlineFieldEyeIconUi({
    super.key,
    required this.isVisibleOnCard,
    required this.onToggle,
  });
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onToggle,
      tooltip: isVisibleOnCard
          ? '👁️ POS کارڈ پر ظاہر (خفیہ کرنے کیلئے دبائیں)'
          : '🙈 خفیہ / صرف معاہدے کیلئے (دکھانے کیلئے دبائیں)',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
      visualDensity: VisualDensity.compact,
      icon: Icon(
        isVisibleOnCard
            ? Icons.visibility_rounded
            : Icons.visibility_off_rounded,
        size: 20,
        color: isVisibleOnCard
            ? AppColors.primaryEmerald
            : Colors.blueGrey.shade500,
      ),
    );
  }
}