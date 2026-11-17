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
          subFolder: 'customers/${cleanCnic.isEmpty ? customer.id : cleanCnic}/profile',
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
                  title: const Text('تصویر بڑی کر کے دیکھیں'),
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
                title: const Text('کیمرہ سے نئی تصویر لیں'),
                onTap: () {
                  Navigator.pop(ctx);
                  _updateCustomerPhoto(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: AppColors.primaryEmerald),
                title: const Text('گیلری سے تصویر منتخب کریں'),
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

  Widget _buildPassportCard(BuildContext context, bool isGuarantor) {
    final url = customer.photoUrl?.trim() ?? '';
    final bool hasImg = url.isNotEmpty && url != 'null';
    Widget imgWidget;

    if (hasImg && url.startsWith('data:image')) {
      try {
        final commaIdx = url.indexOf(',');
        final bytes = base64Decode(url.substring(commaIdx + 1));
        imgWidget = Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        imgWidget = Icon(
          isGuarantor ? Icons.shield_outlined : Icons.person,
          color: isGuarantor
              ? Colors.indigo.shade700
              : AppColors.primaryEmerald,
          size: 36,
        );
      }
    } else if (hasImg) {
      imgWidget = Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(
          isGuarantor ? Icons.shield_outlined : Icons.person,
          color: isGuarantor
              ? Colors.indigo.shade700
              : AppColors.primaryEmerald,
          size: 36,
        ),
      );
    } else {
      imgWidget = Icon(
        isGuarantor ? Icons.shield_outlined : Icons.person,
        color: isGuarantor
            ? Colors.indigo.shade700
            : AppColors.primaryEmerald,
        size: 36,
      );
    }

    return InkWell(
      onTap: () => _showPhotoOptions(context, customer.photoUrl),
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 66,
              height: 76,
              decoration: BoxDecoration(
                color: isGuarantor
                    ? Colors.indigo.shade50
                    : AppColors.primaryEmerald.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primaryEmerald,
                  width: 1.5,
                ),
              ),
              child: imgWidget,
            ),
          ),
          Positioned(
            bottom: 2,
            left: 2,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.primaryEmerald,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 11,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isGuarantor = customer.role.startsWith('ضامن');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              _buildPassportCard(context, isGuarantor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            customer.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isGuarantor
                                ? Colors.indigo.shade50
                                : Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            customer.role,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isGuarantor
                                  ? Colors.indigo.shade800
                                  : AppColors.primaryEmerald,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ولدیت: ${customer.fatherName.isNotEmpty ? customer.fatherName : "درج نہیں"}',
                      style:
                          const TextStyle(fontSize: 12.5, color: Colors.black54),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'CNIC: ${customer.cnic}  |  فون: ${customer.phone}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryEmerald,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 17, color: Colors.black54),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'پتہ: ${customer.address.isNotEmpty ? customer.address : "کوئی پتہ درج نہیں"}',
                  style: const TextStyle(fontSize: 12.5, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}