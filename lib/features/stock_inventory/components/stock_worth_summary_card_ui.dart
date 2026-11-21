import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../services/stock_inventory_storage_service.dart';

class StockWorthSummaryCardUi extends StatelessWidget {
  final StockList allStockItems;

  const StockWorthSummaryCardUi({
    super.key,
    required this.allStockItems,
  });

  Widget _rowItem(
    String label,
    String value, {
    bool isGrand = false,
    Color? valColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isGrand ? 16.5 : 15,
                fontWeight: FontWeight.w900,
                color: isGrand ? AppColors.textDark : AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isGrand ? 19 : 16.5,
              fontWeight: FontWeight.w900,
              color: valColor ?? AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int mobileCount = 0;
    int mobilePurchaseWorth = 0;
    int generalCount = 0;
    int generalPurchaseWorth = 0;

    for (final item in allStockItems) {
      final st =
          (item['status']?.toString() ?? 'AVAILABLE').trim().toUpperCase();
      if (st == 'ON_ORDER' || st == 'SOLD' || st == 'DELETED') continue;
      if (st != 'AVAILABLE' && st != 'RESERVED') continue;
      if (item['isOnOrder'] == true || item['isCustomEstimate'] == true) {
        continue;
      }

      final cat =
          (item['productCategory']?.toString() ?? 'MOBILE').toUpperCase();
      final int purchase = (item['purchasePrice'] as num?)?.toInt() ??
          int.tryParse(item['purchasePrice']?.toString() ?? '0') ??
          0;

      if (cat == 'ELECTRONICS') {
        generalCount++;
        generalPurchaseWorth += purchase;
      } else {
        mobileCount++;
        mobilePurchaseWorth += purchase;
      }
    }

    final int totalUnits = mobileCount + generalCount;
    final int grandPurchaseWorth = mobilePurchaseWorth + generalPurchaseWorth;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.goldHighlight, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryEmerald.withValues(alpha: 0.14),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.primaryLight,
                  AppColors.primaryEmerald,
                  AppColors.deepForestEmerald,
                ],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.goldHighlight, width: 1.3),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 21,
                  color: AppColors.goldHighlight,
                ),
                const SizedBox(width: 7),
                const Expanded(
                  child: Text(
                    'موجودہ اسٹاک مالیت',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.goldHighlight,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: AppColors.goldHighlight,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    '$totalUnits پیسز',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _rowItem(
            '📱 موبائل اسٹاک ($mobileCount یونٹس):',
            'Rs. $mobilePurchaseWorth',
          ),
          _rowItem(
            '🧊 جنرل اشیاء ($generalCount یونٹس):',
            'Rs. $generalPurchaseWorth',
          ),
          const Divider(
            height: 14,
            color: AppColors.borderLight,
            thickness: 1.3,
          ),
          _rowItem(
            '💰 کل موجودہ خرید مالیت:',
            'Rs. $grandPurchaseWorth',
            isGrand: true,
            valColor: AppColors.primaryEmerald,
          ),
        ],
      ),
    );
  }
}