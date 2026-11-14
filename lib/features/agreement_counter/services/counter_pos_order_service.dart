import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../../core/time/time_status_service.dart';

typedef PosOrderMap = Map<String, dynamic>;

class CounterPosOrderService {
  /// ہائیو سے تمام پینڈنگ آرڈرز نکالنا (تازہ ترین سب سے اوپر)
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

  /// POS آرڈر کے فیلڈز کو ایگریمنٹ بکٹ کے اردو ٹیگز میں میپ کرنا
  static Map<String, String> mapOrderToBucketFields(PosOrderMap order) {
    final Map<String, String> mapped = {};

    void putIfNotEmpty(String urduKey, dynamic val) {
      final str = val?.toString().trim() ?? '';
      if (str.isNotEmpty && str != 'null') {
        mapped[urduKey] = str;
      }
    }

    putIfNotEmpty('دستاویز نمبر', order['docId'] ?? order['id']);
    putIfNotEmpty('کسٹمر کا نام', order['customerName']);
    putIfNotEmpty('رابطہ نمبر', order['customerPhone']);
    putIfNotEmpty('شناختی کارڈ', order['customerCnic']);
    putIfNotEmpty('ضامن کا نام', order['guarantorName']);
    putIfNotEmpty('ضامن موبائل نمبر', order['guarantorPhone']);
    putIfNotEmpty('موبائل ماڈل', order['itemName']);
    putIfNotEmpty('IMEI نمبر', order['imeiNo']);
    putIfNotEmpty('ٹوٹل رقم', order['totalContractAmount']);
    putIfNotEmpty('ایڈوانس رقم', order['advance']);
    putIfNotEmpty('ماہانہ قسط', order['monthlyAmount']);

    final months = order['totalMonths']?.toString().trim() ?? '';
    if (months.isNotEmpty && months != 'null') {
      mapped['مدت'] = '$months ماہ';
    }

    final gType = order['guaranteeType']?.toString() ?? '';
    if (gType == 'LEGAL_STAMP') {
      mapped['ضمانت'] = 'قانونی اشٹام و پرنوٹ';
    } else if (gType == 'CHEQUE') {
      final bank = order['bankName']?.toString() ?? '';
      final chq = order['chequeNo']?.toString() ?? '';
      mapped['ضمانت'] = 'بینک چیک ($bank - $chq)';
    }

    return mapped;
  }

  /// معاہدہ پرنٹ ہونے کے بعد POS آرڈر کا اسٹیٹس کلاؤڈ و لوکل میں مکمل مارک کرنا
  static Future<void> markOrderAgreementCompleted(String orderId) async {
    if (orderId.trim().isEmpty) return;
    try {
      final box = HiveBoxManager.getBox(BoxNames.shopOrdersBox);
      final raw = box.get(orderId);
      if (raw is Map) {
        final updated = PosOrderMap.from(raw);
        updated['status'] = 'AGREEMENT_COMPLETED';
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