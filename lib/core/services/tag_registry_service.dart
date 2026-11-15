import '../constants/box_names.dart';
import '../database/hive_box_manager.dart';

typedef RuleMap = Map<String, dynamic>;

class PosMappingRule {
  final String rawKey;
  bool enabled;
  String urduTag;
  Map<String, String> valueTranslations;

  PosMappingRule({
    required this.rawKey,
    required this.enabled,
    required this.urduTag,
    Map<String, String>? valueTranslations,
  }) : valueTranslations = valueTranslations ?? {};

  RuleMap toMap() {
    return {
      'rawKey': rawKey,
      'enabled': enabled,
      'urduTag': urduTag,
      'valueTranslations': valueTranslations,
    };
  }

  factory PosMappingRule.fromMap(Map raw) {
    final map = RuleMap.from(raw);
    final rawTrans = map['valueTranslations'];
    final Map<String, String> trans = {};
    if (rawTrans is Map) {
      rawTrans.forEach((k, v) {
        trans[k.toString()] = v.toString();
      });
    }
    return PosMappingRule(
      rawKey: map['rawKey']?.toString() ?? '',
      enabled: map['enabled'] == true,
      urduTag: map['urduTag']?.toString() ?? '',
      valueTranslations: trans,
    );
  }
}

class TagRegistryService {
  static const String _rulesStorageKey = 'pos_payload_mapping_rules_v1';
  static const String _customTagsStorageKey = 'custom_manual_tags_v1';

  /// ابتدائی معیاری میپنگ قواعد
  static final Map<String, PosMappingRule> _defaultRules = {
    'docId': PosMappingRule(rawKey: 'docId', enabled: true, urduTag: 'دستاویز نمبر'),
    'customerName': PosMappingRule(rawKey: 'customerName', enabled: true, urduTag: 'کسٹمر کا نام'),
    'customerPhone': PosMappingRule(rawKey: 'customerPhone', enabled: true, urduTag: 'رابطہ نمبر'),
    'customerCnic': PosMappingRule(rawKey: 'customerCnic', enabled: true, urduTag: 'شناختی کارڈ'),
    'guarantorName': PosMappingRule(rawKey: 'guarantorName', enabled: true, urduTag: 'ضامن کا نام'),
    'guarantorPhone': PosMappingRule(rawKey: 'guarantorPhone', enabled: true, urduTag: 'ضامن موبائل نمبر'),
    'itemName': PosMappingRule(rawKey: 'itemName', enabled: true, urduTag: 'موبائل ماڈل'),
    'imeiNo': PosMappingRule(rawKey: 'imeiNo', enabled: true, urduTag: 'IMEI نمبر'),
    'totalContractAmount': PosMappingRule(rawKey: 'totalContractAmount', enabled: true, urduTag: 'ٹوٹل رقم'),
    'advance': PosMappingRule(rawKey: 'advance', enabled: true, urduTag: 'ایڈوانس رقم'),
    'monthlyAmount': PosMappingRule(rawKey: 'monthlyAmount', enabled: true, urduTag: 'ماہانہ قسط'),
    'totalMonths': PosMappingRule(rawKey: 'totalMonths', enabled: true, urduTag: 'مدت'),
    'guaranteeType': PosMappingRule(
      rawKey: 'guaranteeType',
      enabled: true,
      urduTag: 'ضمانت',
      valueTranslations: {
        'LEGAL_STAMP': 'قانونی اشٹام و پرنوٹ',
        'CHEQUE': 'بینک چیک',
      },
    ),
    'bankName': PosMappingRule(rawKey: 'bankName', enabled: true, urduTag: 'بینک کا نام'),
    'chequeNo': PosMappingRule(rawKey: 'chequeNo', enabled: true, urduTag: 'چیک نمبر'),
    'id': PosMappingRule(rawKey: 'id', enabled: false, urduTag: 'آئی ڈی'),
    'status': PosMappingRule(rawKey: 'status', enabled: false, urduTag: 'اسٹیٹس'),
    'sourceMode': PosMappingRule(rawKey: 'sourceMode', enabled: false, urduTag: 'ذریعہ'),
    'isDeleted': PosMappingRule(
      rawKey: 'isDeleted',
      enabled: false,
      urduTag: 'حذف شدہ',
      valueTranslations: {'true': 'ہاں', 'false': 'نہیں'},
    ),
    'isSynced': PosMappingRule(rawKey: 'isSynced', enabled: false, urduTag: 'سنک اسٹیٹس'),
    'createdAt': PosMappingRule(rawKey: 'createdAt', enabled: false, urduTag: 'تاریخ تیاری'),
    'updatedAt': PosMappingRule(rawKey: 'updatedAt', enabled: false, urduTag: 'آخری اپڈیٹ'),
    'syncedAt': PosMappingRule(rawKey: 'syncedAt', enabled: false, urduTag: 'سنک وقت'),
  };

  static final List<String> _defaultCustomTags = [
    'ولدیت',
    'قومیت',
    'مستقل پتہ',
    'گواہ 1 کا نام',
    'گواہ 2 کا نام',
    'تاریخ ادائیگی',
  ];

  static Map<String, PosMappingRule> getAllRules() {
    final Map<String, PosMappingRule> result = {};
    _defaultRules.forEach((k, v) {
      result[k] = PosMappingRule(
        rawKey: v.rawKey,
        enabled: v.enabled,
        urduTag: v.urduTag,
        valueTranslations: Map<String, String>.from(v.valueTranslations),
      );
    });

    try {
      final box = HiveBoxManager.getBox(BoxNames.tagsBox);
      final raw = box.get(_rulesStorageKey);
      if (raw is Map) {
        raw.forEach((k, v) {
          if (v is Map) {
            result[k.toString()] = PosMappingRule.fromMap(v);
          }
        });
      }
    } catch (_) {}

    return result;
  }

  static Future<void> saveAllRules(Map<String, PosMappingRule> rules) async {
    final RuleMap serialized = {};
    rules.forEach((k, rule) {
      serialized[k] = rule.toMap();
    });

    await HiveBoxManager.putBatch(
      boxName: BoxNames.tagsBox,
      entries: {_rulesStorageKey: serialized},
    );
  }

  static List<String> getActivePosTags() {
    final rules = getAllRules();
    final List<String> tags = [];
    for (final rule in rules.values) {
      if (rule.enabled && rule.urduTag.trim().isNotEmpty) {
        if (!tags.contains(rule.urduTag.trim())) {
          tags.add(rule.urduTag.trim());
        }
      }
    }
    return tags;
  }

  static List<String> getCustomTags() {
    try {
      final box = HiveBoxManager.getBox(BoxNames.tagsBox);
      final raw = box.get(_customTagsStorageKey);
      if (raw is List && raw.isNotEmpty) {
        return raw.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return List<String>.from(_defaultCustomTags);
  }

  static Future<void> saveCustomTags(List<String> tags) async {
    await HiveBoxManager.putBatch(
      boxName: BoxNames.tagsBox,
      entries: {_customTagsStorageKey: tags},
    );
  }

  /// تازہ ترین POS آرڈر کا خام پے لوڈ نکالنا
  static RuleMap getLatestRawPosOrderSample() {
    try {
      final box = HiveBoxManager.getBox(BoxNames.shopOrdersBox);
      RuleMap? latest;
      String latestTime = '';

      for (final key in box.keys) {
        final raw = box.get(key);
        if (raw is Map) {
          final map = RuleMap.from(raw);
          final t = map['createdAt']?.toString() ?? '';
          if (latest == null || t.compareTo(latestTime) >= 0) {
            latest = map;
            latestTime = t;
          }
        }
      }
      return latest ?? {};
    } catch (_) {
      return {};
    }
  }

  /// تمام پرانے اور نئے POS آرڈرز سے ہر کلید کی تمام منفرد کوڈ ویلیوز اکٹھی کرنا
  static Map<String, Set<String>> discoverAllDistinctValuesPerKey() {
    final Map<String, Set<String>> discovered = {};
    try {
      final box = HiveBoxManager.getBox(BoxNames.shopOrdersBox);
      for (final key in box.keys) {
        final raw = box.get(key);
        if (raw is Map) {
          raw.forEach((k, v) {
            if (v == null || v is List || v is Map) return;
            final valStr = v.toString().trim();
            if (valStr.isEmpty || valStr == 'null') return;
            discovered.putIfAbsent(k.toString(), () => <String>{}).add(valStr);
          });
        }
      }
    } catch (_) {}
    return discovered;
  }

  /// طے کرنا کہ آیا کسی فیلڈ پر '=' بٹن دکھانا ضروری ہے (صرف بولین یا کوڈ/ٹائپ فیلڈز پر)
  static bool supportsValueTranslation(
    String rawKey,
    PosMappingRule rule,
    Set<String> observedValues,
  ) {
    // 1. اگر پہلے سے کوئی ترجمہ موجود ہے تو ضرور دکھائیں
    if (rule.valueTranslations.isNotEmpty) return true;

    final lowerKey = rawKey.toLowerCase();
    // 2. اگر کلید کا نام بولین یا ٹائپ/اسٹیٹس ظاہر کرتا ہے
    if (lowerKey.startsWith('is') ||
        lowerKey.startsWith('has') ||
        lowerKey.contains('type') ||
        lowerKey.contains('mode') ||
        lowerKey.contains('status')) {
      return true;
    }

    // 3. اگر مشاہدہ شدہ ویلیوز میں true/false یا ALL_CAPS کوڈز (مثلاً LEGAL_STAMP) موجود ہوں
    for (final val in observedValues) {
      if (val == 'true' || val == 'false') return true;
      if (RegExp(r'^[A-Z][A-Z0-9_]{1,}$').hasMatch(val)) return true;
    }

    return false;
  }

  /// قواعد کے مطابق خام POS آرڈر کو اردو فیلڈز میں تبدیل کرنا
  static Map<String, String> translateOrderPayload(Map rawOrder) {
    final rules = getAllRules();
    final Map<String, String> translated = {};

    rawOrder.forEach((key, rawVal) {
      final k = key.toString();
      final rule = rules[k];
      if (rule == null || !rule.enabled) return;

      final tagName = rule.urduTag.trim();
      if (tagName.isEmpty) return;

      if (rawVal == null) return;
      String valStr = rawVal.toString().trim();
      if (valStr.isEmpty || valStr == 'null') return;

      if (rule.valueTranslations.containsKey(valStr)) {
        valStr = rule.valueTranslations[valStr]!;
      } else if (k == 'totalMonths' && !valStr.contains('ماہ')) {
        valStr = '$valStr ماہ';
      }

      translated[tagName] = valStr;
    });

    return translated;
  }
}