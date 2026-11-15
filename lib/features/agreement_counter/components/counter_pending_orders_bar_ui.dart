import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../services/counter_pos_order_service.dart';

class CounterPendingOrdersBarUi extends StatelessWidget {
  final String? activeOrderId;
  final Function(PosOrderMap order) onSelectOrder;
  final Function(String orderId) onDismissOrder;

  const CounterPendingOrdersBarUi({
    super.key,
    required this.activeOrderId,
    required this.onSelectOrder,
    required this.onDismissOrder,
  });

  void _confirmDismiss(
    BuildContext context,
    String orderId,
    String customerName,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'آرڈر پینڈنگ لسٹ سے ہٹائیں؟',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Text(
            'کیا آپ "$customerName" کا یہ آرڈر کاؤنٹر کی پینڈنگ لسٹ سے ختم کرنا چاہتے ہیں؟ (ریکارڈ ہسٹری میں محفوظ رہے گا)',
            style: const TextStyle(fontSize: 13.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('منسوخ'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                onDismissOrder(orderId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('ہاں، ختم کریں'),
            ),
          ],
        ),
      ),
    );
  }

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
            maxHeight: MediaQuery.of(context).size.height * 0.75,
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
                    'زیرِ التواء POS آرڈرز (${orders.length})',
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
                'کسٹمر کے نام پر کلک کریں تاکہ معاہدے کی معلومات بالٹی میں بھر جائیں:',
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
                        order['customerName']?.toString() ?? 'نامعلوم کسٹمر';
                    final cnic = order['customerCnic']?.toString() ?? '';
                    final phone = order['customerPhone']?.toString() ?? '';
                    final model = order['itemName']?.toString() ?? 'موبائل';
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
                            Icons.person_outline,
                            color: AppColors.primaryEmerald,
                            size: 22,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                customer,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF0F172A),
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
                                model,
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'شناختی کارڈ: ${cnic.isNotEmpty ? cnic : "درج نہیں"}  |  فون: $phone',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'ماہانہ قسط: $monthly × $months ماہ  (حوالہ: $id)',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red.shade600,
                            size: 20,
                          ),
                          tooltip: 'پینڈنگ لسٹ سے ختم کریں',
                          onPressed: () {
                            Navigator.pop(ctx);
                            _confirmDismiss(context, id, customer);
                          },
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

        // اگر کوئی آرڈر لوڈ ہے تو اس کے کسٹمر کا نام بار پر دکھائیں
        String activeCustomerLabel = '';
        if (activeOrderId != null) {
          final match = pendingOrders.where((o) => o['id'] == activeOrderId);
          if (match.isNotEmpty) {
            final o = match.first;
            final cName = o['customerName']?.toString() ?? '';
            final cModel = o['itemName']?.toString() ?? '';
            activeCustomerLabel = '$cName ($cModel)';
          }
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
                      activeCustomerLabel.isNotEmpty
                          ? 'منتخب کسٹمر: $activeCustomerLabel — تبدیل کرنے کیلئے کلک کریں'
                          : 'POS سے $count کسٹمر آرڈر موصول ہوئے ہیں — انتخاب کیلئے کلک کریں',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryEmerald,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.people_alt_outlined,
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