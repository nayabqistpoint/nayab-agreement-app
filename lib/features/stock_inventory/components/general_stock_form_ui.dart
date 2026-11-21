import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/qr_scanner.dart';
import '../services/stock_inventory_storage_service.dart';
import 'dynamic_stock_fields_card_ui.dart';
import 'lot_invoice_summary_card_ui.dart';
import 'splittable_dropdown_wrapper_ui.dart';
import 'splittable_field_wrapper_ui.dart';
import 'splittable_photo_picker_ui.dart';

class GeneralStockFormUi extends StatefulWidget {
  final Map<String, dynamic>? editingItem;
  final Map<String, dynamic>? prefillData;
  final int quantity;
  final VoidCallback onCancelEdit;
  final Function({
    required String stockId,
    required String itemName,
    required String serialNo,
    required String specsSummary,
    required String color,
    required int purchasePrice,
    required int salePrice,
    required String supplier,
    required String conditionType,
    required String conditionRating,
    required int warranty,
    required bool isOnOrder,
    required int quantity,
    required Map<String, String> dynamicFields,
    required Map<String, List<String>> perUnitOverrides,
    required List<String> images,
    required List<List<String>> perUnitImages,
  }) onSave;

  const GeneralStockFormUi({
    super.key,
    required this.editingItem,
    this.prefillData,
    this.quantity = 1,
    required this.onCancelEdit,
    required this.onSave,
  });

  @override
  State<GeneralStockFormUi> createState() => _GeneralStockFormUiState();
}

class _GeneralStockFormUiState extends State<GeneralStockFormUi> {
  final TextEditingController _modelCtrl = TextEditingController();
  final TextEditingController _serialCtrl = TextEditingController();
  final TextEditingController _specsCtrl = TextEditingController();
  final TextEditingController _purchasePriceCtrl = TextEditingController();
  final TextEditingController _salePriceCtrl = TextEditingController();
  final TextEditingController _supplierCtrl = TextEditingController();

  final Map<String, TextEditingController> _dynamicControllers = {};
  late DynamicFieldDefList _customFieldDefs;

  final Set<String> _activeSplitKeys = {};
  final Map<String, List<TextEditingController>> _splitControllersMap = {};
  final Map<String, List<String>> _splitDropdownValuesMap = {};

  bool _isPhotoSplitActive = false;
  final List<List<String>> _perUnitImages = [];

  List<String> _selectedImages = [];
  String _selectedColor = 'کالا (Black)';
  String _selectedCondition = 'NEW';
  int _selectedWarranty = 12;
  bool _isOnOrder = false;

  static const List<String> _colorOptions = [
    'کالا (Black)',
    'سفید (White)',
    'نیلا (Blue)',
    'سرخ (Red)',
    'سلور (Silver)',
  ];

  static const List<int> _warrantyMonthsList = [
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    24,
    36,
  ];

  int get _currentQty =>
      widget.editingItem != null ? 1 : widget.quantity.clamp(1, 50);

  @override
  void initState() {
    super.initState();
    _initDynamicControllers();
    _purchasePriceCtrl.addListener(_refreshSummary);
    _salePriceCtrl.addListener(_refreshSummary);
    if (widget.editingItem != null) {
      _populate(widget.editingItem!);
    } else if (widget.prefillData != null) {
      _populatePrefill(widget.prefillData!);
    }
  }

  void _refreshSummary() {
    if (mounted) setState(() {});
  }

  void _syncSplitListsToQty(int q) {
    if (q <= 1) {
      _clearAllSplits();
    } else {
      for (final key in _activeSplitKeys) {
        if (_splitDropdownValuesMap.containsKey(key)) {
          _resizeDropdownSplitList(key, q, _defaultDropdownVal(key));
        } else {
          _resizeSplitList(key, q);
        }
      }
      if (_isPhotoSplitActive) {
        _resizePhotoSplitList(q);
      }
    }
  }

  String _defaultDropdownVal(String key) {
    if (key == 'color') return _selectedColor;
    if (key == 'conditionType') return _selectedCondition;
    if (key == 'warranty') return '$_selectedWarranty';
    return '';
  }

  void _resizeSplitList(String key, int targetCount) {
    final list = _splitControllersMap.putIfAbsent(key, () => []);
    while (list.length < targetCount) {
      final c = TextEditingController();
      c.addListener(_refreshSummary);
      list.add(c);
    }
    while (list.length > targetCount) {
      final removed = list.removeLast();
      removed.removeListener(_refreshSummary);
      removed.dispose();
    }
  }

  void _resizeDropdownSplitList(String key, int targetCount, String defVal) {
    final list = _splitDropdownValuesMap.putIfAbsent(key, () => []);
    while (list.length < targetCount) {
      list.add(defVal);
    }
    while (list.length > targetCount) {
      list.removeLast();
    }
  }

  void _resizePhotoSplitList(int targetCount) {
    while (_perUnitImages.length < targetCount) {
      _perUnitImages.add(<String>[]);
    }
    while (_perUnitImages.length > targetCount) {
      _perUnitImages.removeLast();
    }
  }

  void _togglePhotoSplit() {
    setState(() {
      _isPhotoSplitActive = !_isPhotoSplitActive;
      if (_isPhotoSplitActive) {
        _resizePhotoSplitList(_currentQty);
      } else {
        _perUnitImages.clear();
      }
    });
  }

  void _toggleSplit(String key) {
    setState(() {
      if (_activeSplitKeys.contains(key)) {
        _activeSplitKeys.remove(key);
      } else {
        _activeSplitKeys.add(key);
        _resizeSplitList(key, _currentQty);
      }
    });
  }

  void _toggleDropdownSplit(String key) {
    setState(() {
      if (_activeSplitKeys.contains(key)) {
        _activeSplitKeys.remove(key);
      } else {
        _activeSplitKeys.add(key);
        _resizeDropdownSplitList(key, _currentQty, _defaultDropdownVal(key));
      }
    });
  }

  void _clearAllSplits() {
    _activeSplitKeys.clear();
    _isPhotoSplitActive = false;
    _perUnitImages.clear();
    for (final list in _splitControllersMap.values) {
      for (final c in list) {
        c.removeListener(_refreshSummary);
        c.dispose();
      }
    }
    _splitControllersMap.clear();
    _splitDropdownValuesMap.clear();
  }

  void _initDynamicControllers() {
    _customFieldDefs =
        StockInventoryStorageService.getCategoryDynamicFields(isMobile: false);
    for (final def in _customFieldDefs) {
      final key = def['key']!;
      _dynamicControllers.putIfAbsent(key, () => TextEditingController());
    }
  }

  Future<void> _addDynamicField(String urduLabel) async {
    final clean = urduLabel.trim();
    if (clean.isEmpty) return;
    final key = 'gen_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _customFieldDefs.add({'key': key, 'urduLabel': clean});
      _dynamicControllers[key] = TextEditingController();
    });
    await StockInventoryStorageService.saveCategoryDynamicFields(
      isMobile: false,
      fields: _customFieldDefs,
    );
  }

  Future<void> _removeDynamicField(int index) async {
    if (index < 0 || index >= _customFieldDefs.length) return;
    final removedKey = _customFieldDefs[index]['key']!;
    setState(() {
      _customFieldDefs.removeAt(index);
      _dynamicControllers[removedKey]?.dispose();
      _dynamicControllers.remove(removedKey);
      _activeSplitKeys.remove(removedKey);
      final sList = _splitControllersMap.remove(removedKey);
      if (sList != null) {
        for (final c in sList) {
          c.dispose();
        }
      }
    });
    await StockInventoryStorageService.saveCategoryDynamicFields(
      isMobile: false,
      fields: _customFieldDefs,
    );
  }

  @override
  void didUpdateWidget(covariant GeneralStockFormUi oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantity != widget.quantity) {
      _syncSplitListsToQty(_currentQty);
    }
    if (widget.editingItem != oldWidget.editingItem) {
      if (widget.editingItem != null) {
        _populate(widget.editingItem!);
      } else if (widget.prefillData != null) {
        _populatePrefill(widget.prefillData!);
      } else {
        _reset();
      }
    }
  }

  void _populatePrefill(Map<String, dynamic> pre) {
    _modelCtrl.text = pre['itemName']?.toString() ?? '';
    _serialCtrl.text = pre['serialNo']?.toString() ?? '';
    _specsCtrl.text = pre['specsSummary']?.toString() ?? '';
    final pPrice = (pre['purchasePrice'] ?? '').toString();
    _purchasePriceCtrl.text = (pPrice == '0' || pPrice == 'null') ? '' : pPrice;
    final sPrice = (pre['salePrice'] ?? '').toString();
    _salePriceCtrl.text = (sPrice == '0' || sPrice == 'null') ? '' : sPrice;
    _supplierCtrl.text = pre['supplierInfo']?.toString() ?? '';
    _isOnOrder = false;

    final col = pre['color']?.toString() ?? '';
    if (_colorOptions.contains(col)) _selectedColor = col;
    if (pre['warranty'] != null) {
      final w = int.tryParse(pre['warranty'].toString()) ?? 12;
      _selectedWarranty = _warrantyMonthsList.contains(w) ? w : 12;
    }
    for (final entry in _dynamicControllers.entries) {
      final val = pre[entry.key]?.toString() ?? '';
      if (val.isNotEmpty && val != 'null') {
        entry.value.text = val;
      }
    }
  }

  void _populate(Map<String, dynamic> item) {
    _modelCtrl.text = item['itemName']?.toString() ?? '';
    _serialCtrl.text = item['serialNo']?.toString() ?? '';
    _specsCtrl.text = item['specsSummary']?.toString() ?? '';
    _purchasePriceCtrl.text = (item['purchasePrice'] ?? '').toString() == '0'
        ? ''
        : (item['purchasePrice']?.toString() ?? '');
    _salePriceCtrl.text = item['salePrice']?.toString() ?? '';
    _supplierCtrl.text = item['supplierInfo']?.toString() ?? '';
    _clearAllSplits();

    for (final entry in _dynamicControllers.entries) {
      entry.value.text = item[entry.key]?.toString() ?? '';
    }
    final rawImgs = item['images'];
    if (rawImgs is List) {
      _selectedImages =
          rawImgs.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    } else {
      _selectedImages = [];
    }
    final col = item['color']?.toString() ?? 'کالا (Black)';
    _selectedColor = _colorOptions.contains(col) ? col : 'کالا (Black)';
    _selectedCondition = item['conditionType']?.toString() ?? 'NEW';
    final w = int.tryParse(item['warranty']?.toString() ?? '12') ?? 12;
    _selectedWarranty = _warrantyMonthsList.contains(w) ? w : 12;
    final st = (item['status']?.toString() ?? '').toUpperCase();
    _isOnOrder = item['isOnOrder'] == true || st == 'ON_ORDER';
  }

  void _reset() {
    _modelCtrl.clear();
    _serialCtrl.clear();
    _specsCtrl.clear();
    _purchasePriceCtrl.clear();
    _salePriceCtrl.clear();
    _supplierCtrl.clear();
    _clearAllSplits();
    for (final c in _dynamicControllers.values) {
      c.clear();
    }
    _selectedImages = [];
    _selectedColor = 'کالا (Black)';
    _selectedCondition = 'NEW';
    _selectedWarranty = 12;
    _isOnOrder = false;
  }

  @override
  void dispose() {
    _purchasePriceCtrl.removeListener(_refreshSummary);
    _salePriceCtrl.removeListener(_refreshSummary);
    _modelCtrl.dispose();
    _serialCtrl.dispose();
    _specsCtrl.dispose();
    _purchasePriceCtrl.dispose();
    _salePriceCtrl.dispose();
    _supplierCtrl.dispose();
    _clearAllSplits();
    for (final c in _dynamicControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    final res =
        await QrScanner.scan(context, title: 'سیریل / بارکوڈ اسکین کریں');
    if (res != null && res.trim().isNotEmpty) {
      setState(() => _serialCtrl.text = res.trim());
    }
  }

  ({int totalPurchase, int totalSale}) _calculateLotTotals() {
    final qty = _currentQty;
    final basePurchase = int.tryParse(_purchasePriceCtrl.text.trim()) ?? 0;
    final baseSale = int.tryParse(_salePriceCtrl.text.trim()) ?? 0;

    int sumPurchase = 0;
    int sumSale = 0;

    for (int i = 0; i < qty; i++) {
      if (_activeSplitKeys.contains('purchasePrice')) {
        final ctrls = _splitControllersMap['purchasePrice'] ?? [];
        final val = i < ctrls.length
            ? (int.tryParse(ctrls[i].text.trim()) ?? basePurchase)
            : basePurchase;
        sumPurchase += val;
      } else {
        sumPurchase += basePurchase;
      }

      if (_activeSplitKeys.contains('salePrice')) {
        final ctrls = _splitControllersMap['salePrice'] ?? [];
        final val = i < ctrls.length
            ? (int.tryParse(ctrls[i].text.trim()) ?? baseSale)
            : baseSale;
        sumSale += val;
      } else {
        sumSale += baseSale;
      }
    }
    return (totalPurchase: sumPurchase, totalSale: sumSale);
  }

  void _submit() {
    final name = _modelCtrl.text.trim();
    final sale = int.tryParse(_salePriceCtrl.text.trim()) ?? 0;
    final qty = _currentQty;

    final bool hasSplitNames = _activeSplitKeys.contains('itemName');
    final bool hasSplitSales = _activeSplitKeys.contains('salePrice');

    if (!hasSplitNames && name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('براہ کرم آئٹم کا نام درج کریں!'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (!hasSplitSales && sale <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('براہ کرم نقد قیمت فروخت درج کریں!'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final Map<String, String> dynamicMap = {};
    _dynamicControllers.forEach((k, ctrl) {
      dynamicMap[k] = ctrl.text.trim();
    });

    final Map<String, List<String>> overrides = {};
    for (final key in _activeSplitKeys) {
      if (_splitDropdownValuesMap.containsKey(key)) {
        overrides[key] = List<String>.from(_splitDropdownValuesMap[key]!);
      } else {
        final ctrls = _splitControllersMap[key] ?? [];
        overrides[key] = ctrls.map((c) => c.text.trim()).toList();
      }
    }

    widget.onSave(
      stockId: widget.editingItem?['id']?.toString() ?? '',
      itemName: name,
      serialNo: _serialCtrl.text.trim(),
      specsSummary: _specsCtrl.text.trim(),
      color: _selectedColor,
      purchasePrice: int.tryParse(_purchasePriceCtrl.text.trim()) ?? 0,
      salePrice: sale,
      supplier: _supplierCtrl.text.trim(),
      conditionType: _selectedCondition,
      conditionRating: '10/10',
      warranty: _selectedWarranty,
      isOnOrder: _isOnOrder,
      quantity: qty,
      dynamicFields: dynamicMap,
      perUnitOverrides: overrides,
      images: _selectedImages,
      perUnitImages: _isPhotoSplitActive ? _perUnitImages : const [],
    );
    if (widget.editingItem == null) {
      setState(() => _reset());
    }
  }

  InputDecoration _dec(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w900,
        color: AppColors.textDark,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: AppColors.cardSurface,
    );
  }

  @override
  Widget build(BuildContext context) {
    final qty = _currentQty;
    final upcomingIds = StockInventoryStorageService.previewNextStockIds(qty);
    final lotTotals = _calculateLotTotals();

    final colorItems = _colorOptions
        .map((c) => DropdownMenuItem(
            value: c,
            child: Text(c,
                style: const TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 14.5))))
        .toList();

    const condItems = [
      DropdownMenuItem(
          value: 'NEW',
          child: Text('نیا (Brand New)',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5))),
      DropdownMenuItem(
          value: 'USED',
          child: Text('استعمال شدہ (Used)',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5))),
    ];

    final warrantyItems = _warrantyMonthsList
        .map((w) => DropdownMenuItem(
            value: '$w',
            child: Text(w == 0 ? 'بغیر وارنٹی' : '$w ماہ',
                style: const TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 14.5))))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: _isOnOrder
                ? AppColors.warmTintEmerald
                : AppColors.warmSubtleSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isOnOrder
                  ? AppColors.primaryEmerald
                  : AppColors.borderLight,
            ),
          ),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(
              _isOnOrder
                  ? '📦 آرڈر پر دستیاب (ڈیلر سے منگوا کر دیں گے)'
                  : '🏪 دکان / گودام میں موجود اسٹاک',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14.5,
                color: _isOnOrder
                    ? AppColors.primaryEmerald
                    : AppColors.textDark,
              ),
            ),
            value: _isOnOrder,
            activeTrackColor: AppColors.primaryEmerald,
            onChanged: (v) => setState(() => _isOnOrder = v),
          ),
        ),
        const SizedBox(height: 11),
        SplittablePhotoPickerUi(
          sharedImages: _selectedImages,
          onSharedImagesChanged: (imgs) =>
              setState(() => _selectedImages = imgs),
          quantity: qty,
          upcomingStockIds: upcomingIds,
          isSplitActive: _isPhotoSplitActive,
          perUnitImages: _perUnitImages,
          onToggleSplit: _togglePhotoSplit,
          onUnitImagesChanged: (idx, imgs) {
            setState(() => _perUnitImages[idx] = imgs);
          },
        ),
        const SizedBox(height: 11),
        SplittableFieldWrapperUi(
          quantity: qty,
          upcomingStockIds: upcomingIds,
          fieldLabel: 'آئٹم کا نام',
          isSplitActive: _activeSplitKeys.contains('itemName'),
          perUnitControllers: _splitControllersMap['itemName'] ?? const [],
          onToggleSplit: () => _toggleSplit('itemName'),
          singleFieldChild: TextField(
            controller: _modelCtrl,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            decoration: _dec('آئٹم کا نام (مثلاً Dawlance فریج / پنکھا)'),
          ),
        ),
        const SizedBox(height: 11),
        SplittableFieldWrapperUi(
          quantity: qty,
          upcomingStockIds: upcomingIds,
          fieldLabel: 'سیریل / چیسز نمبر',
          isSplitActive: _activeSplitKeys.contains('imeiOrSerial'),
          perUnitControllers: _splitControllersMap['imeiOrSerial'] ?? const [],
          onToggleSplit: () => _toggleSplit('imeiOrSerial'),
          enableScanner: true,
          textAlign: TextAlign.left,
          singleFieldChild: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _serialCtrl,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 16),
                  decoration: _dec('سیریل / چیسز نمبر (اختیاری)'),
                ),
              ),
              const SizedBox(width: 6),
              Tooltip(
                message: 'سیریل / بارکوڈ اسکین کریں',
                child: InkWell(
                  onTap: _scanBarcode,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 46,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade800,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 11),
        SplittableFieldWrapperUi(
          quantity: qty,
          upcomingStockIds: upcomingIds,
          fieldLabel: 'سائز و تفصیل',
          isSplitActive: _activeSplitKeys.contains('specsOrRam'),
          perUnitControllers: _splitControllersMap['specsOrRam'] ?? const [],
          onToggleSplit: () => _toggleSplit('specsOrRam'),
          singleFieldChild: TextField(
            controller: _specsCtrl,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5),
            decoration: _dec('سائز و تفصیل (مثلاً 14 کیوبک فٹ انورٹر)'),
          ),
        ),
        const SizedBox(height: 11),
        SplittableFieldWrapperUi(
          quantity: qty,
          upcomingStockIds: upcomingIds,
          fieldLabel: 'قیمتِ خرید',
          isSplitActive: _activeSplitKeys.contains('purchasePrice'),
          perUnitControllers: _splitControllersMap['purchasePrice'] ?? const [],
          onToggleSplit: () => _toggleSplit('purchasePrice'),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.left,
          singleFieldChild: TextField(
            controller: _purchasePriceCtrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.left,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            decoration: _dec('قیمتِ خرید (روپے)'),
          ),
        ),
        const SizedBox(height: 11),
        SplittableFieldWrapperUi(
          quantity: qty,
          upcomingStockIds: upcomingIds,
          fieldLabel: 'نقد قیمت فروخت',
          isSplitActive: _activeSplitKeys.contains('salePrice'),
          perUnitControllers: _splitControllersMap['salePrice'] ?? const [],
          onToggleSplit: () => _toggleSplit('salePrice'),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.left,
          singleFieldChild: TextField(
            controller: _salePriceCtrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.left,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            decoration: _dec('نقد قیمت فروخت (لازمی)'),
          ),
        ),
        const SizedBox(height: 11),
        SplittableFieldWrapperUi(
          quantity: qty,
          upcomingStockIds: upcomingIds,
          fieldLabel: 'سپلائر / ڈیلر',
          isSplitActive: _activeSplitKeys.contains('supplier'),
          perUnitControllers: _splitControllersMap['supplier'] ?? const [],
          onToggleSplit: () => _toggleSplit('supplier'),
          singleFieldChild: TextField(
            controller: _supplierCtrl,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5),
            decoration: _dec('سپلائر / ڈیلر کا نام و فون'),
          ),
        ),
        const SizedBox(height: 11),
        SplittableDropdownWrapperUi<String>(
          quantity: qty,
          upcomingStockIds: upcomingIds,
          fieldLabel: 'رنگ (Color)',
          isSplitActive: _activeSplitKeys.contains('color'),
          perUnitValues: _splitDropdownValuesMap['color'] ?? const [],
          items: colorItems,
          onToggleSplit: () => _toggleDropdownSplit('color'),
          onUnitValueChanged: (idx, val) {
            setState(() => _splitDropdownValuesMap['color']![idx] = val);
          },
          singleDropdownChild: DropdownButtonFormField<String>(
            key: ValueKey('gen_color_$_selectedColor'),
            initialValue: _selectedColor,
            isExpanded: true,
            decoration: _dec('رنگ (Color)'),
            items: colorItems,
            onChanged: (v) =>
                v != null ? setState(() => _selectedColor = v) : null,
          ),
        ),
        const SizedBox(height: 11),
        SplittableDropdownWrapperUi<String>(
          quantity: qty,
          upcomingStockIds: upcomingIds,
          fieldLabel: 'حالت (New / Used)',
          isSplitActive: _activeSplitKeys.contains('conditionType'),
          perUnitValues: _splitDropdownValuesMap['conditionType'] ?? const [],
          items: condItems,
          onToggleSplit: () => _toggleDropdownSplit('conditionType'),
          onUnitValueChanged: (idx, val) {
            setState(
                () => _splitDropdownValuesMap['conditionType']![idx] = val);
          },
          singleDropdownChild: DropdownButtonFormField<String>(
            key: ValueKey('gen_cond_$_selectedCondition'),
            initialValue: _selectedCondition,
            isExpanded: true,
            decoration: _dec('حالت'),
            items: condItems,
            onChanged: (v) =>
                v != null ? setState(() => _selectedCondition = v) : null,
          ),
        ),
        const SizedBox(height: 11),
        SplittableDropdownWrapperUi<String>(
          quantity: qty,
          upcomingStockIds: upcomingIds,
          fieldLabel: 'وارنٹی',
          isSplitActive: _activeSplitKeys.contains('warranty'),
          perUnitValues: _splitDropdownValuesMap['warranty'] ?? const [],
          items: warrantyItems,
          onToggleSplit: () => _toggleDropdownSplit('warranty'),
          onUnitValueChanged: (idx, val) {
            setState(() => _splitDropdownValuesMap['warranty']![idx] = val);
          },
          singleDropdownChild: DropdownButtonFormField<String>(
            key: ValueKey('gen_warranty_$_selectedWarranty'),
            initialValue: '$_selectedWarranty',
            isExpanded: true,
            decoration: _dec('وارنٹی'),
            items: warrantyItems,
            onChanged: (v) => v != null
                ? setState(() => _selectedWarranty = int.tryParse(v) ?? 12)
                : null,
          ),
        ),
        const SizedBox(height: 12),
        DynamicStockFieldsCardUi(
          fieldDefs: _customFieldDefs,
          controllers: _dynamicControllers,
          quantity: qty,
          upcomingStockIds: upcomingIds,
          activeSplitKeys: _activeSplitKeys,
          splitControllersMap: _splitControllersMap,
          onToggleSplit: _toggleSplit,
          onAddField: _addDynamicField,
          onRemoveField: _removeDynamicField,
        ),
        if (qty > 1 && widget.editingItem == null) ...[
          const SizedBox(height: 12),
          LotInvoiceSummaryCardUi(
            quantity: qty,
            firstStockId: upcomingIds.first,
            lastStockId: upcomingIds.last,
            totalPurchase: lotTotals.totalPurchase,
            totalSale: lotTotals.totalSale,
          ),
        ],
        const SizedBox(height: 14),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryEmerald,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
          ),
          child: Text(
            widget.editingItem != null
                ? 'تبدیلیاں محفوظ کریں'
                : 'اسٹاک میں شامل کریں (مع منفرد Stock IDs)',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16.5),
          ),
        ),
      ],
    );
  }
}