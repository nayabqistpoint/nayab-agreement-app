import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../services/stock_inventory_storage_service.dart';

class StockInventoryListUi extends StatelessWidget {
  final StockList items;
  final ValueChanged<StockMap> onEdit;
  final ValueChanged<String> onDelete;

  const StockInventoryListUi({
    super.key,
    required this.items,
    required this.onEdit,
    required this.onDelete,
  });

  Widget _badge(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(28),
        child: Center(
          child: Text(
            'اس حصے میں کوئی آئٹم موجود نہیں ہے۔',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 16.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
    }
    return Column(
      children: items.map((item) {
        final id = item['id']?.toString() ?? '';
        final name = item['itemName']?.toString() ?? '';
        final cat = item['productCategory']?.toString() ?? 'MOBILE';
        final isMob = cat == 'MOBILE';
        final identifier = isMob
            ? (item['imeiNo']?.toString() ?? '')
            : (item['serialNo']?.toString() ?? '');
        final details = isMob
            ? (item['ramRom']?.toString() ?? '')
            : (item['specsSummary']?.toString() ?? '');
        final salePrice = item['salePrice']?.toString() ?? '0';
        final purchasePrice = item['purchasePrice']?.toString() ?? '0';
        final status = (item['status']?.toString() ?? 'AVAILABLE').toUpperCase();
        final bool isLocked = status == 'RESERVED' || status == 'SOLD';

        String statusLabel = 'موجود';
        Color statusBg = Colors.green.shade100;
        Color statusText = Colors.green.shade900;
        if (status == 'ON_ORDER') {
          statusLabel = 'آرڈر پر دستیاب';
          statusBg = Colors.teal.shade100;
          statusText = Colors.teal.shade900;
        } else if (status == 'RESERVED') {
          statusLabel = 'بُک شدہ';
          statusBg = Colors.orange.shade100;
          statusText = Colors.orange.shade900;
        } else if (status == 'SOLD') {
          statusLabel = 'فروخت شدہ';
          statusBg = Colors.indigo.shade100;
          statusText = Colors.indigo.shade900;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 1.5,
          color: isLocked ? Colors.grey.shade50 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isLocked
                  ? const Color(0xFFCBD5E1)
                  : AppColors.emeraldPillBorder,
              width: 1.3,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: isMob
                          ? AppColors.primaryEmerald.withAlpha(28)
                          : Colors.indigo.shade50,
                      child: Icon(
                        isMob ? Icons.phone_android : Icons.kitchen_outlined,
                        size: 24,
                        color: isMob
                            ? AppColors.primaryEmerald
                            : Colors.indigo.shade800,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$name ${details.isNotEmpty ? "($details)" : ""}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 17.5,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'ID: $id ${identifier.isNotEmpty ? "• No: $identifier" : ""}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    _badge(statusLabel, statusBg, statusText),
                  ],
                ),
                const Divider(height: 16, thickness: 1.1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (purchasePrice != '0' &&
                              purchasePrice.trim().isNotEmpty)
                            Text(
                              'خرید: Rs. $purchasePrice',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: AppColors.textMuted,
                              ),
                            ),
                          Text(
                            'فروخت: Rs. $salePrice',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16.5,
                              color: AppColors.primaryEmerald,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLocked)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => onEdit(item),
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: AppColors.primaryEmerald,
                            ),
                            label: const Text(
                              'ترمیم',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryEmerald,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: AppColors.primaryEmerald),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 6),
                            ),
                          ),
                          const SizedBox(width: 5),
                          OutlinedButton.icon(
                            onPressed: () => onDelete(id),
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: AppColors.errorRed,
                            ),
                            label: const Text(
                              'حذف',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppColors.errorRed,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side:
                                  const BorderSide(color: AppColors.errorRed),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 6),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}