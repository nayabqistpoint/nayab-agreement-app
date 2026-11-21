import 'dart:convert';
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

  String? _resolveActiveCustomerPhoto() {
    try {
      if (activeOrderId != null && activeOrderId!.isNotEmpty) {
        final ordersBox = HiveBoxManager.getBox(BoxNames.shopOrdersBox);
        final rawOrder = ordersBox.get(activeOrderId);
        if (rawOrder is Map) {
          final url = rawOrder['customerPhotoUrl']?.toString().trim() ?? '';
          if (url.isNotEmpty && url != 'null') return url;
        }
      }
      final cnic = currentBucketValues['شناختی کارڈ']?.trim() ?? '';
      if (cnic.isNotEmpty) {
        final custBox = HiveBoxManager.getBox(BoxNames.customersBox);
        final rawCust = custBox.get(cnic);
        if (rawCust is Map) {
          final url = rawCust['photoUrl']?.toString().trim() ?? '';
          if (url.isNotEmpty && url != 'null') return url;
        }
      }
    } catch (_) {}
    return null;
  }

  Widget _buildPassportPhoto(String? photoUrl) {
    final bool hasImg = photoUrl != null && photoUrl.trim().isNotEmpty;
    Widget inner;
    if (hasImg && photoUrl.startsWith('data:image')) {
      try {
        final commaIdx = photoUrl.indexOf(',');
        final bytes = base64Decode(photoUrl.substring(commaIdx + 1));
        inner = Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        inner = const Icon(
          Icons.person_rounded,
          color: AppColors.primaryEmerald,
          size: 30,
        );
      }
    } else if (hasImg) {
      inner = Image.network(
        photoUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const Icon(
          Icons.person_rounded,
          color: AppColors.primaryEmerald,
          size: 30,
        ),
      );
    } else {
      inner = const Icon(
        Icons.person_rounded,
        color: AppColors.primaryEmerald,
        size: 30,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 52,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primaryEmerald,
            width: 1.4,
          ),
        ),
        child: inner,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HiveBoxManager.listenToBox(BoxNames.shopOrdersBox),
      builder: (context, _, _) {
        final installmentOrders =
            PosPendingOrdersService.getInstallmentOrders();
        final pendingOrders = PosPendingOrdersService.getPendingOrders();
        final int pendingCount = pendingOrders.length;
        final int unreadCashCount =
            PosPendingOrdersService.getUnreadCashSalesCount();

        final activeName = currentBucketValues['کسٹمر کا نام']?.trim() ?? '';
        final activeCnic = currentBucketValues['شناختی کارڈ']?.trim() ?? '';
        final activeModel = currentBucketValues['موبائل ماڈل']?.trim() ?? '';
        final hasActiveData = activeOrderId != null ||
            activeName.isNotEmpty ||
            activeCnic.isNotEmpty;
        final String? customerPhoto =
            hasActiveData ? _resolveActiveCustomerPhoto() : null;

        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: InkWell(
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 7),
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
                                horizontal: 7,
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
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                pendingCount > 0
                                    ? 'POS آرڈرز ($pendingCount)'
                                    : 'POS آرڈرز (ہسٹری: ${installmentOrders.length})',
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
                              size: 13,
                              color: pendingCount > 0
                                  ? AppColors.primaryEmerald
                                  : Colors.blueGrey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (unreadCashCount > 0) ...[
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PosPendingOrdersPage(
                              initialFilter: 'CASH',
                            ),
                          ),
                        ).then((_) => onOrderUpdatedFromPage());
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.amber.shade700,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.payments_rounded,
                              size: 16,
                              color: Color(0xFFB45309),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'نقد سیل',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF92400E),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.errorRed,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$unreadCashCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
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
                      _buildPassportPhoto(customerPhoto),
                      const SizedBox(width: 10),
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
                                      fontSize: 14,
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
                                  fontSize: 12,
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