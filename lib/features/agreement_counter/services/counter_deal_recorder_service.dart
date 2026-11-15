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
    final imei = fieldValues['IMEI نمبر']?.trim() ?? '';
    final dealId = 'DEAL_${DateTime.now().millisecondsSinceEpoch}';

    // سنیپ شاٹ فیلڈز میں اسٹاک سے سپلائر اور قیمت خرید بھی مستقل محفوظ کر لیں
    final enrichedSnapshot = Map<String, String>.from(fieldValues);
    if (imei.isNotEmpty && imei != 'null') {
      final stockMeta = _findStockByImei(imei);
      if (stockMeta != null) {
        final supplier = stockMeta['supplierInfo']?.toString().trim() ?? '';
        final pPrice = stockMeta['purchasePrice']?.toString().trim() ?? '';
        if (supplier.isNotEmpty &&
            (enrichedSnapshot['سپلائر'] ?? '').isEmpty) {
          enrichedSnapshot['سپلائر'] = supplier;
        }
        if (pPrice.isNotEmpty &&
            pPrice != '0' &&
            (enrichedSnapshot['قیمت خرید'] ?? '').isEmpty) {
          enrichedSnapshot['قیمت خرید'] = pPrice;
        }
      }
    }

    final deal = CustomerDealModel(
      id: dealId,
      customerCnic: cnic,
      customerName: name,
      mobileModel: enrichedSnapshot['موبائل ماڈل'] ?? '',
      imei: imei,
      totalAmount: enrichedSnapshot['ٹوٹل رقم'] ?? '0',
      advancePayment: enrichedSnapshot['ایڈوانس رقم'] ?? '0',
      monthlyInstallment: enrichedSnapshot['ماہانہ قسط'] ?? '0',
      duration: enrichedSnapshot['مدت'] ?? '',
      bundledTemplates: bundledTemplates,
      snapshotFieldValues: enrichedSnapshot,
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

    // 1. گاہک کا پروفائل محفوظ / اپڈیٹ کریں
    final rawCustomer = customerBox.get(cnic);
    final existing = rawCustomer is Map
        ? CustomerProfileModel.fromMap(Map<String, dynamic>.from(rawCustomer))
        : null;

    final customerProfile = CustomerProfileModel(
      id: cnic,
      fullName: name.isNotEmpty ? name : (existing?.fullName ?? ''),
      fatherName: (enrichedSnapshot['ولدیت'] ?? '').isNotEmpty
          ? enrichedSnapshot['ولدیت']!
          : (existing?.fatherName ?? ''),
      cnic: cnic,
      phone: (enrichedSnapshot['رابطہ نمبر'] ?? '').isNotEmpty
          ? enrichedSnapshot['رابطہ نمبر']!
          : (existing?.phone ?? ''),
      address: (enrichedSnapshot['مستقل پتہ'] ?? '').isNotEmpty
          ? enrichedSnapshot['مستقل پتہ']!
          : (existing?.address ?? ''),
      role: 'گاہک',
      isSynced: false,
      updatedAt: now,
      createdAt: existing?.createdAt ?? now,
      isDeleted: false,
    );
    profileUpdates[cnic] = customerProfile.toMap();

    // 2. ضامن کا پروفائل بھی محفوظ کریں
    final guarantorName = enrichedSnapshot['ضامن کا نام']?.trim() ?? '';
    final guarantorPhone = enrichedSnapshot['ضامن موبائل نمبر']?.trim() ?? '';
    final guarantorCnic = enrichedSnapshot['ضامن شناختی کارڈ']?.trim() ?? '';
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

    // 3. stock_box میں متعلقہ IMEI والے موبائل کو SOLD مارک کریں
    if (imei.isNotEmpty && imei != 'null') {
      await _markStockSoldByImei(
        imei: imei,
        soldToName: name,
        soldToCnic: cnic,
        dealId: dealId,
      );
    }

    return deal;
  }

  static Map<String, dynamic>? _findStockByImei(String imei) {
    try {
      final stockBox = HiveBoxManager.getBox(BoxNames.stockBox);
      for (final key in stockBox.keys) {
        final raw = stockBox.get(key);
        if (raw is Map && raw['imeiNo']?.toString().trim() == imei) {
          return Map<String, dynamic>.from(raw);
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<void> _markStockSoldByImei({
    required String imei,
    required String soldToName,
    required String soldToCnic,
    required String dealId,
  }) async {
    try {
      final stockBox = HiveBoxManager.getBox(BoxNames.stockBox);
      final now = TimeStatusService.nowUtcIso();

      for (final key in stockBox.keys) {
        final rawStock = stockBox.get(key);
        if (rawStock is Map) {
          final stockImei = rawStock['imeiNo']?.toString().trim() ?? '';
          if (stockImei == imei) {
            final updatedStock = Map<String, dynamic>.from(rawStock);
            updatedStock['status'] = 'SOLD';
            updatedStock['soldToName'] = soldToName;
            updatedStock['soldToCnic'] = soldToCnic;
            updatedStock['soldDealId'] = dealId;
            updatedStock['reservedOrderId'] = null;
            updatedStock['reservedCustomerInfo'] = null;
            updatedStock['updatedAt'] = now;
            updatedStock['isSynced'] = false;

            await HiveBoxManager.putBatch(
              boxName: BoxNames.stockBox,
              entries: {key.toString(): updatedStock},
            );
            break;
          }
        }
      }
    } catch (_) {}
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