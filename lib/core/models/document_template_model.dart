import 'overlay_box_model.dart';

enum DocumentMode {
  stampOverlay,
  formFiller,
  plainDocument,
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
  final double subsequentBottomMargin;
  final double sideMargin;
  final double fontSize;
  final String? base64Pdf;
  final String? stampFileName;
  final List<OverlayBoxModel> floatingBoxes;
  final List<String> fields;
  final List<String> pages;

  DocumentTemplateModel({
    required this.id,
    required this.title,
    required this.content,
    this.mode = DocumentMode.stampOverlay,
    this.paperSize = 'Legal',
    this.topMargin = 320.0,
    this.subsequentTopMargin = 65.0,
    this.bottomMargin = 270.0,
    this.subsequentBottomMargin = 65.0,
    this.sideMargin = 40.0,
    this.fontSize = 14.0,
    this.base64Pdf,
    this.stampFileName,
    this.floatingBoxes = const [],
    this.fields = const [],
    this.pages = const [],
  });

  factory DocumentTemplateModel.fromMap(Map<dynamic, dynamic> map) {
    final modeStr = map['mode']?.toString() ?? 'stampOverlay';
    final parsedMode = DocumentMode.values.firstWhere(
      (e) => e.name == modeStr,
      orElse: () => DocumentMode.stampOverlay,
    );

    final rawBoxes = map['floatingBoxes'];
    final List<OverlayBoxModel> parsedBoxes = [];
    if (rawBoxes is List) {
      for (var item in rawBoxes) {
        if (item is Map) {
          parsedBoxes.add(OverlayBoxModel.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    }

    final rawFields = map['fields'];
    final List<String> parsedFields = rawFields is List
        ? rawFields.map((e) => e.toString()).toList()
        : [];

    final rawPages = map['pages'];
    final List<String> parsedPages = rawPages is List
        ? rawPages.map((e) => e.toString()).toList()
        : [];

    final double baseBottom = (map['bottomMargin'] as num?)?.toDouble() ?? 270.0;

    return DocumentTemplateModel(
      id: map['id']?.toString() ?? map['title']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      mode: parsedMode,
      paperSize: map['paperSize']?.toString() ?? 'Legal',
      topMargin: (map['topMargin'] as num?)?.toDouble() ?? 320.0,
      subsequentTopMargin: (map['subsequentTopMargin'] as num?)?.toDouble() ?? 65.0,
      bottomMargin: baseBottom,
      subsequentBottomMargin: (map['subsequentBottomMargin'] as num?)?.toDouble() ?? 65.0,
      sideMargin: (map['sideMargin'] as num?)?.toDouble() ?? 40.0,
      fontSize: (map['fontSize'] as num?)?.toDouble() ?? 14.0,
      base64Pdf: map['base64Pdf']?.toString(),
      stampFileName: map['stampFileName']?.toString(),
      floatingBoxes: parsedBoxes,
      fields: parsedFields,
      pages: parsedPages,
    );
  }

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
      'subsequentBottomMargin': subsequentBottomMargin,
      'sideMargin': sideMargin,
      'fontSize': fontSize,
      'base64Pdf': base64Pdf,
      'stampFileName': stampFileName,
      'floatingBoxes': floatingBoxes.map((b) => b.toMap()).toList(),
      'fields': fields,
      'pages': pages,
    };
  }
}