import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/qr_scanner.dart';
import '../services/stock_inventory_storage_service.dart';
import 'dynamic_stock_fields_card_ui.dart';
import 'lot_invoice_summary_card_ui.dart';
import 'splittable_dropdown_wrapper_ui.dart';
import 'splittable_field_wrapper_ui.dart';
import 'splittable_photo_picker_ui.dart';
import 'stock_field_eye_toggle_ui.dart';
class MobileStockFormUi extends StatefulWidget {
  final Map<String, dynamic>? editingItem;
  final Map<String, dynamic>? prefillData;
  final int quantity;
  final VoidCallback onCancelEdit;
  final Function({
    required String stockId,
    required String itemName,
    required String imei,
    required String ramRom,
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
  const MobileStockFormUi({
    super.key,
    required this.editingItem,
    this.prefillData,
    this.quantity = 1,
    required this.onCancelEdit,
    required this.onSave,
  });
  @override
  State<MobileStockFormUi> createState() => _MobileStockFormUiState();
}
class _MobileStockFormUiState extends State<MobileStockFormUi> {
  final TextEditingController _modelCtrl = TextEditingController();
  final TextEditingController _imeiCtrl = TextEditingController();
  final TextEditingController _purchasePriceCtrl = TextEditingController();
  final TextEditingController _salePriceCtrl = TextEditingController();
  final TextEditingController _supplierCtrl = TextEditingController();
  final FocusNode _singleImeiFocus = FocusNode();
  final List<FocusNode> _splitImeiFocusNodes = [];
  bool _singleImeiError = false;
  Set<int> _invalidImeiIndexes = {};
  final Map<String, TextEditingController> _dynamicControllers = {};
  late DynamicFieldDefList _customFieldDefs;
  late Set<String> _visibleCardKeys;
  final Set<String> _activeSplitKeys = {};
  final Map<String, List<TextEditingController>> _splitControllersMap = {};
  final Map<String, List<String>> _splitDropdownValuesMap = {};
  bool _isPhotoSplitActive = false;
  final List<List<String>> _perUnitImages = [];
  List<String> _selectedImages = [];
  String _selectedRamRom = '8GB / 256GB';
  String _selectedColor = 'کالا (Black)';
  String _selectedCondition = 'NEW';
  String _selectedRating = '10/10';
  int _selectedWarranty = 12;
  bool _isOnOrder = false;
  static const List<String> _ramOptions = [
    '2GB / 32GB',
    '3GB / 32GB',
    '4GB / 64GB',
    '4GB / 128GB',
    '6GB / 128GB',
    '8GB / 128GB',
    '8GB / 256GB',
    '12GB / 256GB',
  ];
  static const List<String> _colorOptions = [
    'کالا (Black)',
    'سفید (White)',
    'نیلا (Blue)',
    'سبز (Green)',
    'سنہری (Gold)',
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
  ];
  int get _currentQty =>
      widget.editingItem != null ? 1 : widget.quantity.clamp(1, 50);
  bool get _forceImeiSplit => !_isOnOrder && _currentQty > 1;
  @override
  void initState() {
    super.initState();
    _initDynamicControllers();
    _purchasePriceCtrl.addListener(_refreshSummary);
    _salePriceCtrl.addListener(_refreshSummary);
    _imeiCtrl.addListener(() {
      if (_singleImeiError && _imeiCtrl.text.trim().isNotEmpty) {
        setState(() => _singleImeiError = false);
      }
    });
    if (widget.editingItem != null) {
      _populate(widget.editingItem!);
    } else if (widget.prefillData != null) {
      _populatePrefill(widget.prefillData!);
    }
    _ensureForcedImeiSplit();
  }
  void _ensureForcedImeiSplit() {
    if (_forceImeiSplit) {
      _activeSplitKeys.add('imeiOrSerial');
      _resizeSplitList('imeiOrSerial', _currentQty);
      _resizeImeiFocusNodes(_currentQty);
    }
  }
  void _refreshSummary() {
    if (mounted) setState(() {});
  }
  void _syncSplitListsToQty(int q) {
    if (q <= 1) {
      _clearAllSplits();
    } else {
      _ensureForcedImeiSplit();
      for (final key in _activeSplitKeys) {
        if (_splitDropdownValuesMap.containsKey(key)) {
          _resizeDropdownSplitList(key, q, _defaultDropdownVal(key));
        } else {
          _resizeSplitList(key, q);
        }
      }
      _resizeImeiFocusNodes(q);
      if (_isPhotoSplitActive) {
        _resizePhotoSplitList(q);
      }
    }
  }
  String _defaultDropdownVal(String key) {
    if (key == 'specsOrRam') return _selectedRamRom;
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
      if (key == 'imeiOrSerial') {
        c.addListener(() {
          if (_invalidImeiIndexes.isNotEmpty && mounted) {
            setState(() => _invalidImeiIndexes = {});
          }
        });
      }
      list.add(c);
    }
    while (list.length > targetCount) {
      final removed = list.removeLast();
      removed.removeListener(_refreshSummary);
      removed.dispose();
    }
  }
  void _resizeImeiFocusNodes(int targetCount) {
    while (_splitImeiFocusNodes.length < targetCount) {
      _splitImeiFocusNodes.add(FocusNode());
    }
    while (_splitImeiFocusNodes.length > targetCount) {
      _splitImeiFocusNodes.removeLast().dispose();
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
        if (_selectedImages.isNotEmpty &&
            _perUnitImages.isNotEmpty &&
            _perUnitImages[0].isEmpty) {
          _perUnitImages[0] = List<String>.from(_selectedImages);
        }
      } else {
        if (_selectedImages.isEmpty &&
            _perUnitImages.isNotEmpty &&
            _perUnitImages[0].isNotEmpty) {
          _selectedImages = List<String>.from(_perUnitImages[0]);
        }
        _perUnitImages.clear();
      }
    });
  }
  void _toggleSplit(String key) {
    if (key == 'imeiOrSerial' && _forceImeiSplit) return;
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
    _invalidImeiIndexes = {};
    _singleImeiError = false;
    for (final list in _splitControllersMap.values) {
      for (final c in list) {
        c.removeListener(_refreshSummary);
        c.dispose();
      }
    }
    _splitControllersMap.clear();
    _splitDropdownValuesMap.clear();
    for (final fn in _splitImeiFocusNodes) {
      fn.dispose();
    }
    _splitImeiFocusNodes.clear();
  }
  void _initDynamicControllers() {
    _customFieldDefs =
        StockInventoryStorageService.getCategoryDynamicFields(isMobile: true);
    _visibleCardKeys =
        StockInventoryStorageService.getVisibleCardFields(isMobile: true);
    for (final def in _customFieldDefs) {
      final key = def['key']!;
      _dynamicControllers.putIfAbsent(key, () => TextEditingController());
    }
  }
  Future<void> _toggleFieldVisibility(String fieldKey) async {
    setState(() {
      if (_visibleCardKeys.contains(fieldKey)) {
        _visibleCardKeys.remove(fieldKey);
      } else {
        _visibleCardKeys.add(fieldKey);
      }
    });
    await StockInventoryStorageService.saveVisibleCardFields(
      isMobile: true,
      visibleKeys: _visibleCardKeys,
    );
  }
  Future<void> _addDynamicField(String urduLabel, bool showOnCard) async {
    final clean = urduLabel.trim();
    if (clean.isEmpty) return;
    final key = 'mob_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _customFieldDefs.add({'key': key, 'urduLabel': clean});
      _dynamicControllers[key] = TextEditingController();
      if (showOnCard) {
        _visibleCardKeys.add(key);
      } else {
        _visibleCardKeys.remove(key);
      }
    });
    await StockInventoryStorageService.saveCategoryDynamicFields(
      isMobile: true,
      fields: _customFieldDefs,
    );
    await StockInventoryStorageService.saveVisibleCardFields(
      isMobile: true,
      visibleKeys: _visibleCardKeys,
    );
  }
  Future<void> _removeDynamicField(int index) async {
    if (index < 0 || index >= _customFieldDefs.length) return;
    final removedKey = _customFieldDefs[index]['key']!;
    setState(() {
      _customFieldDefs.removeAt(index);
      _dynamicControllers[removedKey]?.dispose();
      _dynamicControllers.remove(removedKey);
      _visibleCardKeys.remove(removedKey);
      _activeSplitKeys.remove(removedKey);
      final sList = _splitControllersMap.remove(removedKey);
      if (sList != null) {
        for (final c in sList) {
          c.dispose();
        }
      }
    });
    await StockInventoryStorageService.saveCategoryDynamicFields(
      isMobile: true,
      fields: _customFieldDefs,
    );
    await StockInventoryStorageService.saveVisibleCardFields(
      isMobile: true,
      visibleKeys: _visibleCardKeys,
    );
  }
  Widget _withEyeToggle(String fieldKey, Widget fieldWidget) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: fieldWidget),
        const SizedBox(width: 5),
        StockFieldEyeToggleUi(
          isVisibleOnCard: _visibleCardKeys.contains(fieldKey),
          onToggle: () => _toggleFieldVisibility(fieldKey),
        ),
      ],
    );
  }
  @override
  void didUpdateWidget(covariant MobileStockFormUi oldWidget) {
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
    _imeiCtrl.text = pre['imeiNo']?.toString() ?? '';
    final pPrice = (pre['purchasePrice'] ?? '').toString();
    _purchasePriceCtrl.text = (pPrice == '0' || pPrice == 'null') ? '' : pPrice;
    final sPrice = (pre['salePrice'] ?? '').toString();
    _salePriceCtrl.text = (sPrice == '0' || sPrice == 'null') ? '' : sPrice;
    _supplierCtrl.text = pre['supplierInfo']?.toString() ?? '';
    _isOnOrder = false;
    final ram = pre['ramRom']?.toString() ?? '';
    if (_ramOptions.contains(ram)) _selectedRamRom = ram;
    final col = pre['color']?.toString() ?? '';
    if (_colorOptions.contains(col)) _selectedColor = col;
    if (pre['conditionType'] != null) {
      _selectedCondition = pre['conditionType'].toString();
    }
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
    _imeiCtrl.text = item['imeiNo']?.toString() ?? '';
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
    final ram = item['ramRom']?.toString() ?? '8GB / 256GB';
    _selectedRamRom = _ramOptions.contains(ram) ? ram : '8GB / 256GB';
    final col = item['color']?.toString() ?? 'کالا (Black)';
    _selectedColor = _colorOptions.contains(col) ? col : 'کالا (Black)';
    _selectedCondition = item['conditionType']?.toString() ?? 'NEW';
    _selectedRating = item['conditionRating']?.toString() ?? '10/10';
    final w = int.tryParse(item['warranty']?.toString() ?? '12') ?? 12;
    _selectedWarranty = _warrantyMonthsList.contains(w) ? w : 12;
    final st = (item['status']?.toString() ?? '').toUpperCase();
    _isOnOrder = item['isOnOrder'] == true || st == 'ON_ORDER';
  }
  void _reset() {
    _modelCtrl.clear();
    _imeiCtrl.clear();
    _purchasePriceCtrl.clear();
    _salePriceCtrl.clear();
    _supplierCtrl.clear();
    _clearAllSplits();
    for (final c in _dynamicControllers.values) {
      c.clear();
    }
    _selectedImages = [];
    _selectedRamRom = '8GB / 256GB';
    _selectedColor = 'کالا (Black)';
    _selectedCondition = 'NEW';
    _selectedRating = '10/10';
    _selectedWarranty = 12;
    _isOnOrder = false;
  }
  @override
  void dispose() {
    _purchasePriceCtrl.removeListener(_refreshSummary);
    _salePriceCtrl.removeListener(_refreshSummary);
    _singleImeiFocus.dispose();
    _modelCtrl.dispose();
    _imeiCtrl.dispose();
    _purchasePriceCtrl.dispose();
    _salePriceCtrl.dispose();
    _supplierCtrl.dispose();
    _clearAllSplits();
    for (final c in _dynamicControllers.values) {
      c.dispose();
    }
    super.dispose();
  }
  Future<void> _scanImei() async {
    final res =
        await QrScanner.scan(context, title: 'موبائل ڈبے کا IMEI اسکین کریں');
    if (res != null && res.trim().isNotEmpty) {
      setState(() {
        _imeiCtrl.text = res.trim();
        _singleImeiError = false;
      });
    }
  }
  Set<String> _getExistingStockImeis() {
    final editingId = widget.editingItem?['id']?.toString() ?? '';
    final all = StockInventoryStorageService.getAllStockItems();
    final Set<String> existing = {};
    for (final item in all) {
      if (editingId.isNotEmpty && item['id']?.toString() == editingId) {
        continue;
      }
      final im = (item['imeiNo']?.toString() ?? '').trim();
      if (im.isNotEmpty && im != 'null') {
        existing.add(im);
      }
    }
    return existing;
  }
  void _focusAndReveal(FocusNode node) {
    node.requestFocus();
    final ctx = node.context;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        alignment: 0.35,
      );
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
    final model = _modelCtrl.text.trim();
    final imei = _imeiCtrl.text.trim();
    final sale = int.tryParse(_salePriceCtrl.text.trim()) ?? 0;
    final qty = _currentQty;
    final bool hasSplitNames = _activeSplitKeys.contains('itemName');
    final bool hasSplitSales = _activeSplitKeys.contains('salePrice');
    if (!hasSplitNames && model.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('براہ کرم موبائل ماڈل درج کریں!'),
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
    if (!_isOnOrder) {
      final existingDbImeis = _getExistingStockImeis();
      if (qty > 1) {
        _ensureForcedImeiSplit();
        final unitImeis = _splitControllersMap['imeiOrSerial'] ?? [];
        final Set<int> badIndexes = {};
        final Set<String> seenInBatch = {};
        String? errorReason;
        for (int i = 0; i < unitImeis.length; i++) {
          final val = unitImeis[i].text.trim();
          if (val.isEmpty) {
            badIndexes.add(i);
            errorReason ??=
                '⚠️ تمام $qty موبائلز کا الگ الگ IMEI نمبر درج کرنا لازمی ہے!';
          } else if (seenInBatch.contains(val)) {
            badIndexes.add(i);
            errorReason ??=
                '⚠️ ایک ہی IMEI نمبر ($val) دو موبائلز کو الاٹ نہیں ہو سکتا!';
          } else if (existingDbImeis.contains(val)) {
            badIndexes.add(i);
            errorReason ??=
                '⚠️ یہ IMEI نمبر ($val) پہلے سے اسٹاک ریکارڈ میں موجود ہے!';
          } else {
            seenInBatch.add(val);
          }
        }
        if (badIndexes.isNotEmpty) {
          setState(() => _invalidImeiIndexes = badIndexes);
          final firstBad = badIndexes.reduce((a, b) => a < b ? a : b);
          if (firstBad < _splitImeiFocusNodes.length) {
            _focusAndReveal(_splitImeiFocusNodes[firstBad]);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorReason!),
              backgroundColor: AppColors.errorRed,
            ),
          );
          return;
        }
      } else {
        if (imei.isEmpty) {
          setState(() => _singleImeiError = true);
          _focusAndReveal(_singleImeiFocus);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  '⚠️ دکان پر موجود موبائل کا IMEI نمبر درج کرنا لازمی ہے!'),
              backgroundColor: AppColors.errorRed,
            ),
          );
          return;
        }
        if (existingDbImeis.contains(imei)) {
          setState(() => _singleImeiError = true);
          _focusAndReveal(_singleImeiFocus);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '⚠️ یہ IMEI نمبر ($imei) پہلے سے اسٹاک ریکارڈ میں موجود ہے!'),
              backgroundColor: AppColors.errorRed,
            ),
          );
          return;
        }
      }
    }
    setState(() {
      _singleImeiError = false;
      _invalidImeiIndexes = {};
    });
    final Map<String, String> dynamicMap = {};
    _dynamicControllers.forEach((k, ctrl) {
      dynamicMap[k] = ctrl.text.trim();
    });
    final Map<String, List<String>> overrides = {};
    for (final key in _activeSplitKeys) {
      if (_isOnOrder && key == 'imeiOrSerial') continue;
      if (_splitDropdownValuesMap.containsKey(key)) {
        overrides[key] = List<String>.from(_splitDropdownValuesMap[key]!);
      } else {
        final ctrls = _splitControllersMap[key] ?? [];
        overrides[key] = ctrls.map((c) => c.text.trim()).toList();
      }
    }
    final List<String> copiedSharedImages = List<String>.from(_selectedImages);
    final List<List<String>> copiedPerUnitImages = _isPhotoSplitActive
        ? _perUnitImages.map((list) => List<String>.from(list)).toList()
        : const <List<String>>[];
    widget.onSave(
      stockId: widget.editingItem?['id']?.toString() ?? '',
      itemName: model,
      imei: _isOnOrder ? '' : imei,
      ramRom: _selectedRamRom,
      color: _selectedColor,
      purchasePrice: int.tryParse(_purchasePriceCtrl.text.trim()) ?? 0,
      salePrice: sale,
      supplier: _supplierCtrl.text.trim(),
      conditionType: _selectedCondition,
      conditionRating: _selectedRating,
      warranty: _selectedWarranty,
      isOnOrder: _isOnOrder,
      quantity: qty,
      dynamicFields: dynamicMap,
      perUnitOverrides: overrides,
      images: copiedSharedImages,
      perUnitImages: copiedPerUnitImages,
    );
    if (widget.editingItem == null) {
      setState(() => _reset());
    }
  }
  InputDecoration _dec(String label, {bool isError = false}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w900,
        color: isError ? AppColors.errorRed : AppColors.textDark,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isError ? AppColors.errorRed : const Color(0xFF94A3B8),
          width: isError ? 2.0 : 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isError ? AppColors.errorRed : AppColors.primaryEmerald,
          width: 2.0,
        ),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: isError ? const Color(0xFFFEF2F2) : Colors.white,
    );
  }
  @override
  Widget build(BuildContext context) {
    final qty = _currentQty;
    final upcomingIds = StockInventoryStorageService.previewNextStockIds(qty);
    final lotTotals = _calculateLotTotals();
    final ramItems = _ramOptions
        .map((r) => DropdownMenuItem(
            value: r,
            child: Text(r,
                style: const TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 14.5))))
        .toList();
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
          child: Text('نیا (Box)',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5))),
      DropdownMenuItem(
          value: 'USED',
          child: Text('پرانا (Used)',
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
            color: _isOnOrder ? Colors.teal.shade50 : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isOnOrder
                  ? AppColors.primaryEmerald
                  : const Color(0xFFCBD5E1),
            ),
          ),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(
              _isOnOrder
                  ? '📦 آرڈر پر دستیاب (صرف پروموشن / ڈیلر اسٹاک)'
                  : '🏪 دکان پر موجود اسٹاک (IMEI لازمی)',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14.5,
                color: _isOnOrder
                    ? AppColors.primaryEmerald
                    : const Color(0xFF0F172A),
              ),
            ),
            value: _isOnOrder,
            activeTrackColor: AppColors.primaryEmerald,
            onChanged: (v) {
              setState(() {
                _isOnOrder = v;
                _singleImeiError = false;
                _invalidImeiIndexes = {};
                _ensureForcedImeiSplit();
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.warmSubtleSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: const Row(
            children: [
              Icon(Icons.visibility_rounded,
                  size: 16, color: AppColors.primaryEmerald),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  '👁️ کھلی آنکھ = POS کارڈ پر ظاہر | 🙈 بند آنکھ = خفیہ (صرف معاہدے/بیک اینڈ کیلئے)',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
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
          fieldLabel: 'موبائل ماڈل',
          isSplitActive: _activeSplitKeys.contains('itemName'),
          perUnitControllers: _splitControllersMap['itemName'] ?? const [],
          onToggleSplit: () => _toggleSplit('itemName'),
          singleFieldChild: TextField(
            controller: _modelCtrl,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            decoration: _dec('موبائل کمپنی و ماڈل (مثلاً Vivo Y200)'),
          ),
        ),
        if (!_isOnOrder) ...[
          const SizedBox(height: 11),
          _withEyeToggle(
            'imeiOrSerial',
            SplittableFieldWrapperUi(
              quantity: qty,
              upcomingStockIds: upcomingIds,
              fieldLabel: 'IMEI نمبر*',
              isSplitActive: _activeSplitKeys.contains('imeiOrSerial'),
              forceSplit: _forceImeiSplit,
              perUnitControllers:
                  _splitControllersMap['imeiOrSerial'] ?? const [],
              perUnitFocusNodes: _splitImeiFocusNodes,
              invalidUnitIndexes: _invalidImeiIndexes,
              onToggleSplit: () => _toggleSplit('imeiOrSerial'),
              enableScanner: true,
              allowCopyDown: false,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.left,
              singleFieldChild: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _imeiCtrl,
                      focusNode: _singleImeiFocus,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: _singleImeiError
                            ? AppColors.errorRed
                            : AppColors.textDark,
                      ),
                      decoration: _dec(
                        'IMEI نمبر (لازمی - منفرد نمبر)*',
                        isError: _singleImeiError,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Tooltip(
                    message: 'IMEI اسکین کریں',
                    child: InkWell(
                      onTap: _scanImei,
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
          ),
        ],
        const SizedBox(height: 11),
        _withEyeToggle(
          'purchasePrice',
          SplittableFieldWrapperUi(
            quantity: qty,
            upcomingStockIds: upcomingIds,
            fieldLabel: 'قیمتِ خرید',
            isSplitActive: _activeSplitKeys.contains('purchasePrice'),
            perUnitControllers:
                _splitControllersMap['purchasePrice'] ?? const [],
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
        ),
        const SizedBox(height: 11),
        _withEyeToggle(
          'salePrice',
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
        ),
        const SizedBox(height: 11),
        _withEyeToggle(
          'supplier',
          SplittableFieldWrapperUi(
            quantity: qty,
            upcomingStockIds: upcomingIds,
            fieldLabel: 'سپلائر / ڈیلر',
            isSplitActive: _activeSplitKeys.contains('supplier'),
            perUnitControllers: _splitControllersMap['supplier'] ?? const [],
            onToggleSplit: () => _toggleSplit('supplier'),
            singleFieldChild: TextField(
              controller: _supplierCtrl,
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5),
              decoration: _dec(
                  'سپلائر / ڈیلر کا نام و فون (مثلاً علی موبائل 03001234567)'),
            ),
          ),
        ),
        const SizedBox(height: 11),
        _withEyeToggle(
          'specsOrRam',
          SplittableDropdownWrapperUi<String>(
            quantity: qty,
            upcomingStockIds: upcomingIds,
            fieldLabel: 'میموری (RAM / ROM)',
            isSplitActive: _activeSplitKeys.contains('specsOrRam'),
            perUnitValues: _splitDropdownValuesMap['specsOrRam'] ?? const [],
            items: ramItems,
            onToggleSplit: () => _toggleDropdownSplit('specsOrRam'),
            onUnitValueChanged: (idx, val) {
              setState(
                  () => _splitDropdownValuesMap['specsOrRam']![idx] = val);
            },
            singleDropdownChild: DropdownButtonFormField<String>(
              key: ValueKey('mob_ram_$_selectedRamRom'),
              initialValue: _selectedRamRom,
              isExpanded: true,
              decoration: _dec('میموری (RAM / ROM)'),
              items: ramItems,
              onChanged: (v) =>
                  v != null ? setState(() => _selectedRamRom = v) : null,
            ),
          ),
        ),
        const SizedBox(height: 11),
        _withEyeToggle(
          'color',
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
              key: ValueKey('mob_color_$_selectedColor'),
              initialValue: _selectedColor,
              isExpanded: true,
              decoration: _dec('رنگ (Color)'),
              items: colorItems,
              onChanged: (v) =>
                  v != null ? setState(() => _selectedColor = v) : null,
            ),
          ),
        ),
        const SizedBox(height: 11),
        _withEyeToggle(
          'conditionType',
          SplittableDropdownWrapperUi<String>(
            quantity: qty,
            upcomingStockIds: upcomingIds,
            fieldLabel: 'حالت (New / Used)',
            isSplitActive: _activeSplitKeys.contains('conditionType'),
            perUnitValues:
                _splitDropdownValuesMap['conditionType'] ?? const [],
            items: condItems,
            onToggleSplit: () => _toggleDropdownSplit('conditionType'),
            onUnitValueChanged: (idx, val) {
              setState(
                  () => _splitDropdownValuesMap['conditionType']![idx] = val);
            },
            singleDropdownChild: DropdownButtonFormField<String>(
              key: ValueKey('mob_cond_$_selectedCondition'),
              initialValue: _selectedCondition,
              isExpanded: true,
              decoration: _dec('حالت'),
              items: condItems,
              onChanged: (v) =>
                  v != null ? setState(() => _selectedCondition = v) : null,
            ),
          ),
        ),
        const SizedBox(height: 11),
        _withEyeToggle(
          'warranty',
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
              key: ValueKey('mob_warranty_$_selectedWarranty'),
              initialValue: '$_selectedWarranty',
              isExpanded: true,
              decoration: _dec('وارنٹی'),
              items: warrantyItems,
              onChanged: (v) => v != null
                  ? setState(() => _selectedWarranty = int.tryParse(v) ?? 12)
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 12),
        DynamicStockFieldsCardUi(
          fieldDefs: _customFieldDefs,
          controllers: _dynamicControllers,
          visibleCardKeys: _visibleCardKeys,
          onToggleCardVisibility: _toggleFieldVisibility,
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
                : (qty > 1
                    ? '$qty موبائلز اسٹاک میں شامل کریں (مع منفرد IDs)'
                    : 'اسٹاک میں شامل کریں'),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16.5),
          ),
        ),
      ],
    );
  }
}