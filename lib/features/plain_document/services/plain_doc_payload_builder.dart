import '../../../core/models/document_template_model.dart';
import '../../../core/utils/tag_extraction_helper.dart';

class PlainDocPayloadBuilder {
  static Map<String, dynamic> build({
    required String title,
    required String content,
    required double fontSize,
    required double topMargin,
    required double bottomMargin,
    required double sideMargin,
    required List<String> pages,
  }) {
    final doc = DocumentTemplateModel(
      id: title,
      title: title,
      content: content.trim(),
      mode: DocumentMode.plainDocument,
      paperSize: 'A4',
      topMargin: topMargin,
      subsequentTopMargin: topMargin,
      bottomMargin: bottomMargin,
      sideMargin: sideMargin,
      fontSize: fontSize,
      base64Pdf: null,
      stampFileName: null,
      fields: TemplateService.extractFields(content),
      pages: pages,
    );
    return doc.toMap();
  }
}