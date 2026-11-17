import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../../core/network/connectivity_service.dart';
import '../../../core/services/cloudinary_storage_service.dart';
import '../../../core/time/time_status_service.dart';

typedef StockMap = Map<String, dynamic>;
typedef StockList = List<StockMap>;

class StockInventoryStorageService {
  static const String configDocId = 'calculator_config';

  static StockMap getCalculatorConfig() {
    final box = HiveBoxManager.getBox(BoxNames.appConfigBox);
    final raw = box.get(configDocId);
    if (raw is Map) {
      return StockMap.from(raw);
    }
    return {
      'lastStockNumber': 0,
    };
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
    return 'STK_${nextNum.toString().padLeft(3, '0')}';
  }

  static Future<void> _updateCounter(String stockId) async {
    final match = RegExp(r'STK_(\d+)').firstMatch(stockId);
    if (match == null) return;
    final numVal = int.tryParse(match.group(1) ?? '0') ?? 0;
    if (numVal <= 0) return;

    final box = HiveBoxManager.getBox(BoxNames.appConfigBox);
    final raw = box.get(configDocId);
    final cfg = raw is Map ? StockMap.from(raw) : <String, dynamic>{};
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

  static Future<void> saveStock({
    required String stockId,
    required String category,
    required String itemName,
    required String imeiOrSerial,
    required String specsOrRam,
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
        ? StockMap.from(rawExisting)
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

    final isMob = category == 'MOBILE';
    final StockMap payload = {
      ...existingMap,
      'id': cleanId,
      'itemId': cleanId,
      'stockId': cleanId,
      'productCategory': isMob ? 'MOBILE' : 'ELECTRONICS',
      'itemName': itemName.trim(),
      'imeiNo': isMob ? imeiOrSerial.trim() : '',
      'serialNo': !isMob ? imeiOrSerial.trim() : '',
      'ramRom': isMob ? specsOrRam.trim() : '',
      'specsSummary': !isMob ? specsOrRam.trim() : '',
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
    await _updateCounter(cleanId);
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
}