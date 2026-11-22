import 'dart:core' as core;
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../../core/models/tag_bank_item_model.dart';
import '../../../core/network/connectivity_service.dart';
import '../../../core/services/cloudinary_storage_service.dart';
import '../../../core/services/tags_bank_service.dart';
import '../../../core/time/time_status_service.dart';

typedef RemoteConfigMap = core.Map<String, dynamic>;
typedef FieldDefMap = core.Map<String, String>;
typedef FieldDefList = core.List<FieldDefMap>;

class PosRemoteConfigService {
  static const String configDocId = 'calculator_config';
  static const core.Set<String> _legacySeededGeneralKeys = {
    'gen_category',
    'gen_serial',
    'gen_specs',
    'gen_brand',
  };

  static FieldDefList defaultGeneralFields() => [];
  static core.List<String> defaultMobileGroupingKeys() =>
      ['itemName', 'salePrice', 'specs', 'condition'];
  static core.List<String> defaultGeneralGroupingKeys() =>
      ['itemName', 'salePrice', 'specs', 'condition'];

  static FieldDefList getGroupingOptionsForCategory({required bool isMobile}) {
    final FieldDefList options = isMobile
        ? [
            {'key': 'images', 'urduLabel': 'موبائل کی تصاویر (Images)'},
            {'key': 'itemName', 'urduLabel': 'موبائل کمپنی و ماڈل'},
            {'key': 'imeiNo', 'urduLabel': 'IMEI نمبر'},
            {'key': 'purchasePrice', 'urduLabel': 'قیمتِ خرید'},
            {'key': 'salePrice', 'urduLabel': 'نقد قیمتِ فروخت'},
            {'key': 'supplier', 'urduLabel': 'سپلائر / ڈیلر'},
            {'key': 'specs', 'urduLabel': 'میموری (RAM / ROM)'},
            {'key': 'color', 'urduLabel': 'رنگ (Color)'},
            {'key': 'condition', 'urduLabel': 'حالت (New / Used)'},
            {'key': 'warranty', 'urduLabel': 'وارنٹی (Warranty)'},
          ]
        : [
            {'key': 'images', 'urduLabel': 'آئٹم کی تصاویر (Images)'},
            {'key': 'itemName', 'urduLabel': 'آئٹم کا نام'},
            {'key': 'serialNo', 'urduLabel': 'سیریل / چیسز نمبر'},
            {'key': 'specs', 'urduLabel': 'سائز و تفصیل'},
            {'key': 'purchasePrice', 'urduLabel': 'قیمتِ خرید'},
            {'key': 'salePrice', 'urduLabel': 'نقد قیمتِ فروخت'},
            {'key': 'supplier', 'urduLabel': 'سپلائر / ڈیلر'},
            {'key': 'color', 'urduLabel': 'رنگ (Color)'},
            {'key': 'condition', 'urduLabel': 'حالت (New / Used)'},
            {'key': 'warranty', 'urduLabel': 'وارنٹی (Warranty)'},
          ];
    final cfg = getFullConfig();
    final Set<String> seenKeys = options.map((e) => e['key']!).toSet();
    final rawList =
        isMobile ? cfg['mobileCustomFields'] : cfg['generalCustomFields'];
    if (rawList is core.List) {
      for (final item in rawList) {
        if (item is core.Map) {
          final k = item['key']?.toString().trim() ?? '';
          final label = item['urduLabel']?.toString().trim() ?? '';
          if (k.isNotEmpty &&
              label.isNotEmpty &&
              !seenKeys.contains(k) &&
              !_legacySeededGeneralKeys.contains(k)) {
            seenKeys.add(k);
            options.add({'key': k, 'urduLabel': '$label (اضافی فیلڈ)'});
          }
        }
      }
    }
    return options;
  }

  static String getActiveGroupingSummaryText({required bool isMobile}) {
    final cfg = getFullConfig();
    final rawKeys = isMobile
        ? (cfg['mobileGroupingMatchKeys'] ?? cfg['groupingMatchKeys'])
        : (cfg['generalGroupingMatchKeys'] ?? cfg['groupingMatchKeys']);
    final core.List<String> activeKeys = rawKeys is core.List
        ? rawKeys.map((e) => e.toString()).toList()
        : (isMobile
            ? defaultMobileGroupingKeys()
            : defaultGeneralGroupingKeys());
    final allOpts = getGroupingOptionsForCategory(isMobile: isMobile);
    final labelMap = {
      for (final o in allOpts) o['key']!: o['urduLabel']!.split(' (').first,
    };
    final core.List<String> labels = [];
    for (final k in activeKeys) {
      final lbl = labelMap[k];
      if (lbl != null && lbl.isNotEmpty) labels.add(lbl);
    }
    return labels.isEmpty ? 'صرف کیٹگری' : labels.join(' + ');
  }

  static RemoteConfigMap getFullConfig() {
    final box = HiveBoxManager.getBox(BoxNames.appConfigBox);
    final raw = box.get(configDocId);
    final RemoteConfigMap base = {
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
      'mdmLockFee': 1000,
      'openBoxDeductionType': 'PERCENT',
      'openBoxDeductionValue': 10,
      'maxRiskLimit': 0,
      'adminOverridePin': '7860',
      'lastStockNumber': 0,
      'generalEnabled': true,
      'generalAdvancePercentage': 0.75,
      'generalProfitWithCheck': 0.25,
      'generalProfitWithoutCheck': 0.35,
      'generalPerMonthIncrement': 0.05,
      'generalInstallmentDueDay': 5,
      'generalGracePeriodDays': 15,
      'generalProcessingFee': 0,
      'generalRoundToNearest': 100,
      'generalIsCompoundingProfit': false,
      'generalAddProcessingFeeToPrincipal': false,
      'generalAllowedDurations': [6, 8, 10, 12, 15, 18],
      'generalMaxRiskLimit': 0,
      'generalMdmLockFee': 1000,
      'generalOpenBoxDeductionType': 'PERCENT',
      'generalOpenBoxDeductionValue': 10,
      'generalAdminOverridePin': '7860',
      'generalRequireCustomerMobileMdm': true,
      'generalCustomFields': defaultGeneralFields(),
      'mobileCustomFields': <FieldDefMap>[],
      'customAdvancePercentage': 0.8,
      'customProfitWithCheck': 0.25,
      'customProfitWithoutCheck': 0.35,
      'customPerMonthIncrement': 0.05,
      'customInstallmentDueDay': 5,
      'customGracePeriodDays': 15,
      'customProcessingFee': 0,
      'customRoundToNearest': 100,
      'customIsCompoundingProfit': false,
      'customAddProcessingFeeToPrincipal': false,
      'customAllowedDurations': [6, 7, 8, 9, 10, 11, 12],
      'customMaxRiskLimit': 0,
      'customMdmLockFee': 1000,
      'customOpenBoxDeductionType': 'PERCENT',
      'customOpenBoxDeductionValue': 10,
      'customAdminOverridePin': '7860',
      'customRequireCustomerMobileMdm': true,
      'customAllowedZones': ['MOBILE', 'ELECTRONICS', 'CUSTOM_ESTIMATE'],
      'requireDeviceActivation': true,
      'geofenceEnabled': false,
      'geofenceRadiusMeters': 150,
      'shopLatitude': null,
      'shopLongitude': null,
      'shopName': 'نایاب قسط پوائنٹ',
      'shopSubtitle': 'آسان اقساط سینٹر',
      'shopLogoUrl': '',
      'ownerPhotoUrl': '',
      'showShopLogo': true,
      'showOwnerPhoto': true,
      'tickerEnabled': true,
      'tickerText':
          'نایاب قسط پوائنٹ میں خوش آمدید • بغیر ایڈوانس اور آسان ماہانہ اقساط پر موبائل اور گھریلو اشیاء دستیاب ہیں',
      'showReservedItems': true,
      'showSoldItems': true,
      'showOnOrderItems': true,
      'mobileGroupingMatchKeys': defaultMobileGroupingKeys(),
      'generalGroupingMatchKeys': defaultGeneralGroupingKeys(),
      'cashSaleEnabled': true,
      'cashMarkupType': 'NONE',
      'cashMarkupValue': 0,
      'allowCashPriceEdit': true,
      'status': 'approved',
    };
    if (raw is core.Map) {
      raw.forEach((k, v) {
        if (k.toString() != 'zeroAdvanceMaxLimit') {
          base[k.toString()] = v;
        }
      });
    }
    if (base['generalCustomFields'] is core.List) {
      base['generalCustomFields'] = (base['generalCustomFields'] as core.List)
          .where((e) =>
              e is core.Map &&
              !_legacySeededGeneralKeys.contains(e['key']?.toString() ?? ''))
          .toList();
    }
    return base;
  }

  static FieldDefList getGeneralCustomFields() {
    final cfg = getFullConfig();
    final rawList = cfg['generalCustomFields'];
    if (rawList is core.List) {
      final FieldDefList result = [];
      for (final item in rawList) {
        if (item is core.Map) {
          final k = item['key']?.toString().trim() ?? '';
          final label = item['urduLabel']?.toString().trim() ?? '';
          if (k.isNotEmpty &&
              label.isNotEmpty &&
              !_legacySeededGeneralKeys.contains(k)) {
            result.add({'key': k, 'urduLabel': label});
          }
        }
      }
      return result;
    }
    return [];
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
      if (await ConnectivityService.isOnline) {
        final logo = payload['shopLogoUrl']?.toString().trim() ?? '';
        if (logo.isNotEmpty && !logo.startsWith('http')) {
          final uploadedLogo = await CloudinaryStorageService.uploadImageFile(
            filePath: logo,
            subFolder: 'branding',
            customPublicId: 'shop_logo_${DateTime.now().millisecondsSinceEpoch}',
          );
          if (uploadedLogo != null) payload['shopLogoUrl'] = uploadedLogo;
        }
        final owner = payload['ownerPhotoUrl']?.toString().trim() ?? '';
        if (owner.isNotEmpty && !owner.startsWith('http')) {
          final uploadedOwner = await CloudinaryStorageService.uploadImageFile(
            filePath: owner,
            subFolder: 'branding',
            customPublicId:
                'owner_photo_${DateTime.now().millisecondsSinceEpoch}',
          );
          if (uploadedOwner != null) payload['ownerPhotoUrl'] = uploadedOwner;
        }
      }
      await HiveBoxManager.putBatch(
        boxName: BoxNames.appConfigBox,
        entries: {configDocId: payload},
      );
      for (final field in getGeneralCustomFields()) {
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

  static core.List<core.Map<String, dynamic>> getRegisteredDevices() {
    final box = HiveBoxManager.getBox(BoxNames.posDevicesBox);
    final core.List<core.Map<String, dynamic>> devices = [];
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is core.Map) {
        final map = core.Map<String, dynamic>.from(raw);
        if (map['isDeleted'] == true) continue;
        map['deviceId'] = map['deviceId']?.toString() ?? key.toString();
        devices.add(map);
      }
    }
    devices.sort((a, b) {
      final tA =
          a['lastSeenAt']?.toString() ?? a['requestedAt']?.toString() ?? '';
      final tB =
          b['lastSeenAt']?.toString() ?? b['requestedAt']?.toString() ?? '';
      return tB.compareTo(tA);
    });
    return devices;
  }

  static Future<void> setDeviceStatus({
    required String deviceId,
    required String status,
    String? customLabel,
  }) async {
    final box = HiveBoxManager.getBox(BoxNames.posDevicesBox);
    final raw = box.get(deviceId);
    final now = TimeStatusService.nowUtcIso();
    final core.Map<String, dynamic> map = raw is core.Map
        ? core.Map<String, dynamic>.from(raw)
        : {'deviceId': deviceId};
    map['status'] = status;
    if (customLabel != null && customLabel.trim().isNotEmpty) {
      map['employeeLabel'] = customLabel.trim();
    }
    map['updatedAt'] = now;
    map['isSynced'] = false;
    await HiveBoxManager.putBatch(
      boxName: BoxNames.posDevicesBox,
      entries: {deviceId: map},
    );
  }

  static Future<void> setDeviceGeofenceBypass({
    required String deviceId,
    required bool bypass,
  }) async {
    final box = HiveBoxManager.getBox(BoxNames.posDevicesBox);
    final raw = box.get(deviceId);
    final now = TimeStatusService.nowUtcIso();
    final core.Map<String, dynamic> map = raw is core.Map
        ? core.Map<String, dynamic>.from(raw)
        : {'deviceId': deviceId};
    map['bypassGeofence'] = bypass;
    map['updatedAt'] = now;
    map['isSynced'] = false;
    await HiveBoxManager.putBatch(
      boxName: BoxNames.posDevicesBox,
      entries: {deviceId: map},
    );
  }

  static Future<void> deleteRegisteredDevice(String deviceId) async {
    if (deviceId.trim().isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection(BoxNames.posDevicesBox)
          .doc(deviceId)
          .delete();
    } catch (_) {}
    await HiveBoxManager.deleteKey(
      boxName: BoxNames.posDevicesBox,
      key: deviceId,
    );
  }
}