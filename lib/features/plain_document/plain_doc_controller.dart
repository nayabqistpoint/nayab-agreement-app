import 'package:flutter/material.dart';
import '../../core/utils/paper_pagination_helper.dart';
import 'services/plain_doc_payload_builder.dart';
import 'services/plain_doc_storage_handler_service.dart';

class PlainDocController extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController(text: 'سادہ رسید و اقرار نامہ');
  final TextEditingController bodyController = TextEditingController();

  double topMargin = 45.0;
  double bottomMargin = 45.0;
  double sideMargin = 35.0;
  double fontSize = 13.5;

  void initFromTemplate(String? existingTitle) {
    if (existingTitle == null || existingTitle.isEmpty) return;
    final doc = PlainDocStorageHandlerService.fetchTemplate(existingTitle);
    if (doc == null) return;

    titleController.text = doc.title;
    bodyController.text = doc.content;
    topMargin = doc.topMargin;
    bottomMargin = doc.bottomMargin;
    sideMargin = doc.sideMargin;
    fontSize = doc.fontSize;
    notifyListeners();
  }

  void setFontSize(double size) { fontSize = size.clamp(10.0, 22.0); notifyListeners(); }
  void setTopMargin(double val) { topMargin = val.clamp(20.0, 300.0); notifyListeners(); }
  void setBottomMargin(double val) { bottomMargin = val.clamp(20.0, 300.0); notifyListeners(); }
  void setSideMargin(double val) { sideMargin = val.clamp(15.0, 150.0); notifyListeners(); }

  List<String> paginateText() {
    return AgreementPaginationService.paginate(
      fullText: bodyController.text,
      fontSize: fontSize,
      p1TopMargin: topMargin,
      subsequentTopMargin: topMargin,
      bottomMargin: bottomMargin,
      sideMargin: sideMargin,
      paperSize: 'A4',
    );
  }

  Future<bool> saveTemplate() async {
    final title = titleController.text.trim();
    if (title.isEmpty) return false;

    final payload = PlainDocPayloadBuilder.build(
      title: title,
      content: bodyController.text,
      fontSize: fontSize,
      topMargin: topMargin,
      bottomMargin: bottomMargin,
      sideMargin: sideMargin,
      pages: paginateText(),
    );

    await PlainDocStorageHandlerService.saveTemplate(payload);
    return true;
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }
}