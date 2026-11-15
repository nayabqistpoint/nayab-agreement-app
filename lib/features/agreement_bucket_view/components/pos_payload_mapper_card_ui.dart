import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../../core/models/tag_bank_item_model.dart';
import '../../../core/services/tags_bank_service.dart';
import '../../../core/time/time_status_service.dart';

class PosPayloadMapperCardUi extends StatefulWidget {
  final VoidCallback onRulesSaved;

  const PosPayloadMapperCardUi({
    super.key,
    required this.onRulesSaved,
  });

  @override
  State<PosPayloadMapperCardUi> createState() => _PosPayloadMapperCardUiState();
}

class _PosPayloadMapperCardUiState extends State<PosPayloadMapperCardUi> {
  bool _isExpanded = false;
  late List<TagBankItemModel> _posItems;
  late Map<String, dynamic> _samplePayload;
  late Map<String, Set<String>> _discoveredValues;
  final Map<String, TextEditingController> _nameControllers = {};
  final Map<String, bool> _enabledStates = {};
  final Map<String, Map<String, String>> _translationsMap = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _posItems = TagsBankService.getAllPosRules();
    _samplePayload = _getLatestSampleOrder();
    _discoveredValues = _discoverDistinctValues();

    final existingRawKeys = _posItems.map((e) => e.rawKey).toSet();
    final now = TimeStatusService.nowUtcIso();

    // آرڈر یا جڑے ہوئے اسٹاک ریکارڈ کی کوئی بھی نئی کلید خودکار مرر میں شامل کریں
    _samplePayload.forEach((k, _) {
      final keyStr = k.toString();
      if (!existingRawKeys.contains(keyStr)) {
        _posItems.add(
          TagBankItemModel(
            id: 'pos_$keyStr',
            urduName: keyStr,
            source: TagSourceType.pos,
            rawKey: keyStr,
            isEnabled: false,
            updatedAt: now,
          ),
        );
      }
    });

    for (final ctrl in _nameControllers.values) {
      ctrl.dispose();
    }
    _nameControllers.clear();
    _enabledStates.clear();
    _translationsMap.clear();

    for (final item in _posItems) {
      final key = item.rawKey ?? item.id;
      _nameControllers[key] = TextEditingController(text: item.urduName);
      _enabledStates[key] = item.isEnabled;
      _translationsMap[key] = Map<String, String>.from(item.valueTranslations);
    }
  }

  Map<String, dynamic> _getLatestSampleOrder() {
    final box = HiveBoxManager.getBox(BoxNames.shopOrdersBox);
    Map<String, dynamic>? latest;
    String latestTime = '';
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        final map = Map<String, dynamic>.from(raw);
        final t = map['createdAt']?.toString() ?? '';
        if (latest == null || t.compareTo(latestTime) >= 0) {
          latest = map;
          latestTime = t;
        }
      }
    }
    if (latest == null) return {};
    // لوکل Hive کے stock_box سے IMEI کے ذریعے موبائل تفصیلات بھی جوڑ دیں
    return TagsBankService.enrichOrderWithStockByImei(latest);
  }

  Map<String, Set<String>> _discoverDistinctValues() {
    final Map<String, Set<String>> discovered = {};
    final box = HiveBoxManager.getBox(BoxNames.shopOrdersBox);
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        final enriched = TagsBankService.enrichOrderWithStockByImei(raw);
        enriched.forEach((k, v) {
          if (v == null || v is List || v is Map) return;
          final valStr = v.toString().trim();
          if (valStr.isEmpty || valStr == 'null') return;
          discovered.putIfAbsent(k.toString(), () => <String>{}).add(valStr);
        });
      }
    }
    return discovered;
  }

  bool _supportsValueTranslation(
    String rawKey,
    Map<String, String> trans,
    Set<String> observed,
  ) {
    if (trans.isNotEmpty) return true;
    final lowerKey = rawKey.toLowerCase();
    if (lowerKey.startsWith('is') ||
        lowerKey.startsWith('has') ||
        lowerKey.contains('type') ||
        lowerKey.contains('mode') ||
        lowerKey.contains('status')) {
      return true;
    }
    for (final val in observed) {
      if (val == 'true' || val == 'false') return true;
      if (RegExp(r'^[A-Z][A-Z0-9_]{1,}$').hasMatch(val)) return true;
    }
    return false;
  }

  @override
  void dispose() {
    for (final ctrl in _nameControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _openValueTranslatorDialog(String rawKey) {
    final trans = _translationsMap[rawKey]!;
    final fromCtrl = TextEditingController();
    final toCtrl = TextEditingController();
    String? editingOldFromKey;

    final Set<String> suggestions = {...(_discoveredValues[rawKey] ?? {})};
    if (rawKey.toLowerCase().startsWith('is') ||
        rawKey.toLowerCase().startsWith('has') ||
        suggestions.contains('true') ||
        suggestions.contains('false')) {
      suggestions.addAll(['true', 'false']);
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(
              'ویلیو تبدیلی (=) برائے: $rawKey',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            content: SizedBox(
              width: 380,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'جب POS سے بائیں طرف والا کوڈ آئے تو اسے دائیں طرف والے اردو مطلب سے بدل دیا جائے گا:',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    if (suggestions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'آرڈرز و اسٹاک سے دریافت شدہ کوڈز (کلک کر کے منتخب کریں):',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryEmerald,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: suggestions.map((s) {
                          return ActionChip(
                            label: Text(
                              s,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: Colors.teal.shade50,
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              setDialogState(() {
                                editingOldFromKey = null;
                                fromCtrl.text = s;
                                toCtrl.text = trans[s] ?? '';
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: fromCtrl,
                            textAlign: TextAlign.left,
                            decoration: const InputDecoration(
                              labelText: 'From (POS کوڈ)',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '=',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryEmerald,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: toCtrl,
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(
                              labelText: 'To (اردو مطلب)',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final f = fromCtrl.text.trim();
                              final t = toCtrl.text.trim();
                              if (f.isNotEmpty && t.isNotEmpty) {
                                setDialogState(() {
                                  if (editingOldFromKey != null &&
                                      editingOldFromKey != f) {
                                    trans.remove(editingOldFromKey);
                                  }
                                  trans[f] = t;
                                  editingOldFromKey = null;
                                  fromCtrl.clear();
                                  toCtrl.clear();
                                });
                              }
                            },
                            icon: Icon(
                              editingOldFromKey != null
                                  ? Icons.check
                                  : Icons.add,
                              size: 16,
                            ),
                            label: Text(
                              editingOldFromKey != null
                                  ? 'تبدیلی محفوظ کریں'
                                  : 'قانون شامل کریں',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: editingOldFromKey != null
                                  ? Colors.orange.shade800
                                  : AppColors.primaryEmerald,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        if (editingOldFromKey != null) ...[
                          const SizedBox(width: 6),
                          TextButton(
                            onPressed: () {
                              setDialogState(() {
                                editingOldFromKey = null;
                                fromCtrl.clear();
                                toCtrl.clear();
                              });
                            },
                            child: const Text('منسوخ'),
                          ),
                        ],
                      ],
                    ),
                    const Divider(height: 18),
                    if (trans.isEmpty)
                      const Text(
                        'ابھی کوئی ویلیو تبدیلی سیٹ نہیں ہے۔',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      )
                    else
                      ...trans.entries.map(
                        (e) => Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${e.key}  =  ${e.value}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: AppColors.primaryEmerald,
                                ),
                                tooltip: 'ترمیم کریں',
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  setDialogState(() {
                                    editingOldFromKey = e.key;
                                    fromCtrl.text = e.key;
                                    toCtrl.text = e.value;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: AppColors.errorRed,
                                ),
                                tooltip: 'حذف کریں',
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  setDialogState(() {
                                    if (editingOldFromKey == e.key) {
                                      editingOldFromKey = null;
                                      fromCtrl.clear();
                                      toCtrl.clear();
                                    }
                                    trans.remove(e.key);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryEmerald,
                  foregroundColor: Colors.white,
                ),
                child: const Text('مکمل اور بند کریں'),
              ),
            ],
          ),
        ),
      ),
    ).then((_) => setState(() {}));
  }

  Future<void> _saveRules() async {
    final now = TimeStatusService.nowUtcIso();
    final Map<String, dynamic> batchEntries = {};

    for (final item in _posItems) {
      final key = item.rawKey ?? item.id;
      final newName = _nameControllers[key]?.text.trim() ?? item.urduName;
      final isEnabled = _enabledStates[key] ?? item.isEnabled;
      final trans = _translationsMap[key] ?? item.valueTranslations;

      final updated = TagBankItemModel(
        id: item.id,
        urduName: newName.isNotEmpty ? newName : item.urduName,
        source: TagSourceType.pos,
        rawKey: item.rawKey,
        isEnabled: isEnabled,
        valueTranslations: trans,
        isSynced: false,
        updatedAt: now,
      );
      batchEntries[updated.id] = updated.toMap();
    }

    await HiveBoxManager.putBatch(
      boxName: BoxNames.tagsBox,
      entries: batchEntries,
    );

    widget.onRulesSaved();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('✅ POS و اسٹاک ٹیگ میپنگ محفوظ ہو گئی اور ٹیگز بینک میں سنک ہو گئی!'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCount =
        _enabledStates.values.where((enabled) => enabled).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _isExpanded ? AppColors.primaryEmerald : AppColors.borderLight,
          width: _isExpanded ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              if (!_isExpanded) _loadData();
              setState(() => _isExpanded = !_isExpanded);
            },
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_tree_outlined,
                    color: AppColors.primaryEmerald,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'POS پے لوڈ مرر اور ٹیگ میپنگ (مع IMEI اسٹاک لنک)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          'کل ${_posItems.length} خام فیلڈز میں سے $activeCount فعال ٹیگز منتخب ہیں',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.primaryEmerald,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'ٹِک (✅) لگائیں کہ کون سی آرڈر یا اسٹاک فیلڈ معاہدے کا ٹیگ بنے، اس کا اردو نام لکھیں، اور ٹائپ/بولین فیلڈز کے لیے (=) دبائیں:',
                      style: TextStyle(fontSize: 11.5, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._posItems.map((item) {
                    final key = item.rawKey ?? item.id;
                    final isEnabled = _enabledStates[key] ?? false;
                    final trans = _translationsMap[key] ?? {};
                    final sampleVal = _samplePayload[key];
                    final samplePreview = (sampleVal == null ||
                            sampleVal is List ||
                            sampleVal is Map)
                        ? ''
                        : ' (مثال: $sampleVal)';

                    final observed = _discoveredValues[key] ?? <String>{};
                    final showEqualsBtn =
                        _supportsValueTranslation(key, trans, observed);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: isEnabled
                            ? Colors.teal.shade50.withAlpha(110)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isEnabled
                              ? AppColors.primaryEmerald.withAlpha(90)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isEnabled,
                            activeColor: AppColors.primaryEmerald,
                            visualDensity: VisualDensity.compact,
                            onChanged: (val) {
                              setState(() {
                                _enabledStates[key] = val ?? false;
                              });
                            },
                          ),
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                if (samplePreview.isNotEmpty)
                                  Text(
                                    samplePreview,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      color: Colors.black54,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 5,
                            child: TextField(
                              controller: _nameControllers[key],
                              enabled: isEnabled,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'اردو ٹیگ نام',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 7),
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                          if (showEqualsBtn) ...[
                            const SizedBox(width: 4),
                            Tooltip(
                              message:
                                  'ویلیو تبدیلی (=) مثلاً NEW/USED یا LEGAL_STAMP',
                              child: InkWell(
                                onTap: isEnabled
                                    ? () => _openValueTranslatorDialog(key)
                                    : null,
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: trans.isNotEmpty
                                        ? Colors.amber.shade700
                                        : (isEnabled
                                            ? Colors.blueGrey.shade700
                                            : Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    '=',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _saveRules,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text(
                      'ٹیگ میپنگ محفوظ کریں اور لاگو کریں',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryEmerald,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}