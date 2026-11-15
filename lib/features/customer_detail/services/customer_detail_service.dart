import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../../core/models/customer_deal_model.dart';
import '../../../core/models/customer_profile_model.dart';
import '../../../core/time/time_status_service.dart';

class CustomerDetailService {
  static CustomerProfileModel? getProfileById(String customerId) {
    final box = HiveBoxManager.getBox(BoxNames.customersBox);
    final raw = box.get(customerId);
    if (raw is Map) {
      final profile =
          CustomerProfileModel.fromMap(Map<String, dynamic>.from(raw));
      if (!profile.isDeleted) return profile;
    }
    return null;
  }

  static List<CustomerDealModel> getDealsByCnic(String cnic) {
    final cleanCnic = cnic.replaceAll('-', '').trim();
    if (cleanCnic.isEmpty) return [];

    final box = HiveBoxManager.getBox(BoxNames.customerDealsBox);
    final List<CustomerDealModel> deals = [];

    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        final deal = CustomerDealModel.fromMap(raw);
        if (!deal.isDeleted &&
            deal.customerCnic.replaceAll('-', '').trim() == cleanCnic) {
          deals.add(deal);
        }
      }
    }

    deals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return deals;
  }

  static Future<void> deleteSingleDeal(String dealId) async {
    final box = HiveBoxManager.getBox(BoxNames.customerDealsBox);
    final raw = box.get(dealId);
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      map['isDeleted'] = true;
      map['isSynced'] = false;
      map['updatedAt'] = TimeStatusService.nowUtcIso();

      await HiveBoxManager.putBatch(
        boxName: BoxNames.customerDealsBox,
        entries: {dealId: map},
      );
    }
  }

  static Future<void> deleteProfileAndDeals(
      String customerId, String cnic) async {
    final now = TimeStatusService.nowUtcIso();
    final custBox = HiveBoxManager.getBox(BoxNames.customersBox);
    final rawCust = custBox.get(customerId);
    if (rawCust is Map) {
      final map = Map<String, dynamic>.from(rawCust);
      map['isDeleted'] = true;
      map['isSynced'] = false;
      map['updatedAt'] = now;
      await HiveBoxManager.putBatch(
        boxName: BoxNames.customersBox,
        entries: {customerId: map},
      );
    }

    final cleanCnic = cnic.replaceAll('-', '').trim();
    final dealsBox = HiveBoxManager.getBox(BoxNames.customerDealsBox);
    final Map<String, dynamic> dealUpdates = {};
    for (final key in dealsBox.keys) {
      final rawDeal = dealsBox.get(key);
      if (rawDeal is Map) {
        final dMap = Map<String, dynamic>.from(rawDeal);
        final dCnic =
            (dMap['customerCnic']?.toString() ?? '').replaceAll('-', '').trim();
        if (dCnic == cleanCnic) {
          dMap['isDeleted'] = true;
          dMap['isSynced'] = false;
          dMap['updatedAt'] = now;
          dealUpdates[key.toString()] = dMap;
        }
      }
    }
    if (dealUpdates.isNotEmpty) {
      await HiveBoxManager.putBatch(
        boxName: BoxNames.customerDealsBox,
        entries: dealUpdates,
      );
    }
  }

  static Future<void> loadDealIntoDraft(
    CustomerDealModel deal, {
    bool asLegalNotice = false,
  }) async {
    final fields = Map<String, String>.from(deal.snapshotFieldValues);
    fields['تاریخ ڈیل'] = deal.createdAt.split('T').first;

    final Map<String, dynamic> draftEntries = {
      'fieldValues': fields,
      'customerCnic': deal.customerCnic,
      'phone': deal.snapshotFieldValues['رابطہ نمبر'] ?? '',
      'activePosOrderId': null,
      'updatedAt': TimeStatusService.nowUtcIso(),
      'isSynced': false,
    };

    if (asLegalNotice) {
      fields['بقایا اقساط کا نوٹس'] =
          'آپ کے ذمہ نایاب قسط پوائنٹ کی واجب الادا اقساط فوری ادا کریں۔';
      draftEntries['selectedTemplateTitle'] = 'قانونی نوٹس اقساط';
      draftEntries['paperSize'] = 'Legal';
      draftEntries['fontSize'] = 14.0;
    }

    await HiveBoxManager.putBatch(
      boxName: BoxNames.agreementDraftBox,
      entries: draftEntries,
    );
  }
}