import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class CounterMediaPickerService {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> capturePhoto({required String prefixName}) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo == null) return null;

      final dir = await getApplicationDocumentsDirectory();
      final targetFolder = Directory('${dir.path}/nayab_media');
      if (!await targetFolder.exists()) {
        await targetFolder.create(recursive: true);
      }

      final fileName = '${prefixName}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = await File(photo.path).copy('${targetFolder.path}/$fileName');
      return savedFile.path;
    } catch (_) {
      return null;
    }
  }
}