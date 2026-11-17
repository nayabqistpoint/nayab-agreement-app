import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../../core/network/connectivity_service.dart';
import '../../../core/services/cloudinary_storage_service.dart';
import '../../../core/time/time_status_service.dart';

typedef ControlDataMap = Map<String, dynamic>;

class PosControlStorageService {
  static const String configDocId = 'calculator_config';

  static ControlDataMap getCalculatorConfig() {
    final box = HiveBoxManager.getBox(BoxNames.appConfigBox);
    final raw = box.get(configDocId);
    if (raw is Map) {
      final map = ControlDataMap.from(raw);
      map.remove('zeroAdvanceMaxLimit');
      map['maxRiskLimit'] = (map['maxRiskLimit'] as num?)?.toInt() ?? 0;
      return map;
    }
    return {
      'id': configDocId,
      'advancePercentage': 0.8,
      'profitWithCheck': 0.25,
      'profitWithoutCheck': 0.35,
      'perMonthIncrement': 0.05,
      'gracePeriodDays': 15,
      'installmentDueDay': 5,
      'processingFee': 0,
      'roundToNearest': 100,
      'isCompoundingProfit': false,
      'addProcessingFeeToPrincipal': false,
      'allowedDurations': [6, 7, 8, 9, 10, 11, 12],
      'mdmLockFee': 1000,
      'openBoxDeductionType': 'PERCENT',
      'openBoxDeductionValue': 10,
      'maxRiskLimit': 0,
      'adminOverridePin': '7860',
      'lastStockNumber': 0,
      'status': 'approved',
    };
  }

  static Future<bool> saveCalculatorConfig({
    required double advancePercentage,
    required double profitWithCheck,
    required double profitWithoutCheck,
    required double perMonthIncrement,
    required int gracePeriodDays,
    required int installmentDueDay,
    required int processingFee,
    required int roundToNearest,
    required bool isCompoundingProfit,
    required bool addProcessingFeeToPrincipal,
    required List<int> allowedDurations,
    int mdmLockFee = 1000,
    String openBoxDeductionType = 'PERCENT',
    int openBoxDeductionValue = 10,
    int maxRiskLimit = 0,
    String adminOverridePin = '7860',
  }) async {
    try {
      final now = TimeStatusService.nowUtcIso();
      final existingCfg = getCalculatorConfig();
      final payload = <String, dynamic>{
        ...existingCfg,
        'id': configDocId,
        'advancePercentage': advancePercentage,
        'profitWithCheck': profitWithCheck,
        'profitWithoutCheck': profitWithoutCheck,
        'perMonthIncrement': perMonthIncrement,
        'gracePeriodDays': gracePeriodDays,
        'installmentDueDay': installmentDueDay,
        'processingFee': processingFee,
        'roundToNearest': roundToNearest,
        'isCompoundingProfit': isCompoundingProfit,
        'addProcessingFeeToPrincipal': addProcessingFeeToPrincipal,
        'allowedDurations': List<int>.from(allowedDurations),
        'mdmLockFee': mdmLockFee,
        'openBoxDeductionType': openBoxDeductionType,
        'openBoxDeductionValue': openBoxDeductionValue,
        'maxRiskLimit': maxRiskLimit < 0 ? 0 : maxRiskLimit,
        'adminOverridePin':
            adminOverridePin.trim().isEmpty ? '7860' : adminOverridePin.trim(),
        'status': 'approved',
        'isSynced': false,
        'updatedAt': now,
      };
      await HiveBoxManager.putBatch(
        boxName: BoxNames.appConfigBox,
        entries: {configDocId: payload},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  static List<ControlDataMap> getAllStockItems() {
    final box = HiveBoxManager.getBox(BoxNames.stockBox);
    final List<ControlDataMap> list = [];
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        final item = ControlDataMap.from(raw);
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

  /// مسلسل بڑھتی ہوئی منفرد اسٹاک ID (STK_001, STK_002...) — پرانا نمبر کبھی دہرایا نہیں جائے گا
  static String generateNextStockId() {
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
    final nextNum = maxNum + 1;
    final nextStr = nextNum.toString().padLeft(3, '0');
    return 'STK_$nextStr';
  }

  static Future<void> _updateLastStockCounter(String stockId) async {
    final match = RegExp(r'STK_(\d+)').firstMatch(stockId);
    if (match == null) return;
    final numVal = int.tryParse(match.group(1) ?? '0') ?? 0;
    if (numVal <= 0) return;

    final cfg = getCalculatorConfig();
    final currentMax = (cfg['lastStockNumber'] as num?)?.toInt() ?? 0;
    if (numVal > currentMax) {
      cfg['lastStockNumber'] = numVal;
      cfg['isSynced'] = false;
      cfg['updatedAt'] = TimeStatusService.nowUtcIso();
      await HiveBoxManager.putBatch(
        boxName: BoxNames.appConfigBox,
        entries: {configDocId: cfg},
      );
    }
  }

  static Future<void> saveStockItem({
    required String stockId,
    String productCategory = 'MOBILE',
    required String itemName,
    required String imeiNo,
    String serialNo = '',
    required String ramRom,
    String specsSummary = '',
    required String color,
    required int purchasePrice,
    required int salePrice,
    required String supplierInfo,
    required String conditionType,
    required String conditionRating,
    required int warrantyMonths,
    List<String> images = const [],
  }) async {
    final cleanId =
        stockId.trim().isEmpty ? generateNextStockId() : stockId.trim();
    final now = TimeStatusService.nowUtcIso();
    final box = HiveBoxManager.getBox(BoxNames.stockBox);
    final rawExisting = box.get(cleanId);
    final existingMap = rawExisting is Map
        ? ControlDataMap.from(rawExisting)
        : <String, dynamic>{};
    final existingStatus =
        (existingMap['status']?.toString() ?? 'AVAILABLE').toUpperCase();

    List<String> processedImages = List<String>.from(images);
    if (processedImages.isNotEmpty && await ConnectivityService.isOnline) {
      processedImages = await CloudinaryStorageService.uploadStockImages(
        stockId: cleanId,
        pathsOrUrls: processedImages,
      );
    }

    final payload = <String, dynamic>{
      ...existingMap,
      'id': cleanId,
      'itemId': cleanId,
      'stockId': cleanId,
      'productCategory': productCategory,
      'itemName': itemName.trim(),
      'imeiNo': imeiNo.trim(),
      'serialNo': serialNo.trim(),
      'ramRom': ramRom.trim(),
      'specsSummary': specsSummary.trim(),
      'color': color.trim(),
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'supplierInfo': supplierInfo.trim(),
      'conditionType': conditionType,
      'conditionRating': conditionRating.trim(),
      'warranty': warrantyMonths,
      'status': existingStatus == 'DELETED' ? 'AVAILABLE' : existingStatus,
      'images': processedImages,
      'isDeleted': false,
      'isSynced': false,
      'updatedAt': now,
    };
    await HiveBoxManager.putBatch(
      boxName: BoxNames.stockBox,
      entries: {cleanId: payload},
    );
    await _updateLastStockCounter(cleanId);
  }

  static Future<bool> softDeleteStockItem(String stockId) async {
    final box = HiveBoxManager.getBox(BoxNames.stockBox);
    final raw = box.get(stockId);
    if (raw is Map) {
      final updated = ControlDataMap.from(raw);
      final status = (updated['status']?.toString() ?? 'AVAILABLE').toUpperCase();
      if (status == 'RESERVED' || status == 'SOLD') {
        return false;
      }
      updated['isDeleted'] = true;
      updated['status'] = 'DELETED';
      updated['isSynced'] = false;
      updated['updatedAt'] = TimeStatusService.nowUtcIso();
      await HiveBoxManager.putBatch(
        boxName: BoxNames.stockBox,
        entries: {stockId: updated},
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
          await firestore.collection(collectionName).doc(key.toString()).delete();
        } catch (_) {}
        await box.delete(key);
        purgedCount++;
      }
    }
    return purgedCount;
  }
}