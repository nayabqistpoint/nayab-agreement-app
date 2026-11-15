import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DynamicBucketFieldListUi extends StatelessWidget {
  final List<String> fields;
  final Map<String, TextEditingController> controllers;
  final Map<String, dynamic> qrSourceData;
  final Set<String> posFilledFields;
  final VoidCallback onFieldChanged;

  const DynamicBucketFieldListUi({
    super.key,
    required this.fields,
    required this.controllers,
    required this.qrSourceData,
    this.posFilledFields = const {},
    required this.onFieldChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (fields.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Center(
          child: Text(
            'کوئی فیلڈز موجود نہیں۔ پہلے کوئی معاہدہ منتخب کریں۔',
            style: TextStyle(fontSize: 15, color: AppColors.textMuted),
          ),
        ),
      );
    }

    return Column(
      children: fields.map((field) {
        final isPosFilled = posFilledFields.contains(field);
        final isQrFilled = qrSourceData.containsKey(field);
        final ctrl = controllers[field];

        String? helperText;
        Color fillColor = Colors.white;
        IconData prefixIcon = Icons.edit_outlined;
        Color iconColor = AppColors.primaryEmerald;

        if (isPosFilled) {
          helperText = 'POS آرڈر سے موصول شدہ (صرف معاہدے کیلئے قابلِ ترمیم)';
          fillColor = const Color(0xFFECFDF5);
          prefixIcon = Icons.point_of_sale_rounded;
          iconColor = AppColors.successGreen;
        } else if (isQrFilled) {
          helperText = 'کیو آر کوڈ سے خودکار درج شدہ';
          fillColor = Colors.teal.shade50;
          prefixIcon = Icons.qr_code_2;
          iconColor = AppColors.primaryEmerald;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: TextField(
            controller: ctrl,
            textAlign: TextAlign.right,
            onChanged: (_) => onFieldChanged(),
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              labelText: field,
              prefixIcon: Icon(prefixIcon, color: iconColor, size: 20),
              helperText: helperText,
              helperStyle: TextStyle(
                color: isPosFilled ? AppColors.successGreen : Colors.black54,
                fontWeight: isPosFilled ? FontWeight.bold : FontWeight.normal,
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: fillColor,
            ),
          ),
        );
      }).toList(),
    );
  }
}