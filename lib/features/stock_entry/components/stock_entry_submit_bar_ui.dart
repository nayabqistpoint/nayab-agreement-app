import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
class StockEntrySubmitBarUi extends StatelessWidget {
  final bool isEditing;
  final bool isMobile;
  final int quantity;
  final VoidCallback onPressed;
  const StockEntrySubmitBarUi({
    super.key,
    required this.isEditing,
    required this.isMobile,
    required this.quantity,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    final String label = isEditing
        ? 'تبدیلیاں محفوظ کریں'
        : (quantity > 1
            ? '$quantity ${isMobile ? "موبائلز" : "آئٹمز"} اسٹاک میں شامل کریں (مع منفرد IDs)'
            : 'اسٹاک میں شامل کریں');
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        border: Border(
          top: BorderSide(color: AppColors.borderLight, width: 1.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(
            isEditing ? Icons.check_circle_rounded : Icons.add_box_rounded,
            size: 21,
          ),
          label: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryEmerald,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
          ),
        ),
      ),
    );
  }
}