import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../../core/services/tags_bank_service.dart';
import '../../../core/time/time_status_service.dart';

typedef PosOrderRecord = Map<String, dynamic>;

class PosPendingOrdersService {
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

  static List<PosOrderRecord> getPendingOrders() {
    return getAllOrders().where((map) {
      final status = (map['status']?.toString() ?? '').trim().toUpperCase();
      return status != 'AGREEMENT_COMPLETED' &&
          status != 'DISMISSED_BY_COUNTER' &&
          status != 'CANCELLED';
    }).toList();
  }

  static Future<void> applyOrderToDraftBucket(PosOrderRecord order) async {
    final mappedFields = TagsBankService.translatePosOrder(order);
    if (mappedFields.isEmpty) return;
    await HiveBoxManager.putBatch(
      boxName: BoxNames.agreementDraftBox,
      entries: {
        'fieldValues': mappedFields,
        'activePosOrderId': order['id']?.toString(),
        'customerCnic': mappedFields['شناختی کارڈ'] ?? '',
        'phone': mappedFields['رابطہ نمبر'] ?? '',
        'updatedAt': TimeStatusService.nowUtcIso(),
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

      updated['status'] = 'DISMISSED_BY_COUNTER';
      updated['updatedAt'] = now;
      updated['isSynced'] = false;

      await HiveBoxManager.putBatch(
        boxName: BoxNames.shopOrdersBox,
        entries: {orderId: updated},
      );

      await releaseStockReservation(stockId: stockId, imei: imei);

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