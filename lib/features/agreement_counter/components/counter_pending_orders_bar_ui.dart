import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../services/counter_pos_order_service.dart';

class CounterPendingOrdersBarUi extends StatelessWidget {
  final String? activeOrderId;
  final Function(PosOrderMap order) onSelectOrder;

  const CounterPendingOrdersBarUi({
    super.key,
    required this.activeOrderId,
    required this.onSelectOrder,
  });

  void _showOrdersBottomSheet(
    BuildContext context,
    List<PosOrderMap> orders,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.72,
          ),
          decoration: const BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.point_of_sale_rounded,
                    color: AppColors.primaryEmerald,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'POS پینڈنگ آرڈرز (${orders.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'کسی بھی آرڈر پر کلک کریں، تمام کوائف خودکار ایگریمنٹ بالٹی میں بھر جائیں گے:',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: orders.length,
                  itemBuilder: (_, index) {
                    final order = orders[index];
                    final id = order['id']?.toString() ?? '';
                    final customer =
                        order['customerName']?.toString() ?? 'کسٹمر';
                    final phone = order['customerPhone']?.toString() ?? '';
                    final model = order['itemName']?.toString() ?? 'موبائل';
                    final advance = order['advance']?.toString() ?? '0';
                    final monthly = order['monthlyAmount']?.toString() ?? '0';
                    final months = order['totalMonths']?.toString() ?? '';
                    final isCurrent = id == activeOrderId;

                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isCurrent
                              ? AppColors.primaryEmerald
                              : AppColors.borderLight,
                          width: isCurrent ? 1.8 : 1.0,
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.pop(ctx);
                          onSelectOrder(order);
                        },
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.primaryEmerald.withAlpha(25),
                          child: const Icon(
                            Icons.receipt_long,
                            color: AppColors.primaryEmerald,
                            size: 20,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '$customer ($model)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                id,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryEmerald,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'فون: $phone | ایڈوانس: $advance | قسط: $monthly × $months ماہ',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: AppColors.primaryEmerald,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HiveBoxManager.listenToBox(BoxNames.shopOrdersBox),
      builder: (context, box, _) {
        final pendingOrders = CounterPosOrderService.getPendingOrders();
        final int count = pendingOrders.length;

        if (count == 0) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 2),
          child: InkWell(
            onTap: () => _showOrdersBottomSheet(context, pendingOrders),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryEmerald,
                  width: 1.3,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryEmerald,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      activeOrderId != null
                          ? 'لوڈ شدہ POS آرڈر: $activeOrderId (تبدیل کرنے کیلئے کلک کریں)'
                          : 'POS ایپ سے $count نیا معاہدہ آرڈر موصول ہوا ہے — آٹو فل کیلئے کلک کریں',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryEmerald,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.download_for_offline_outlined,
                    size: 19,
                    color: AppColors.primaryEmerald,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}