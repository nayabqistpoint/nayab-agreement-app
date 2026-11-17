import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../../core/models/tag_bank_item_model.dart';
import '../../../core/services/tags_bank_service.dart';
import '../../../core/time/time_status_service.dart';

typedef RemoteConfigMap = Map<String, dynamic>;
typedef FieldDefMap = Map<String, String>;
typedef FieldDefList = List<FieldDefMap>;

class PosRemoteConfigService {
  static const String configDocId = 'calculator_config';

  static FieldDefList defaultGeneralFields() {
    return [
      {'key': 'gen_category', 'urduLabel': 'پراڈکٹ کیٹیگری'},
      {'key': 'gen_serial', 'urduLabel': 'سیریل / چیسز نمبر'},
      {'key': 'gen_specs', 'urduLabel': 'سائز و تفصیل'},
      {'key': 'gen_brand', 'urduLabel': 'کمپنی / برانڈ'},
    ];
  }

  static RemoteConfigMap getFullConfig() {
    final box = HiveBoxManager.getBox(BoxNames.appConfigBox);
    final raw = box.get(configDocId);
    final RemoteConfigMap base = {
      'id': configDocId,
      // موبائل زون کے ریٹس
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
      // جنرل زون کے الگ ریٹس و فیلڈز
      'generalEnabled': true,
      'generalAdvancePercentage': 0.75,
      'generalProfitWithCheck': 0.25,
      'generalProfitWithoutCheck': 0.35,
      'generalPerMonthIncrement': 0.05,
      'generalProcessingFee': 0,
      'generalIsCompoundingProfit': false,
      'generalAllowedDurations': [6, 8, 10, 12, 15, 18],
      'generalMaxRiskLimit': 0,
      'generalRequireCustomerMobileMdm': true,
      'generalCustomFields': defaultGeneralFields(),
      'status': 'approved',
    };

    if (raw is Map) {
      raw.forEach((k, v) {
        if (k.toString() != 'zeroAdvanceMaxLimit') {
          base[k.toString()] = v;
        }
      });
    }
    return base;
  }

  static FieldDefList getGeneralCustomFields() {
    final cfg = getFullConfig();
    final rawList = cfg['generalCustomFields'];
    if (rawList is List) {
      final FieldDefList result = [];
      for (final item in rawList) {
        if (item is Map) {
          final k = item['key']?.toString().trim() ?? '';
          final label = item['urduLabel']?.toString().trim() ?? '';
          if (k.isNotEmpty && label.isNotEmpty) {
            result.add({'key': k, 'urduLabel': label});
          }
        }
      }
      if (result.isNotEmpty) return result;
    }
    return defaultGeneralFields();
  }

  static Future<bool> saveFullConfig(RemoteConfigMap updatedValues) async {
    try {
      final now = TimeStatusService.nowUtcIso();
      final current = getFullConfig();
      final RemoteConfigMap payload = {
        ...current,
        ...updatedValues,
        'id': configDocId,
        'status': 'approved',
        'isSynced': false,
        'updatedAt': now,
      };
      payload.remove('zeroAdvanceMaxLimit');

      await HiveBoxManager.putBatch(
        boxName: BoxNames.appConfigBox,
        entries: {configDocId: payload},
      );

      final customFields = getGeneralCustomFields();
      for (final field in customFields) {
        final key = field['key']!;
        final urdu = field['urduLabel']!;
        await TagsBankService.saveTagItem(
          TagBankItemModel(
            id: 'pos_$key',
            urduName: urdu,
            source: TagSourceType.pos,
            rawKey: key,
            isEnabled: true,
            isSynced: false,
            updatedAt: now,
          ),
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}