import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/customer_deal_model.dart';
import 'customer_media_viewer_modal_ui.dart';

class CustomerDealCardUi extends StatelessWidget {
  final CustomerDealModel deal;
  final VoidCallback onLoadIntoBucket;
  final VoidCallback onGenerateNotice;
  final VoidCallback onDeleteDeal;

  const CustomerDealCardUi({
    super.key,
    required this.deal,
    required this.onLoadIntoBucket,
    required this.onGenerateNotice,
    required this.onDeleteDeal,
  });

  Widget _buildMediaThumbnail(
    BuildContext context, {
    required String title,
    required String? path,
  }) {
    if (path == null || !File(path).existsSync()) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: InkWell(
        onTap: () => CustomerMediaViewerModalUi.show(
          context,
          title: title,
          imagePath: path,
        ),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.primaryEmerald.withAlpha(100)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.image_outlined,
                  size: 14, color: AppColors.primaryEmerald),
              const SizedBox(width: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryEmerald,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = deal.createdAt.split('T').first;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  deal.mobileModel.isNotEmpty
                      ? deal.mobileModel
                      : 'موبائل قسط ڈیل',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  date,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    size: 18, color: Colors.red.shade600),
                tooltip: 'یہ معاہدہ حذف کریں',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onDeleteDeal,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'IMEI نمبر: ${deal.imei.isNotEmpty ? deal.imei : "درج نہیں"}',
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(
                'کل رقم: ${deal.totalAmount} روپے',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                'پیشگی: ${deal.advancePayment} روپے',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.successGreen),
              ),
              Text(
                'ماہانہ قسط: ${deal.monthlyInstallment} روپے',
                style: const TextStyle(fontSize: 12, color: Colors.redAccent),
              ),
            ],
          ),
          const Divider(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMediaThumbnail(
                    context,
                    title: 'موبائل وصولی فوٹو',
                    path: deal.deliveryPhotoPath,
                  ),
                  _buildMediaThumbnail(
                    context,
                    title: 'سائن شدہ اسٹامپ',
                    path: deal.signedDocPhotoPath,
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: onLoadIntoBucket,
                    icon: const Icon(Icons.upload_file_rounded, size: 15),
                    label: const Text(
                      'کاؤنٹر پر لوڈ کریں',
                      style:
                          TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryEmerald,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton.icon(
                    onPressed: onGenerateNotice,
                    icon: const Icon(Icons.gavel_rounded, size: 15),
                    label: const Text(
                      'قانونی نوٹس',
                      style:
                          TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade900,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}