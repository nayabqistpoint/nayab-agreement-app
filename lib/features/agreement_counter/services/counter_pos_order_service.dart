import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../../core/services/tags_bank_service.dart';
import '../../../core/time/time_status_service.dart';
import '../../pos_pending_orders/services/pos_pending_orders_service.dart';

typedef PosOrderMap = Map<String, dynamic>;

class CounterPosOrderService {
  static List<PosOrderMap> getAllOrders() {
    try {
      final box = HiveBoxManager.getBox(BoxNames.shopOrdersBox);
      final List<PosOrderMap> orders = [];
      for (final key in box.keys) {
        final raw = box.get(key);
        if (raw is Map) {
          final map = PosOrderMap.from(raw);
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

  static List<PosOrderMap> getPendingOrders() {
    return getAllOrders().where((map) {
      final status = (map['status']?.toString() ?? '').trim().toUpperCase();
      return status != 'AGREEMENT_COMPLETED' &&
          status != 'DISMISSED_BY_COUNTER' &&
          status != 'CANCELLED';
    }).toList();
  }

  static Map<String, String> mapOrderToBucketFields(PosOrderMap order) {
    return TagsBankService.translatePosOrder(order);
  }

  static Future<void> markOrderAgreementCompleted(String orderId) async {
    await _updateOrderStatus(orderId, 'AGREEMENT_COMPLETED');
  }

  static Future<void> dismissOrderFromPending(String orderId) async {
    if (orderId.trim().isEmpty) return;
    final box = HiveBoxManager.getBox(BoxNames.shopOrdersBox);
    final raw = box.get(orderId);
    if (raw is Map) {
      final stockId = raw['stockId']?.toString().trim() ?? '';
      final imei = raw['imeiNo']?.toString().trim() ?? '';
      await PosPendingOrdersService.releaseStockReservation(
        stockId: stockId,
        imei: imei,
      );
    }
    await _updateOrderStatus(orderId, 'DISMISSED_BY_COUNTER');
  }

  static Future<void> _updateOrderStatus(
      String orderId, String newStatus) async {
    if (orderId.trim().isEmpty) return;
    try {
      final box = HiveBoxManager.getBox(BoxNames.shopOrdersBox);
      final raw = box.get(orderId);
      if (raw is Map) {
        final updated = PosOrderMap.from(raw);
        updated['status'] = newStatus;
        updated['updatedAt'] = TimeStatusService.nowUtcIso();
        updated['isSynced'] = false;
        await HiveBoxManager.putBatch(
          boxName: BoxNames.shopOrdersBox,
          entries: {orderId: updated},
        );
      }
    } catch (_) {}
  }
}