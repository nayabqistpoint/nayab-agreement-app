import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/customer_profile_model.dart';

class CustomerProfileTileUi extends StatelessWidget {
  final CustomerProfileModel customer;
  final VoidCallback onTap;

  const CustomerProfileTileUi({
    super.key,
    required this.customer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryEmerald.withAlpha(30),
          child: const Icon(Icons.person, color: AppColors.primaryEmerald),
        ),
        title: Text(
          customer.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          'شناختی کارڈ: ${customer.cnic} | فون: ${customer.phone}',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black38),
      ),
    );
  }
}