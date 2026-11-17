import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/portable_image_ui.dart';
import '../pos_remote_controller.dart';

class StoreBrandingConfigUi extends StatelessWidget {
  final PosRemoteController controller;
  const StoreBrandingConfigUi({super.key, required this.controller});

  Future<void> _pickImage(
    ImageSource source,
    ValueChanged<String> onPicked,
  ) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (file == null) return;
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        onPicked('data:image/jpeg;base64,${base64Encode(bytes)}');
      } else {
        onPicked(file.path);
      }
    } catch (_) {}
  }

  Widget _imagePickerCard({
    required String title,
    required String subtitle,
    required String currentUrl,
    required bool isVisible,
    required ValueChanged<bool> onToggleVisible,
    required ValueChanged<String> onUrlChanged,
    required VoidCallback onClear,
    required IconData fallbackIcon,
    required bool isPassport,
  }) {
    final hasImg = currentUrl.trim().isNotEmpty && currentUrl != 'null';
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(isPassport ? 8 : 10),
                child: Container(
                  width: isPassport ? 54 : 58,
                  height: isPassport ? 64 : 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    border: Border.all(
                      color: AppColors.primaryEmerald,
                      width: 1.3,
                    ),
                    borderRadius: BorderRadius.circular(isPassport ? 8 : 10),
                  ),
                  child: PortableImageUi(
                    pathOrUrl: currentUrl,
                    fit: BoxFit.cover,
                    fallbackIcon: fallbackIcon,
                    fallbackIconSize: 28,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () =>
                              _pickImage(ImageSource.gallery, onUrlChanged),
                          icon: const Icon(Icons.photo_library_outlined,
                              size: 14),
                          label: const Text('گیلری',
                              style: TextStyle(fontSize: 11.5)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryEmerald,
                            foregroundColor: Colors.white,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              _pickImage(ImageSource.camera, onUrlChanged),
                          icon: const Icon(Icons.camera_alt_outlined, size: 14),
                          label: const Text('کیمرہ',
                              style: TextStyle(fontSize: 11.5)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryEmerald,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        if (hasImg)
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                size: 18, color: AppColors.errorRed),
                            tooltip: 'تصویر ہٹائیں',
                            visualDensity: VisualDensity.compact,
                            onPressed: onClear,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text(
              'POS اسکرین پر یہ تصویر دکھائیں',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            value: isVisible,
            activeTrackColor: AppColors.primaryEmerald,
            onChanged: onToggleVisible,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF94A3B8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'دکان کا نام و عنوان (POS ایپ بار):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller.shopNameCtrl,
                textAlign: TextAlign.right,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'دکان کا مرکزی نام',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller.shopSubtitleCtrl,
                textAlign: TextAlign.right,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'ذیلی عنوان / شہر (مثلاً قائم پور / آسان اقساط)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _imagePickerCard(
          title: 'دکان کا لوگو (Shop Logo)',
          subtitle: 'POS ایپ بار کے دائیں کونے میں ظاہر ہوگا',
          currentUrl: controller.shopLogoUrl,
          isVisible: controller.showShopLogo,
          onToggleVisible: controller.setShowShopLogo,
          onUrlChanged: controller.setShopLogoUrl,
          onClear: () => controller.setShopLogoUrl(''),
          fallbackIcon: Icons.storefront_rounded,
          isPassport: false,
        ),
        const SizedBox(height: 10),
        _imagePickerCard(
          title: 'مالک کی پاسپورٹ سائز تصویر (Owner Photo)',
          subtitle: 'POS ایپ بار میں آپ کی شناختی تصویر کے طور پر نظر آئے گی',
          currentUrl: controller.ownerPhotoUrl,
          isVisible: controller.showOwnerPhoto,
          onToggleVisible: controller.setShowOwnerPhoto,
          onUrlChanged: controller.setOwnerPhotoUrl,
          onClear: () => controller.setOwnerPhotoUrl(''),
          fallbackIcon: Icons.person_rounded,
          isPassport: true,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade700, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'لائیو چلنے والی نیوز ٹِکر پٹی (Ticker Bar) آن رکھیں',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                value: controller.tickerEnabled,
                activeTrackColor: AppColors.primaryEmerald,
                onChanged: controller.setTickerEnabled,
              ),
              TextField(
                controller: controller.tickerTextCtrl,
                textAlign: TextAlign.right,
                maxLines: 2,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'ٹِکر پٹی پر چلنے والا پیغام / اشتہار',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF94A3B8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'POS مارکیٹ لسٹ میں آئٹمز کی نمائش کا کنٹرول:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  '📦 آرڈر پر دستیاب (On-Order) آئٹمز دکھائیں',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                value: controller.showOnOrderItems,
                activeTrackColor: AppColors.primaryEmerald,
                onChanged: controller.setShowOnOrderItems,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  '🔒 بُک شدہ (Reserved) آئٹمز مع منتخب پیکج دکھائیں',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                value: controller.showReservedItems,
                activeTrackColor: AppColors.primaryEmerald,
                onChanged: controller.setShowReservedItems,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  '✅ فروخت شدہ (Sold) آئٹمز مع فروخت شدہ پیکج دکھائیں',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                value: controller.showSoldItems,
                activeTrackColor: AppColors.primaryEmerald,
                onChanged: controller.setShowSoldItems,
              ),
            ],
          ),
        ),
      ],
    );
  }
}