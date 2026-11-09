class StampSpanStyle {
  int start;
  int end;
  bool isBold;
  bool isUnderline;
  double? fontSize;

  StampSpanStyle({
    required this.start,
    required this.end,
    this.isBold = false,
    this.isUnderline = false,
    this.fontSize,
  });

  Map<String, dynamic> toJson() => {
        'start': start,
        'end': end,
        'isBold': isBold,
        'isUnderline': isUnderline,
        'fontSize': fontSize,
      };

  factory StampSpanStyle.fromJson(Map<String, dynamic> json) => StampSpanStyle(
        start: json['start'] as int,
        end: json['end'] as int,
        isBold: json['isBold'] as bool? ?? false,
        isUnderline: json['isUnderline'] as bool? ?? false,
        fontSize: (json['fontSize'] as num?)?.toDouble(),
      );
}