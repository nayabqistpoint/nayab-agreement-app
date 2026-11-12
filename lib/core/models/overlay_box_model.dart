class OverlayBoxModel {
  final String id;
  final String tag;
  final double x;
  final double y;
  final double width;
  final double height;
  final double fontSize;
  final bool isBold;
  final bool isUnderline;
  final bool isMultiLine;

  const OverlayBoxModel({
    required this.id,
    required this.tag,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.fontSize = 13.5,
    this.isBold = false,
    this.isUnderline = false,
    this.isMultiLine = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tag': tag,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'fontSize': fontSize,
      'isBold': isBold,
      'isUnderline': isUnderline,
      'isMultiLine': isMultiLine,
    };
  }

  factory OverlayBoxModel.fromMap(Map<String, dynamic> map) {
    return OverlayBoxModel(
      id: map['id']?.toString() ?? '',
      tag: map['tag']?.toString() ?? '',
      x: (map['x'] as num?)?.toDouble() ?? 0.0,
      y: (map['y'] as num?)?.toDouble() ?? 0.0,
      width: (map['width'] as num?)?.toDouble() ?? 180.0,
      height: (map['height'] as num?)?.toDouble() ?? 32.0,
      fontSize: (map['fontSize'] as num?)?.toDouble() ?? 13.5,
      isBold: map['isBold'] as bool? ?? false,
      isUnderline: map['isUnderline'] as bool? ?? false,
      isMultiLine: map['isMultiLine'] as bool? ?? false,
    );
  }

  OverlayBoxModel copyWith({
    String? id,
    String? tag,
    double? x,
    double? y,
    double? width,
    double? height,
    double? fontSize,
    bool? isBold,
    bool? isUnderline,
    bool? isMultiLine,
  }) {
    return OverlayBoxModel(
      id: id ?? this.id,
      tag: tag ?? this.tag,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      fontSize: fontSize ?? this.fontSize,
      isBold: isBold ?? this.isBold,
      isUnderline: isUnderline ?? this.isUnderline,
      isMultiLine: isMultiLine ?? this.isMultiLine,
    );
  }
}