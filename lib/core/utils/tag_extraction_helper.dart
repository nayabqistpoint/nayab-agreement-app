class TemplateService {
  static final Map<String, String> defaultPresets = {
    'موبائل اقساط کا معاہدہ': '''نایاب قسط پوائنٹ حاصل پور
اقرار نامہ و معاہدہ بیع بالاقساط
منکہ {{کسٹمر کا نام}} ولد {{ولدیت}} قوم {{قومیت}} شناختی کارڈ نمبر {{شناختی کارڈ}} رہائشی {{مستقل پتہ}} موبائل نمبر {{رابطہ نمبر}} نے نایاب قسط پوائنٹ سے ایک عدد موبائل بمطابق تفصیل ذیل قسطوں پر خریدا ہے:
- موبائل کمپنی و ماڈل: {{موبائل ماڈل}}
- آئی ایم ای آئی نمبر: {{IMEI نمبر}}
- کل قیمت طے شدہ: {{ٹوٹل رقم}} روپے
- پیشگی ادائیگی (ایڈوانس): {{ایڈوانس رقم}} روپے
- ماہانہ قسط: {{ماہانہ قسط}} روپے
- اقساط کی کل مدت: {{مدت}}
مقررہ تاریخ سے پہلے ہر ماہ کی قسط ادا کرنے کا پابند رہوں گا/رہوں گی۔ بصورت دیگر کمپنی کو قانونی کارروائی کا حق حاصل ہوگا۔''',
    'بیان حلفی اقساط': '''حلف نامہ / بیان حلفی
میں مسمی {{کسٹمر کا نام}} ولد {{ولدیت}} ساکن {{مستقل پتہ}} شناختی کارڈ نمبر {{شناختی کارڈ}} کا رہائشی ہوں اور حلفاً بیان کرتا ہوں کہ:
1. میں نے نایاب قسط پوائنٹ سے {{موبائل ماڈل}} کل قیمت {{ٹوٹل رقم}} روپے میں خریدا ہے۔
2. میں ہر ماہ کی {{تاریخ ادائیگی}} کو ماہانہ قسط مبلغ {{ماہانہ قسط}} روپے بروقت ادا کرنے کا پابند رہوں گا۔
3. بقایا رقم کی مکمل ادائیگی تک موبائل سیٹ نایاب قسط پوائنٹ کی ملکیت تصور ہوگا۔
المحلف: {{کسٹمر کا نام}}'''
  };

  static Map<String, String> get presetTemplates => defaultPresets;

  /// تمام ٹیگز کو الگ الگ بغیر لالچ (Non-Greedy) کے نکالتا ہے چاہے اکٹھے جڑے ہوں
  static List<String> extractFields(String template) {
    if (template.isEmpty) return [];
    final regex = RegExp(r'\{\{([^{}]+?)\}\}');
    final matches = regex.allMatches(template);
    final Set<String> uniqueKeys = {};
    for (final m in matches) {
      final key = m.group(1)!.trim();
      if (key.isNotEmpty) {
        uniqueKeys.add(key);
      }
    }
    return uniqueKeys.toList();
  }

  /// ٹیگز کو ویلیوز سے بدلتا ہے اور آگے موجود انڈر سکور/ڈیش کی لکیروں کو سمارٹ انداز میں ایڈجسٹ کرتا ہے
  static String replaceTags(String template, Map<String, String> values) {
    if (template.isEmpty) return '';

    // ریجیکس: ٹیگ اور اس کے فوری بعد جڑی ہوئی انڈر سکور یا ڈیش کی لکیریں
    final combinedRegex = RegExp(r'\{\{([^{}]+?)\}\}([_\-\s]*)');

    return template.replaceAllMapped(combinedRegex, (match) {
      final key = match.group(1)!.trim();
      final trailingDashes = match.group(2) ?? '';
      final val = values[key]?.trim() ?? '';

      // اگر گاہک کا ڈیٹا موجود نہیں ہے تو معیاری خالی لکیر برقرار رکھیں
      if (val.isEmpty) {
        if (trailingDashes.isNotEmpty) {
          return '__________$trailingDashes';
        }
        return '__________';
      }

      // اگر گاہک کا ڈیٹا موجود ہے اور آگے لکیریں کھینچی گئی تھیں
      if (trailingDashes.isNotEmpty) {
        final dashCount = trailingDashes.length;
        // جتنا لمبا ڈیٹا ہے اتنی لکیریں کم کر دیں تاکہ اگلی عبارت اپنی جگہ سے نہ ہلے
        final remainingDashesCount = (dashCount - val.length).clamp(0, dashCount);
        final remainingDashes = trailingDashes.substring(0, remainingDashesCount);
        return '$val$remainingDashes';
      }

      return val;
    });
  }
}