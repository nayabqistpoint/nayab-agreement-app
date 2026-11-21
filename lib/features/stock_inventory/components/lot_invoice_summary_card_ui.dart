import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LotInvoiceSummaryCardUi extends StatelessWidget {
  final int quantity;
  final String firstStockId;
  final String lastStockId;
  final int totalPurchase;
  final int totalSale;

  const LotInvoiceSummaryCardUi({
    super.key,
    required this.quantity,
    required this.firstStockId,
    required this.lastStockId,
    required this.totalPurchase,
    required this.totalSale,
  });

  Widget _metricRow({
    required String label,
    required String value,
    Color? valueColor,
    bool isLarge = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isLarge ? 15.5 : 14.5,
                fontWeight: FontWeight.w900,
                color: isLarge ? AppColors.textDark : AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isLarge ? 18 : 16,
              fontWeight: FontWeight.w900,
              color: valueColor ?? AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int expectedMargin = totalSale - totalPurchase;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.goldHighlight, width: 1.7),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryEmerald.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppColors.goldHighlight, width: 1.2),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  size: 19,
                  color: AppColors.goldHighlight,
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'ٹوٹل خلاصہ',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.goldHighlight,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.goldHighlight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$firstStockId تا $lastStockId',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _metricRow(
            label: 'کل تعداد (پیسز):',
            value: '$quantity یونٹس',
          ),
          _metricRow(
            label: 'کل قیمتِ خرید:',
            value: 'Rs. $totalPurchase',
          ),
          const Divider(height: 14, color: AppColors.borderLight),
          _metricRow(
            label: 'کل نقد قیمتِ فروخت:',
            value: 'Rs. $totalSale',
            valueColor: AppColors.primaryEmerald,
            isLarge: true,
          ),
          if (totalPurchase > 0)
            _metricRow(
              label: 'متوقع مجموعی منافع:',
              value: 'Rs. $expectedMargin',
              valueColor: expectedMargin >= 0
                  ? AppColors.successGreen
                  : AppColors.errorRed,
            ),
        ],
      ),
    );
  }
}