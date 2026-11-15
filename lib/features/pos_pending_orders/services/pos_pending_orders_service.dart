import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../../core/services/tags_bank_service.dart';
import '../../../core/time/time_status_service.dart';

typedef PosOrderRecord = Map<String, dynamic>;

class PosPendingOrdersService {
  /// ہائیو کے shop_orders_box سے تمام غیر حذف شدہ آرڈرز نکالنا
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

  /// صرف پینڈنگ آرڈرز نکالنا
  static List<PosOrderRecord> getPendingOrders() {
    return getAllOrders().where((map) {
      final status = (map['status']?.toString() ?? '').trim().toUpperCase();
      return status != 'AGREEMENT_COMPLETED' &&
          status != 'DISMISSED_BY_COUNTER' &&
          status != 'CANCELLED';
    }).toList();
  }

  /// منتخب کردہ آرڈر کو صاف بالٹی (agreement_draft_box) میں محفوظ کرنا
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

  /// آرڈر کو پینڈنگ لسٹ سے ختم کرنا اور متعلقہ موبائل کا اسٹاک اسٹیٹس واپس AVAILABLE کرنا
  static Future<void> dismissOrder(String orderId) async {
    if (orderId.trim().isEmpty) return;
    final box = HiveBoxManager.getBox(BoxNames.shopOrdersBox);
    final raw = box.get(orderId);
    if (raw is Map) {
      final now = TimeStatusService.nowUtcIso();
      final updated = PosOrderRecord.from(raw);
      final imei = updated['imeiNo']?.toString().trim() ?? '';

      updated['status'] = 'DISMISSED_BY_COUNTER';
      updated['updatedAt'] = now;
      updated['isSynced'] = false;

      await HiveBoxManager.putBatch(
        boxName: BoxNames.shopOrdersBox,
        entries: {orderId: updated},
      );

      // متعلقہ IMEI والے اسٹاک کو واپس AVAILABLE کر دیں
      if (imei.isNotEmpty && imei != 'null') {
        await releaseStockReservationByImei(imei);
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

  /// آرڈر منسوخ ہونے پر stock_box میں موبائل کا اسٹیٹس واپس AVAILABLE کرنا
  static Future<void> releaseStockReservationByImei(String imei) async {
    try {
      final stockBox = HiveBoxManager.getBox(BoxNames.stockBox);
      final now = TimeStatusService.nowUtcIso();

      for (final key in stockBox.keys) {
        final rawStock = stockBox.get(key);
        if (rawStock is Map) {
          final stockImei = rawStock['imeiNo']?.toString().trim() ?? '';
          if (stockImei == imei) {
            final updatedStock = Map<String, dynamic>.from(rawStock);
            updatedStock['status'] = 'AVAILABLE';
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
}