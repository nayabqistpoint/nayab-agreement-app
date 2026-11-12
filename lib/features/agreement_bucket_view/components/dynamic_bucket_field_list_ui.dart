import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DynamicBucketFieldListUi extends StatelessWidget {
  final List<String> fields;
  final Map<String, TextEditingController> controllers;
  final Map<String, dynamic> qrSourceData;
  final VoidCallback onFieldChanged;

  const DynamicBucketFieldListUi({
    super.key,
    required this.fields,
    required this.controllers,
    required this.qrSourceData,
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
        final isAutoFilled = qrSourceData.containsKey(field);
        final ctrl = controllers[field];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: TextField(
            controller: ctrl,
            textAlign: TextAlign.right,
            onChanged: (_) => onFieldChanged(),
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              labelText: field,
              prefixIcon: isAutoFilled
                  ? const Icon(Icons.check_circle, color: AppColors.successGreen, size: 20)
                  : const Icon(Icons.edit_outlined, color: AppColors.primaryEmerald, size: 18),
              helperText: isAutoFilled ? 'کیو آر کوڈ سے خودکار درج شدہ' : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: isAutoFilled ? Colors.teal.shade50 : Colors.white,
            ),
          ),
        );
      }).toList(),
    );
  }
}