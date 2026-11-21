import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../../core/models/tag_bank_item_model.dart';
import '../../../core/services/cloudinary_storage_service.dart';
import '../../../core/services/tags_bank_service.dart';
import '../../../core/time/time_status_service.dart';

typedef StockMap = Map<String, dynamic>;
typedef StockList = List<StockMap>;
typedef DynamicFieldDef = Map<String, String>;
typedef DynamicFieldDefList = List<DynamicFieldDef>;

class StockInventoryStorageService {
  static const String configDocId = 'calculator_config';

  static StockMap getCalculatorConfig() {
    final box = HiveBoxManager.getBox(BoxNames.appConfigBox);
    final raw = box.get(configDocId);
    if (raw is Map) {
      return StockMap.from(raw);
    }
    return {'lastStockNumber': 0};
  }

  static DynamicFieldDefList getCategoryDynamicFields({required bool isMobile}) {
    final cfg = getCalculatorConfig();
    final keyName = isMobile ? 'mobileCustomFields' : 'generalCustomFields';
    final rawList = cfg[keyName];
    if (rawList is List) {
      final DynamicFieldDefList result = [];
      for (final item in rawList) {
        if (item is Map) {
          final k = item['key']?.toString().trim() ?? '';
          final label = item['urduLabel']?.toString().trim() ?? '';
          if (k.isNotEmpty && label.isNotEmpty) {
            result.add({'key': k, 'urduLabel': label});
          }
        }
      }
      return result;
    }
    return [];
  }

  static Future<void> saveCategoryDynamicFields({
    required bool isMobile,
    required DynamicFieldDefList fields,
  }) async {
    final box = HiveBoxManager.getBox(BoxNames.appConfigBox);
    final raw = box.get(configDocId);
    final cfg = raw is Map ? StockMap.from(raw) : <String, dynamic>{};
    final now = TimeStatusService.nowUtcIso();
    final keyName = isMobile ? 'mobileCustomFields' : 'generalCustomFields';
    cfg[keyName] = fields;
    cfg['isSynced'] = false;
    cfg['updatedAt'] = now;
    await HiveBoxManager.putBatch(
      boxName: BoxNames.appConfigBox,
      entries: {configDocId: cfg},
    );
    for (final f in fields) {
      final k = f['key'] ?? '';
      final label = f['urduLabel'] ?? '';
      if (k.isNotEmpty && label.isNotEmpty) {
        await TagsBankService.saveTagItem(
          TagBankItemModel(
            id: 'pos_$k',
            urduName: label,
            source: TagSourceType.pos,
            rawKey: k,
            isEnabled: true,
            isSynced: false,
            updatedAt: now,
          ),
        );
      }
    }
  }

  static StockList getAllStockItems() {
    final box = HiveBoxManager.getBox(BoxNames.stockBox);
    final StockList list = [];
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        final item = StockMap.from(raw);
        final status = (item['status']?.toString() ?? '').trim().toUpperCase();
        if (item['isDeleted'] == true || status == 'DELETED') continue;
        item['id'] = item['id']?.toString() ?? key.toString();
        item['status'] = status.isEmpty ? 'AVAILABLE' : status;
        list.add(item);
      }
    }
    list.sort((a, b) {
      final idA = a['id']?.toString() ?? '';
      final idB = b['id']?.toString() ?? '';
      return idB.compareTo(idA);
    });
    return list;
  }

  static int getMaxStockNumber() {
    final stockBox = HiveBoxManager.getBox(BoxNames.stockBox);
    final cfg = getCalculatorConfig();
    int maxNum = (cfg['lastStockNumber'] as num?)?.toInt() ?? 0;
    for (final key in stockBox.keys) {
      final id = key.toString();
      final match = RegExp(r'STK_(\d+)').firstMatch(id);
      if (match != null) {
        final numVal = int.tryParse(match.group(1) ?? '0') ?? 0;
        if (numVal > maxNum) maxNum = numVal;
      }
    }
    return maxNum;
  }

  static List<String> previewNextStockIds(int count) {
    final int safeCount = count.clamp(1, 50);
    final int start = getMaxStockNumber();
    return List.generate(
      safeCount,
      (i) => 'STK_${(start + i + 1).toString().padLeft(3, '0')}',
    );
  }

  static Future<void> _updateCounterTo(int maxNum) async {
    if (maxNum <= 0) return;
    final box = HiveBoxManager.getBox(BoxNames.appConfigBox);
    final raw = box.get(configDocId);
    final cfg = raw is Map ? StockMap.from(raw) : <String, dynamic>{};
    final currentMax = (cfg['lastStockNumber'] as num?)?.toInt() ?? 0;
    if (maxNum > currentMax) {
      cfg['lastStockNumber'] = maxNum;
      cfg['isSynced'] = false;
      cfg['updatedAt'] = TimeStatusService.nowUtcIso();
      await HiveBoxManager.putBatch(
        boxName: BoxNames.appConfigBox,
        entries: {configDocId: cfg},
      );
    }
  }

  static ({String key, StockMap data})? _findOrderRecord(String orderId) {
    final cleanId = orderId.trim();
    if (cleanId.isEmpty) return null;
    final ordersBox = HiveBoxManager.getBox(BoxNames.shopOrdersBox);
    final direct = ordersBox.get(cleanId);
    if (direct is Map) {
      return (key: cleanId, data: StockMap.from(direct));
    }
    for (final k in ordersBox.keys) {
      final raw = ordersBox.get(k);
      if (raw is Map) {
        final rowId = raw['id']?.toString().trim() ?? '';
        final docId = raw['docId']?.toString().trim() ?? '';
        if (rowId == cleanId || docId == cleanId || k.toString() == cleanId) {
          return (key: k.toString(), data: StockMap.from(raw));
        }
      }
    }
    return null;
  }

  static Future<({int count, String firstStockId, String firstCode})> saveStock({
    required String stockId,
    required String category,
    required String itemName,
    required String imeiOrSerial,
    required String specsOrRam,
    required String color,
    required int purchasePrice,
    required int salePrice,
    required String supplier,
    required String conditionType,
    required String conditionRating,
    required int warrantyMonths,
    required bool isOnOrder,
    int quantity = 1,
    Map<String, String> dynamicFields = const {},
    Map<String, List<String>> perUnitOverrides = const {},
    List<String> images = const [],
    List<List<String>> perUnitImages = const [],
    String? linkToOrderId,
  }) async {
    final now = TimeStatusService.nowUtcIso();
    final box = HiveBoxManager.getBox(BoxNames.stockBox);
    final isEditing = stockId.trim().isNotEmpty;
    final int count = isEditing ? 1 : quantity.clamp(1, 50);
    int currentMax = getMaxStockNumber();
    final String firstId = isEditing
        ? stockId.trim()
        : 'STK_${(currentMax + 1).toString().padLeft(3, '0')}';

    // اگر یہ خریداری کسی کسٹم یا آن آرڈر کسٹمر کے لیے ہے تو پہلے ہی آرڈر تلاش کر لیں
    final cleanLinkOrderId = linkToOrderId?.trim() ?? '';
    final linkedOrderEntry = cleanLinkOrderId.isNotEmpty
        ? _findOrderRecord(cleanLinkOrderId)
        : null;

    String? linkedCustomerInfo;
    String? linkedPlanSummary;
    if (linkedOrderEntry != null) {
      final oMap = linkedOrderEntry.data;
      final cName = oMap['customerName']?.toString().trim() ?? '';
      final cCnic = oMap['customerCnic']?.toString().trim() ?? '';
      final int months = (oMap['totalMonths'] as num?)?.toInt() ?? 0;
      final int adv = (oMap['advance'] as num?)?.toInt() ?? 0;
      final int monthly = (oMap['monthlyAmount'] as num?)?.toInt() ?? 0;
      final String gType =
          (oMap['guaranteeType']?.toString() ?? '') == 'BANK_CHEQUE'
              ? 'بینک چیک'
              : 'اشٹام پرنوٹ';
      final String advText =
          adv > 0 ? 'ایڈوانس: Rs. $adv' : '⭐ بغیر ایڈوانس';
      linkedCustomerInfo = cCnic.isNotEmpty ? '$cName ($cCnic)' : cName;
      linkedPlanSummary =
          '$months ماہ • $advText • قسط: Rs. $monthly/ماہ ($gType)';
    }

    List<String> sharedProcessedImages = List<String>.from(images);
    if (sharedProcessedImages.isNotEmpty) {
      sharedProcessedImages = await CloudinaryStorageService.uploadStockImages(
        stockId: firstId,
        pathsOrUrls: sharedProcessedImages,
      );
    }

    String unitValue(String fieldKey, String fallback, int unitIdx) {
      final list = perUnitOverrides[fieldKey];
      if (!isEditing && list != null && unitIdx < list.length) {
        final v = list[unitIdx].trim();
        if (v.isNotEmpty) return v;
      }
      return fallback;
    }

    final Map<String, dynamic> batchEntries = {};
    final isMob = category == 'MOBILE';
    String firstResolvedCode = '';

    for (int i = 0; i < count; i++) {
      final String targetId;
      if (isEditing) {
        targetId = stockId.trim();
      } else {
        currentMax++;
        targetId = 'STK_${currentMax.toString().padLeft(3, '0')}';
      }

      List<String> unitImgs = [];
      if (!isEditing &&
          i < perUnitImages.length &&
          perUnitImages[i].isNotEmpty) {
        unitImgs = await CloudinaryStorageService.uploadStockImages(
          stockId: targetId,
          pathsOrUrls: List<String>.from(perUnitImages[i]),
        );
      } else {
        unitImgs = sharedProcessedImages;
      }

      final rawExisting = box.get(targetId);
      final existingMap = rawExisting is Map
          ? StockMap.from(rawExisting)
          : <String, dynamic>{};
      final existingStatus =
          (existingMap['status']?.toString() ?? 'AVAILABLE').toUpperCase();

      // پہلی یونٹ اگر کسٹمر آرڈر سے منسلک ہے تو ایٹامک طور پر RESERVED محفوظ ہوگی (زیرو بفر گیپ)
      final bool isUnitLinkedToOrder =
          i == 0 && linkedOrderEntry != null && !isOnOrder;

      String resolvedStatus;
      if (isUnitLinkedToOrder) {
        resolvedStatus = 'RESERVED';
      } else if (existingStatus == 'RESERVED' || existingStatus == 'SOLD') {
        resolvedStatus = existingStatus;
      } else {
        resolvedStatus = isOnOrder ? 'ON_ORDER' : 'AVAILABLE';
      }

      final String uName = unitValue('itemName', itemName.trim(), i);
      final String uCode =
          isOnOrder ? '' : unitValue('imeiOrSerial', imeiOrSerial.trim(), i);
      final String uSpecs = unitValue('specsOrRam', specsOrRam.trim(), i);
      final String uColor = unitValue('color', color.trim(), i);
      final String uCondition =
          unitValue('conditionType', conditionType.trim(), i);
      final int uWarranty =
          int.tryParse(unitValue('warranty', '$warrantyMonths', i)) ??
              warrantyMonths;
      final String uSupplier = unitValue('supplier', supplier.trim(), i);
      final int uPurchase =
          int.tryParse(unitValue('purchasePrice', '$purchasePrice', i)) ??
              purchasePrice;
      final int uSale =
          int.tryParse(unitValue('salePrice', '$salePrice', i)) ?? salePrice;

      if (i == 0) {
        firstResolvedCode = uCode;
      }

      final Map<String, String> uDynamic = {};
      dynamicFields.forEach((k, v) {
        uDynamic[k] = unitValue(k, v.trim(), i);
      });

      final StockMap payload = {
        ...existingMap,
        ...uDynamic,
        'id': targetId,
        'itemId': targetId,
        'stockId': targetId,
        'productCategory': isMob ? 'MOBILE' : 'ELECTRONICS',
        'itemName': uName,
        'imeiNo': isMob ? uCode : '',
        'serialNo': !isMob ? uCode : '',
        'ramRom': isMob ? uSpecs : '',
        'specsSummary': !isMob ? uSpecs : '',
        'color': uColor,
        'purchasePrice': uPurchase,
        'salePrice': uSale,
        'supplierInfo': uSupplier,
        'conditionType': uCondition,
        'conditionRating': conditionRating.trim(),
        'warranty': uWarranty,
        'isOnOrder': isOnOrder,
        'status': resolvedStatus,
        if (isUnitLinkedToOrder) ...{
          'reservedOrderId': linkedOrderEntry.key,
          'reservedCustomerInfo': linkedCustomerInfo,
          'reservedPlanSummary': linkedPlanSummary,
        },
        'images': unitImgs,
        'isDeleted': false,
        'isSynced': false,
        'updatedAt': now,
      };
      batchEntries[targetId] = payload;
    }

    await HiveBoxManager.putBatch(
      boxName: BoxNames.stockBox,
      entries: batchEntries,
    );

    if (!isEditing) {
      await _updateCounterTo(currentMax);
    }

    if (linkedOrderEntry != null) {
      final orderMap = StockMap.from(linkedOrderEntry.data);
      final resolvedName = unitValue('itemName', itemName.trim(), 0);
      orderMap['stockId'] = firstId;
      orderMap['stockIds'] = [firstId];
      orderMap['itemName'] = resolvedName;
      orderMap['productCategory'] = isMob ? 'MOBILE' : 'ELECTRONICS';
      if (isMob && firstResolvedCode.isNotEmpty) {
        orderMap['imeiNo'] = firstResolvedCode;
      } else if (!isMob && firstResolvedCode.isNotEmpty) {
        orderMap['serialNo'] = firstResolvedCode;
      }
      orderMap['isCustomEstimate'] = false;
      orderMap['updatedAt'] = now;
      orderMap['isSynced'] = false;

      await HiveBoxManager.putBatch(
        boxName: BoxNames.shopOrdersBox,
        entries: {linkedOrderEntry.key: orderMap},
      );
    }

    return (count: count, firstStockId: firstId, firstCode: firstResolvedCode);
  }

  static Future<bool> deleteStock(String stockId) async {
    final box = HiveBoxManager.getBox(BoxNames.stockBox);
    final raw = box.get(stockId);
    if (raw is Map) {
      final item = StockMap.from(raw);
      final st = (item['status']?.toString() ?? 'AVAILABLE').toUpperCase();
      if (st == 'RESERVED' || st == 'SOLD') return false;
      item['isDeleted'] = true;
      item['status'] = 'DELETED';
      item['isSynced'] = false;
      item['updatedAt'] = TimeStatusService.nowUtcIso();
      await HiveBoxManager.putBatch(
        boxName: BoxNames.stockBox,
        entries: {stockId: item},
      );
      return true;
    }
    return false;
  }

  static Future<int> purgeAllDeletedRecords() async {
    int purgedCount = 0;
    final firestore = FirebaseFirestore.instance;
    final boxCollectionPairs = <String, String>{
      BoxNames.stockBox: 'stock_box',
      BoxNames.shopOrdersBox: 'shop_orders_box',
      BoxNames.customersBox: 'customers_box',
      BoxNames.customerDealsBox: 'customer_deals_box',
      BoxNames.templatesBox: 'templates_box',
    };
    for (final entry in boxCollectionPairs.entries) {
      final box = HiveBoxManager.getBox(entry.key);
      final collectionName = entry.value;
      final List<dynamic> keysToDelete = [];
      for (final key in box.keys) {
        final raw = box.get(key);
        if (raw is Map) {
          final st = (raw['status']?.toString() ?? '').toUpperCase();
          if (raw['isDeleted'] == true || st == 'DELETED') {
            keysToDelete.add(key);
          }
        }
      }
      for (final key in keysToDelete) {
        try {
          await firestore
              .collection(collectionName)
              .doc(key.toString())
              .delete();
        } catch (_) {}
        await box.delete(key);
        purgedCount++;
      }
    }
    return purgedCount;
  }

  static Future<int> resetAllTestDataToZero() async {
    int clearedCount = 0;
    final firestore = FirebaseFirestore.instance;
    final boxCollectionPairs = <String, String>{
      BoxNames.stockBox: 'stock_box',
      BoxNames.shopOrdersBox: 'shop_orders_box',
      BoxNames.customersBox: 'customers_box',
      BoxNames.customerDealsBox: 'customer_deals_box',
    };
    for (final entry in boxCollectionPairs.entries) {
      final box = HiveBoxManager.getBox(entry.key);
      final collectionName = entry.value;
      final keys = box.keys.toList();
      for (final key in keys) {
        try {
          await firestore
              .collection(collectionName)
              .doc(key.toString())
              .delete();
        } catch (_) {}
        clearedCount++;
      }
      await box.clear();
    }
    final cfgBox = HiveBoxManager.getBox(BoxNames.appConfigBox);
    final rawCfg = cfgBox.get(configDocId);
    final cfg = rawCfg is Map ? StockMap.from(rawCfg) : <String, dynamic>{};
    cfg['lastStockNumber'] = 0;
    cfg['isSynced'] = false;
    cfg['updatedAt'] = TimeStatusService.nowUtcIso();
    await HiveBoxManager.putBatch(
      boxName: BoxNames.appConfigBox,
      entries: {configDocId: cfg},
    );
    return clearedCount;
  }
}