import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../services/pos_pending_orders_service.dart';

class PosPendingOrderCardUi extends StatelessWidget {
  final PosOrderRecord order;
  final bool isCurrentlyActive;
  final VoidCallback onSelect;
  final VoidCallback onDismiss;

  const PosPendingOrderCardUi({
    super.key,
    required this.order,
    required this.isCurrentlyActive,
    required this.onSelect,
    required this.onDismiss,
  });

  Widget _buildPassportPhoto(String? photoUrl, {bool isGuarantor = false}) {
    final clean = photoUrl?.trim() ?? '';
    final bool hasImg = clean.isNotEmpty && clean != 'null';
    Widget imgWidget;

    if (hasImg && clean.startsWith('data:image')) {
      try {
        final commaIdx = clean.indexOf(',');
        final bytes = base64Decode(clean.substring(commaIdx + 1));
        imgWidget = Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        imgWidget = Icon(
          isGuarantor ? Icons.shield_outlined : Icons.person_rounded,
          color: isGuarantor
              ? Colors.indigo.shade700
              : AppColors.primaryEmerald,
          size: 34,
        );
      }
    } else if (hasImg) {
      imgWidget = Image.network(
        clean,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(
          isGuarantor ? Icons.shield_outlined : Icons.person_rounded,
          color: isGuarantor
              ? Colors.indigo.shade700
              : AppColors.primaryEmerald,
          size: 34,
        ),
      );
    } else {
      imgWidget = Icon(
        isGuarantor ? Icons.shield_outlined : Icons.person_rounded,
        color: isGuarantor
            ? Colors.indigo.shade700
            : AppColors.primaryEmerald,
        size: 34,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 58,
        height: 66,
        decoration: BoxDecoration(
          color: isGuarantor
              ? Colors.indigo.shade50
              : AppColors.primaryEmerald.withAlpha(22),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isGuarantor
                ? Colors.indigo.shade300
                : AppColors.primaryEmerald,
            width: 1.4,
          ),
        ),
        child: imgWidget,
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
        isGuarantor ? const Color(0xFFF5F7FF) : const Color(0xFFF3FBF8);

    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: bgTint,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isGuarantor
              ? Colors.indigo.shade200
              : AppColors.primaryEmerald.withAlpha(90),
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
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        roleLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
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
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'شناختی کارڈ: ${cnic.isNotEmpty ? cnic : "درج نہیں"}  |  فون: $phone',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
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
          ? AppColors.primaryEmerald.withAlpha(16)
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isCurrentlyActive
              ? AppColors.primaryEmerald
              : const Color(0xFFCBD5E1),
          width: isCurrentlyActive ? 2.2 : 1.2,
        ),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryEmerald,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      stockId.isNotEmpty ? '$model ($stockId)' : model,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isCurrentlyActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade700,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.white, size: 15),
                          SizedBox(width: 4),
                          Text(
                            'منتخب شدہ',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade600),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified,
                              color: Colors.green.shade800, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'مکمل شدہ',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (isDismissed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'ہٹایا گیا',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
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
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.orange.shade600),
                      ),
                      child: Text(
                        'زیرِ التواء',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  if (!isCompleted && !isDismissed) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade600,
                        size: 22,
                      ),
                      tooltip: 'پینڈنگ لسٹ سے ختم کریں',
                      visualDensity: VisualDensity.compact,
                      onPressed: onDismiss,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              _buildPersonFullRow(
                roleLabel: 'خریدار',
                name: customer,
                cnic: cnic,
                phone: phone,
                photoUrl: customerPhoto,
                isGuarantor: false,
              ),
              if (hasGuarantor) ...[
                const SizedBox(height: 8),
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
                  fontSize: 13.5,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}