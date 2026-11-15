import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/customer_profile_model.dart';

class CustomerDetailHeaderUi extends StatelessWidget {
  final CustomerProfileModel customer;

  const CustomerDetailHeaderUi({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final bool isGuarantor = customer.role.startsWith('ضامن');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: isGuarantor
                    ? Colors.indigo.shade50
                    : AppColors.primaryEmerald.withAlpha(25),
                child: Icon(
                  isGuarantor ? Icons.shield_outlined : Icons.person,
                  color: isGuarantor
                      ? Colors.indigo.shade700
                      : AppColors.primaryEmerald,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            customer.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isGuarantor
                                ? Colors.indigo.shade50
                                : Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            customer.role,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isGuarantor
                                  ? Colors.indigo.shade800
                                  : AppColors.primaryEmerald,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ولدیت: ${customer.fatherName.isNotEmpty ? customer.fatherName : "درج نہیں"}',
                      style:
                          const TextStyle(fontSize: 12.5, color: Colors.black54),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'CNIC: ${customer.cnic}  |  فون: ${customer.phone}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryEmerald,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 17, color: Colors.black54),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'پتہ: ${customer.address.isNotEmpty ? customer.address : "کوئی پتہ درج نہیں"}',
                  style: const TextStyle(fontSize: 12.5, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}