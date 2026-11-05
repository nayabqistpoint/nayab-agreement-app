import 'package:flutter/material.dart';
import 'qr_scanner_service.dart';

class CnicOcrScannerService {
  static Future<dynamic> scanCnic(BuildContext context) async {
    final rawData = await QrScannerService.scanQrCode(context);
    if (rawData == null || rawData.isEmpty) return null;

    final Map<String, String> result = <String, String>{};

    final cnicRegexWithHyphen = RegExp(r'\d{5}-\d{7}-\d{1}');
    final cnicRegexRaw = RegExp(r'\b\d{13}\b');

    if (cnicRegexWithHyphen.hasMatch(rawData)) {
      result['شناختی کارڈ'] = cnicRegexWithHyphen.firstMatch(rawData)!.group(0)!;
    } else if (cnicRegexRaw.hasMatch(rawData)) {
      final rawCnic = cnicRegexRaw.firstMatch(rawData)!.group(0)!;
      result['شناختی کارڈ'] =
          '${rawCnic.substring(0, 5)}-${rawCnic.substring(5, 12)}-${rawCnic.substring(12)}';
    }

    return result.isNotEmpty ? result : null;
  }
}