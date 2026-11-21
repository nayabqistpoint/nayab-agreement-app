import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/portable_image_ui.dart';
import '../pos_order_full_profile_page.dart';
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
        width: 64,
        height: 74,
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
          fallbackIconSize: 36,
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgTint,
        borderRadius: BorderRadius.circular(10),
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
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        roleLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name.isNotEmpty ? name : 'درج نہیں',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'CNIC: ${cnic.isNotEmpty ? cnic : "درج نہیں"}  |  فون: $phone',
                  style: TextStyle(
                    fontSize: 13,
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
    final stockId = order['stockId']?.toString().trim() ?? '';
    final bool isCustomOrder =
        order['isCustomEstimate'] == true || stockId.isEmpty;
    final total = order['totalContractAmount']?.toString() ?? '0';
    final advance = order['advance']?.toString() ?? '0';
    final monthly = order['monthlyAmount']?.toString() ?? '0';
    final months = order['totalMonths']?.toString() ?? '';
    final status = (order['status']?.toString() ?? '').toUpperCase();
    final bool isCompleted = status == 'AGREEMENT_COMPLETED';
    final bool isDismissed = status == 'DISMISSED_BY_COUNTER';

    return Card(
      elevation: isCurrentlyActive ? 3 : 1.5,
      margin: const EdgeInsets.only(bottom: 12),
      color: isCurrentlyActive
          ? AppColors.warmTintEmerald
          : AppColors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isCurrentlyActive
              ? AppColors.primaryEmerald
              : AppColors.borderLight,
          width: isCurrentlyActive ? 2.2 : 1.2,
        ),
      ),
      child: InkWell(
        onTap: () => _openFullProfile(context),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryEmerald,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        stockId.isNotEmpty ? '$model ($stockId)' : model,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        'مکمل شدہ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.green.shade900,
                        ),
                      ),
                    )
                  else if (isDismissed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Text(
                        'ہٹایا گیا',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.black54,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: AppColors.pendingOrange),
                      ),
                      child: Text(
                        'زیرِ التواء',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                ],
              ),
              if (isCustomOrder) ...[
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(6),
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
                ),
              ],
              const SizedBox(height: 9),
              _buildPersonFullRow(
                roleLabel: 'خریدار',
                name: customer,
                cnic: cnic,
                phone: phone,
                photoUrl: customerPhoto,
                isGuarantor: false,
              ),
              if (hasGuarantor) ...[
                const SizedBox(height: 7),
                _buildPersonFullRow(
                  roleLabel: 'ضامن',
                  name: guarantor,
                  cnic: guarantorCnic,
                  phone: guarantorPhone,
                  photoUrl: guarantorPhoto,
                  isGuarantor: true,
                ),
              ],
              const Divider(height: 16),
              Text(
                'ٹوٹل: Rs. $total  |  ایڈوانس: Rs. $advance  |  قسط: Rs. $monthly × $months ماہ',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openFullProfile(context),
                      icon: const Icon(Icons.visibility_outlined, size: 17),
                      label: const Text(
                        'مکمل پروفائل و تصویر',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryEmerald,
                        side: const BorderSide(
                            color: AppColors.primaryEmerald, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 9),
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
                        padding: const EdgeInsets.symmetric(vertical: 9),
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