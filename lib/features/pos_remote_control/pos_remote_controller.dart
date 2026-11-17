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
  late final TextEditingController genFeeCtrl;
  late final TextEditingController genMaxRiskCtrl;

  bool genEnabled = true;
  bool genCompounding = false;
  bool genRequireCustomerMdm = true;
  List<int> genDurations = [6, 8, 10, 12, 15, 18];
  int genMaxMonth = 24;
  FieldDefList genCustomFields = [];

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
    final next = (mobMaxMonth + delta).clamp(6, 36);
    mobMaxMonth = next;
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
    final next = (genMaxMonth + delta).clamp(6, 36);
    genMaxMonth = next;
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

  Future<void> saveAllSettings() async {
    if (mobDurations.isEmpty || genDurations.isEmpty) {
      isStatusError = true;
      statusMessage = '⚠️ دونوں زونز میں کم از کم ایک مدت (ماہ) منتخب کریں!';
      notifyListeners();
      return;
    }

    final sortedMob = List<int>.from(mobDurations)..sort();
    final sortedGen = List<int>.from(genDurations)..sort();

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
      'generalProcessingFee': int.tryParse(genFeeCtrl.text.trim()) ?? 0,
      'generalMaxRiskLimit': int.tryParse(genMaxRiskCtrl.text.trim()) ?? 0,
      'generalIsCompoundingProfit': genCompounding,
      'generalRequireCustomerMobileMdm': genRequireCustomerMdm,
      'generalAllowedDurations': sortedGen,
      'generalCustomFields': genCustomFields,
    });

    isStatusError = !ok;
    statusMessage = ok
        ? '✅ موبائل اور جنرل دونوں زونز کی تمام سیٹنگز محفوظ ہو کر POS ایپ پر سنک ہو گئیں!'
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
    super.dispose();
  }
}