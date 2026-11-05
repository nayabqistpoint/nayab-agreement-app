class TimeStatusService {
  /// موجودہ وقت کو معیاری UTC ISO 8601 فارمیٹ میں واپس کرتا ہے
  static String nowUtcIso() {
    return DateTime.now().toUtc().toIso8601String();
  }

  /// پے لوڈ کے لیے موجودہ ٹائم اسٹیمپ
  static String get currentTimestamp => nowUtcIso();
}