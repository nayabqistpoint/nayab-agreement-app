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
    final cnic = fieldValues['شناختی کارڈ']?.trim() ?? '';
    if (cnic.isEmpty) {
      throw Exception('کسٹمر کا شناختی کارڈ نمبر درج کرنا لازمی ہے!');
    }

    final now = TimeStatusService.nowUtcIso();
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
    final Map<String, dynamic> profileUpdates = {};

    // 1. گاہک کا پروفائل محفوظ / اپڈیٹ کریں (CNIC کی بنیاد پر)
    final rawCustomer = customerBox.get(cnic);
    final existing = rawCustomer is Map
        ? CustomerProfileModel.fromMap(Map<String, dynamic>.from(rawCustomer))
        : null;

    final customerProfile = CustomerProfileModel(
      id: cnic,
      fullName: name.isNotEmpty ? name : (existing?.fullName ?? ''),
      fatherName: (fieldValues['ولدیت'] ?? '').isNotEmpty
          ? fieldValues['ولدیت']!
          : (existing?.fatherName ?? ''),
      cnic: cnic,
      phone: (fieldValues['رابطہ نمبر'] ?? '').isNotEmpty
          ? fieldValues['رابطہ نمبر']!
          : (existing?.phone ?? ''),
      address: (fieldValues['مستقل پتہ'] ?? '').isNotEmpty
          ? fieldValues['مستقل پتہ']!
          : (existing?.address ?? ''),
      role: 'گاہک',
      isSynced: false,
      updatedAt: now,
      createdAt: existing?.createdAt ?? now,
      isDeleted: false,
    );
    profileUpdates[cnic] = customerProfile.toMap();

    // 2. ضامن کا پروفائل بھی محفوظ کریں (اگر ضامن کا نام درج ہو)
    final guarantorName = fieldValues['ضامن کا نام']?.trim() ?? '';
    final guarantorPhone = fieldValues['ضامن موبائل نمبر']?.trim() ?? '';
    final guarantorCnic = fieldValues['ضامن شناختی کارڈ']?.trim() ?? '';
    if (guarantorName.isNotEmpty) {
      final guarantorKey = guarantorCnic.isNotEmpty
          ? guarantorCnic
          : (guarantorPhone.isNotEmpty
              ? 'G_${guarantorPhone.replaceAll(RegExp(r'[^0-9]'), '')}'
              : 'G_${guarantorName.hashCode}');

      final rawG = customerBox.get(guarantorKey);
      final existingG = rawG is Map
          ? CustomerProfileModel.fromMap(Map<String, dynamic>.from(rawG))
          : null;

      final guarantorProfile = CustomerProfileModel(
        id: guarantorKey,
        fullName: guarantorName,
        fatherName: existingG?.fatherName ?? '',
        cnic: guarantorCnic.isNotEmpty ? guarantorCnic : guarantorKey,
        phone: guarantorPhone.isNotEmpty
            ? guarantorPhone
            : (existingG?.phone ?? ''),
        address: existingG?.address ?? '',
        role: 'ضامن (سرپرست: $name)',
        isSynced: false,
        updatedAt: now,
        createdAt: existingG?.createdAt ?? now,
        isDeleted: false,
      );
      profileUpdates[guarantorKey] = guarantorProfile.toMap();
    }

    await HiveBoxManager.putBatch(
      boxName: BoxNames.customersBox,
      entries: profileUpdates,
    );

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