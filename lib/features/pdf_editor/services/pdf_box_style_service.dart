import '../models/pdf_overlay_field_model.dart';

class PdfBoxStyleService {
  static double lastFontSize = 13.0;
  static bool lastIsBold = false;
  static bool lastIsUnderline = false;
  static String lastFontType = 'JameelNoori';
  static double toolbarScale = 1.0; // ٹول بار کا اسکیل یاد رکھنے کے لیے

  static void rememberStyle({
    double? fontSize,
    bool? isBold,
    bool? isUnderline,
    String? fontType,
    double? newToolbarScale,
  }) {
    if (fontSize != null) lastFontSize = fontSize;
    if (isBold != null) lastIsBold = isBold;
    if (isUnderline != null) lastIsUnderline = isUnderline;
    if (fontType != null) lastFontType = fontType;
    if (newToolbarScale != null) toolbarScale = newToolbarScale.clamp(0.8, 1.6);
  }

  static PdfOverlayFieldModel createField({
    required String id,
    required String tag,
    required double x,
    required double y,
    bool isStaticText = false,
  }) {
    return PdfOverlayFieldModel(
      id: id,
      tag: tag,
      x: x,
      y: y,
      fontSize: lastFontSize,
      isBold: lastIsBold,
      isUnderline: lastIsUnderline,
      fontType: lastFontType,
      isStaticText: isStaticText,
    );
  }

  static void syncFromFields(List<PdfOverlayFieldModel> fields) {
    if (fields.isNotEmpty) {
      final last = fields.last;
      lastFontSize = last.fontSize;
      lastIsBold = last.isBold;
      lastIsUnderline = last.isUnderline;
      lastFontType = last.fontType;
    }
  }

  static void resetToDefault() {
    lastFontSize = 13.0;
    lastIsBold = false;
    lastIsUnderline = false;
    lastFontType = 'JameelNoori';
    toolbarScale = 1.0;
  }
}