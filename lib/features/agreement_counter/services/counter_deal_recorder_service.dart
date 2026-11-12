import '../../../../core/constants/box_names.dart';
import '../../../../core/database/hive_box_manager.dart';
import '../../../../core/models/customer_deal_model.dart';
import '../../../../core/models/customer_profile_model.dart';
import '../../../../core/time/time_status_service.dart';

class CounterDealRecorderService {
  static Future<CustomerDealModel> recordDeal({
    required List<String> bundledTemplates,
    required Map<String, String> fieldValues,
    String? deliveryPhotoPath,
    String? signedDocPhotoPath,
  }) async {
    final now = TimeStatusService.nowUtcIso();
    final cnic = fieldValues['شناختی کارڈ']?.trim() ?? 'UNREGISTERED_${DateTime.now().millisecondsSinceEpoch}';
    final name = fieldValues['کسٹمر کا نام']?.trim() ?? 'نامعلوم کسٹمر';
    final dealId = 'DEAL_${DateTime.now().millisecondsSinceEpoch}';

    final deal = CustomerDealModel(
      id: dealId,
      customerCnic: cnic,
      customerName: name,
      mobileModel: fieldValues['موبائل ماڈل'] ?? '',
      imei: fieldValues['IMEI نمبر'] ?? '',
      totalAmount: fieldValues['ٹوٹل رقم'] ?? '0',
      advancePayment: fieldValues['ایڈوانس رقم'] ?? '0',
      monthlyInstallment: fieldValues['ماہانہ قسط'] ?? '0',
      duration: fieldValues['مدت'] ?? '',
      bundledTemplates: bundledTemplates,
      snapshotFieldValues: fieldValues,
      deliveryPhotoPath: deliveryPhotoPath,
      signedDocPhotoPath: signedDocPhotoPath,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
    );

    await HiveBoxManager.putBatch(
      boxName: BoxNames.customerDealsBox,
      entries: {dealId: deal.toMap()},
    );

    final customerBox = HiveBoxManager.getBox(BoxNames.customersBox);
    final rawCustomer = customerBox.get(cnic);
    if (rawCustomer == null && cnic.isNotEmpty) {
      final newProfile = CustomerProfileModel(
        id: cnic,
        fullName: name,
        fatherName: fieldValues['ولدیت'] ?? '',
        cnic: cnic,
        phone: fieldValues['رابطہ نمبر'] ?? '',
        address: fieldValues['مستقل پتہ'] ?? '',
        role: 'گاہک',
        isSynced: false,
        updatedAt: now,
        createdAt: now,
        isDeleted: false,
      );

      await HiveBoxManager.putBatch(
        boxName: BoxNames.customersBox,
        entries: {cnic: newProfile.toMap()},
      );
    }

    return deal;
  }

  static Future<void> updateDealMedia({
    required String dealId,
    String? deliveryPhotoPath,
    String? signedDocPhotoPath,
  }) async {
    final box = HiveBoxManager.getBox(BoxNames.customerDealsBox);
    final raw = box.get(dealId);
    if (raw is Map) {
      final current = CustomerDealModel.fromMap(raw);
      final updated = current.copyWith(
        deliveryPhotoPath: deliveryPhotoPath ?? current.deliveryPhotoPath,
        signedDocPhotoPath: signedDocPhotoPath ?? current.signedDocPhotoPath,
        updatedAt: TimeStatusService.nowUtcIso(),
        isSynced: false,
      );

      await HiveBoxManager.putBatch(
        boxName: BoxNames.customerDealsBox,
        entries: {dealId: updated.toMap()},
      );
    }
  }
}