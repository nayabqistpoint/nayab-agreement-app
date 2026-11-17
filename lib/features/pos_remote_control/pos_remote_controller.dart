import 'package:flutter/material.dart';
import 'services/pos_remote_config_service.dart';

class PosRemoteController extends ChangeNotifier {
  int selectedZoneIndex = 0;

  // Zone 1: Mobile
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

  // Zone 2: General
  late final TextEditingController genAdvanceCtrl;
  late final TextEditingController genProfitCheckCtrl;
  late final TextEditingController genProfitNoCheckCtrl;
  late final TextEditingController genIncrementCtrl;
  late final TextEditingController genFeeCtrl;
  late final TextEditingController genMaxRiskCtrl;

  bool genEnabled = true;
  bool genCompounding = false;
  bool genRequireCustomerMdm = true;
  List<int> genDurations = [6, 8, 10, 12, 15, 18];
  int genMaxMonth = 24;
  FieldDefList genCustomFields = [];

  // Zone 3: Custom Estimate
  late final TextEditingController custAdvanceCtrl;
  late final TextEditingController custProfitCheckCtrl;
  late final TextEditingController custProfitNoCheckCtrl;
  late final TextEditingController custIncrementCtrl;
  late final TextEditingController custFeeCtrl;
  late final TextEditingController custMaxRiskCtrl;

  bool custCompounding = false;
  List<int> custDurations = [6, 7, 8, 9, 10, 11, 12];
  int custMaxMonth = 18;
  List<String> customAllowedZones = ['MOBILE', 'ELECTRONICS', 'CUSTOM_ESTIMATE'];

  // Zone 4: Store Branding, Ticker & Display
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

  String? statusMessage;
  bool isStatusError = false;

  PosRemoteController() {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final cfg = PosRemoteConfigService.getFullConfig();

    // Mobile
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

    // General
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
    genFeeCtrl = TextEditingController(
      text: ((cfg['generalProcessingFee'] as num?)?.toInt() ?? 0).toString(),
    );
    genMaxRiskCtrl = TextEditingController(
      text: ((cfg['generalMaxRiskLimit'] as num?)?.toInt() ?? 0).toString(),
    );
    genCompounding = cfg['generalIsCompoundingProfit'] == true;
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

    // Custom Estimate
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
    custFeeCtrl = TextEditingController(
      text: ((cfg['customProcessingFee'] as num?)?.toInt() ?? 0).toString(),
    );
    custMaxRiskCtrl = TextEditingController(
      text: ((cfg['customMaxRiskLimit'] as num?)?.toInt() ?? 0).toString(),
    );
    custCompounding = cfg['customIsCompoundingProfit'] == true;

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

    // Branding & Ticker
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

  void setGenCompounding(bool val) {
    genCompounding = val;
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

  void setCustCompounding(bool val) {
    custCompounding = val;
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
      // General
      'generalEnabled': genEnabled,
      'generalAdvancePercentage':
          double.tryParse(genAdvanceCtrl.text.trim()) ?? 0.75,
      'generalProfitWithCheck':
          double.tryParse(genProfitCheckCtrl.text.trim()) ?? 0.25,
      'generalProfitWithoutCheck':
          double.tryParse(genProfitNoCheckCtrl.text.trim()) ?? 0.35,
      'generalPerMonthIncrement':
          double.tryParse(genIncrementCtrl.text.trim()) ?? 0.05,
      'generalProcessingFee': int.tryParse(genFeeCtrl.text.trim()) ?? 0,
      'generalMaxRiskLimit': int.tryParse(genMaxRiskCtrl.text.trim()) ?? 0,
      'generalIsCompoundingProfit': genCompounding,
      'generalRequireCustomerMobileMdm': genRequireCustomerMdm,
      'generalAllowedDurations': sortedGen,
      'generalCustomFields': genCustomFields,
      // Custom
      'customAdvancePercentage':
          double.tryParse(custAdvanceCtrl.text.trim()) ?? 0.8,
      'customProfitWithCheck':
          double.tryParse(custProfitCheckCtrl.text.trim()) ?? 0.25,
      'customProfitWithoutCheck':
          double.tryParse(custProfitNoCheckCtrl.text.trim()) ?? 0.35,
      'customPerMonthIncrement':
          double.tryParse(custIncrementCtrl.text.trim()) ?? 0.05,
      'customProcessingFee': int.tryParse(custFeeCtrl.text.trim()) ?? 0,
      'customMaxRiskLimit': int.tryParse(custMaxRiskCtrl.text.trim()) ?? 0,
      'customIsCompoundingProfit': custCompounding,
      'customAllowedDurations': sortedCust,
      'customAllowedZones': customAllowedZones,
      // Branding & Ticker
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
    });

    isStatusError = !ok;
    statusMessage = ok
        ? '✅ تمام زونز، برانڈنگ اور ڈسپلے کنٹرولز محفوظ ہو کر POS ایپ پر سنک ہو گئے!'
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
    genFeeCtrl.dispose();
    genMaxRiskCtrl.dispose();
    custAdvanceCtrl.dispose();
    custProfitCheckCtrl.dispose();
    custProfitNoCheckCtrl.dispose();
    custIncrementCtrl.dispose();
    custFeeCtrl.dispose();
    custMaxRiskCtrl.dispose();
    shopNameCtrl.dispose();
    shopSubtitleCtrl.dispose();
    tickerTextCtrl.dispose();
    super.dispose();
  }
}