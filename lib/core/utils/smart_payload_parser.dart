import 'dart:convert';

class SmartPayloadParser {
  static Map<String, String> parseScannedInput(String raw) {
    final clean = raw.trim();
    if (clean.isEmpty) return {};

    try {
      final decoded = jsonDecode(clean);
      if (decoded is Map) {
        final Map<String, String> result = {};
        decoded.forEach((key, value) {
          final k = _normalizeKey(key.toString());
          result[k] = value.toString().trim();
        });
        return result;
      }
    } catch (_) {}

    final cnicRegex = RegExp(r'^\d{5}-?\d{7}-?\d{1}$');
    if (cnicRegex.hasMatch(clean)) {
      return {'شناختی کارڈ': _formatCnic(clean)};
    }

    if (clean.length == 15 && RegExp(r'^\d{15}$').hasMatch(clean)) {
      return {'IMEI نمبر': clean};
    }

    return {'عمومی ان پٹ': clean};
  }

  static String _normalizeKey(String rawKey) {
    final lower = rawKey.toLowerCase().trim();
    if (lower.contains('model') || lower.contains('ماڈل')) return 'موبائل ماڈل';
    if (lower.contains('imei') || lower.contains('آئی ایم ای آئی')) return 'IMEI نمبر';
    if (lower.contains('total') || lower.contains('قیمت') || lower.contains('رقم')) return 'ٹوٹل رقم';
    if (lower.contains('advance') || lower.contains('پیشگی') || lower.contains('ایڈوانس')) return 'ایڈوانس رقم';
    if (lower.contains('installment') || lower.contains('قسط')) return 'ماہانہ قسط';
    if (lower.contains('duration') || lower.contains('مدت')) return 'مدت';
    if (lower.contains('name') || lower.contains('نام')) return 'کسٹمر کا نام';
    if (lower.contains('father') || lower.contains('ولدیت')) return 'ولدیت';
    if (lower.contains('cnic') || lower.contains('شناختی')) return 'شناختی کارڈ';
    if (lower.contains('phone') || lower.contains('فون') || lower.contains('رابطہ')) return 'رابطہ نمبر';
    if (lower.contains('address') || lower.contains('پتہ')) return 'مستقل پتہ';
    return rawKey;
  }

  static String _formatCnic(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 13) {
      return '${digits.substring(0, 5)}-${digits.substring(5, 12)}-${digits.substring(12, 13)}';
    }
    return raw;
  }
}