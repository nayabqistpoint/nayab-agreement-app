import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../services/order_invoice_calculator_service.dart';
class OrderMirrorInvoiceCardUi extends StatelessWidget {
  final OrderInvoiceSummary invoice;
  final int advance;
  final int monthly;
  final int totalMonths;
  final String guaranteeText;
  const OrderMirrorInvoiceCardUi({
    super.key,
    required this.invoice,
    required this.advance,
    required this.monthly,
    required this.totalMonths,
    required this.guaranteeText,
  });
  Widget _summaryRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 14 : 13,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: isBold ? AppColors.textDark : AppColors.textMuted,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 15 : 13.5,
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
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.primaryEmerald, width: 1.5),
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
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.goldHighlight,
                  size: 20,
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'آرڈر انوائس و منافع کا آئینہ',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (invoice.combinedHashBadge.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.goldHighlight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      invoice.combinedHashBadge,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warmSubtleSurface,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'آئٹم و تعداد',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'نقد مالیت',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'نقد منافع',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryEmerald,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          ...invoice.lines.map((line) {
            final bool hasProfit = line.unitPurchasePrice > 0;
            final bool isProfitPositive = line.lineCashProfit >= 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 5),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (line.hashBadge.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.warmTintEmerald,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: AppColors.emeraldPillBorder),
                                ),
                                child: Text(
                                  line.hashBadge,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryEmerald,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                line.itemName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${line.quantity} × Rs. ${line.unitCashPrice}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Rs. ${line.lineCashSubTotal}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          hasProfit
                              ? '${isProfitPositive ? "+" : ""}Rs. ${line.lineCashProfit}'
                              : '—',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: !hasProfit
                                ? AppColors.textMuted
                                : (isProfitPositive
                                    ? AppColors.successGreen
                                    : AppColors.errorRed),
                          ),
                        ),
                        if (hasProfit && line.quantity > 1)
                          Text(
                            '(Rs. ${line.unitCashProfit} فی پیس)',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 12, color: AppColors.borderLight),
          _summaryRow(
            'مجموعی نقد مالیت (${invoice.totalPieces} پیس):',
            'Rs. ${invoice.totalCashBase}',
            isBold: true,
          ),
          if (invoice.hasPurchaseData)
            _summaryRow(
              'کل قیمتِ خرید (لاگت):',
              'Rs. ${invoice.totalPurchaseCost}',
            ),
          if (invoice.installmentMarkupProfit > 0)
            _summaryRow(
              'اقساطی مارک اپ منافع:',
              '+ Rs. ${invoice.installmentMarkupProfit}',
              valueColor: AppColors.primaryEmerald,
            ),
          _summaryRow(
            'ٹوٹل معاہدہ رقم:',
            'Rs. ${invoice.totalContractAmount}',
            isBold: true,
          ),
          _summaryRow(
            'ایڈوانس وصولی:',
            'Rs. $advance',
            valueColor: AppColors.successGreen,
          ),
          _summaryRow(
            'ماہانہ قسط و ضمانت:',
            'Rs. $monthly × $totalMonths ماہ ($guaranteeText)',
            valueColor: AppColors.textDark,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              color: invoice.grandNetProfit >= 0
                  ? AppColors.warmTintEmerald
                  : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: invoice.grandNetProfit >= 0
                    ? AppColors.primaryEmerald
                    : AppColors.errorRed,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  invoice.hasPurchaseData
                      ? '💰 مجموعی خالص منافع (مع قسط):'
                      : '💰 متوقع اقساطی منافع:',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  'Rs. ${invoice.grandNetProfit}',
                  style: TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w900,
                    color: invoice.grandNetProfit >= 0
                        ? AppColors.successGreen
                        : AppColors.errorRed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}