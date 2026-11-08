import '../../../core/models/document_template_model.dart';

class FormFillerPayloadBuilder {
  static Map<String, dynamic> build({
    required String title,
    required String? base64Pdf,
    required String? fileName,
    required List<String> fields,
  }) {
    final doc = DocumentTemplateModel(
      id: title,
      title: title,
      content: '',
      mode: DocumentMode.formFiller,
      paperSize: 'A4',
      topMargin: 0.0,
      subsequentTopMargin: 0.0,
      bottomMargin: 0.0,
      sideMargin: 0.0,
      fontSize: 12.0,
      base64Pdf: base64Pdf,
      stampFileName: fileName,
      fields: fields,
      pages: [],
    );
    return doc.toMap();
  }
}