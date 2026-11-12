import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/customer_deal_model.dart';
import '../../../../core/models/customer_profile_model.dart';
import 'customer_deal_card_ui.dart';

class CustomerDetailSheetUi extends StatelessWidget {
  final CustomerProfileModel customer;
  final List<CustomerDealModel> deals;
  final Function(CustomerDealModel) onGenerateNotice;

  const CustomerDetailSheetUi({
    super.key,
    required this.customer,
    required this.deals,
    required this.onGenerateNotice,
  });

  static void show({
    required BuildContext context,
    required CustomerProfileModel customer,
    required List<CustomerDealModel> deals,
    required Function(CustomerDealModel) onGenerateNotice,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomerDetailSheetUi(
        customer: customer,
        deals: deals,
        onGenerateNotice: onGenerateNotice,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: const BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 45,
                height: 4.5,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.primaryEmerald.withAlpha(25),
                    child: const Icon(Icons.person, color: AppColors.primaryEmerald, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ولدیت: ${customer.fatherName.isNotEmpty ? customer.fatherName : "درج نہیں"}',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        Text(
                          'CNIC: ${customer.cnic} | فون: ${customer.phone}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryEmerald),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.black54),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'پتہ: ${customer.address.isNotEmpty ? customer.address : "کوئی پتہ درج نہیں"}',
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.receipt_long_outlined, size: 18, color: AppColors.primaryEmerald),
                const SizedBox(width: 6),
                Text(
                  'سابقہ خریداری و اقساط معاہدات (${deals.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: deals.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.folder_open_outlined, size: 45, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          const Text('اس کسٹمر کی کوئی محفوظ شدہ ڈیل موجود نہیں ہے', style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: deals.length,
                      itemBuilder: (context, i) => CustomerDealCardUi(
                        deal: deals[i],
                        onGenerateNotice: () => onGenerateNotice(deals[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}