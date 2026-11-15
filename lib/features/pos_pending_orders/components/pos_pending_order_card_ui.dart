import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../services/pos_pending_orders_service.dart';

class PosPendingOrderCardUi extends StatelessWidget {
  final PosOrderRecord order;
  final bool isCurrentlyActive;
  final VoidCallback onSelect;
  final VoidCallback onDismiss;

  const PosPendingOrderCardUi({
    super.key,
    required this.order,
    required this.isCurrentlyActive,
    required this.onSelect,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final customer = order['customerName']?.toString() ?? 'نامعلوم کسٹمر';
    final cnic = order['customerCnic']?.toString() ?? '';
    final phone = order['customerPhone']?.toString() ?? '';
    final model = order['itemName']?.toString() ?? 'موبائل';
    final total = order['totalContractAmount']?.toString() ?? '0';
    final advance = order['advance']?.toString() ?? '0';
    final monthly = order['monthlyAmount']?.toString() ?? '0';
    final months = order['totalMonths']?.toString() ?? '';
    final status = (order['status']?.toString() ?? '').toUpperCase();

    final bool isCompleted = status == 'AGREEMENT_COMPLETED';
    final bool isDismissed = status == 'DISMISSED_BY_COUNTER';

    return Card(
      elevation: isCurrentlyActive ? 2 : 1,
      margin: const EdgeInsets.only(bottom: 10),
      color: isCurrentlyActive
          ? AppColors.primaryEmerald.withAlpha(18)
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCurrentlyActive
              ? AppColors.primaryEmerald
              : const Color(0xFFE2E8F0),
          width: isCurrentlyActive ? 2.0 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: isCurrentlyActive
                        ? AppColors.primaryEmerald
                        : (isCompleted
                            ? Colors.green.shade50
                            : AppColors.primaryEmerald.withAlpha(25)),
                    child: Icon(
                      isCurrentlyActive
                          ? Icons.check
                          : (isCompleted
                              ? Icons.verified
                              : Icons.person_outline),
                      color: isCurrentlyActive
                          ? Colors.white
                          : (isCompleted
                              ? AppColors.successGreen
                              : AppColors.primaryEmerald),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'شناختی کارڈ: ${cnic.isNotEmpty ? cnic : "درج نہیں"}  |  فون: $phone',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isCompleted && !isDismissed)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade600,
                        size: 21,
                      ),
                      tooltip: 'پینڈنگ لسٹ سے ختم کریں',
                      onPressed: onDismiss,
                    ),
                ],
              ),
              const Divider(height: 16),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      model,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryEmerald,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ٹوٹل: $total | ایڈوانس: $advance | قسط: $monthly × $months ماہ',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCompleted || isDismissed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green.shade100
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isCompleted ? 'مکمل شدہ' : 'ہٹایا گیا',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: isCompleted
                              ? Colors.green.shade800
                              : Colors.black54,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}