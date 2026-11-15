import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../../core/services/tags_bank_service.dart';
import '../../../core/time/time_status_service.dart';

typedef PosOrderMap = Map<String, dynamic>;

class CounterPosOrderService {
  static List<PosOrderMap> getPendingOrders() {
    try {
      final box = HiveBoxManager.getBox(BoxNames.shopOrdersBox);
      final List<PosOrderMap> orders = [];

      for (final key in box.keys) {
        final raw = box.get(key);
        if (raw is Map) {
          final map = PosOrderMap.from(raw);
          if (map['isDeleted'] == true) continue;
          final status = map['status']?.toString() ?? '';
          if (status == 'PENDING_AGREEMENT' || status.isEmpty) {
            map['id'] = map['id']?.toString() ?? key.toString();
            orders.add(map);
          }
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

  static Map<String, String> mapOrderToBucketFields(PosOrderMap order) {
    return TagsBankService.translatePosOrder(order);
  }

  /// حوالگی مکمل ہونے پر آرڈر کا اسٹیٹس AGREEMENT_COMPLETED کرنا
  static Future<void> markOrderAgreementCompleted(String orderId) async {
    await _updateOrderStatus(orderId, 'AGREEMENT_COMPLETED');
  }

  /// دستی طور پر آرڈر کو پینڈنگ لسٹ سے ختم کرنا (ہسٹری میں محفوظ رہے گا)
  static Future<void> dismissOrderFromPending(String orderId) async {
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