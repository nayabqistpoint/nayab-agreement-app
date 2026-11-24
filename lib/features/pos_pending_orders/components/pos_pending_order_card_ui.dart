import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/portable_image_ui.dart';
import '../pos_order_full_profile_page.dart';
import '../services/order_invoice_calculator_service.dart';
import '../services/pos_pending_orders_service.dart';
class PosPendingOrderCardUi extends StatelessWidget {
  final PosOrderRecord order;
  final bool isCurrentlyActive;
  final ValueChanged<PosOrderRecord> onSelect;
  final VoidCallback onDismiss;
  const PosPendingOrderCardUi({
    super.key,
    required this.order,
    required this.isCurrentlyActive,
    required this.onSelect,
    required this.onDismiss,
  });
  Widget _buildPassportPhoto(String? photoUrl, {bool isGuarantor = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: Container(
        width: 60,
        height: 68,
        decoration: BoxDecoration(
          color: isGuarantor
              ? Colors.indigo.shade50
              : AppColors.warmTintEmerald,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isGuarantor
                ? Colors.indigo.shade400
                : AppColors.primaryEmerald,
            width: 1.4,
          ),
        ),
        child: PortableImageUi(
          pathOrUrl: photoUrl,
          fit: BoxFit.cover,
          fallbackIcon:
              isGuarantor ? Icons.shield_outlined : Icons.person_rounded,
          fallbackIconSize: 34,
          fallbackColor: isGuarantor
              ? Colors.indigo.shade700
              : AppColors.primaryEmerald,
        ),
      ),
    );
  }
  Widget _buildPersonFullRow({
    required String roleLabel,
    required String name,
    required String cnic,
    required String phone,
    required String? photoUrl,
    required bool isGuarantor,
  }) {
    final Color accentColor =
        isGuarantor ? Colors.indigo.shade800 : AppColors.primaryEmerald;
    final Color bgTint =
        isGuarantor ? const Color(0xFFF5F7FF) : AppColors.warmTintEmerald;
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: bgTint,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: isGuarantor
              ? Colors.indigo.shade200
              : AppColors.emeraldPillBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildPassportPhoto(photoUrl, isGuarantor: isGuarantor),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        roleLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        name.isNotEmpty ? name : 'درج نہیں',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'CNIC: ${cnic.isNotEmpty ? cnic : "درج نہیں"}  |  فون: $phone',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  void _openFullProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PosOrderFullProfilePage(
          order: order,
          onLoadToCounter: (updatedOrder) => onSelect(updatedOrder),
          onDismissOrder: onDismiss,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final invoice = OrderInvoiceCalculatorService.buildInvoice(order);
    final customer = order['customerName']?.toString() ?? 'نامعلوم کسٹمر';
    final cnic = order['customerCnic']?.toString() ?? '';
    final phone = order['customerPhone']?.toString() ?? '';
    final customerPhoto = order['customerPhotoUrl']?.toString();
    final guarantor = order['guarantorName']?.toString().trim() ?? '';
    final guarantorCnic = order['guarantorCnic']?.toString().trim() ?? '';
    final guarantorPhone = order['guarantorPhone']?.toString().trim() ?? '';
    final guarantorPhoto = order['guarantorPhotoUrl']?.toString();
    final bool hasGuarantor = guarantor.isNotEmpty;
    final model = order['itemName']?.toString() ?? 'موبائل';
    final hashBadge = invoice.combinedHashBadge;
    final bool isCustomOrder =
        order['isCustomEstimate'] == true || hashBadge.isEmpty;
    final bool isHighRisk = order['isRiskOverLimit'] == true ||
        order['adminOverrideApplied'] == true;
    final int netRisk = (order['netRiskAmount'] as num?)?.toInt() ?? 0;
    final int maxRisk = (order['maxRiskLimit'] as num?)?.toInt() ?? 0;
    final total = order['totalContractAmount']?.toString() ?? '0';
    final advance = order['advance']?.toString() ?? '0';
    final monthly = order['monthlyAmount']?.toString() ?? '0';
    final months = order['totalMonths']?.toString() ?? '';
    final status = (order['status']?.toString() ?? '').toUpperCase();
    final bool isCompleted = status == 'AGREEMENT_COMPLETED';
    final bool isDismissed = status == 'DISMISSED_BY_COUNTER';
    return Card(
      elevation: isCurrentlyActive ? 3 : 1.5,
      margin: const EdgeInsets.only(bottom: 10),
      color: isHighRisk
          ? const Color(0xFFFEF2F2)
          : (isCurrentlyActive
              ? AppColors.warmTintEmerald
              : AppColors.cardSurface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
        side: BorderSide(
          color: isHighRisk
              ? AppColors.errorRed
              : (isCurrentlyActive
                  ? AppColors.primaryEmerald
                  : AppColors.borderLight),
          width: (isHighRisk || isCurrentlyActive) ? 2.0 : 1.2,
        ),
      ),
      child: InkWell(
        onTap: () => _openFullProfile(context),
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (hashBadge.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.goldHighlight,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        hashBadge,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                  ],
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryEmerald,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        model,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Text(
                        '✓ مکمل',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else if (isDismissed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Text(
                        'ہٹایا گیا',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: AppColors.pendingOrange),
                      ),
                      child: Text(
                        'زیرِ التواء',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              if (isHighRisk)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.goldHighlight,
                        size: 17,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          netRisk > 0 && maxRisk > 0
                              ? '🚨 ہائی رسک انٹری (ادھار Rs. $netRisk / حد Rs. $maxRisk) — ایڈمن منظور شدہ'
                              : '🚨 ہائی رسک انٹری (رسک حد سے زائد — ایڈمن منظور شدہ)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (isCustomOrder)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: AppColors.pendingOrange),
                  ),
                  child: const Text(
                    '🛒 آن ڈیمانڈ / کسٹم آرڈر (اسٹاک خریدنا باقی)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF9A3412),
                    ),
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: AppColors.warmTintEmerald,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: AppColors.emeraldPillBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 16,
                        color: AppColors.primaryEmerald,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'محفوظ معاہدہ (${invoice.totalPieces} پیس) • مجموعی منافع: Rs. ${invoice.grandNetProfit}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryEmerald,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              _buildPersonFullRow(
                roleLabel: 'خریدار',
                name: customer,
                cnic: cnic,
                phone: phone,
                photoUrl: customerPhoto,
                isGuarantor: false,
              ),
              if (hasGuarantor) ...[
                const SizedBox(height: 6),
                _buildPersonFullRow(
                  roleLabel: 'ضامن',
                  name: guarantor,
                  cnic: guarantorCnic,
                  phone: guarantorPhone,
                  photoUrl: guarantorPhoto,
                  isGuarantor: true,
                ),
              ],
              const Divider(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'ٹوٹل: Rs. $total | ایڈوانس: Rs. $advance | قسط: Rs. $monthly × $months ماہ',
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (isHighRisk) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warmTintEmerald,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: AppColors.emeraldPillBorder),
                      ),
                      child: Text(
                        'منافع: Rs. ${invoice.grandNetProfit}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.successGreen,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openFullProfile(context),
                      icon: const Icon(Icons.receipt_long_outlined, size: 17),
                      label: const Text(
                        'بل و مکمل پروفائل',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryEmerald,
                        side: const BorderSide(
                            color: AppColors.primaryEmerald, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onSelect(order),
                      icon: const Icon(Icons.check_circle_outline, size: 17),
                      label: const Text(
                        'کاؤنٹر پر لوڈ کریں',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryEmerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
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