enum TagSourceType {
  pos,     // POS آرڈرز سے آنے والے ٹیگز
  scanner, // شناختی کارڈ / QR اسکینر سے آنے والے ٹیگز
  custom,  // دستی یا واٹس ایپ سے منگوائے جانے والے ٹیگز
}

class TagBankItemModel {
  final String id;
  final String urduName;
  final TagSourceType source;
  final String? rawKey;
  final bool isEnabled;
  final Map<String, String> valueTranslations;
  final bool isSynced;
  final String updatedAt;
  final bool isDeleted;

  const TagBankItemModel({
    required this.id,
    required this.urduName,
    required this.source,
    this.rawKey,
    this.isEnabled = true,
    this.valueTranslations = const {},
    this.isSynced = false,
    required this.updatedAt,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'urduName': urduName,
      'source': source.name,
      'rawKey': rawKey,
      'isEnabled': isEnabled,
      'valueTranslations': valueTranslations,
      'isSynced': isSynced,
      'updatedAt': updatedAt,
      'isDeleted': isDeleted,
    };
  }

  factory TagBankItemModel.fromMap(Map raw) {
    final map = Map<String, dynamic>.from(raw);
    final sourceStr = map['source']?.toString() ?? 'custom';
    final parsedSource = TagSourceType.values.firstWhere(
      (e) => e.name == sourceStr,
      orElse: () => TagSourceType.custom,
    );

    final Map<String, String> trans = {};
    final rawTrans = map['valueTranslations'];
    if (rawTrans is Map) {
      rawTrans.forEach((k, v) {
        trans[k.toString()] = v.toString();
      });
    }

    return TagBankItemModel(
      id: map['id']?.toString() ?? '',
      urduName: map['urduName']?.toString() ?? '',
      source: parsedSource,
      rawKey: map['rawKey']?.toString(),
      isEnabled: map['isEnabled'] != false,
      valueTranslations: trans,
      isSynced: map['isSynced'] == true,
      updatedAt: map['updatedAt']?.toString() ?? '',
      isDeleted: map['isDeleted'] == true,
    );
  }
}