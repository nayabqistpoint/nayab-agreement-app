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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text(
            'اس حصے میں کوئی آئٹم موجود نہیں ہے۔',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13.5),
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
        final price = item['salePrice']?.toString() ?? '0';
        final status = (item['status']?.toString() ?? 'AVAILABLE').toUpperCase();
        final bool isLocked = status == 'RESERVED' || status == 'SOLD';

        String statusLabel = 'موجود';
        Color statusBg = Colors.green.shade100;
        Color statusText = Colors.green.shade800;

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
          margin: const EdgeInsets.only(bottom: 8),
          color: isLocked ? Colors.grey.shade50 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: isMob
                          ? AppColors.primaryEmerald.withAlpha(25)
                          : Colors.indigo.shade50,
                      child: Icon(
                        isMob ? Icons.phone_android : Icons.kitchen_outlined,
                        size: 20,
                        color: isMob
                            ? AppColors.primaryEmerald
                            : Colors.indigo.shade700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$name ${details.isNotEmpty ? "($details)" : ""}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ID: $id ${identifier.isNotEmpty ? "• No: $identifier" : ""}',
                            style: const TextStyle(
                                fontSize: 11.5, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    _badge(statusLabel, statusBg, statusText),
                  ],
                ),
                const Divider(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'قیمتِ فروخت: Rs. $price',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: AppColors.primaryEmerald,
                      ),
                    ),
                    if (!isLocked)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            onPressed: () => onEdit(item),
                            icon: const Icon(Icons.edit_outlined,
                                size: 16, color: AppColors.primaryEmerald),
                            label: const Text('ترمیم',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primaryEmerald)),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          const SizedBox(width: 4),
                          TextButton.icon(
                            onPressed: () => onDelete(id),
                            icon: const Icon(Icons.delete_outline,
                                size: 16, color: AppColors.errorRed),
                            label: const Text('حذف',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.errorRed)),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
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