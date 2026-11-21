import 'package:flutter/material.dart';
import 'services/pos_remote_config_service.dart';

class PosRemoteController extends ChangeNotifier {
  int selectedZoneIndex = 0;
  late final TextEditingController mobAdvanceCtrl;
  late final TextEditingController mobProfitCheckCtrl;
  late final TextEditingController mobProfitNoCheckCtrl;
  late final TextEditingController mobIncrementCtrl;
  late final TextEditingController mobDueDayCtrl;
  late final TextEditingController mobGraceDaysCtrl;
  late final TextEditingController mobFeeCtrl;
  late final TextEditingController mobRoundCtrl;
  late final TextEditingController mobMdmFeeCtrl;
  late final TextEditingController mobOpenBoxValCtrl;
  late final TextEditingController mobMaxRiskCtrl;
  late final TextEditingController adminPinCtrl;
  String mobOpenBoxType = 'PERCENT';
  bool mobCompounding = false;
  bool mobAddFeeToPrincipal = false;
  List<int> mobDurations = [6, 7, 8, 9, 10, 11, 12];
  int mobMaxMonth = 15;

  late final TextEditingController genAdvanceCtrl;
  late final TextEditingController genProfitCheckCtrl;
  late final TextEditingController genProfitNoCheckCtrl;
  late final TextEditingController genIncrementCtrl;
  late final TextEditingController genDueDayCtrl;
  late final TextEditingController genGraceDaysCtrl;
  late final TextEditingController genFeeCtrl;
  late final TextEditingController genRoundCtrl;
  late final TextEditingController genMdmFeeCtrl;
  late final TextEditingController genOpenBoxValCtrl;
  late final TextEditingController genMaxRiskCtrl;
  late final TextEditingController genAdminPinCtrl;
  String genOpenBoxType = 'PERCENT';
  bool genEnabled = true;
  bool genCompounding = false;
  bool genAddFeeToPrincipal = false;
  bool genRequireCustomerMdm = true;
  List<int> genDurations = [6, 8, 10, 12, 15, 18];
  int genMaxMonth = 24;
  FieldDefList genCustomFields = [];

  late final TextEditingController custAdvanceCtrl;
  late final TextEditingController custProfitCheckCtrl;
  late final TextEditingController custProfitNoCheckCtrl;
  late final TextEditingController custIncrementCtrl;
  late final TextEditingController custDueDayCtrl;
  late final TextEditingController custGraceDaysCtrl;
  late final TextEditingController custFeeCtrl;
  late final TextEditingController custRoundCtrl;
  late final TextEditingController custMdmFeeCtrl;
  late final TextEditingController custOpenBoxValCtrl;
  late final TextEditingController custMaxRiskCtrl;
  late final TextEditingController custAdminPinCtrl;
  String custOpenBoxType = 'PERCENT';
  bool custCompounding = false;
  bool custAddFeeToPrincipal = false;
  bool custRequireCustomerMdm = true;
  List<int> custDurations = [6, 7, 8, 9, 10, 11, 12];
  int custMaxMonth = 18;
  List<String> customAllowedZones = ['MOBILE', 'ELECTRONICS', 'CUSTOM_ESTIMATE'];

  bool requireDeviceActivation = true;
  late final TextEditingController shopNameCtrl;
  late final TextEditingController shopSubtitleCtrl;
  late final TextEditingController tickerTextCtrl;
  String shopLogoUrl = '';
  String ownerPhotoUrl = '';
  bool showShopLogo = true;
  bool showOwnerPhoto = true;
  bool tickerEnabled = true;
  bool showReservedItems = true;
  bool showSoldItems = true;
  bool showOnOrderItems = true;

  List<String> mobileGroupingMatchKeys = ['itemName', 'salePrice', 'specs', 'condition'];
  List<String> generalGroupingMatchKeys = ['itemName', 'salePrice', 'specs', 'condition'];

  bool cashSaleEnabled = true;
  String cashMarkupType = 'NONE';
  late final TextEditingController cashMarkupValCtrl;
  bool allowCashPriceEdit = true;

  String? statusMessage;
  bool isStatusError = false;

  PosRemoteController() {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final cfg = PosRemoteConfigService.getFullConfig();

    mobAdvanceCtrl = TextEditingController(
      text: ((cfg['advancePercentage'] as num?)?.toDouble() ?? 0.8).toString(),
    );
    mobProfitCheckCtrl = TextEditingController(
      text: ((cfg['profitWithCheck'] as num?)?.toDouble() ?? 0.25).toString(),
    );
    mobProfitNoCheckCtrl = TextEditingController(
      text:
          ((cfg['profitWithoutCheck'] as num?)?.toDouble() ?? 0.35).toString(),
    );
    mobIncrementCtrl = TextEditingController(
      text:
          ((cfg['perMonthIncrement'] as num?)?.toDouble() ?? 0.05).toString(),
    );
    mobDueDayCtrl = TextEditingController(
      text: ((cfg['installmentDueDay'] as num?)?.toInt() ?? 5).toString(),
    );
    mobGraceDaysCtrl = TextEditingController(
      text: ((cfg['gracePeriodDays'] as num?)?.toInt() ?? 15).toString(),
    );
    mobFeeCtrl = TextEditingController(
      text: ((cfg['processingFee'] as num?)?.toInt() ?? 0).toString(),
    );
    mobRoundCtrl = TextEditingController(
      text: ((cfg['roundToNearest'] as num?)?.toInt() ?? 100).toString(),
    );
    mobMdmFeeCtrl = TextEditingController(
      text: ((cfg['mdmLockFee'] as num?)?.toInt() ?? 1000).toString(),
    );
    mobOpenBoxType =
        (cfg['openBoxDeductionType']?.toString() ?? 'PERCENT') == 'FIXED'
            ? 'FIXED'
            : 'PERCENT';
    mobOpenBoxValCtrl = TextEditingController(
      text: ((cfg['openBoxDeductionValue'] as num?)?.toInt() ?? 10).toString(),
    );
    mobMaxRiskCtrl = TextEditingController(
      text: ((cfg['maxRiskLimit'] as num?)?.toInt() ?? 0).toString(),
    );
    adminPinCtrl = TextEditingController(
      text: cfg['adminOverridePin']?.toString() ?? '7860',
    );
    mobCompounding = cfg['isCompoundingProfit'] == true;
    mobAddFeeToPrincipal = cfg['addProcessingFeeToPrincipal'] == true;
    final rawMobDur = cfg['allowedDurations'];
    if (rawMobDur is List && rawMobDur.isNotEmpty) {
      mobDurations = rawMobDur
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .where((e) => e >= 3)
          .toList()
        ..sort();
      if (mobDurations.isNotEmpty && mobDurations.last > mobMaxMonth) {
        mobMaxMonth = mobDurations.last;
      }
    }

    genEnabled = cfg['generalEnabled'] != false;
    genAdvanceCtrl = TextEditingController(
      text: ((cfg['generalAdvancePercentage'] as num?)?.toDouble() ?? 0.75)
          .toString(),
    );
    genProfitCheckCtrl = TextEditingController(
      text: ((cfg['generalProfitWithCheck'] as num?)?.toDouble() ?? 0.25)
          .toString(),
    );
    genProfitNoCheckCtrl = TextEditingController(
      text: ((cfg['generalProfitWithoutCheck'] as num?)?.toDouble() ?? 0.35)
          .toString(),
    );
    genIncrementCtrl = TextEditingController(
      text: ((cfg['generalPerMonthIncrement'] as num?)?.toDouble() ?? 0.05)
          .toString(),
    );
    genDueDayCtrl = TextEditingController(
      text: ((cfg['generalInstallmentDueDay'] as num?)?.toInt() ??
              ((cfg['installmentDueDay'] as num?)?.toInt() ?? 5))
          .toString(),
    );
    genGraceDaysCtrl = TextEditingController(
      text: ((cfg['generalGracePeriodDays'] as num?)?.toInt() ??
              ((cfg['gracePeriodDays'] as num?)?.toInt() ?? 15))
          .toString(),
    );
    genFeeCtrl = TextEditingController(
      text: ((cfg['generalProcessingFee'] as num?)?.toInt() ?? 0).toString(),
    );
    genRoundCtrl = TextEditingController(
      text: ((cfg['generalRoundToNearest'] as num?)?.toInt() ??
              ((cfg['roundToNearest'] as num?)?.toInt() ?? 100))
          .toString(),
    );
    genMdmFeeCtrl = TextEditingController(
      text: ((cfg['generalMdmLockFee'] as num?)?.toInt() ??
              ((cfg['mdmLockFee'] as num?)?.toInt() ?? 1000))
          .toString(),
    );
    genOpenBoxType =
        (cfg['generalOpenBoxDeductionType']?.toString() ?? mobOpenBoxType) ==
                'FIXED'
            ? 'FIXED'
            : 'PERCENT';
    genOpenBoxValCtrl = TextEditingController(
      text: ((cfg['generalOpenBoxDeductionValue'] as num?)?.toInt() ??
              ((cfg['openBoxDeductionValue'] as num?)?.toInt() ?? 10))
          .toString(),
    );
    genMaxRiskCtrl = TextEditingController(
      text: ((cfg['generalMaxRiskLimit'] as num?)?.toInt() ?? 0).toString(),
    );
    genAdminPinCtrl = TextEditingController(
      text: cfg['generalAdminOverridePin']?.toString() ??
          (cfg['adminOverridePin']?.toString() ?? '7860'),
    );
    genCompounding = cfg['generalIsCompoundingProfit'] == true;
    genAddFeeToPrincipal = cfg['generalAddProcessingFeeToPrincipal'] == true;
    genRequireCustomerMdm = cfg['generalRequireCustomerMobileMdm'] != false;
    final rawGenDur = cfg['generalAllowedDurations'];
    if (rawGenDur is List && rawGenDur.isNotEmpty) {
      genDurations = rawGenDur
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .where((e) => e >= 3)
          .toList()
        ..sort();
      if (genDurations.isNotEmpty && genDurations.last > genMaxMonth) {
        genMaxMonth = genDurations.last;
      }
    }
    genCustomFields = PosRemoteConfigService.getGeneralCustomFields();

    custAdvanceCtrl = TextEditingController(
      text: ((cfg['customAdvancePercentage'] as num?)?.toDouble() ?? 0.8)
          .toString(),
    );
    custProfitCheckCtrl = TextEditingController(
      text: ((cfg['customProfitWithCheck'] as num?)?.toDouble() ?? 0.25)
          .toString(),
    );
    custProfitNoCheckCtrl = TextEditingController(
      text: ((cfg['customProfitWithoutCheck'] as num?)?.toDouble() ?? 0.35)
          .toString(),
    );
    custIncrementCtrl = TextEditingController(
      text: ((cfg['customPerMonthIncrement'] as num?)?.toDouble() ?? 0.05)
          .toString(),
    );
    custDueDayCtrl = TextEditingController(
      text: ((cfg['customInstallmentDueDay'] as num?)?.toInt() ??
              ((cfg['installmentDueDay'] as num?)?.toInt() ?? 5))
          .toString(),
    );
    custGraceDaysCtrl = TextEditingController(
      text: ((cfg['customGracePeriodDays'] as num?)?.toInt() ??
              ((cfg['gracePeriodDays'] as num?)?.toInt() ?? 15))
          .toString(),
    );
    custFeeCtrl = TextEditingController(
      text: ((cfg['customProcessingFee'] as num?)?.toInt() ?? 0).toString(),
    );
    custRoundCtrl = TextEditingController(
      text: ((cfg['customRoundToNearest'] as num?)?.toInt() ??
              ((cfg['roundToNearest'] as num?)?.toInt() ?? 100))
          .toString(),
    );
    custMdmFeeCtrl = TextEditingController(
      text: ((cfg['customMdmLockFee'] as num?)?.toInt() ??
              ((cfg['mdmLockFee'] as num?)?.toInt() ?? 1000))
          .toString(),
    );
    custOpenBoxType =
        (cfg['customOpenBoxDeductionType']?.toString() ?? mobOpenBoxType) ==
                'FIXED'
            ? 'FIXED'
            : 'PERCENT';
    custOpenBoxValCtrl = TextEditingController(
      text: ((cfg['customOpenBoxDeductionValue'] as num?)?.toInt() ??
              ((cfg['openBoxDeductionValue'] as num?)?.toInt() ?? 10))
          .toString(),
    );
    custMaxRiskCtrl = TextEditingController(
      text: ((cfg['customMaxRiskLimit'] as num?)?.toInt() ?? 0).toString(),
    );
    custAdminPinCtrl = TextEditingController(
      text: cfg['customAdminOverridePin']?.toString() ??
          (cfg['adminOverridePin']?.toString() ?? '7860'),
    );
    custCompounding = cfg['customIsCompoundingProfit'] == true;
    custAddFeeToPrincipal = cfg['customAddProcessingFeeToPrincipal'] == true;
    custRequireCustomerMdm = cfg['customRequireCustomerMobileMdm'] != false;
    final rawCustDur = cfg['customAllowedDurations'];
    if (rawCustDur is List && rawCustDur.isNotEmpty) {
      custDurations = rawCustDur
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .where((e) => e >= 3)
          .toList()
        ..sort();
      if (custDurations.isNotEmpty && custDurations.last > custMaxMonth) {
        custMaxMonth = custDurations.last;
      }
    }
    final rawCustZones = cfg['customAllowedZones'];
    if (rawCustZones is List && rawCustZones.isNotEmpty) {
      customAllowedZones =
          rawCustZones.map((e) => e.toString().toUpperCase()).toList();
    }

    requireDeviceActivation = cfg['requireDeviceActivation'] != false;
    shopNameCtrl = TextEditingController(
      text: cfg['shopName']?.toString() ?? 'نایاب قسط پوائنٹ',
    );
    shopSubtitleCtrl = TextEditingController(
      text: cfg['shopSubtitle']?.toString() ?? 'آسان اقساط سینٹر',
    );
    tickerTextCtrl = TextEditingController(
      text: cfg['tickerText']?.toString() ?? '',
    );
    shopLogoUrl = cfg['shopLogoUrl']?.toString() ?? '';
    ownerPhotoUrl = cfg['ownerPhotoUrl']?.toString() ?? '';
    showShopLogo = cfg['showShopLogo'] != false;
    showOwnerPhoto = cfg['showOwnerPhoto'] != false;
    tickerEnabled = cfg['tickerEnabled'] != false;
    showReservedItems = cfg['showReservedItems'] != false;
    showSoldItems = cfg['showSoldItems'] != false;
    showOnOrderItems = cfg['showOnOrderItems'] != false;

    final rawMobGrouping = cfg['mobileGroupingMatchKeys'] ?? cfg['groupingMatchKeys'];
    if (rawMobGrouping is List) {
      mobileGroupingMatchKeys = rawMobGrouping.map((e) => e.toString()).toList();
    } else {
      mobileGroupingMatchKeys = PosRemoteConfigService.defaultMobileGroupingKeys();
    }

    final rawGenGrouping = cfg['generalGroupingMatchKeys'] ?? cfg['groupingMatchKeys'];
    if (rawGenGrouping is List) {
      generalGroupingMatchKeys = rawGenGrouping.map((e) => e.toString()).toList();
    } else {
      generalGroupingMatchKeys = PosRemoteConfigService.defaultGeneralGroupingKeys();
    }

    cashSaleEnabled = cfg['cashSaleEnabled'] != false;
    final rawMarkupType = (cfg['cashMarkupType']?.toString() ?? 'NONE').toUpperCase();
    cashMarkupType = (rawMarkupType == 'PERCENT' || rawMarkupType == 'FIXED')
        ? rawMarkupType
        : 'NONE';
    cashMarkupValCtrl = TextEditingController(
      text: ((cfg['cashMarkupValue'] as num?)?.toDouble() ?? 0)
          .toString()
          .replaceAll(RegExp(r'\.0$'), ''),
    );
    allowCashPriceEdit = cfg['allowCashPriceEdit'] != false;
  }

  void setCashSaleEnabled(bool v) {
    cashSaleEnabled = v;
    notifyListeners();
  }

  void setCashMarkupType(String type) {
    cashMarkupType = type;
    notifyListeners();
  }

  void setAllowCashPriceEdit(bool v) {
    allowCashPriceEdit = v;
    notifyListeners();
  }

  void toggleCategoryGroupingKey({
    required bool isMobile,
    required String key,
    required bool selected,
  }) {
    final targetList =
        isMobile ? mobileGroupingMatchKeys : generalGroupingMatchKeys;
    if (selected) {
      if (!targetList.contains(key)) {
        targetList.add(key);
      }
    } else {
      targetList.remove(key);
    }
    notifyListeners();
  }

  void setZone(int index) {
    selectedZoneIndex = index;
    statusMessage = null;
    notifyListeners();
  }

  void setMobOpenBoxType(String val) {
    mobOpenBoxType = val;
    notifyListeners();
  }

  void setMobCompounding(bool val) {
    mobCompounding = val;
    notifyListeners();
  }

  void setMobAddFee(bool val) {
    mobAddFeeToPrincipal = val;
    notifyListeners();
  }

  void adjustMobMaxMonth(int delta) {
    mobMaxMonth = (mobMaxMonth + delta).clamp(6, 36);
    mobDurations.removeWhere((m) => m > mobMaxMonth);
    notifyListeners();
  }

  void toggleMobDuration(int m, bool selected) {
    if (selected) {
      if (!mobDurations.contains(m)) mobDurations.add(m);
    } else {
      mobDurations.remove(m);
    }
    notifyListeners();
  }

  void setGenEnabled(bool val) {
    genEnabled = val;
    notifyListeners();
  }

  void setGenOpenBoxType(String val) {
    genOpenBoxType = val;
    notifyListeners();
  }

  void setGenCompounding(bool val) {
    genCompounding = val;
    notifyListeners();
  }

  void setGenAddFee(bool val) {
    genAddFeeToPrincipal = val;
    notifyListeners();
  }

  void setGenRequireCustomerMdm(bool val) {
    genRequireCustomerMdm = val;
    notifyListeners();
  }

  void adjustGenMaxMonth(int delta) {
    genMaxMonth = (genMaxMonth + delta).clamp(6, 36);
    genDurations.removeWhere((m) => m > genMaxMonth);
    notifyListeners();
  }

  void toggleGenDuration(int m, bool selected) {
    if (selected) {
      if (!genDurations.contains(m)) genDurations.add(m);
    } else {
      genDurations.remove(m);
    }
    notifyListeners();
  }

  void addGeneralField(String urduLabel) {
    final clean = urduLabel.trim();
    if (clean.isEmpty) return;
    final key = 'gen_${DateTime.now().millisecondsSinceEpoch}';
    genCustomFields.add({'key': key, 'urduLabel': clean});
    notifyListeners();
  }

  void renameGeneralField(int index, String newUrduLabel) {
    final clean = newUrduLabel.trim();
    if (clean.isEmpty || index < 0 || index >= genCustomFields.length) return;
    genCustomFields[index]['urduLabel'] = clean;
    notifyListeners();
  }

  void removeGeneralField(int index) {
    if (index < 0 || index >= genCustomFields.length) return;
    genCustomFields.removeAt(index);
    notifyListeners();
  }

  void setCustOpenBoxType(String val) {
    custOpenBoxType = val;
    notifyListeners();
  }

  void setCustCompounding(bool val) {
    custCompounding = val;
    notifyListeners();
  }

  void setCustAddFee(bool val) {
    custAddFeeToPrincipal = val;
    notifyListeners();
  }

  void setCustRequireCustomerMdm(bool val) {
    custRequireCustomerMdm = val;
    notifyListeners();
  }

  void adjustCustMaxMonth(int delta) {
    custMaxMonth = (custMaxMonth + delta).clamp(6, 36);
    custDurations.removeWhere((m) => m > custMaxMonth);
    notifyListeners();
  }

  void toggleCustDuration(int m, bool selected) {
    if (selected) {
      if (!custDurations.contains(m)) custDurations.add(m);
    } else {
      custDurations.remove(m);
    }
    notifyListeners();
  }

  void toggleCustomAllowedZone(String zoneKey, bool selected) {
    if (selected) {
      if (!customAllowedZones.contains(zoneKey)) {
        customAllowedZones.add(zoneKey);
      }
    } else {
      if (customAllowedZones.length > 1) {
        customAllowedZones.remove(zoneKey);
      }
    }
    notifyListeners();
  }

  void setRequireDeviceActivation(bool v) {
    requireDeviceActivation = v;
    notifyListeners();
  }

  void setShopLogoUrl(String url) {
    shopLogoUrl = url;
    notifyListeners();
  }

  void setOwnerPhotoUrl(String url) {
    ownerPhotoUrl = url;
    notifyListeners();
  }

  void setShowShopLogo(bool v) {
    showShopLogo = v;
    notifyListeners();
  }

  void setShowOwnerPhoto(bool v) {
    showOwnerPhoto = v;
    notifyListeners();
  }

  void setTickerEnabled(bool v) {
    tickerEnabled = v;
    notifyListeners();
  }

  void setShowReservedItems(bool v) {
    showReservedItems = v;
    notifyListeners();
  }

  void setShowSoldItems(bool v) {
    showSoldItems = v;
    notifyListeners();
  }

  void setShowOnOrderItems(bool v) {
    showOnOrderItems = v;
    notifyListeners();
  }

  Future<void> saveAllSettings() async {
    if (mobDurations.isEmpty ||
        genDurations.isEmpty ||
        custDurations.isEmpty) {
      isStatusError = true;
      statusMessage = '⚠️ تینوں زونز میں کم از کم ایک مدت (ماہ) منتخب کریں!';
      notifyListeners();
      return;
    }
    final sortedMob = List<int>.from(mobDurations)..sort();
    final sortedGen = List<int>.from(genDurations)..sort();
    final sortedCust = List<int>.from(custDurations)..sort();
    final ok = await PosRemoteConfigService.saveFullConfig({
      'advancePercentage': double.tryParse(mobAdvanceCtrl.text.trim()) ?? 0.8,
      'profitWithCheck': double.tryParse(mobProfitCheckCtrl.text.trim()) ?? 0.25,
      'profitWithoutCheck':
          double.tryParse(mobProfitNoCheckCtrl.text.trim()) ?? 0.35,
      'perMonthIncrement':
          double.tryParse(mobIncrementCtrl.text.trim()) ?? 0.05,
      'installmentDueDay': int.tryParse(mobDueDayCtrl.text.trim()) ?? 5,
      'gracePeriodDays': int.tryParse(mobGraceDaysCtrl.text.trim()) ?? 15,
      'processingFee': int.tryParse(mobFeeCtrl.text.trim()) ?? 0,
      'roundToNearest': int.tryParse(mobRoundCtrl.text.trim()) ?? 100,
      'mdmLockFee': int.tryParse(mobMdmFeeCtrl.text.trim()) ?? 1000,
      'openBoxDeductionType': mobOpenBoxType,
      'openBoxDeductionValue':
          int.tryParse(mobOpenBoxValCtrl.text.trim()) ?? 10,
      'maxRiskLimit': int.tryParse(mobMaxRiskCtrl.text.trim()) ?? 0,
      'adminOverridePin': adminPinCtrl.text.trim(),
      'isCompoundingProfit': mobCompounding,
      'addProcessingFeeToPrincipal': mobAddFeeToPrincipal,
      'allowedDurations': sortedMob,
      'generalEnabled': genEnabled,
      'generalAdvancePercentage':
          double.tryParse(genAdvanceCtrl.text.trim()) ?? 0.75,
      'generalProfitWithCheck':
          double.tryParse(genProfitCheckCtrl.text.trim()) ?? 0.25,
      'generalProfitWithoutCheck':
          double.tryParse(genProfitNoCheckCtrl.text.trim()) ?? 0.35,
      'generalPerMonthIncrement':
          double.tryParse(genIncrementCtrl.text.trim()) ?? 0.05,
      'generalInstallmentDueDay': int.tryParse(genDueDayCtrl.text.trim()) ?? 5,
      'generalGracePeriodDays': int.tryParse(genGraceDaysCtrl.text.trim()) ?? 15,
      'generalProcessingFee': int.tryParse(genFeeCtrl.text.trim()) ?? 0,
      'generalRoundToNearest': int.tryParse(genRoundCtrl.text.trim()) ?? 100,
      'generalMdmLockFee': int.tryParse(genMdmFeeCtrl.text.trim()) ?? 1000,
      'generalOpenBoxDeductionType': genOpenBoxType,
      'generalOpenBoxDeductionValue':
          int.tryParse(genOpenBoxValCtrl.text.trim()) ?? 10,
      'generalMaxRiskLimit': int.tryParse(genMaxRiskCtrl.text.trim()) ?? 0,
      'generalAdminOverridePin': genAdminPinCtrl.text.trim(),
      'generalIsCompoundingProfit': genCompounding,
      'generalAddProcessingFeeToPrincipal': genAddFeeToPrincipal,
      'generalRequireCustomerMobileMdm': genRequireCustomerMdm,
      'generalAllowedDurations': sortedGen,
      'generalCustomFields': genCustomFields,
      'customAdvancePercentage':
          double.tryParse(custAdvanceCtrl.text.trim()) ?? 0.8,
      'customProfitWithCheck':
          double.tryParse(custProfitCheckCtrl.text.trim()) ?? 0.25,
      'customProfitWithoutCheck':
          double.tryParse(custProfitNoCheckCtrl.text.trim()) ?? 0.35,
      'customPerMonthIncrement':
          double.tryParse(custIncrementCtrl.text.trim()) ?? 0.05,
      'customInstallmentDueDay': int.tryParse(custDueDayCtrl.text.trim()) ?? 5,
      'customGracePeriodDays':
          int.tryParse(custGraceDaysCtrl.text.trim()) ?? 15,
      'customProcessingFee': int.tryParse(custFeeCtrl.text.trim()) ?? 0,
      'customRoundToNearest': int.tryParse(custRoundCtrl.text.trim()) ?? 100,
      'customMdmLockFee': int.tryParse(custMdmFeeCtrl.text.trim()) ?? 1000,
      'customOpenBoxDeductionType': custOpenBoxType,
      'customOpenBoxDeductionValue':
          int.tryParse(custOpenBoxValCtrl.text.trim()) ?? 10,
      'customMaxRiskLimit': int.tryParse(custMaxRiskCtrl.text.trim()) ?? 0,
      'customAdminOverridePin': custAdminPinCtrl.text.trim(),
      'customIsCompoundingProfit': custCompounding,
      'customAddProcessingFeeToPrincipal': custAddFeeToPrincipal,
      'customRequireCustomerMobileMdm': custRequireCustomerMdm,
      'customAllowedDurations': sortedCust,
      'customAllowedZones': customAllowedZones,
      'requireDeviceActivation': requireDeviceActivation,
      'shopName': shopNameCtrl.text.trim(),
      'shopSubtitle': shopSubtitleCtrl.text.trim(),
      'shopLogoUrl': shopLogoUrl,
      'ownerPhotoUrl': ownerPhotoUrl,
      'showShopLogo': showShopLogo,
      'showOwnerPhoto': showOwnerPhoto,
      'tickerEnabled': tickerEnabled,
      'tickerText': tickerTextCtrl.text.trim(),
      'showReservedItems': showReservedItems,
      'showSoldItems': showSoldItems,
      'showOnOrderItems': showOnOrderItems,
      'mobileGroupingMatchKeys': mobileGroupingMatchKeys,
      'generalGroupingMatchKeys': generalGroupingMatchKeys,
      'cashSaleEnabled': cashSaleEnabled,
      'cashMarkupType': cashMarkupType,
      'cashMarkupValue':
          double.tryParse(cashMarkupValCtrl.text.trim()) ?? 0,
      'allowCashPriceEdit': allowCashPriceEdit,
    });
    isStatusError = !ok;
    statusMessage = ok
        ? '✅ تمام زونز، برانڈنگ، نقد فروخت اور گروپنگ رولز محفوظ ہو کر POS ایپ پر سنک ہو گئے!'
        : '⚠️ محفوظ کرتے وقت مسئلہ پیش آیا، دوبارہ کوشش کریں۔';
    notifyListeners();
  }

  @override
  void dispose() {
    mobAdvanceCtrl.dispose();
    mobProfitCheckCtrl.dispose();
    mobProfitNoCheckCtrl.dispose();
    mobIncrementCtrl.dispose();
    mobDueDayCtrl.dispose();
    mobGraceDaysCtrl.dispose();
    mobFeeCtrl.dispose();
    mobRoundCtrl.dispose();
    mobMdmFeeCtrl.dispose();
    mobOpenBoxValCtrl.dispose();
    mobMaxRiskCtrl.dispose();
    adminPinCtrl.dispose();
    genAdvanceCtrl.dispose();
    genProfitCheckCtrl.dispose();
    genProfitNoCheckCtrl.dispose();
    genIncrementCtrl.dispose();
    genDueDayCtrl.dispose();
    genGraceDaysCtrl.dispose();
    genFeeCtrl.dispose();
    genRoundCtrl.dispose();
    genMdmFeeCtrl.dispose();
    genOpenBoxValCtrl.dispose();
    genMaxRiskCtrl.dispose();
    genAdminPinCtrl.dispose();
    custAdvanceCtrl.dispose();
    custProfitCheckCtrl.dispose();
    custProfitNoCheckCtrl.dispose();
    custIncrementCtrl.dispose();
    custDueDayCtrl.dispose();
    custGraceDaysCtrl.dispose();
    custFeeCtrl.dispose();
    custRoundCtrl.dispose();
    custMdmFeeCtrl.dispose();
    custOpenBoxValCtrl.dispose();
    custMaxRiskCtrl.dispose();
    custAdminPinCtrl.dispose();
    shopNameCtrl.dispose();
    shopSubtitleCtrl.dispose();
    tickerTextCtrl.dispose();
    cashMarkupValCtrl.dispose();
    super.dispose();
  }
}