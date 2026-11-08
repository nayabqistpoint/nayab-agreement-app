import '../../../core/models/document_template_model.dart';
import '../../../shared_services/agreement_storage_handler_service.dart';

class StampStorageHandlerService {
  static DocumentTemplateModel? fetchTemplate(String title) {
    final all = AgreementStorageHandlerService.getAllTemplates();
    if (all.containsKey(title)) {
      return DocumentTemplateModel.fromMap(all[title]!);
    }
    return null;
  }

  static Future<void> saveTemplate(Map<String, dynamic> payload) async {
    await AgreementStorageHandlerService.saveTemplate(payload);
  }
}