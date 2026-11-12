import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class BucketCustomerBlockUi extends StatelessWidget {
  final Map<String, TextEditingController> controllers;

  const BucketCustomerBlockUi({super.key, required this.controllers});

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primaryEmerald),
          const SizedBox(width: 6),
          Text('$label: ', style: const TextStyle(fontSize: 12, color: Colors.black54)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cnic = controllers['شناختی کارڈ']?.text;
    final name = controllers['کسٹمر کا نام']?.text;
    final phone = controllers['رابطہ نمبر']?.text;
    final model = controllers['موبائل ماڈل']?.text;
    final imei = controllers['IMEI نمبر']?.text;

    final bool hasData = (cnic != null && cnic.isNotEmpty) ||
        (name != null && name.isNotEmpty) ||
        (model != null && model.isNotEmpty);

    if (!hasData) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.badge_outlined, size: 16, color: AppColors.primaryEmerald),
              SizedBox(width: 6),
              Text(
                'اسکین شدہ کسٹمر و موبائل خلاصہ:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.primaryEmerald,
                ),
              ),
            ],
          ),
          const Divider(height: 12),
          _buildInfoRow(Icons.person, 'کسٹمر نام', name),
          _buildInfoRow(Icons.credit_card, 'شناختی کارڈ', cnic),
          _buildInfoRow(Icons.phone, 'فون نمبر', phone),
          _buildInfoRow(Icons.phone_android, 'موبائل ماڈل', model),
          _buildInfoRow(Icons.qr_code, 'IMEI', imei),
        ],
      ),
    );
  }
}