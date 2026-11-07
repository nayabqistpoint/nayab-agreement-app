import 'overlay_box_model.dart';

enum DocumentMode {
  plainDocument, // سادہ A4 خط، رسید یا انوائس
  stampOverlay,   // پنجاب ای-اسٹامپ اوورلے
  formFiller,    // اسکول فارم یا سرکاری پرفارما
}

class DocumentTemplateModel {
  final String id;
  final String title;
  final String content;
  final DocumentMode mode;
  final String paperSize; // 'A4' یا 'Legal'
  final double topMargin;
  final double subsequentTopMargin;
  final double bottomMargin;
  final double sideMargin;
  final double fontSize;
  final String? base64Pdf;
  final String? stampFileName;
  final List<OverlayBoxModel> floatingBoxes;
  final List<String> fields;

  const DocumentTemplateModel({
    required this.id,
    required this.title,
    required this.content,
    this.mode = DocumentMode.stampOverlay,
    this.paperSize = 'Legal',
    this.topMargin = 320.0,
    this.subsequentTopMargin = 65.0,
    this.bottomMargin = 270.0,
    this.sideMargin = 40.0,
    this.fontSize = 13.5,
    this.base64Pdf,
    this.stampFileName,
    this.floatingBoxes = const [],
    this.fields = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'mode': mode.name,
      'paperSize': paperSize,
      'topMargin': topMargin,
      'subsequentTopMargin': subsequentTopMargin,
      'bottomMargin': bottomMargin,
      'sideMargin': sideMargin,
      'fontSize': fontSize,
      'base64Pdf': base64Pdf,
      'stampFileName': stampFileName,
      'floatingBoxes': floatingBoxes.map((b) => b.toMap()).toList(),
      'fields': fields,
    };
  }

  factory DocumentTemplateModel.fromMap(Map<String, dynamic> map) {
    DocumentMode mode = DocumentMode.stampOverlay;
    if (map['mode'] != null) {
      mode = DocumentMode.values.firstWhere(
        (e) => e.name == map['mode'].toString(),
        orElse: () => DocumentMode.stampOverlay,
      );
    } else {
      final isEStamp = map['isEStamp'] as bool? ?? true;
      mode = isEStamp ? DocumentMode.stampOverlay : DocumentMode.plainDocument;
    }

    final rawBoxes = map['floatingBoxes'] as List<dynamic>? ?? [];
    final boxes = rawBoxes
        .map((e) => OverlayBoxModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    return DocumentTemplateModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      mode: mode,
      paperSize: map['paperSize']?.toString() ?? 'Legal',
      topMargin: (map['topMargin'] as num?)?.toDouble() ?? 320.0,
      subsequentTopMargin: (map['subsequentTopMargin'] as num?)?.toDouble() ?? 65.0,
      bottomMargin: (map['bottomMargin'] as num?)?.toDouble() ?? 270.0,
      sideMargin: (map['sideMargin'] as num?)?.toDouble() ?? 40.0,
      fontSize: (map['fontSize'] as num?)?.toDouble() ?? 13.5,
      base64Pdf: map['base64Pdf']?.toString(),
      stampFileName: map['stampFileName']?.toString(),
      floatingBoxes: boxes,
      fields: (map['fields'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}