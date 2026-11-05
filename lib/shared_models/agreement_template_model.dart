class AgreementTemplateModel {
  final String id;
  final String title;
  final String content;
  final String paperSize; // 'A4' یا 'Legal'
  final double topMargin; // ای-اسٹامپ کے ہیڈر کے لیے خالی جگہ (ڈیفالٹ: 0)
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
    this.topMargin = 0.0,
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
      'topMargin': topMargin,
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
      topMargin: (map['topMargin'] as num?)?.toDouble() ?? 0.0,
      fields: List<String>.from(map['fields'] ?? []),
      isSynced: map['isSynced'] as bool? ?? false,
      updatedAt: map['updatedAt']?.toString() ?? '',
      createdAt: map['createdAt']?.toString() ?? '',
      isDeleted: map['isDeleted'] as bool? ?? false,
    );
  }
}