import '../constants/box_names.dart';
import '../database/hive_box_manager.dart';
import '../models/tag_bank_item_model.dart';
import '../time/time_status_service.dart';

typedef TagRawMap = Map<String, dynamic>;

class TagsBankService {
  static Future<void> seedDefaultTagsIfEmpty() async {
    final box = HiveBoxManager.getBox(BoxNames.tagsBox);
    if (box.isNotEmpty) return;

    final now = TimeStatusService.nowUtcIso();
    final TagRawMap initialEntries = {};
    int orderCounter = 0;

    void addSeed(
      String id,
      String urdu,
      TagSourceType src, {
      String? rawKey,
      bool enabled = true,
      Map<String, String> trans = const {},
    }) {
      final item = TagBankItemModel(
        id: id,
        urduName: urdu,
        source: src,
        rawKey: rawKey,
        isEnabled: enabled,
        valueTranslations: trans,
        isSynced: false,
        updatedAt: now,
      );
      final map = item.toMap();
      map['sortOrder'] = orderCounter++;
      initialEntries[id] = map;
    }

    addSeed('pos_docId', 'دستاویز نمبر', TagSourceType.pos, rawKey: 'docId');
    addSeed('pos_stockId', 'اسٹاک آئی ڈی', TagSourceType.pos, rawKey: 'stockId');
    addSeed('pos_customerName', 'کسٹمر کا نام', TagSourceType.pos,
        rawKey: 'customerName');
    addSeed('pos_customerFatherName', 'ولدیت', TagSourceType.pos,
        rawKey: 'customerFatherName');
    addSeed('pos_customerCaste', 'قومیت', TagSourceType.pos,
        rawKey: 'customerCaste');
    addSeed('pos_customerPhone', 'رابطہ نمبر', TagSourceType.pos,
        rawKey: 'customerPhone');
    addSeed('pos_customerCnic', 'شناختی کارڈ', TagSourceType.pos,
        rawKey: 'customerCnic');
    addSeed('pos_customerAddress', 'مستقل پتہ', TagSourceType.pos,
        rawKey: 'customerAddress');
    addSeed('pos_guarantorName', 'ضامن کا نام', TagSourceType.pos,
        rawKey: 'guarantorName');
    addSeed('pos_guarantorFatherName', 'ضامن ولدیت', TagSourceType.pos,
        rawKey: 'guarantorFatherName');
    addSeed('pos_guarantorCaste', 'ضامن قومیت', TagSourceType.pos,
        rawKey: 'guarantorCaste');
    addSeed('pos_guarantorPhone', 'ضامن موبائل نمبر', TagSourceType.pos,
        rawKey: 'guarantorPhone');
    addSeed('pos_guarantorCnic', 'ضامن شناختی کارڈ', TagSourceType.pos,
        rawKey: 'guarantorCnic');
    addSeed('pos_guarantorAddress', 'ضامن پتہ', TagSourceType.pos,
        rawKey: 'guarantorAddress');
    addSeed('pos_guarantorRelation', 'ضامن رشتہ', TagSourceType.pos,
        rawKey: 'guarantorRelation');
    addSeed('pos_guardianPhone', 'سرپرست فون', TagSourceType.pos,
        rawKey: 'guardianPhone');
    addSeed('pos_itemName', 'موبائل ماڈل', TagSourceType.pos,
        rawKey: 'itemName');
    addSeed('pos_imeiNo', 'IMEI نمبر', TagSourceType.pos, rawKey: 'imeiNo');
    addSeed('pos_serialNo', 'سیریل نمبر', TagSourceType.pos, rawKey: 'serialNo');
    addSeed('pos_specsSummary', 'تفصیل و سائز', TagSourceType.pos,
        rawKey: 'specsSummary');
    addSeed('pos_totalContractAmount', 'ٹوٹل رقم', TagSourceType.pos,
        rawKey: 'totalContractAmount');
    addSeed('pos_advance', 'ایڈوانس رقم', TagSourceType.pos,
        rawKey: 'advance');
    addSeed('pos_monthlyAmount', 'ماہانہ قسط', TagSourceType.pos,
        rawKey: 'monthlyAmount');
    addSeed('pos_totalMonths', 'مدت', TagSourceType.pos,
        rawKey: 'totalMonths');
    addSeed(
      'pos_guaranteeType',
      'ضمانت',
      TagSourceType.pos,
      rawKey: 'guaranteeType',
      trans: {'LEGAL_STAMP': 'قانونی اشٹام و پرنوٹ', 'CHEQUE': 'بینک چیک'},
    );
    addSeed('pos_bankName', 'بینک کا نام', TagSourceType.pos,
        rawKey: 'bankName');
    addSeed('pos_chequeNo', 'چیک نمبر', TagSourceType.pos,
        rawKey: 'chequeNo');
    addSeed('pos_mdmLockFee', 'MDM لاک فیس', TagSourceType.pos,
        rawKey: 'mdmLockFee');
    addSeed('pos_openBoxDeductionRule', 'اوپن باکس کٹوتی', TagSourceType.pos,
        rawKey: 'openBoxDeductionRule');
    addSeed('pos_ramRom', 'میموری (RAM/ROM)', TagSourceType.pos,
        rawKey: 'ramRom');
    addSeed('pos_color', 'موبائل رنگ', TagSourceType.pos, rawKey: 'color');
    addSeed(
      'pos_conditionType',
      'موبائل حالت',
      TagSourceType.pos,
      rawKey: 'conditionType',
      trans: {'NEW': 'نیا ڈبہ پیک', 'USED': 'استعمال شدہ'},
    );
    addSeed('pos_conditionRating', 'کنڈیشن ریٹنگ', TagSourceType.pos,
        rawKey: 'conditionRating');
    addSeed('pos_warranty', 'وارنٹی (ماہ)', TagSourceType.pos,
        rawKey: 'warranty');
    addSeed('pos_salePrice', 'نقد قیمت', TagSourceType.pos,
        rawKey: 'salePrice', enabled: false);
    addSeed('pos_purchasePrice', 'قیمت خرید', TagSourceType.pos,
        rawKey: 'purchasePrice', enabled: false);
    addSeed('pos_supplierInfo', 'سپلائر', TagSourceType.pos,
        rawKey: 'supplierInfo', enabled: false);

    addSeed('cst_witness1', 'گواہ 1 کا نام', TagSourceType.custom);
    addSeed('cst_witness2', 'گواہ 2 کا نام', TagSourceType.custom);
    addSeed('cst_dueDate', 'تاریخ ادائیگی', TagSourceType.custom);

    await HiveBoxManager.putBatch(
      boxName: BoxNames.tagsBox,
      entries: initialEntries,
    );
  }

  /// پہلے stockId (STK_001) سے اسٹاک تلاش کرنا، اور بیک اپ کے طور پر IMEI سے
  static TagRawMap enrichOrderWithStock(Map rawOrder) {
    final TagRawMap merged = TagRawMap.from(rawOrder);
    final stockId = merged['stockId']?.toString().trim() ?? '';
    final imei = merged['imeiNo']?.toString().trim() ?? '';

    try {
      final stockBox = HiveBoxManager.getBox(BoxNames.stockBox);
      Map? matchedStock;

      if (stockId.isNotEmpty && stockId != 'null') {
        final direct = stockBox.get(stockId);
        if (direct is Map) {
          matchedStock = direct;
        }
      }
      if (matchedStock == null && imei.isNotEmpty && imei != 'null') {
        for (final key in stockBox.keys) {
          final rawStock = stockBox.get(key);
          if (rawStock is Map &&
              rawStock['imeiNo']?.toString().trim() == imei) {
            matchedStock = rawStock;
            break;
          }
        }
      }

      if (matchedStock != null) {
        matchedStock.forEach((sKey, sVal) {
          final kStr = sKey.toString();
          if (!merged.containsKey(kStr) ||
              merged[kStr] == null ||
              merged[kStr].toString().trim().isEmpty) {
            merged[kStr] = sVal;
          }
        });
      }
    } catch (_) {}
    return merged;
  }

  static Map<String, dynamic> discoverAllDynamicPayloadSamples() {
    final Map<String, dynamic> samples = {};
    void scanBox(String boxName) {
      try {
        final box = HiveBoxManager.getBox(boxName);
        for (final key in box.keys) {
          final raw = box.get(key);
          if (raw is Map) {
            raw.forEach((k, v) {
              final keyStr = k.toString();
              if (!samples.containsKey(keyStr)) {
                samples[keyStr] = v;
              } else if (v != null &&
                  v is! List &&
                  v is! Map &&
                  v.toString().trim().isNotEmpty &&
                  v.toString().trim() != 'null') {
                samples[keyStr] = v;
              }
            });
          }
        }
      } catch (_) {}
    }

    scanBox(BoxNames.shopOrdersBox);
    scanBox(BoxNames.stockBox);
    return samples;
  }

  static Map<String, Set<String>> discoverAllDistinctValuesAcrossBoxes() {
    final Map<String, Set<String>> discovered = {};
    void scanBox(String boxName) {
      try {
        final box = HiveBoxManager.getBox(boxName);
        for (final key in box.keys) {
          final raw = box.get(key);
          if (raw is Map) {
            raw.forEach((k, v) {
              if (v == null || v is List || v is Map) return;
              final valStr = v.toString().trim();
              if (valStr.isEmpty || valStr == 'null') return;
              discovered.putIfAbsent(k.toString(), () => <String>{}).add(valStr);
            });
          }
        }
      } catch (_) {}
    }

    scanBox(BoxNames.shopOrdersBox);
    scanBox(BoxNames.stockBox);
    return discovered;
  }

  static List<TagBankItemModel> getAllActiveTags() {
    final box = HiveBoxManager.getBox(BoxNames.tagsBox);
    final List<TagRawMap> rawList = [];
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map && raw.containsKey('urduName')) {
        final map = TagRawMap.from(raw);
        if (map['isDeleted'] == true) continue;
        if (map['isEnabled'] == false) continue;
        final name = map['urduName']?.toString().trim() ?? '';
        if (name.isEmpty) continue;
        rawList.add(map);
      }
    }
    rawList.sort((a, b) {
      final orderA = (a['sortOrder'] as num?)?.toInt() ?? 9999;
      final orderB = (b['sortOrder'] as num?)?.toInt() ?? 9999;
      return orderA.compareTo(orderB);
    });
    return rawList.map((m) => TagBankItemModel.fromMap(m)).toList();
  }

  static Future<void> saveReorderedTags(
      List<TagBankItemModel> orderedList) async {
    final box = HiveBoxManager.getBox(BoxNames.tagsBox);
    final now = TimeStatusService.nowUtcIso();
    final TagRawMap batchUpdates = {};
    for (int i = 0; i < orderedList.length; i++) {
      final item = orderedList[i];
      final existingRaw = box.get(item.id);
      final TagRawMap updatedMap = existingRaw is Map
          ? TagRawMap.from(existingRaw)
          : item.toMap();
      updatedMap['sortOrder'] = i;
      updatedMap['updatedAt'] = now;
      updatedMap['isSynced'] = false;
      batchUpdates[item.id] = updatedMap;
    }
    if (batchUpdates.isNotEmpty) {
      await HiveBoxManager.putBatch(
        boxName: BoxNames.tagsBox,
        entries: batchUpdates,
      );
    }
  }

  static List<TagBankItemModel> getAllPosRules() {
    final box = HiveBoxManager.getBox(BoxNames.tagsBox);
    final List<TagBankItemModel> list = [];
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map && raw.containsKey('urduName')) {
        final item = TagBankItemModel.fromMap(raw);
        if (!item.isDeleted && item.source == TagSourceType.pos) {
          list.add(item);
        }
      }
    }
    return list;
  }

  static Future<void> saveTagItem(TagBankItemModel item) async {
    final box = HiveBoxManager.getBox(BoxNames.tagsBox);
    final existing = box.get(item.id);
    final int currentOrder = (existing is Map && existing['sortOrder'] is num)
        ? (existing['sortOrder'] as num).toInt()
        : box.length;
    final updated = TagBankItemModel(
      id: item.id,
      urduName: item.urduName.trim(),
      source: item.source,
      rawKey: item.rawKey,
      isEnabled: item.isEnabled,
      valueTranslations: item.valueTranslations,
      isSynced: false,
      updatedAt: TimeStatusService.nowUtcIso(),
      isDeleted: item.isDeleted,
    );
    final map = updated.toMap();
    map['sortOrder'] = currentOrder;
    await HiveBoxManager.putBatch(
      boxName: BoxNames.tagsBox,
      entries: {updated.id: map},
    );
  }

  static Map<String, String> translatePosOrder(Map rawOrder) {
    final enrichedOrder = enrichOrderWithStock(rawOrder);
    final rules = getAllPosRules().where((r) => r.isEnabled).toList();
    final Map<String, String> translated = {};
    for (final rule in rules) {
      final k = rule.rawKey;
      if (k == null || !enrichedOrder.containsKey(k)) continue;
      final rawVal = enrichedOrder[k];
      if (rawVal == null) continue;
      String valStr = rawVal.toString().trim();
      if (valStr.isEmpty || valStr == 'null') continue;
      if (rule.valueTranslations.containsKey(valStr)) {
        valStr = rule.valueTranslations[valStr]!;
      } else if (k == 'totalMonths' && !valStr.contains('ماہ')) {
        valStr = '$valStr ماہ';
      } else if (k == 'warranty' && !valStr.contains('ماہ')) {
        valStr = '$valStr ماہ';
      }
      translated[rule.urduName] = valStr;
    }
    return translated;
  }
}