import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class CloudinaryStorageService {
  static const String cloudName = 'snioixz8';
  static const String uploadPreset = 'nayab_unsigned';
  static const String rootFolder = 'nayab_qist_point';

  static Uri get _uploadUri =>
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

  /// کسی بھی لوکل تصویر کو Cloudinary کے مخصوص فولڈر میں اپلوڈ کرنا
  static Future<String?> uploadImageFile({
    required String filePath,
    required String subFolder,
    String? customPublicId,
  }) async {
    if (filePath.trim().isEmpty) return null;
    if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
      return filePath;
    }

    final file = File(filePath);
    if (!await file.exists()) return null;

    try {
      final bytes = await file.readAsBytes();
      final fileName = file.uri.pathSegments.isNotEmpty
          ? file.uri.pathSegments.last
          : 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final boundary =
          '----NayabBoundary${DateTime.now().microsecondsSinceEpoch}';
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 25);

      final request = await client.postUrl(_uploadUri);
      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'multipart/form-data; boundary=$boundary',
      );

      final fullFolder = '$rootFolder/$subFolder';

      void writeField(String name, String value) {
        request.add(utf8.encode('--$boundary\r\n'));
        request.add(
          utf8.encode('Content-Disposition: form-data; name="$name"\r\n\r\n'),
        );
        request.add(utf8.encode('$value\r\n'));
      }

      writeField('upload_preset', uploadPreset);
      writeField('folder', fullFolder);
      if (customPublicId != null && customPublicId.trim().isNotEmpty) {
        writeField('public_id', customPublicId.trim());
      }

      request.add(utf8.encode('--$boundary\r\n'));
      request.add(
        utf8.encode(
          'Content-Disposition: form-data; name="file"; filename="$fileName"\r\n',
        ),
      );
      request.add(utf8.encode('Content-Type: image/jpeg\r\n\r\n'));
      request.add(bytes);
      request.add(utf8.encode('\r\n--$boundary--\r\n'));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(responseBody);
        if (decoded is Map && decoded['secure_url'] != null) {
          final secureUrl = decoded['secure_url'].toString();
          debugPrint('☁️ Cloudinary اپلوڈ کامیاب [$fullFolder]: $secureUrl');
          return secureUrl;
        }
      } else {
        debugPrint(
          '❌ Cloudinary اپلوڈ ناکام (${response.statusCode}): $responseBody',
        );
      }
    } catch (e) {
      debugPrint('❌ Cloudinary Exception: $e');
    }
    return null;
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
        // اگر آف لائن ہو تو لوکل پاتھ محفوظ رکھیں تاکہ بعد میں سنک ہو سکے
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