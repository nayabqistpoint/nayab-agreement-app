import '../../../core/models/document_template_model.dart';
import '../../../shared_services/template_service.dart';

class StampPayloadBuilder {
  static Map<String, dynamic> build({
    required String title,
    required String content,
    required String paperSize,
    required double topMargin,
    required double subsequentTopMargin,
    required double bottomMargin,
    required double sideMargin,
    required double fontSize,
    required String? base64Pdf,
    required String? stampFileName,
    required List<String> pages,
  }) {
    final doc = DocumentTemplateModel(
      id: title,
      title: title,
      content: content.trim(),
      mode: DocumentMode.stampOverlay,
      paperSize: paperSize,
      topMargin: topMargin,
      subsequentTopMargin: subsequentTopMargin,
      bottomMargin: bottomMargin,
      sideMargin: sideMargin,
      fontSize: fontSize,
      base64Pdf: base64Pdf,
      stampFileName: stampFileName,
      fields: TemplateService.extractFields(content),
      pages: pages,
    );
    return doc.toMap();
  }
}