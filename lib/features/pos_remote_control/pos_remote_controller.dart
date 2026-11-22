import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
  bool geofenceEnabled = false;
  bool isFetchingShopLocation = false;
  late final TextEditingController geofenceRadiusCtrl;
  late final TextEditingController shopLatCtrl;
  late final TextEditingController shopLngCtrl;
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
  String cashMinFloorType = 'BASE_STRICT';
  late final TextEditingController cashMinFloorValCtrl;
  String cashMaxCeilingType = 'NONE';
  late final TextEditingController cashMaxCeilingValCtrl;
  String? statusMessage;
  bool isStatusError = false;
  PosRemoteController() {
    _loadFromStorage();
  }
  static String _fmtNum(dynamic raw) {
    return ((raw as num?)?.toDouble() ?? 0)
        .toString()
        .replaceAll(RegExp(r'\.0$'), '');
  }
  void _loadFromStorage() {
    final cfg = PosRemoteConfigService.getFullConfig();
    mobAdvanceCtrl = TextEditingController(
        text: ((cfg['advancePercentage'] as num?)?.toDouble() ?? 0.8).toString());
    mobProfitCheckCtrl = TextEditingController(
        text: ((cfg['profitWithCheck'] as num?)?.toDouble() ?? 0.25).toString());
    mobProfitNoCheckCtrl = TextEditingController(
        text:
            ((cfg['profitWithoutCheck'] as num?)?.toDouble() ?? 0.35).toString());
    mobIncrementCtrl = TextEditingController(
        text:
            ((cfg['perMonthIncrement'] as num?)?.toDouble() ?? 0.05).toString());
    mobDueDayCtrl = TextEditingController(
        text: ((cfg['installmentDueDay'] as num?)?.toInt() ?? 5).toString());
    mobGraceDaysCtrl = TextEditingController(
        text: ((cfg['gracePeriodDays'] as num?)?.toInt() ?? 15).toString());
    mobFeeCtrl = TextEditingController(
        text: ((cfg['processingFee'] as num?)?.toInt() ?? 0).toString());
    mobRoundCtrl = TextEditingController(
        text: ((cfg['roundToNearest'] as num?)?.toInt() ?? 100).toString());
    mobMdmFeeCtrl = TextEditingController(
        text: ((cfg['mdmLockFee'] as num?)?.toInt() ?? 1000).toString());
    mobOpenBoxType =
        (cfg['openBoxDeductionType']?.toString() ?? 'PERCENT') == 'FIXED'
            ? 'FIXED'
            : 'PERCENT';
    mobOpenBoxValCtrl = TextEditingController(
        text: ((cfg['openBoxDeductionValue'] as num?)?.toInt() ?? 10).toString());
    mobMaxRiskCtrl = TextEditingController(
        text: ((cfg['maxRiskLimit'] as num?)?.toInt() ?? 0).toString());
    adminPinCtrl =
        TextEditingController(text: cfg['adminOverridePin']?.toString() ?? '7860');
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
            .toString());
    genProfitCheckCtrl = TextEditingController(
        text: ((cfg['generalProfitWithCheck'] as num?)?.toDouble() ?? 0.25)
            .toString());
    genProfitNoCheckCtrl = TextEditingController(
        text: ((cfg['generalProfitWithoutCheck'] as num?)?.toDouble() ?? 0.35)
            .toString());
    genIncrementCtrl = TextEditingController(
        text: ((cfg['generalPerMonthIncrement'] as num?)?.toDouble() ?? 0.05)
            .toString());
    genDueDayCtrl = TextEditingController(
        text: ((cfg['generalInstallmentDueDay'] as num?)?.toInt() ?? 5)
            .toString());
    genGraceDaysCtrl = TextEditingController(
        text: ((cfg['generalGracePeriodDays'] as num?)?.toInt() ?? 15)
            .toString());
    genFeeCtrl = TextEditingController(
        text:
            ((cfg['generalProcessingFee'] as num?)?.toInt() ?? 0).toString());
    genRoundCtrl = TextEditingController(
        text: ((cfg['generalRoundToNearest'] as num?)?.toInt() ?? 100)
            .toString());
    genMdmFeeCtrl = TextEditingController(
        text: ((cfg['generalMdmLockFee'] as num?)?.toInt() ?? 1000).toString());
    genOpenBoxType =
        (cfg['generalOpenBoxDeductionType']?.toString() ?? mobOpenBoxType) ==
                'FIXED'
            ? 'FIXED'
            : 'PERCENT';
    genOpenBoxValCtrl = TextEditingController(
        text: ((cfg['generalOpenBoxDeductionValue'] as num?)?.toInt() ?? 10)
            .toString());
    genMaxRiskCtrl = TextEditingController(
        text: ((cfg['generalMaxRiskLimit'] as num?)?.toInt() ?? 0).toString());
    genAdminPinCtrl = TextEditingController(
        text: cfg['generalAdminOverridePin']?.toString() ?? '7860');
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
            .toString());
    custProfitCheckCtrl = TextEditingController(
        text: ((cfg['customProfitWithCheck'] as num?)?.toDouble() ?? 0.25)
            .toString());
    custProfitNoCheckCtrl = TextEditingController(
        text: ((cfg['customProfitWithoutCheck'] as num?)?.toDouble() ?? 0.35)
            .toString());
    custIncrementCtrl = TextEditingController(
        text: ((cfg['customPerMonthIncrement'] as num?)?.toDouble() ?? 0.05)
            .toString());
    custDueDayCtrl = TextEditingController(
        text: ((cfg['customInstallmentDueDay'] as num?)?.toInt() ?? 5)
            .toString());
    custGraceDaysCtrl = TextEditingController(
        text: ((cfg['customGracePeriodDays'] as num?)?.toInt() ?? 15)
            .toString());
    custFeeCtrl = TextEditingController(
        text:
            ((cfg['customProcessingFee'] as num?)?.toInt() ?? 0).toString());
    custRoundCtrl = TextEditingController(
        text: ((cfg['customRoundToNearest'] as num?)?.toInt() ?? 100)
            .toString());
    custMdmFeeCtrl = TextEditingController(
        text: ((cfg['customMdmLockFee'] as num?)?.toInt() ?? 1000).toString());
    custOpenBoxType =
        (cfg['customOpenBoxDeductionType']?.toString() ?? mobOpenBoxType) ==
                'FIXED'
            ? 'FIXED'
            : 'PERCENT';
    custOpenBoxValCtrl = TextEditingController(
        text: ((cfg['customOpenBoxDeductionValue'] as num?)?.toInt() ?? 10)
            .toString());
    custMaxRiskCtrl = TextEditingController(
        text: ((cfg['customMaxRiskLimit'] as num?)?.toInt() ?? 0).toString());
    custAdminPinCtrl = TextEditingController(
        text: cfg['customAdminOverridePin']?.toString() ?? '7860');
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
    geofenceEnabled = cfg['geofenceEnabled'] == true;
    geofenceRadiusCtrl = TextEditingController(
        text: ((cfg['geofenceRadiusMeters'] as num?)?.toInt() ?? 150)
            .toString());
    shopLatCtrl = TextEditingController(
        text: cfg['shopLatitude']?.toString() ?? '');
    shopLngCtrl = TextEditingController(
        text: cfg['shopLongitude']?.toString() ?? '');
    shopNameCtrl = TextEditingController(
        text: cfg['shopName']?.toString() ?? 'نایاب قسط پوائنٹ');
    shopSubtitleCtrl = TextEditingController(
        text: cfg['shopSubtitle']?.toString() ?? 'آسان اقساط سینٹر');
    tickerTextCtrl =
        TextEditingController(text: cfg['tickerText']?.toString() ?? '');
    shopLogoUrl = cfg['shopLogoUrl']?.toString() ?? '';
    ownerPhotoUrl = cfg['ownerPhotoUrl']?.toString() ?? '';
    showShopLogo = cfg['showShopLogo'] != false;
    showOwnerPhoto = cfg['showOwnerPhoto'] != false;
    tickerEnabled = cfg['tickerEnabled'] != false;
    showReservedItems = cfg['showReservedItems'] != false;
    showSoldItems = cfg['showSoldItems'] != false;
    showOnOrderItems = cfg['showOnOrderItems'] != false;
    final rawMobGrouping =
        cfg['mobileGroupingMatchKeys'] ?? cfg['groupingMatchKeys'];
    mobileGroupingMatchKeys = rawMobGrouping is List
        ? rawMobGrouping.map((e) => e.toString()).toList()
        : PosRemoteConfigService.defaultMobileGroupingKeys();
    final rawGenGrouping =
        cfg['generalGroupingMatchKeys'] ?? cfg['groupingMatchKeys'];
    generalGroupingMatchKeys = rawGenGrouping is List
        ? rawGenGrouping.map((e) => e.toString()).toList()
        : PosRemoteConfigService.defaultGeneralGroupingKeys();
    cashSaleEnabled = cfg['cashSaleEnabled'] != false;
    final rawMarkupType =
        (cfg['cashMarkupType']?.toString() ?? 'NONE').toUpperCase();
    cashMarkupType = (rawMarkupType == 'PERCENT' || rawMarkupType == 'FIXED')
        ? rawMarkupType
        : 'NONE';
    cashMarkupValCtrl =
        TextEditingController(text: _fmtNum(cfg['cashMarkupValue']));
    allowCashPriceEdit = cfg['allowCashPriceEdit'] != false;
    final rawFloor =
        (cfg['cashMinFloorType']?.toString() ?? 'BASE_STRICT').toUpperCase();
    cashMinFloorType =
        (rawFloor == 'PERCENT' || rawFloor == 'FIXED') ? rawFloor : 'BASE_STRICT';
    cashMinFloorValCtrl =
        TextEditingController(text: _fmtNum(cfg['cashMinFloorValue']));
    final rawCeiling =
        (cfg['cashMaxCeilingType']?.toString() ?? 'NONE').toUpperCase();
    cashMaxCeilingType =
        (rawCeiling == 'PERCENT' || rawCeiling == 'FIXED') ? rawCeiling : 'NONE';
    cashMaxCeilingValCtrl =
        TextEditingController(text: _fmtNum(cfg['cashMaxCeilingValue']));
  }
  void setGeofenceEnabled(bool v) {
    geofenceEnabled = v;
    notifyListeners();
  }
  Future<void> captureCurrentShopLocation() async {
    isFetchingShopLocation = true;
    statusMessage = null;
    notifyListeners();
    try {
      if (!kIsWeb && !await Geolocator.isLocationServiceEnabled()) {
        isFetchingShopLocation = false;
        isStatusError = true;
        statusMessage = '⚠️ براہ کرم ڈیوائس کی GPS / Location سروس آن کریں!';
        notifyListeners();
        return;
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        isFetchingShopLocation = false;
        isStatusError = true;
        statusMessage = '⚠️ براہ کرم لوکیشن کی اجازت (Allow) دیں!';
        notifyListeners();
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      shopLatCtrl.text = pos.latitude.toStringAsFixed(6);
      shopLngCtrl.text = pos.longitude.toStringAsFixed(6);
      isFetchingShopLocation = false;
      isStatusError = false;
      statusMessage =
          '📍 دکان کی موجودہ لوکیشن حاصل ہو گئی (${shopLatCtrl.text}, ${shopLngCtrl.text}) — اب نیچے محفوظ کریں دبائیں!';
      notifyListeners();
    } catch (_) {
      isFetchingShopLocation = false;
      isStatusError = true;
      statusMessage = '⚠️ GPS لوکیشن حاصل نہیں ہو سکی، GPS یا براؤزر پرمیشن چیک کریں۔';
      notifyListeners();
    }
  }
  void setCashSaleEnabled(bool v) { cashSaleEnabled = v; notifyListeners(); }
  void setCashMarkupType(String type) { cashMarkupType = type; notifyListeners(); }
  void setAllowCashPriceEdit(bool v) { allowCashPriceEdit = v; notifyListeners(); }
  void setCashMinFloorType(String type) { cashMinFloorType = type; notifyListeners(); }
  void setCashMaxCeilingType(String type) { cashMaxCeilingType = type; notifyListeners(); }
  void toggleCategoryGroupingKey({required bool isMobile, required String key, required bool selected}) {
    final list = isMobile ? mobileGroupingMatchKeys : generalGroupingMatchKeys;
    selected ? (!list.contains(key) ? list.add(key) : null) : list.remove(key);
    notifyListeners();
  }
  void setZone(int index) { selectedZoneIndex = index; statusMessage = null; notifyListeners(); }
  void setMobOpenBoxType(String val) { mobOpenBoxType = val; notifyListeners(); }
  void setMobCompounding(bool val) { mobCompounding = val; notifyListeners(); }
  void setMobAddFee(bool val) { mobAddFeeToPrincipal = val; notifyListeners(); }
  void adjustMobMaxMonth(int delta) { mobMaxMonth = (mobMaxMonth + delta).clamp(6, 36); mobDurations.removeWhere((m) => m > mobMaxMonth); notifyListeners(); }
  void toggleMobDuration(int m, bool sel) { sel ? (!mobDurations.contains(m) ? mobDurations.add(m) : null) : mobDurations.remove(m); notifyListeners(); }
  void setGenEnabled(bool val) { genEnabled = val; notifyListeners(); }
  void setGenOpenBoxType(String val) { genOpenBoxType = val; notifyListeners(); }
  void setGenCompounding(bool val) { genCompounding = val; notifyListeners(); }
  void setGenAddFee(bool val) { genAddFeeToPrincipal = val; notifyListeners(); }
  void setGenRequireCustomerMdm(bool val) { genRequireCustomerMdm = val; notifyListeners(); }
  void adjustGenMaxMonth(int delta) { genMaxMonth = (genMaxMonth + delta).clamp(6, 36); genDurations.removeWhere((m) => m > genMaxMonth); notifyListeners(); }
  void toggleGenDuration(int m, bool sel) { sel ? (!genDurations.contains(m) ? genDurations.add(m) : null) : genDurations.remove(m); notifyListeners(); }
  void addGeneralField(String urduLabel) { final c = urduLabel.trim(); if (c.isNotEmpty) { genCustomFields.add({'key': 'gen_${DateTime.now().millisecondsSinceEpoch}', 'urduLabel': c}); notifyListeners(); } }
  void renameGeneralField(int idx, String label) { final c = label.trim(); if (c.isNotEmpty && idx >= 0 && idx < genCustomFields.length) { genCustomFields[idx]['urduLabel'] = c; notifyListeners(); } }
  void removeGeneralField(int idx) { if (idx >= 0 && idx < genCustomFields.length) { genCustomFields.removeAt(idx); notifyListeners(); } }
  void setCustOpenBoxType(String val) { custOpenBoxType = val; notifyListeners(); }
  void setCustCompounding(bool val) { custCompounding = val; notifyListeners(); }
  void setCustAddFee(bool val) { custAddFeeToPrincipal = val; notifyListeners(); }
  void setCustRequireCustomerMdm(bool val) { custRequireCustomerMdm = val; notifyListeners(); }
  void adjustCustMaxMonth(int delta) { custMaxMonth = (custMaxMonth + delta).clamp(6, 36); custDurations.removeWhere((m) => m > custMaxMonth); notifyListeners(); }
  void toggleCustDuration(int m, bool sel) { sel ? (!custDurations.contains(m) ? custDurations.add(m) : null) : custDurations.remove(m); notifyListeners(); }
  void toggleCustomAllowedZone(String z, bool sel) { if (sel) { if (!customAllowedZones.contains(z)) customAllowedZones.add(z); } else if (customAllowedZones.length > 1) { customAllowedZones.remove(z); } notifyListeners(); }
  void setRequireDeviceActivation(bool v) { requireDeviceActivation = v; notifyListeners(); }
  void setShopLogoUrl(String url) { shopLogoUrl = url; notifyListeners(); }
  void setOwnerPhotoUrl(String url) { ownerPhotoUrl = url; notifyListeners(); }
  void setShowShopLogo(bool v) { showShopLogo = v; notifyListeners(); }
  void setShowOwnerPhoto(bool v) { showOwnerPhoto = v; notifyListeners(); }
  void setTickerEnabled(bool v) { tickerEnabled = v; notifyListeners(); }
  void setShowReservedItems(bool v) { showReservedItems = v; notifyListeners(); }
  void setShowSoldItems(bool v) { showSoldItems = v; notifyListeners(); }
  void setShowOnOrderItems(bool v) { showOnOrderItems = v; notifyListeners(); }
  Future<void> saveAllSettings() async {
    if (mobDurations.isEmpty || genDurations.isEmpty || custDurations.isEmpty) {
      isStatusError = true;
      statusMessage = '⚠️ تینوں زونز میں کم از کم ایک مدت (ماہ) منتخب کریں!';
      notifyListeners();
      return;
    }
    final parsedLat = double.tryParse(shopLatCtrl.text.trim());
    final parsedLng = double.tryParse(shopLngCtrl.text.trim());
    if (geofenceEnabled && (parsedLat == null || parsedLng == null)) {
      isStatusError = true;
      statusMessage = '⚠️ جیو فینسنگ آن کرنے سے پہلے دکان کی لوکیشن (Lat / Lng) سیٹ کریں!';
      notifyListeners();
      return;
    }
    final parsedRadius =
        (int.tryParse(geofenceRadiusCtrl.text.trim()) ?? 150).clamp(10, 50000);
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
      'allowedDurations': List<int>.from(mobDurations)..sort(),
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
      'generalAllowedDurations': List<int>.from(genDurations)..sort(),
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
      'customAllowedDurations': List<int>.from(custDurations)..sort(),
      'customAllowedZones': customAllowedZones,
      'requireDeviceActivation': requireDeviceActivation,
      'geofenceEnabled': geofenceEnabled,
      'geofenceRadiusMeters': parsedRadius,
      'shopLatitude': parsedLat,
      'shopLongitude': parsedLng,
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
      'cashMarkupValue': double.tryParse(cashMarkupValCtrl.text.trim()) ?? 0,
      'allowCashPriceEdit': allowCashPriceEdit,
      'cashMinFloorType': cashMinFloorType,
      'cashMinFloorValue': double.tryParse(cashMinFloorValCtrl.text.trim()) ?? 0,
      'cashMaxCeilingType': cashMaxCeilingType,
      'cashMaxCeilingValue':
          double.tryParse(cashMaxCeilingValCtrl.text.trim()) ?? 0,
    });
    isStatusError = !ok;
    statusMessage = ok
        ? '✅ تمام ریموٹ سیٹنگز اور نقد فروخت بیریئر کنٹرول محفوظ ہو کر POS پر سنک ہو گئے!'
        : '⚠️ محفوظ کرتے وقت مسئلہ پیش آیا، دوبارہ کوشش کریں۔';
    notifyListeners();
  }
  @override
  void dispose() {
    for (final c in [
      mobAdvanceCtrl, mobProfitCheckCtrl, mobProfitNoCheckCtrl, mobIncrementCtrl,
      mobDueDayCtrl, mobGraceDaysCtrl, mobFeeCtrl, mobRoundCtrl, mobMdmFeeCtrl,
      mobOpenBoxValCtrl, mobMaxRiskCtrl, adminPinCtrl, genAdvanceCtrl,
      genProfitCheckCtrl, genProfitNoCheckCtrl, genIncrementCtrl, genDueDayCtrl,
      genGraceDaysCtrl, genFeeCtrl, genRoundCtrl, genMdmFeeCtrl,
      genOpenBoxValCtrl, genMaxRiskCtrl, genAdminPinCtrl, custAdvanceCtrl,
      custProfitCheckCtrl, custProfitNoCheckCtrl, custIncrementCtrl,
      custDueDayCtrl, custGraceDaysCtrl, custFeeCtrl, custRoundCtrl,
      custMdmFeeCtrl, custOpenBoxValCtrl, custMaxRiskCtrl, custAdminPinCtrl,
      geofenceRadiusCtrl, shopLatCtrl, shopLngCtrl, shopNameCtrl,
      shopSubtitleCtrl, tickerTextCtrl, cashMarkupValCtrl,
      cashMinFloorValCtrl, cashMaxCeilingValCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }
}