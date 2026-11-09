class StampTagService {
  static final List<String> defaultTags = [
    'کسٹمر کا نام',
    'ولدیت',
    'شناختی کارڈ',
    'موبائل ماڈل',
    'IMEI نمبر',
    'ایڈوانس رقم',
    'ماہانہ قسط',
    'ٹوٹل رقم',
    'مدت',
  ];

  static void addTag(List<String> currentTags, String newTag) {
    final clean = newTag.trim();
    if (clean.isNotEmpty && !currentTags.contains(clean)) {
      currentTags.add(clean);
    }
  }

  static void removeTag(List<String> currentTags, String tag) {
    currentTags.remove(tag);
  }
}