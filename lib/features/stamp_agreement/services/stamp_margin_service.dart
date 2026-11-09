class StampMarginService {
  static ({double top, double subTop, double bottom, double side}) getDefaults(String size) {
    final isA4 = size.toUpperCase() == 'A4';
    return (
      top: isA4 ? 45.0 : 320.0,
      subTop: isA4 ? 45.0 : 65.0,
      bottom: isA4 ? 45.0 : 270.0,
      side: isA4 ? 35.0 : 40.0,
    );
  }

  static double clampTop(double val) => val.clamp(30.0, 700.0);
  static double clampSubTop(double val) => val.clamp(30.0, 400.0);
  static double clampBottom(double val) => val.clamp(30.0, 500.0);
  static double clampSide(double val) => val.clamp(15.0, 150.0);
  static double clampFontSize(double val) => val.roundToDouble().clamp(10.0, 32.0);
}