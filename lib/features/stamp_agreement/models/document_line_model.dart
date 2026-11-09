import 'package:flutter/material.dart';

class DocumentLine {
  String text;
  TextAlign alignment;
  bool isBold;
  bool isUnderline;
  double fontSize;

  DocumentLine({
    required this.text,
    this.alignment = TextAlign.right,
    this.isBold = false,
    this.isUnderline = false,
    this.fontSize = 14.0,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'alignment': alignment.index,
        'isBold': isBold,
        'isUnderline': isUnderline,
        'fontSize': fontSize,
      };

  factory DocumentLine.fromJson(Map<String, dynamic> json) => DocumentLine(
        text: json['text'] ?? '',
        alignment: TextAlign.values[json['alignment'] ?? TextAlign.right.index],
        isBold: json['isBold'] ?? false,
        isUnderline: json['isUnderline'] ?? false,
        fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
      );

  DocumentLine copyWith({
    String? text,
    TextAlign? alignment,
    bool? isBold,
    bool? isUnderline,
    double? fontSize,
  }) {
    return DocumentLine(
      text: text ?? this.text,
      alignment: alignment ?? this.alignment,
      isBold: isBold ?? this.isBold,
      isUnderline: isUnderline ?? this.isUnderline,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}