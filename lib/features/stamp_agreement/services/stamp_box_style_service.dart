import '../models/stamp_overlay_field_model.dart';

class StampBoxStyleService {
  static double lastFontSize = 14.0;
  static bool lastIsBold = false;
  static bool lastIsUnderline = false;
  static String lastFontType = 'JameelNoori';
  // موبائل سکرین کے لیے شروع سے ہی بڑا اور نمایاں سکیل
  static double toolbarScale = 1.35;

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
    if (newToolbarScale != null) toolbarScale = newToolbarScale.clamp(1.0, 2.4);
  }

  static StampOverlayFieldModel createField({
    required String id,
    required String tag,
    required double x,
    required double y,
    int pageIndex = 0,
    bool isStaticText = false,
  }) {
    return StampOverlayFieldModel(
      id: id,
      tag: tag,
      x: x,
      y: y,
      pageIndex: pageIndex,
      fontSize: lastFontSize,
      isBold: lastIsBold,
      isUnderline: lastIsUnderline,
      fontType: lastFontType,
      isStaticText: isStaticText,
    );
  }

  static void syncFromFields(List<StampOverlayFieldModel> fields) {
    if (fields.isNotEmpty) {
      final last = fields.last;
      lastFontSize = last.fontSize;
      lastIsBold = last.isBold;
      lastIsUnderline = last.isUnderline;
      lastFontType = last.fontType;
    }
  }

  static void resetToDefault() {
    lastFontSize = 14.0;
    lastIsBold = false;
    lastIsUnderline = false;
    lastFontType = 'JameelNoori';
    toolbarScale = 1.35;
  }
}