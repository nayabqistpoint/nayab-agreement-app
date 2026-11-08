class CounterPayloadBuilder {
  static Map<String, dynamic> buildDraftPayload({
    required String templateTitle,
    required String paperSize,
    required double fontSize,
    required Map<String, String> fieldValues,
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