import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';

class CounterDeliveryModalUi extends StatelessWidget {
  final String dealId;
  final String customerName;
  final List<String> deliveryPhotoPaths;
  final List<String> signedDocPhotoPaths;
  final ValueChanged<List<String>> onDeliveryPhotosChanged;
  final ValueChanged<List<String>> onSignedDocPhotosChanged;
  final VoidCallback onDone;

  const CounterDeliveryModalUi({
    super.key,
    required this.dealId,
    required this.customerName,
    required this.deliveryPhotoPaths,
    required this.signedDocPhotoPaths,
    required this.onDeliveryPhotosChanged,
    required this.onSignedDocPhotosChanged,
    required this.onDone,
  });

  Future<void> _addPhoto({
    required List<String> currentList,
    required ValueChanged<List<String>> onChanged,
    required ImageSource source,
  }) async {
    if (currentList.length >= 6) return;
    try {
      final picker = ImagePicker();
      if (source == ImageSource.gallery) {
        final files = await picker.pickMultiImage(imageQuality: 85);
        if (files.isEmpty) return;
        final updated = List<String>.from(currentList);
        for (final f in files) {
          if (updated.length >= 6) break;
          if (kIsWeb) {
            final bytes = await f.readAsBytes();
            updated.add('data:image/jpeg;base64,${base64Encode(bytes)}');
          } else {
            updated.add(f.path);
          }
        }
        onChanged(updated);
      } else {
        final photo = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
        if (photo == null) return;
        final updated = List<String>.from(currentList);
        if (kIsWeb) {
          final bytes = await photo.readAsBytes();
          updated.add('data:image/jpeg;base64,${base64Encode(bytes)}');
        } else {
          updated.add(photo.path);
        }
        onChanged(updated);
      }
    } catch (_) {}
  }

  Widget _buildImageContent(String path) {
    if (path.startsWith('data:image')) {
      try {
        final commaIdx = path.indexOf(',');
        final bytes = base64Decode(path.substring(commaIdx + 1));
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        return const Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.red),
        );
      }
    }
    return Image.network(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const Center(
        child: Icon(
          Icons.check_circle,
          color: AppColors.successGreen,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildMultiPhotoSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<String> photos,
    required ValueChanged<List<String>> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: photos.isNotEmpty
              ? AppColors.successGreen
              : Colors.grey.shade300,
          width: photos.isNotEmpty ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 19, color: AppColors.primaryEmerald),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$title (${photos.length}/6)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: photos.length >= 6
                    ? null
                    : () => _addPhoto(
                          currentList: photos,
                          onChanged: onChanged,
                          source: ImageSource.camera,
                        ),
                icon: const Icon(Icons.camera_alt_outlined, size: 15),
                label: const Text('کیمرہ', style: TextStyle(fontSize: 11.5)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryEmerald,
                  side: const BorderSide(color: AppColors.primaryEmerald),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 5),
              ElevatedButton.icon(
                onPressed: photos.length >= 6
                    ? null
                    : () => _addPhoto(
                          currentList: photos,
                          onChanged: onChanged,
                          source: ImageSource.gallery,
                        ),
                icon: const Icon(Icons.photo_library_outlined, size: 15),
                label: const Text('گیلری', style: TextStyle(fontSize: 11.5)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryEmerald,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          if (photos.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 78,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (ctx, idx) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 74,
                          height: 74,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primaryEmerald,
                              width: 1.2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _buildImageContent(photos[idx]),
                        ),
                      ),
                      Positioned(
                        top: 2,
                        left: 2,
                        child: GestureDetector(
                          onTap: () {
                            final updated = List<String>.from(photos)
                              ..removeAt(idx);
                            onChanged(updated);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    color: AppColors.successGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'موبائل حوالگی لاگ: $customerName',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'معاہدہ پرنٹ ہونے کے بعد گاہک کی موبائل وصولی اور سائن شدہ اسٹامپ پیپر کے تمام صفحات کی تصاویر شامل کر کے محفوظ کریں:',
                style: TextStyle(fontSize: 12.5, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              _buildMultiPhotoSection(
                title: 'موبائل وصولی تصاویر',
                subtitle: 'موبائل باکس اور گاہک کی وصولی فوٹوز (1 سے 6)',
                icon: Icons.camera_alt_outlined,
                photos: deliveryPhotoPaths,
                onChanged: onDeliveryPhotosChanged,
              ),
              const SizedBox(height: 10),
              _buildMultiPhotoSection(
                title: 'سائن شدہ اسٹامپ و دستاویزات',
                subtitle: 'اسٹامپ پیپر کے تمام صفحات الگ الگ کھینچیں (1 سے 6)',
                icon: Icons.document_scanner_outlined,
                photos: signedDocPhotoPaths,
                onChanged: onSignedDocPhotosChanged,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryEmerald,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'مکمل اور محفوظ کریں',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}