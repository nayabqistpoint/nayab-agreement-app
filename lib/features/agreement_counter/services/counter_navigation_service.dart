import 'package:flutter/material.dart';
import '../../../core/models/document_template_model.dart';
import '../../../shared_services/agreement_storage_handler_service.dart';
import '../../customer_directory/customer_directory_page.dart';
import '../../form_filler/form_filler_studio_page.dart';
import '../../plain_document/plain_doc_studio_page.dart';
import '../../stamp_agreement/stamp_studio_page.dart';

class CounterNavigationService {
  static Future<bool?> openEditor(BuildContext context, String templateTitle) async {
    final all = AgreementStorageHandlerService.getAllTemplates();
    Widget target = StampStudioPage(initialTitle: templateTitle);

    if (all.containsKey(templateTitle)) {
      final doc = DocumentTemplateModel.fromMap(all[templateTitle]!);
      if (doc.mode == DocumentMode.plainDocument) {
        target = PlainDocStudioPage(initialTitle: templateTitle);
      } else if (doc.mode == DocumentMode.formFiller) {
        target = FormFillerStudioPage(initialTitle: templateTitle);
      }
    }

    return await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => target));
  }

  static Future<bool?> openStudio(BuildContext context, Widget studioPage) async {
    return await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => studioPage));
  }

  static void openCustomerDirectory(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerDirectoryPage()));
  }
}