class AgreementTemplateModel {
  final String id;
  final String title;
  final String content;
  final String paperSize;
  final bool isEStamp;
  final double topMargin; // صفحہ نمبر 1 کا ٹاپ مارجن (مونوگرام)
  final double subsequentTopMargin; // صفحہ 2 اور آگے کے صفحات کا ٹاپ مارجن
  final double bottomMargin;
  final double sideMargin;
  final List<String> fields;
  final bool isSynced;
  final String updatedAt;
  final String createdAt;
  final bool isDeleted;

  AgreementTemplateModel({
    required this.id,
    required this.title,
    required this.content,
    this.paperSize = 'A4',
    this.isEStamp = false,
    this.topMargin = 220.0,
    this.subsequentTopMargin = 45.0,
    this.bottomMargin = 75.0,
    this.sideMargin = 35.0,
    required this.fields,
    this.isSynced = false,
    required this.updatedAt,
    required this.createdAt,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'paperSize': paperSize,
      'isEStamp': isEStamp,
      'topMargin': topMargin,
      'subsequentTopMargin': subsequentTopMargin,
      'bottomMargin': bottomMargin,
      'sideMargin': sideMargin,
      'fields': fields,
      'isSynced': isSynced,
      'updatedAt': updatedAt,
      'createdAt': createdAt,
      'isDeleted': isDeleted,
    };
  }

  factory AgreementTemplateModel.fromMap(Map<String, dynamic> map) {
    return AgreementTemplateModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      paperSize: map['paperSize']?.toString() ?? 'A4',
      isEStamp: map['isEStamp'] as bool? ?? false,
      topMargin: (map['topMargin'] as num?)?.toDouble() ?? 220.0,
      subsequentTopMargin: (map['subsequentTopMargin'] as num?)?.toDouble() ?? 45.0,
      bottomMargin: (map['bottomMargin'] as num?)?.toDouble() ?? 75.0,
      sideMargin: (map['sideMargin'] as num?)?.toDouble() ?? 35.0,
      fields: List<String>.from(map['fields'] ?? []),
      isSynced: map['isSynced'] as bool? ?? false,
      updatedAt: map['updatedAt']?.toString() ?? '',
      createdAt: map['createdAt']?.toString() ?? '',
      isDeleted: map['isDeleted'] as bool? ?? false,
    );
  }
}