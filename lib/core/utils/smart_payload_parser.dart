import 'dart:convert';

class SmartPayloadParser {
  static Map<String, String> parseScannedInput(String raw) {
    String clean = raw.trim();
    if (clean.isEmpty) return {};

    // اگر خفیہ NQP_QR فارمیٹ ہو تو پہلے اسے ڈی کوڈ کریں
    if (clean.startsWith('NQP_QR:')) {
      try {
        final b64 = clean.substring(7).trim();
        clean = utf8.decode(base64Decode(b64));
      } catch (_) {}
    }

    try {
      final decoded = jsonDecode(clean);
      if (decoded is Map) {
        final Map<String, String> result = {};
        decoded.forEach((key, value) {
          if (value == null) return;
          final valStr = value.toString().trim();
          if (valStr.isEmpty || valStr == 'null') return;
          final k = _normalizeKey(key.toString());
          result[k] = valStr;
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
    final trimmed = rawKey.trim();
    final lower = trimmed.toLowerCase();

    // اگر پہلے سے معیاری اردو کلید ہو تو اسے جوں کا توں رکھیں
    const exactUrduKeys = {
      'موبائل ماڈل',
      'IMEI نمبر',
      'ٹوٹل رقم',
      'ایڈوانس رقم',
      'ماہانہ قسط',
      'مدت',
      'ضمانت',
      'کسٹمر کا نام',
      'ولدیت',
      'قومیت',
      'شناختی کارڈ',
      'رابطہ نمبر',
      'مستقل پتہ',
      'ضامن کا نام',
      'ضامن ولدیت',
      'ضامن قومیت',
      'ضامن موبائل نمبر',
      'ضامن شناختی کارڈ',
      'ضامن پتہ',
      'ضامن رشتہ',
      'سرپرست فون',
      'بینک کا نام',
      'چیک نمبر',
      'MDM لاک فیس',
      'اوپن باکس کٹوتی',
      'تاریخ ادائیگی',
    };
    if (exactUrduKeys.contains(trimmed)) return trimmed;

    if (lower.contains('guarantor')) {
      if (lower.contains('father')) return 'ضامن ولدیت';
      if (lower.contains('caste')) return 'ضامن قومیت';
      if (lower.contains('cnic')) return 'ضامن شناختی کارڈ';
      if (lower.contains('phone')) return 'ضامن موبائل نمبر';
      if (lower.contains('address')) return 'ضامن پتہ';
      if (lower.contains('relation')) return 'ضامن رشتہ';
      return 'ضامن کا نام';
    }
    if (lower.contains('guardian')) return 'سرپرست فون';
    if (lower.contains('model') || lower.contains('itemname')) return 'موبائل ماڈل';
    if (lower.contains('imei')) return 'IMEI نمبر';
    if (lower.contains('totalcontract') || lower.contains('total')) return 'ٹوٹل رقم';
    if (lower.contains('advance')) return 'ایڈوانس رقم';
    if (lower.contains('monthly') || lower.contains('installment')) return 'ماہانہ قسط';
    if (lower.contains('months') || lower.contains('duration')) return 'مدت';
    if (lower.contains('father')) return 'ولدیت';
    if (lower.contains('caste')) return 'قومیت';
    if (lower.contains('cnic')) return 'شناختی کارڈ';
    if (lower.contains('phone')) return 'رابطہ نمبر';
    if (lower.contains('address')) return 'مستقل پتہ';
    if (lower.contains('bank')) return 'بینک کا نام';
    if (lower.contains('cheque')) return 'چیک نمبر';
    if (lower.contains('name')) return 'کسٹمر کا نام';
    return trimmed;
  }

  static String _formatCnic(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 13) {
      return '${digits.substring(0, 5)}-${digits.substring(5, 12)}-${digits.substring(12, 13)}';
    }
    return raw;
  }
}