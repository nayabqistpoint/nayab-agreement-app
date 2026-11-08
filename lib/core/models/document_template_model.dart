import 'overlay_box_model.dart';

enum DocumentMode {
  stampOverlay,
  plainDocument,
  formFiller,
}

class DocumentTemplateModel {
  final String id;
  final String title;
  final String content;
  final DocumentMode mode;
  final String paperSize;
  final double topMargin;
  final double subsequentTopMargin;
  final double bottomMargin;
  final double sideMargin;
  final double fontSize;
  final String? base64Pdf;
  final String? stampFileName;
  final List<OverlayBoxModel> floatingBoxes;
  final List<String> fields;
  final List<String> pages; // فائنل شدہ صفحات کی لسٹ

  DocumentTemplateModel({
    required this.id,
    required this.title,
    required this.content,
    required this.mode,
    required this.paperSize,
    required this.topMargin,
    required this.subsequentTopMargin,
    required this.bottomMargin,
    required this.sideMargin,
    required this.fontSize,
    this.base64Pdf,
    this.stampFileName,
    this.floatingBoxes = const [],
    this.fields = const [],
    this.pages = const [],
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
      'pages': pages,
    };
  }

  factory DocumentTemplateModel.fromMap(Map<dynamic, dynamic> map) {
    DocumentMode parsedMode = DocumentMode.stampOverlay;
    final modeStr = map['mode']?.toString();
    if (modeStr == DocumentMode.plainDocument.name) {
      parsedMode = DocumentMode.plainDocument;
    } else if (modeStr == DocumentMode.formFiller.name) {
      parsedMode = DocumentMode.formFiller;
    }

    List<OverlayBoxModel> boxes = [];
    if (map['floatingBoxes'] != null && map['floatingBoxes'] is List) {
      boxes = (map['floatingBoxes'] as List)
          .map((b) => OverlayBoxModel.fromMap(Map<String, dynamic>.from(b)))
          .toList();
    }

    List<String> parsedPages = [];
    if (map['pages'] != null && map['pages'] is List) {
      parsedPages = List<String>.from(map['pages'].map((e) => e.toString()));
    }

    return DocumentTemplateModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      mode: parsedMode,
      paperSize: map['paperSize']?.toString() ?? 'Legal',
      topMargin: (map['topMargin'] as num?)?.toDouble() ?? 320.0,
      subsequentTopMargin: (map['subsequentTopMargin'] as num?)?.toDouble() ?? 65.0,
      bottomMargin: (map['bottomMargin'] as num?)?.toDouble() ?? 270.0,
      sideMargin: (map['sideMargin'] as num?)?.toDouble() ?? 40.0,
      fontSize: (map['fontSize'] as num?)?.toDouble() ?? 13.5,
      base64Pdf: map['base64Pdf']?.toString(),
      stampFileName: map['stampFileName']?.toString(),
      floatingBoxes: boxes,
      fields: map['fields'] != null ? List<String>.from(map['fields']) : [],
      pages: parsedPages,
    );
  }
}