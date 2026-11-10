class PdfOverlayFieldModel {
  final String id;
  String tag;
  double x;
  double y;
  double fontSize;
  String fontType;
  bool isBold;
  bool isUnderline;
  bool isStaticText;

  PdfOverlayFieldModel({
    required this.id,
    required this.tag,
    required this.x,
    required this.y,
    this.fontSize = 13.0,
    this.fontType = 'JameelNoori',
    this.isBold = false,
    this.isUnderline = false,
    this.isStaticText = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tag': tag,
      'x': x,
      'y': y,
      'fontSize': fontSize,
      'fontType': fontType,
      'isBold': isBold,
      'isUnderline': isUnderline,
      'isStaticText': isStaticText,
    };
  }

  factory PdfOverlayFieldModel.fromMap(Map<String, dynamic> map) {
    return PdfOverlayFieldModel(
      id: map['id']?.toString() ?? '',
      tag: map['tag']?.toString() ?? '',
      x: (map['x'] as num?)?.toDouble() ?? 50.0,
      y: (map['y'] as num?)?.toDouble() ?? 50.0,
      fontSize: (map['fontSize'] as num?)?.toDouble() ?? 13.0,
      fontType: map['fontType']?.toString() ?? 'JameelNoori',
      isBold: map['isBold'] as bool? ?? false,
      isUnderline: map['isUnderline'] as bool? ?? false,
      isStaticText: map['isStaticText'] as bool? ?? false,
    );
  }
}