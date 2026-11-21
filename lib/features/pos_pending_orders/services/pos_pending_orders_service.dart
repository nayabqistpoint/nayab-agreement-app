import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../../core/services/tags_bank_service.dart';
import '../../../core/time/time_status_service.dart';

typedef PosOrderRecord = Map<String, dynamic>;

class PosPendingOrdersService {
  static bool isCashSaleRecord(PosOrderRecord map) {
    final st = (map['status']?.toString() ?? '').trim().toUpperCase();
    return st == 'CASH_SALE_COMPLETED' || map['isCashSale'] == true;
  }

  static List<PosOrderRecord> getAllOrders() {
    try {
      final box = HiveBoxManager.getBox(BoxNames.shopOrdersBox);
      final List<PosOrderRecord> orders = [];
      for (final key in box.keys) {
        final raw = box.get(key);
        if (raw is Map) {
          final map = PosOrderRecord.from(raw);
          if (map['isDeleted'] == true) continue;
          map['id'] = map['id']?.toString() ?? key.toString();
          orders.add(map);
        }
      }
      orders.sort((a, b) {
        final tA = a['createdAt']?.toString() ?? '';
        final tB = b['createdAt']?.toString() ?? '';
        return tB.compareTo(tA);
      });
      return orders;
    } catch (_) {
      return [];
    }
  }

  static List<PosOrderRecord> getInstallmentOrders() {
    return getAllOrders().where((map) => !isCashSaleRecord(map)).toList();
  }

  static List<PosOrderRecord> getPendingOrders() {
    return getInstallmentOrders().where((map) {
      final status = (map['status']?.toString() ?? '').trim().toUpperCase();
      return status != 'AGREEMENT_COMPLETED' &&
          status != 'DISMISSED_BY_COUNTER' &&
          status != 'CANCELLED';
    }).toList();
  }

  static List<PosOrderRecord> getCashSaleOrders() {
    return getAllOrders().where(isCashSaleRecord).toList();
  }

  static int getUnreadCashSalesCount() {
    return getCashSaleOrders()
        .where((map) => map['isCashSaleRead'] != true)
        .length;
  }

  static Future<void> markCashSaleAsRead(String orderId) async {
    if (orderId.trim().isEmpty) return;
    final box = HiveBoxManager.getBox(BoxNames.shopOrdersBox);
    final raw = box.get(orderId);
    if (raw is Map) {
      final updated = PosOrderRecord.from(raw);
      if (updated['isCashSaleRead'] == true) return;
      updated['isCashSaleRead'] = true;
      updated['updatedAt'] = TimeStatusService.nowUtcIso();
      updated['isSynced'] = false;
      await HiveBoxManager.putBatch(
        boxName: BoxNames.shopOrdersBox,
        entries: {orderId: updated},
      );
    }
  }

  static Future<void> markAllCashSalesAsRead() async {
    final box = HiveBoxManager.getBox(BoxNames.shopOrdersBox);
    final now = TimeStatusService.nowUtcIso();
    final Map<String, dynamic> batch = {};
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        final map = PosOrderRecord.from(raw);
        if (isCashSaleRecord(map) && map['isCashSaleRead'] != true) {
          map['isCashSaleRead'] = true;
          map['updatedAt'] = now;
          map['isSynced'] = false;
          batch[key.toString()] = map;
        }
      }
    }
    if (batch.isNotEmpty) {
      await HiveBoxManager.putBatch(
        boxName: BoxNames.shopOrdersBox,
        entries: batch,
      );
    }
  }

  static Future<void> applyOrderToDraftBucket(PosOrderRecord order) async {
    final now = TimeStatusService.nowUtcIso();
    final orderId = order['id']?.toString() ?? '';
    final mappedFields = TagsBankService.translatePosOrder(order);
    if (order['stockIds'] is List && (order['stockIds'] as List).isNotEmpty) {
      final joinedIds = (order['stockIds'] as List)
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .join(', ');
      if (joinedIds.isNotEmpty) {
        mappedFields['اسٹاک آئی ڈی'] = joinedIds;
      }
    }
    if (mappedFields.isEmpty) return;
    await HiveBoxManager.putBatch(
      boxName: BoxNames.agreementDraftBox,
      entries: {
        'fieldValues': mappedFields,
        'activePosOrderId': orderId,
        'customerCnic': mappedFields['شناختی کارڈ'] ?? '',
        'phone': mappedFields['رابطہ نمبر'] ?? '',
        'updatedAt': now,
        'isSynced': false,
      },
    );
  }

  static Future<void> dismissOrder(String orderId) async {
    if (orderId.trim().isEmpty) return;
    final box = HiveBoxManager.getBox(BoxNames.shopOrdersBox);
    final raw = box.get(orderId);
    if (raw is Map) {
      final now = TimeStatusService.nowUtcIso();
      final updated = PosOrderRecord.from(raw);
      final stockId = updated['stockId']?.toString().trim() ?? '';
      final imei = updated['imeiNo']?.toString().trim() ?? '';
      final List<String> allIds = (updated['stockIds'] is List)
          ? (updated['stockIds'] as List)
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList()
          : <String>[];
      updated['status'] = 'DISMISSED_BY_COUNTER';
      updated['updatedAt'] = now;
      updated['isSynced'] = false;
      await HiveBoxManager.putBatch(
        boxName: BoxNames.shopOrdersBox,
        entries: {orderId: updated},
      );
      if (allIds.isNotEmpty) {
        for (final sid in allIds) {
          await releaseStockReservation(stockId: sid, imei: '');
        }
      } else {
        await releaseStockReservation(stockId: stockId, imei: imei);
      }
      final draftBox = HiveBoxManager.getBox(BoxNames.agreementDraftBox);
      if (draftBox.get('activePosOrderId')?.toString() == orderId) {
        await HiveBoxManager.putBatch(
          boxName: BoxNames.agreementDraftBox,
          entries: {
            'fieldValues': <String, String>{},
            'activePosOrderId': null,
            'updatedAt': now,
            'isSynced': false,
          },
        );
      }
    }
  }

  static Future<void> releaseStockReservation({
    required String stockId,
    required String imei,
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
          if (updatedStock['status']?.toString().toUpperCase() == 'RESERVED') {
            updatedStock['status'] = updatedStock['isOnOrder'] == true
                ? 'ON_ORDER'
                : 'AVAILABLE';
            updatedStock['reservedOrderId'] = null;
            updatedStock['reservedCustomerInfo'] = null;
            updatedStock['reservedPlanSummary'] = null;
            updatedStock['updatedAt'] = now;
            updatedStock['isSynced'] = false;
            await HiveBoxManager.putBatch(
              boxName: BoxNames.stockBox,
              entries: {targetKey: updatedStock},
            );
          }
        }
      }
    } catch (_) {}
  }
}