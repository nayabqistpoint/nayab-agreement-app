import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class CounterMediaPickerService {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> capturePhoto({required String prefixName}) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo == null) return null;
      if (kIsWeb) {
        final bytes = await photo.readAsBytes();
        return 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }
      return photo.path;
    } catch (_) {
      return null;
    }
  }
}