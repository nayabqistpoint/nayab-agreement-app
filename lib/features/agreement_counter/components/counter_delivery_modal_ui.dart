import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CounterDeliveryModalUi extends StatelessWidget {
  final String dealId;
  final String customerName;
  final String? deliveryPhotoPath;
  final String? signedDocPhotoPath;
  final VoidCallback onCaptureDeliveryPhoto;
  final VoidCallback onCaptureSignedDocPhoto;
  final VoidCallback onDone;

  const CounterDeliveryModalUi({
    super.key,
    required this.dealId,
    required this.customerName,
    required this.deliveryPhotoPath,
    required this.signedDocPhotoPath,
    required this.onCaptureDeliveryPhoto,
    required this.onCaptureSignedDocPhoto,
    required this.onDone,
  });

  static Future<void> show({
    required BuildContext context,
    required String dealId,
    required String customerName,
    required String? deliveryPhotoPath,
    required String? signedDocPhotoPath,
    required VoidCallback onCaptureDeliveryPhoto,
    required VoidCallback onCaptureSignedDocPhoto,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      builder: (_) => CounterDeliveryModalUi(
        dealId: dealId,
        customerName: customerName,
        deliveryPhotoPath: deliveryPhotoPath,
        signedDocPhotoPath: signedDocPhotoPath,
        onCaptureDeliveryPhoto: onCaptureDeliveryPhoto,
        onCaptureSignedDocPhoto: onCaptureSignedDocPhoto,
        onDone: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildMediaBox({
    required String title,
    required IconData icon,
    required String? path,
    required VoidCallback onCapture,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onCapture,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 125,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: path != null ? AppColors.successGreen : Colors.grey.shade300,
              width: path != null ? 2 : 1,
            ),
          ),
          child: path != null && File(path).existsSync()
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.file(File(path), fit: BoxFit.cover),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 30, color: AppColors.primaryEmerald),
                    const SizedBox(height: 6),
                    Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('تصویر بنائیں', style: TextStyle(fontSize: 10, color: Colors.black54)),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_user_outlined, color: AppColors.successGreen, size: 24),
                const SizedBox(width: 8),
                Text(
                  'موبائل حوالگی لاگ: $customerName',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'معاہدہ کامیابی سے پرنٹ ہو گیا ہے۔ اب گاہک کی موبائل وصولی اور سائن شدہ دستاویز محفوظ فرمائیں:',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildMediaBox(
                  title: 'موبائل وصولی تصویر',
                  icon: Icons.camera_alt_outlined,
                  path: deliveryPhotoPath,
                  onCapture: onCaptureDeliveryPhoto,
                ),
                const SizedBox(width: 12),
                _buildMediaBox(
                  title: 'سائن شدہ دستاویز',
                  icon: Icons.document_scanner_outlined,
                  path: signedDocPhotoPath,
                  onCapture: onCaptureSignedDocPhoto,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryEmerald,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('مکمل اور محفوظ کریں', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }
}