class BucketPayloadBuilder {
  static Map<String, dynamic> buildDraft({
    required Map<String, String> fieldValues,
    required String templateTitle,
    required String paperSize,
    required double fontSize,
    String? stampFileName,
  }) {
    return {
      'selectedTemplateTitle': templateTitle,
      'paperSize': paperSize,
      'fontSize': fontSize,
      'fieldValues': fieldValues,
      'stampFileName': stampFileName,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
      'isSynced': false,
    };
  }
}