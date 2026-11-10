class StampOverlayFieldModel {
  final String id;
  String tag;
  double x;
  double y;
  int pageIndex; // تاکہ ہر صفحے (پیج 1، پیج 2 وغیرہ) پر آزادانہ شناخت ہو سکے
  double fontSize;
  bool isBold;
  bool isUnderline;
  String fontType;
  bool isStaticText;

  StampOverlayFieldModel({
    required this.id,
    required this.tag,
    required this.x,
    required this.y,
    this.pageIndex = 0,
    this.fontSize = 13.0,
    this.isBold = false,
    this.isUnderline = false,
    this.fontType = 'JameelNoori',
    this.isStaticText = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tag': tag,
      'x': x,
      'y': y,
      'pageIndex': pageIndex,
      'fontSize': fontSize,
      'isBold': isBold,
      'isUnderline': isUnderline,
      'fontType': fontType,
      'isStaticText': isStaticText,
    };
  }

  factory StampOverlayFieldModel.fromMap(Map<dynamic, dynamic> map) {
    return StampOverlayFieldModel(
      id: map['id']?.toString() ?? '',
      tag: map['tag']?.toString() ?? '',
      x: (map['x'] as num?)?.toDouble() ?? 50.0,
      y: (map['y'] as num?)?.toDouble() ?? 50.0,
      pageIndex: (map['pageIndex'] as num?)?.toInt() ?? 0,
      fontSize: (map['fontSize'] as num?)?.toDouble() ?? 13.0,
      isBold: map['isBold'] == true,
      isUnderline: map['isUnderline'] == true,
      fontType: map['fontType']?.toString() ?? 'JameelNoori',
      isStaticText: map['isStaticText'] == true,
    );
  }
}