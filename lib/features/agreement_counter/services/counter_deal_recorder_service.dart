import '../../../../core/constants/box_names.dart';
import '../../../../core/database/hive_box_manager.dart';
import '../../../../core/models/customer_deal_model.dart';
import '../../../../core/models/customer_profile_model.dart';
import '../../../../core/time/time_status_service.dart';

class CounterDealRecorderService {
  static Future<CustomerDealModel> recordDeal({
    required List<String> bundledTemplates,
    required Map<String, String> fieldValues,
    List<String> deliveryPhotoPaths = const [],
    List<String> signedDocPhotoPaths = const [],
    String? activePosOrderId,
  }) async {
    final cnic = fieldValues['شناختی کارڈ']?.trim() ?? '';
    if (cnic.isEmpty) {
      throw Exception('کسٹمر کا شناختی کارڈ نمبر درج کرنا لازمی ہے!');
    }

    final now = TimeStatusService.nowUtcIso();
    final name = fieldValues['کسٹمر کا نام']?.trim() ?? 'نامعلوم کسٹمر';
    final imei = fieldValues['IMEI نمبر']?.trim() ?? '';
    final stockIdFromField = fieldValues['اسٹاک آئی ڈی']?.trim() ?? '';
    final dealId = 'DEAL_${DateTime.now().millisecondsSinceEpoch}';

    String? orderCustomerPhotoUrl;
    String? orderGuarantorPhotoUrl;
    String orderStockId = stockIdFromField;
    List<String> orderStockIds = [];
    String orderGuaranteeLabel = fieldValues['ضمانت']?.trim() ?? '';

    if (activePosOrderId != null && activePosOrderId.isNotEmpty) {
      final ordersBox = HiveBoxManager.getBox(BoxNames.shopOrdersBox);
      final rawOrder = ordersBox.get(activePosOrderId);
      if (rawOrder is Map) {
        final cu = rawOrder['customerPhotoUrl']?.toString().trim() ?? '';
        if (cu.isNotEmpty && cu != 'null') orderCustomerPhotoUrl = cu;
        final gu = rawOrder['guarantorPhotoUrl']?.toString().trim() ?? '';
        if (gu.isNotEmpty && gu != 'null') orderGuarantorPhotoUrl = gu;
        final sid = rawOrder['stockId']?.toString().trim() ?? '';
        if (sid.isNotEmpty && sid != 'null') orderStockId = sid;
        if (rawOrder['stockIds'] is List) {
          orderStockIds = (rawOrder['stockIds'] as List)
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty && e != 'null')
              .toList();
        }
        if (orderGuaranteeLabel.isEmpty) {
          final gRaw = rawOrder['guaranteeType']?.toString() ?? '';
          orderGuaranteeLabel =
              gRaw == 'BANK_CHEQUE' ? 'بینک چیک' : 'اشٹام پرنوٹ';
        }
      }
    }

    if (orderStockId.isNotEmpty && !orderStockIds.contains(orderStockId)) {
      orderStockIds.insert(0, orderStockId);
    }

    final enrichedSnapshot = Map<String, String>.from(fieldValues);
    if (orderStockIds.isNotEmpty) {
      enrichedSnapshot['اسٹاک آئی ڈی'] = orderStockIds.join(', ');
    }

    final stockMeta = _findStock(stockId: orderStockId, imei: imei);
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
      deliveryPhotoPaths: deliveryPhotoPaths,
      signedDocPhotoPaths: signedDocPhotoPaths,
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

    final guarantorName = enrichedSnapshot['ضامن کا نام']?.trim() ?? '';
    final guarantorPhone = enrichedSnapshot['ضامن موبائل نمبر']?.trim() ?? '';
    final guarantorCnic = enrichedSnapshot['ضامن شناختی کارڈ']?.trim() ?? '';

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
      photoUrl: orderCustomerPhotoUrl ?? existing?.photoUrl,
      role: 'گاہک',
      isSynced: false,
      updatedAt: now,
      createdAt: existing?.createdAt ?? now,
      isDeleted: false,
    );

    final custMap = customerProfile.toMap();
    if (guarantorName.isNotEmpty) {
      custMap['linkedGuarantorName'] = guarantorName;
      custMap['linkedGuarantorCnic'] = guarantorCnic;
      if (orderGuarantorPhotoUrl != null) {
        custMap['linkedGuarantorPhotoUrl'] = orderGuarantorPhotoUrl;
      }
    }
    profileUpdates[cnic] = custMap;

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
        fatherName: (enrichedSnapshot['ضامن ولدیت'] ?? '').isNotEmpty
            ? enrichedSnapshot['ضامن ولدیت']!
            : (existingG?.fatherName ?? ''),
        cnic: guarantorCnic.isNotEmpty ? guarantorCnic : guarantorKey,
        phone: guarantorPhone.isNotEmpty
            ? guarantorPhone
            : (existingG?.phone ?? ''),
        address: (enrichedSnapshot['ضامن پتہ'] ?? '').isNotEmpty
            ? enrichedSnapshot['ضامن پتہ']!
            : (existingG?.address ?? ''),
        photoUrl: orderGuarantorPhotoUrl ?? existingG?.photoUrl,
        role: 'ضامن (سرپرست: $name)',
        isSynced: false,
        updatedAt: now,
        createdAt: existingG?.createdAt ?? now,
        isDeleted: false,
      );
      profileUpdates[guarantorKey] = guarantorProfile.toMap();
    }

    final supplierRaw = enrichedSnapshot['سپلائر']?.trim() ?? '';
    if (supplierRaw.isNotEmpty) {
      final phoneMatch = RegExp(r'03\d{9}').firstMatch(supplierRaw);
      final supPhone = phoneMatch?.group(0) ?? '';
      final supName = supplierRaw.replaceAll(supPhone, '').trim();
      final supKey = supPhone.isNotEmpty
          ? 'SUP_$supPhone'
          : 'SUP_${supplierRaw.hashCode}';
      final rawSup = customerBox.get(supKey);
      final existingSup = rawSup is Map
          ? CustomerProfileModel.fromMap(Map<String, dynamic>.from(rawSup))
          : null;

      final supplierProfile = CustomerProfileModel(
        id: supKey,
        fullName: supName.isNotEmpty ? supName : supplierRaw,
        fatherName: '',
        cnic: supKey,
        phone: supPhone.isNotEmpty ? supPhone : (existingSup?.phone ?? ''),
        address: 'فراہم کردہ آئٹم: ${enrichedSnapshot['موبائل ماڈل'] ?? ''}',
        role: 'سپلائر / ڈیلر',
        isSynced: false,
        updatedAt: now,
        createdAt: existingSup?.createdAt ?? now,
        isDeleted: false,
      );
      profileUpdates[supKey] = supplierProfile.toMap();
    }

    await HiveBoxManager.putBatch(
      boxName: BoxNames.customersBox,
      entries: profileUpdates,
    );

    if (orderStockIds.isNotEmpty || (imei.isNotEmpty && imei != 'null')) {
      final int advNum =
          int.tryParse(enrichedSnapshot['ایڈوانس رقم']?.trim() ?? '0') ?? 0;
      final String monthly = enrichedSnapshot['ماہانہ قسط']?.trim() ?? '0';
      final String dur = enrichedSnapshot['مدت']?.trim() ?? '';
      final String advText =
          advNum > 0 ? 'ایڈوانس: Rs. $advNum' : '⭐ بغیر ایڈوانس';
      final String gPart =
          orderGuaranteeLabel.isNotEmpty ? ' ($orderGuaranteeLabel)' : '';
      final soldSummary = '$dur • $advText • قسط: Rs. $monthly/ماہ$gPart';

      if (orderStockIds.isNotEmpty) {
        for (final sid in orderStockIds) {
          await _markStockSold(
            stockId: sid,
            imei: imei,
            soldToName: name,
            soldToCnic: cnic,
            dealId: dealId,
            soldPlanSummary: soldSummary,
          );
        }
      } else {
        await _markStockSold(
          stockId: '',
          imei: imei,
          soldToName: name,
          soldToCnic: cnic,
          dealId: dealId,
          soldPlanSummary: soldSummary,
        );
      }
    }

    return deal;
  }

  static Map<String, dynamic>? _findStock({
    required String stockId,
    required String imei,
  }) {
    try {
      final stockBox = HiveBoxManager.getBox(BoxNames.stockBox);
      if (stockId.isNotEmpty && stockId != 'null') {
        final direct = stockBox.get(stockId);
        if (direct is Map) return Map<String, dynamic>.from(direct);
      }
      if (imei.isNotEmpty && imei != 'null') {
        for (final key in stockBox.keys) {
          final raw = stockBox.get(key);
          if (raw is Map && raw['imeiNo']?.toString().trim() == imei) {
            return Map<String, dynamic>.from(raw);
          }
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<void> _markStockSold({
    required String stockId,
    required String imei,
    required String soldToName,
    required String soldToCnic,
    required String dealId,
    required String soldPlanSummary,
  }) async {
    try {
      final stockBox = HiveBoxManager.getBox(BoxNames.stockBox);
      final now = TimeStatusService.nowUtcIso();
      String? targetKey;

      if (stockId.isNotEmpty &&
          stockId != 'null' &&
          stockBox.containsKey(stockId)) {
        targetKey = stockId;
      } else if (imei.isNotEmpty && imei != 'null') {
        for (final key in stockBox.keys) {
          final rawStock = stockBox.get(key);
          if (rawStock is Map &&
              rawStock['imeiNo']?.toString().trim() == imei) {
            targetKey = key.toString();
            break;
          }
        }
      }

      if (targetKey != null) {
        final rawStock = stockBox.get(targetKey);
        if (rawStock is Map) {
          final updatedStock = Map<String, dynamic>.from(rawStock);
          final currentStatus =
              (updatedStock['status']?.toString() ?? 'AVAILABLE').toUpperCase();
          if (currentStatus != 'ON_ORDER' && updatedStock['isOnOrder'] != true) {
            updatedStock['status'] = 'SOLD';
          }
          updatedStock['soldToName'] = soldToName;
          updatedStock['soldToCnic'] = soldToCnic;
          updatedStock['soldDealId'] = dealId;
          updatedStock['soldPlanSummary'] = soldPlanSummary;
          updatedStock['reservedOrderId'] = null;
          updatedStock['reservedCustomerInfo'] = null;
          updatedStock['updatedAt'] = now;
          updatedStock['isSynced'] = false;

          await HiveBoxManager.putBatch(
            boxName: BoxNames.stockBox,
            entries: {targetKey: updatedStock},
          );
        }
      }
    } catch (_) {}
  }

  static Future<void> updateDealMedia({
    required String dealId,
    List<String>? deliveryPhotoPaths,
    List<String>? signedDocPhotoPaths,
  }) async {
    final box = HiveBoxManager.getBox(BoxNames.customerDealsBox);
    final raw = box.get(dealId);
    if (raw is Map) {
      final current = CustomerDealModel.fromMap(raw);
      final updated = current.copyWith(
        deliveryPhotoPaths: deliveryPhotoPaths,
        signedDocPhotoPaths: signedDocPhotoPaths,
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