class AgreementTemplateModel {
  final String id;
  final String title;
  final String content;
  final String paperSize;
  final bool isEStamp;
  final double topMargin;
  final double subsequentTopMargin;
  final double bottomMargin;
  final double sideMargin;
  final List<String> fields;
  final String? base64Pdf; // ہائیو میں اسٹامپ محفوظ رکھنے کے لیے
  final bool isSynced;
  final String updatedAt;
  final String createdAt;
  final bool isDeleted;

  AgreementTemplateModel({
    required this.id,
    required this.title,
    required this.content,
    this.paperSize = 'Legal',
    this.isEStamp = true,
    this.topMargin = 320.0,
    this.subsequentTopMargin = 65.0,
    this.bottomMargin = 270.0,
    this.sideMargin = 40.0,
    required this.fields,
    this.base64Pdf,
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
      'base64Pdf': base64Pdf,
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
      paperSize: map['paperSize']?.toString() ?? 'Legal',
      isEStamp: map['isEStamp'] as bool? ?? true,
      topMargin: (map['topMargin'] as num?)?.toDouble() ?? 320.0,
      subsequentTopMargin: (map['subsequentTopMargin'] as num?)?.toDouble() ?? 65.0,
      bottomMargin: (map['bottomMargin'] as num?)?.toDouble() ?? 270.0,
      sideMargin: (map['sideMargin'] as num?)?.toDouble() ?? 40.0,
      fields: List<String>.from(map['fields'] ?? []),
      base64Pdf: map['base64Pdf']?.toString(),
      isSynced: map['isSynced'] as bool? ?? false,
      updatedAt: map['updatedAt']?.toString() ?? '',
      createdAt: map['createdAt']?.toString() ?? '',
      isDeleted: map['isDeleted'] as bool? ?? false,
    );
  }
}