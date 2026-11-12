import '../../../../core/constants/box_names.dart';
import '../../../../core/database/hive_box_manager.dart';
import '../../../../core/models/customer_deal_model.dart';

class CustomerNoticeGeneratorService {
  static Future<void> prepareNoticeInDraft(CustomerDealModel deal) async {
    final draftBox = HiveBoxManager.getBox(BoxNames.agreementDraftBox);

    final noticeFieldValues = Map<String, String>.from(deal.snapshotFieldValues);
    noticeFieldValues['تاریخ ڈیل'] = deal.createdAt.split('T').first;
    noticeFieldValues['بقایا اقساط کا نوٹس'] = 'آپ کے ذمہ نایاب قسط پوائنٹ کی واجب الادا اقساط فوری ادا کریں۔';

    await draftBox.putAll({
      'selectedTemplateTitle': 'قانونی نوٹس اقساط',
      'paperSize': 'Legal',
      'fontSize': 14.0,
      'fieldValues': noticeFieldValues,
      'customerCnic': deal.customerCnic,
      'phone': deal.snapshotFieldValues['رابطہ نمبر'] ?? '',
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
      'isSynced': false,
    });
  }
}