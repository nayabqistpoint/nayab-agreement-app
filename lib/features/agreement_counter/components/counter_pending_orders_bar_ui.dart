import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../pos_pending_orders/pos_pending_orders_page.dart';
import '../../pos_pending_orders/services/pos_pending_orders_service.dart';

class CounterPendingOrdersBarUi extends StatelessWidget {
  final String? activeOrderId;
  final Map<String, String> currentBucketValues;
  final VoidCallback onOrderUpdatedFromPage;
  final VoidCallback onClearActiveBucket;

  const CounterPendingOrdersBarUi({
    super.key,
    required this.activeOrderId,
    required this.currentBucketValues,
    required this.onOrderUpdatedFromPage,
    required this.onClearActiveBucket,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HiveBoxManager.listenToBox(BoxNames.shopOrdersBox),
      builder: (context, _, _) {
        final allOrders = PosPendingOrdersService.getAllOrders();
        final pendingOrders = PosPendingOrdersService.getPendingOrders();
        final int pendingCount = pendingOrders.length;

        final activeName = currentBucketValues['کسٹمر کا نام']?.trim() ?? '';
        final activeCnic = currentBucketValues['شناختی کارڈ']?.trim() ?? '';
        final activeModel = currentBucketValues['موبائل ماڈل']?.trim() ?? '';
        final hasActiveData = activeOrderId != null ||
            activeName.isNotEmpty ||
            activeCnic.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. POS آرڈرز کی مستقل پٹی — کلک کرنے پر پورا فل پیج کھلے گا
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PosPendingOrdersPage(),
                    ),
                  ).then((_) => onOrderUpdatedFromPage());
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: pendingCount > 0
                        ? const Color(0xFFE0F2F1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: pendingCount > 0
                          ? AppColors.primaryEmerald
                          : Colors.grey.shade300,
                      width: 1.2,
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
                          color: pendingCount > 0
                              ? AppColors.primaryEmerald
                              : Colors.blueGrey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$pendingCount',
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
                          pendingCount > 0
                              ? 'POS پینڈنگ آرڈرز ($pendingCount) — کسٹمر منتخب کرنے کیلئے کلک کریں'
                              : 'POS آرڈرز: کوئی نیا پینڈنگ آرڈر نہیں (ہسٹری: ${allOrders.length})',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: pendingCount > 0
                                ? AppColors.primaryEmerald
                                : Colors.blueGrey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: pendingCount > 0
                            ? AppColors.primaryEmerald
                            : Colors.blueGrey,
                      ),
                    ],
                  ),
                ),
              ),

              // 2. فعال کسٹمر کارڈ (صرف تب نظر آتا ہے جب کوئی کسٹمر لوڈ ہو)
              if (hasActiveData) ...[
                const SizedBox(height: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryEmerald,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_pin_rounded,
                        color: AppColors.primaryEmerald,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    activeName.isNotEmpty
                                        ? activeName
                                        : 'منتخب کسٹمر',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                      color: Color(0xFF064E3B),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (activeModel.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryEmerald,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      activeModel,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (activeCnic.isNotEmpty)
                              Text(
                                'شناختی کارڈ: $activeCnic',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: onClearActiveBucket,
                        icon: const Icon(Icons.close,
                            size: 16, color: Colors.red),
                        label: const Text(
                          'خالی کریں',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}