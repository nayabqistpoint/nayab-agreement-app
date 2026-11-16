import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_colors.dart';

class PosStockPhotoPickerUi extends StatelessWidget {
  final List<String> imagePaths;
  final ValueChanged<List<String>> onImagesChanged;

  const PosStockPhotoPickerUi({
    super.key,
    required this.imagePaths,
    required this.onImagesChanged,
  });

  Future<String?> _persistPickedFile(XFile picked) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory('${dir.path}/nayab_stock_media');
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }
      final fileName = 'stk_${DateTime.now().microsecondsSinceEpoch}.jpg';
      final saved = await File(picked.path).copy('${folder.path}/$fileName');
      return saved.path;
    } catch (_) {
      return picked.path;
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 88);
    if (files.isEmpty) return;

    final updated = List<String>.from(imagePaths);
    for (final f in files) {
      if (updated.length >= 6) break;
      final savedPath = await _persistPickedFile(f);
      if (savedPath != null && savedPath.isNotEmpty) {
        updated.add(savedPath);
      }
    }
    onImagesChanged(updated);
  }

  Future<void> _captureFromCamera(BuildContext context) async {
    if (imagePaths.length >= 6) return;
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 88,
    );
    if (photo == null) return;

    final savedPath = await _persistPickedFile(photo);
    if (savedPath != null && savedPath.isNotEmpty) {
      final updated = List<String>.from(imagePaths)..add(savedPath);
      onImagesChanged(updated);
    }
  }

  void _removeAt(int index) {
    final updated = List<String>.from(imagePaths)..removeAt(index);
    onImagesChanged(updated);
  }

  Widget _buildImagePreview(String pathOrUrl) {
    final isNetwork =
        pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://');
    if (isNetwork) {
      return Image.network(
        pathOrUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const Icon(
          Icons.broken_image_outlined,
          color: Colors.grey,
        ),
      );
    }
    final file = File(pathOrUrl);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }
    return const Icon(Icons.image_not_supported_outlined, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF94A3B8), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.photo_camera_back_outlined,
                color: AppColors.primaryEmerald,
                size: 20,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'موبائل کی HD تصاویر (${imagePaths.length}/6)',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed:
                    imagePaths.length >= 6 ? null : () => _captureFromCamera(context),
                icon: const Icon(Icons.camera_alt_outlined, size: 16),
                label: const Text('کیمرہ', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryEmerald,
                  side: const BorderSide(color: AppColors.primaryEmerald),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton.icon(
                onPressed:
                    imagePaths.length >= 6 ? null : () => _pickFromGallery(context),
                icon: const Icon(Icons.photo_library_outlined, size: 16),
                label: const Text('گیلری', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryEmerald,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (imagePaths.isEmpty)
            InkWell(
              onTap: () => _pickFromGallery(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primaryEmerald.withAlpha(90),
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      color: AppColors.primaryEmerald,
                      size: 24,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'فرنٹ، بیک اور ڈبے کی تصاویر شامل کریں (POS ایپ پر HD نظر آئیں گی)',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: imagePaths.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final path = imagePaths[index];
                  final isUploaded = path.startsWith('http');
                  return Stack(
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isUploaded
                                ? AppColors.successGreen
                                : Colors.amber.shade700,
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6.5),
                          child: _buildImagePreview(path),
                        ),
                      ),
                      if (index == 0)
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryEmerald,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'مین',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 2,
                        left: 2,
                        child: GestureDetector(
                          onTap: () => _removeAt(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 13,
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
      ),
    );
  }
}