import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../../core/models/customer_profile_model.dart';
import '../../../core/network/connectivity_service.dart';
import '../../../core/services/cloudinary_storage_service.dart';
import '../../../core/time/time_status_service.dart';
import '../../../core/widgets/portable_image_ui.dart';
import 'customer_media_viewer_modal_ui.dart';

class CustomerDetailHeaderUi extends StatelessWidget {
  final CustomerProfileModel customer;
  const CustomerDetailHeaderUi({super.key, required this.customer});

  Future<void> _updateCustomerPhoto(
      BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (file == null) return;
      String localOrData;
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        localOrData = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      } else {
        localOrData = file.path;
      }
      String finalUrl = localOrData;
      if (await ConnectivityService.isOnline) {
        final cleanCnic = customer.cnic.replaceAll(RegExp(r'[^0-9]'), '');
        final uploaded = await CloudinaryStorageService.uploadImageFile(
          filePath: localOrData,
          subFolder:
              'customers/${cleanCnic.isEmpty ? customer.id : cleanCnic}/profile',
          customPublicId: 'profile_${DateTime.now().millisecondsSinceEpoch}',
        );
        if (uploaded != null) {
          finalUrl = uploaded;
        }
      }
      final box = HiveBoxManager.getBox(BoxNames.customersBox);
      final raw = box.get(customer.id);
      if (raw is Map) {
        final map = Map<String, dynamic>.from(raw);
        map['photoUrl'] = finalUrl;
        map['isSynced'] = false;
        map['updatedAt'] = TimeStatusService.nowUtcIso();
        await HiveBoxManager.putBatch(
          boxName: BoxNames.customersBox,
          entries: {customer.id: map},
        );
      }
    } catch (_) {}
  }

  void _showPhotoOptions(BuildContext context, String? currentUrl) {
    final hasImg = currentUrl != null &&
        currentUrl.trim().isNotEmpty &&
        currentUrl.trim() != 'null';
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasImg)
                ListTile(
                  leading: const Icon(Icons.zoom_in_rounded,
                      color: AppColors.primaryEmerald),
                  title: const Text('تصویر فل اسکرین زوم کر کے دیکھیں',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(ctx);
                    CustomerMediaViewerModalUi.show(
                      context,
                      title: customer.fullName,
                      imagePath: currentUrl.trim(),
                    );
                  },
                ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined,
                    color: AppColors.primaryEmerald),
                title: const Text('کیمرہ سے نئی تصویر لیں',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(ctx);
                  _updateCustomerPhoto(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: AppColors.primaryEmerald),
                title: const Text('گیلری سے تصویر منتخب کریں',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(ctx);
                  _updateCustomerPhoto(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isGuarantor = customer.role.startsWith('ضامن');
    final url = customer.photoUrl?.trim() ?? '';
    final bool hasImg = url.isNotEmpty && url != 'null';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Upper Half بڑی واضح تصویر والا ہیڈر
        GestureDetector(
          onTap: () => _showPhotoOptions(context, customer.photoUrl),
          child: Container(
            height: 270,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isGuarantor
                    ? Colors.indigo.shade400
                    : AppColors.primaryEmerald,
                width: 2.0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PortableImageUi(
                    pathOrUrl: url,
                    fit: BoxFit.contain,
                    fallbackIcon: isGuarantor
                        ? Icons.shield_outlined
                        : Icons.person_rounded,
                    fallbackIconSize: 95,
                    fallbackColor: Colors.white54,
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryEmerald,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 1.2),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt_rounded,
                              size: 16, color: Colors.white),
                          SizedBox(width: 5),
                          Text(
                            'تصویر تبدیل / زوم',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!hasImg)
                    const Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          'تصویر لگانے کے لیے یہاں کلک کریں',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      customer.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isGuarantor
                          ? Colors.indigo.shade50
                          : AppColors.warmTintEmerald,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      customer.role,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: isGuarantor
                            ? Colors.indigo.shade800
                            : AppColors.primaryEmerald,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'ولدیت: ${customer.fatherName.isNotEmpty ? customer.fatherName : "درج نہیں"}',
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'CNIC: ${customer.cnic}  |  فون: ${customer.phone}',
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryEmerald,
                ),
              ),
              const Divider(height: 16),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 19, color: AppColors.primaryEmerald),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'پتہ: ${customer.address.isNotEmpty ? customer.address : "کوئی پتہ درج نہیں"}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}