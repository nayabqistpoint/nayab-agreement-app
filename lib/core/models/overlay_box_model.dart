class OverlayBoxModel {
  final String id;
  final String tag;
  final double x;
  final double y;
  final double width;
  final double height;
  final double fontSize;
  final bool isMultiLine;

  const OverlayBoxModel({
    required this.id,
    required this.tag,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.fontSize = 13.5,
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
      'isMultiLine': isMultiLine,
    };
  }

  factory OverlayBoxModel.fromMap(Map<String, dynamic> map) {
    return OverlayBoxModel(
      id: map['id']?.toString() ?? '',
      tag: map['tag']?.toString() ?? '',
      x: (map['x'] as num?)?.toDouble() ?? 0.0,
      y: (map['y'] as num?)?.toDouble() ?? 0.0,
      width: (map['width'] as num?)?.toDouble() ?? 120.0,
      height: (map['height'] as num?)?.toDouble() ?? 30.0,
      fontSize: (map['fontSize'] as num?)?.toDouble() ?? 13.5,
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
      isMultiLine: isMultiLine ?? this.isMultiLine,
    );
  }
}