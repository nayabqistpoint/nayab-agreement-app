import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryStorageService {
  static const String cloudName = 'snioixz8';
  static const String uploadPreset = 'nayab_unsigned';
  static const String rootFolder = 'nayab_qist_point';

  static Uri get _uploadUri =>
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

  /// کسی بھی پلیٹ فارم (Web / Android / Windows) سے تصویر کے بائٹس اپلوڈ کرنا
  static Future<String?> uploadImageBytes({
    required Uint8List bytes,
    required String fileName,
    required String subFolder,
    String? customPublicId,
  }) async {
    if (bytes.isEmpty) return null;
    try {
      final fullFolder = '$rootFolder/$subFolder';
      final request = http.MultipartRequest('POST', _uploadUri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = fullFolder;

      if (customPublicId != null && customPublicId.trim().isNotEmpty) {
        request.fields['public_id'] = customPublicId.trim();
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName.isNotEmpty ? fileName : 'photo.jpg',
        ),
      );

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 30));
      final responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode >= 200 &&
          streamedResponse.statusCode < 300) {
        final decoded = jsonDecode(responseBody);
        if (decoded is Map && decoded['secure_url'] != null) {
          final secureUrl = decoded['secure_url'].toString();
          debugPrint('☁️ Cloudinary اپلوڈ کامیاب [$fullFolder]: $secureUrl');
          return secureUrl;
        }
      } else {
        debugPrint(
          '❌ Cloudinary اپلوڈ ناکام (${streamedResponse.statusCode}): $responseBody',
        );
      }
    } catch (e) {
      debugPrint('❌ Cloudinary Upload Exception: $e');
    }
    return null;
  }

  /// پاتھ، blob URL، یا data:image URL سے بائٹس پڑھ کر Cloudinary پر اپلوڈ کرنا
  static Future<String?> uploadImageFile({
    required String filePath,
    required String subFolder,
    String? customPublicId,
  }) async {
    final cleanPath = filePath.trim();
    if (cleanPath.isEmpty) return null;
    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      return cleanPath;
    }

    try {
      Uint8List bytes;
      String fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';

      if (cleanPath.startsWith('data:image')) {
        final commaIndex = cleanPath.indexOf(',');
        if (commaIndex == -1) return null;
        bytes = base64Decode(cleanPath.substring(commaIndex + 1));
      } else {
        final xFile = XFile(cleanPath);
        bytes = await xFile.readAsBytes();
        if (xFile.name.isNotEmpty) {
          fileName = xFile.name;
        }
      }

      return await uploadImageBytes(
        bytes: bytes,
        fileName: fileName,
        subFolder: subFolder,
        customPublicId: customPublicId,
      );
    } catch (e) {
      debugPrint('❌ Image Read Error: $e');
      return null;
    }
  }

  /// اسٹاک موبائل کی تصاویر اپلوڈ کرنا: nayab_qist_point/stock_devices/{stockId}
  static Future<List<String>> uploadStockImages({
    required String stockId,
    required List<String> pathsOrUrls,
  }) async {
    final List<String> finalUrls = [];
    final cleanId = stockId.trim().isEmpty ? 'general_stock' : stockId.trim();
    for (int i = 0; i < pathsOrUrls.length; i++) {
      final path = pathsOrUrls[i].trim();
      if (path.isEmpty) continue;
      if (path.startsWith('http://') || path.startsWith('https://')) {
        finalUrls.add(path);
        continue;
      }
      final uploaded = await uploadImageFile(
        filePath: path,
        subFolder: 'stock_devices/$cleanId',
        customPublicId: 'photo_${i + 1}_${DateTime.now().millisecondsSinceEpoch}',
      );
      if (uploaded != null) {
        finalUrls.add(uploaded);
      } else {
        finalUrls.add(path);
      }
    }
    return finalUrls;
  }

  /// کسٹمر کی ڈیل تصاویر اپلوڈ کرنا: nayab_qist_point/customers/{cnic}/deals/{dealId}
  static Future<String?> uploadCustomerDealPhoto({
    required String customerCnic,
    required String dealId,
    required String filePath,
    required String photoType,
  }) async {
    final cleanCnic = customerCnic.replaceAll(RegExp(r'[^0-9]'), '');
    final folderCnic = cleanCnic.isEmpty ? 'unknown_cnic' : cleanCnic;
    return uploadImageFile(
      filePath: filePath,
      subFolder: 'customers/$folderCnic/deals/$dealId',
      customPublicId: '${photoType}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}