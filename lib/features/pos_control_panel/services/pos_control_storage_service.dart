import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../../core/time/time_status_service.dart';

typedef ControlDataMap = Map<String, dynamic>;

class PosControlStorageService {
  static const String configDocId = 'calculator_config';

  /// کیلکولیٹر کنفیگ پڑھنا (اگر موجود نہ ہو تو ڈیفالٹ اقدار)
  static ControlDataMap getCalculatorConfig() {
    final box = HiveBoxManager.getBox(BoxNames.appConfigBox);
    final raw = box.get(configDocId);
    if (raw is Map) {
      return ControlDataMap.from(raw);
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
      'status': 'approved',
    };
  }

  /// کیلکولیٹر کنفیگ محفوظ کرنا (isSynced: false کے ساتھ تاکہ فوری کلاؤڈ پر پش ہو)
  static Future<void> saveCalculatorConfig({
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
  }) async {
    final now = TimeStatusService.nowUtcIso();
    final payload = <String, dynamic>{
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
      'allowedDurations': allowedDurations,
      'status': 'approved',
      'isSynced': false,
      'updatedAt': now,
    };

    await HiveBoxManager.putBatch(
      boxName: BoxNames.appConfigBox,
      entries: {configDocId: payload},
    );
  }

  /// تمام فعال اسٹاک آئٹمز نکالنا
  static List<ControlDataMap> getAllStockItems() {
    final box = HiveBoxManager.getBox(BoxNames.stockBox);
    final List<ControlDataMap> list = [];

    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        final item = ControlDataMap.from(raw);
        if (item['isDeleted'] == true) continue;
        item['id'] = item['id']?.toString() ?? key.toString();
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

  /// اگلا خودکار اسٹاک کوڈ جنریٹ کرنا (مثلاً STK_004)
  static String generateNextStockId() {
    final items = getAllStockItems();
    int maxNum = 0;
    for (final item in items) {
      final id = item['id']?.toString() ?? '';
      final match = RegExp(r'STK_(\d+)').firstMatch(id);
      if (match != null) {
        final numVal = int.tryParse(match.group(1) ?? '0') ?? 0;
        if (numVal > maxNum) maxNum = numVal;
      }
    }
    final next = (maxNum + 1).toString().padLeft(3, '0');
    return 'STK_$next';
  }

  /// نیا یا ترمیم شدہ اسٹاک آئٹم محفوظ کرنا
  static Future<void> saveStockItem({
    required String stockId,
    required String itemName,
    required String imeiNo,
    required String ramRom,
    required String color,
    required int salePrice,
    required String conditionType,
    required String conditionRating,
    required int warrantyMonths,
  }) async {
    final cleanId = stockId.trim().isEmpty ? generateNextStockId() : stockId.trim();
    final now = TimeStatusService.nowUtcIso();

    final payload = <String, dynamic>{
      'id': cleanId,
      'itemId': cleanId,
      'itemName': itemName.trim(),
      'imeiNo': imeiNo.trim(),
      'ramRom': ramRom.trim(),
      'color': color.trim(),
      'salePrice': salePrice,
      'conditionType': conditionType,
      'conditionRating': conditionRating.trim(),
      'warranty': warrantyMonths,
      'status': 'available',
      'images': [],
      'isDeleted': false,
      'isSynced': false,
      'updatedAt': now,
    };

    await HiveBoxManager.putBatch(
      boxName: BoxNames.stockBox,
      entries: {cleanId: payload},
    );
  }

  /// اسٹاک آئٹم کو سافٹ ڈیلیٹ کرنا (کلاؤڈ و POS دونوں سے ہٹانے کیلئے)
  static Future<void> softDeleteStockItem(String stockId) async {
    final box = HiveBoxManager.getBox(BoxNames.stockBox);
    final raw = box.get(stockId);
    if (raw is Map) {
      final updated = ControlDataMap.from(raw);
      updated['isDeleted'] = true;
      updated['status'] = 'deleted';
      updated['isSynced'] = false;
      updated['updatedAt'] = TimeStatusService.nowUtcIso();

      await HiveBoxManager.putBatch(
        boxName: BoxNames.stockBox,
        entries: {stockId: updated},
      );
    }
  }
}