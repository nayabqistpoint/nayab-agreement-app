import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/qr_scanner.dart';
import '../../pos_control_panel/components/pos_stock_photo_picker_ui.dart';

class MobileStockFormUi extends StatefulWidget {
  final Map<String, dynamic>? editingItem;
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
    required List<String> images,
  }) onSave;

  const MobileStockFormUi({
    super.key,
    required this.editingItem,
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

  @override
  void didUpdateWidget(covariant MobileStockFormUi oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editingItem != oldWidget.editingItem) {
      if (widget.editingItem != null) {
        _populate(widget.editingItem!);
      } else {
        _reset();
      }
    } else if (widget.editingItem != null && _modelCtrl.text.isEmpty) {
      _populate(widget.editingItem!);
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
    _selectedWarranty = int.tryParse(item['warranty']?.toString() ?? '12') ?? 12;
    final st = (item['status']?.toString() ?? '').toUpperCase();
    _isOnOrder = item['isOnOrder'] == true || st == 'ON_ORDER';
  }

  void _reset() {
    _modelCtrl.clear();
    _imeiCtrl.clear();
    _purchasePriceCtrl.clear();
    _salePriceCtrl.clear();
    _supplierCtrl.clear();
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
    _modelCtrl.dispose();
    _imeiCtrl.dispose();
    _purchasePriceCtrl.dispose();
    _salePriceCtrl.dispose();
    _supplierCtrl.dispose();
    super.dispose();
  }

  Future<void> _scanImei() async {
    final res =
        await QrScanner.scan(context, title: 'موبائل ڈبے کا IMEI اسکین کریں');
    if (res != null && res.trim().isNotEmpty) {
      setState(() => _imeiCtrl.text = res.trim());
    }
  }

  void _submit() {
    final model = _modelCtrl.text.trim();
    final imei = _imeiCtrl.text.trim();
    final sale = int.tryParse(_salePriceCtrl.text.trim()) ?? 0;

    if (model.isEmpty || sale <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('براہ کرم موبائل ماڈل اور نقد قیمت فروخت درج کریں!'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (!_isOnOrder && imei.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'دکان پر موجود موبائل کیلئے IMEI درج کریں یا اوپر "آرڈر پر دستیاب" منتخب کریں!'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    widget.onSave(
      stockId: widget.editingItem?['id']?.toString() ?? '',
      itemName: model,
      imei: imei,
      ramRom: _selectedRamRom,
      color: _selectedColor,
      purchasePrice: int.tryParse(_purchasePriceCtrl.text.trim()) ?? 0,
      salePrice: sale,
      supplier: _supplierCtrl.text.trim(),
      conditionType: _selectedCondition,
      conditionRating: _selectedRating,
      warranty: _selectedWarranty,
      isOnOrder: _isOnOrder,
      images: _selectedImages,
    );
    if (widget.editingItem == null) {
      setState(() => _reset());
    }
  }

  InputDecoration _dec(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F172A),
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  ? '📦 آرڈر پر دستیاب (IMEI کی ضرورت نہیں)'
                  : '🏪 دکان پر موجود اسٹاک (IMEI لازمی)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
                color: _isOnOrder
                    ? AppColors.primaryEmerald
                    : const Color(0xFF0F172A),
              ),
            ),
            subtitle: const Text(
              'ڈیلر سے منگوا کر دینے والے ماڈلز کیلئے آن کریں',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
            value: _isOnOrder,
            activeTrackColor: AppColors.primaryEmerald,
            onChanged: (v) => setState(() => _isOnOrder = v),
          ),
        ),
        const SizedBox(height: 12),
        PosStockPhotoPickerUi(
          imagePaths: _selectedImages,
          onImagesChanged: (imgs) => setState(() => _selectedImages = imgs),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _modelCtrl,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          decoration: _dec('موبائل کمپنی و ماڈل (مثلاً Vivo Y200)'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _imeiCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.left,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                decoration: _dec(
                  _isOnOrder
                      ? 'IMEI نمبر (آرڈر پر اختیاری)'
                      : 'IMEI نمبر (لازمی - 15 ہندسے)',
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _scanImei,
              icon: const Icon(Icons.qr_code_scanner, size: 18),
              label: const Text('اسکین',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey.shade800,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _purchasePriceCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.left,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                decoration: _dec('قیمتِ خرید (روپے)'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _salePriceCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.left,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                decoration: _dec('نقد قیمت فروخت (لازمی)'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _supplierCtrl,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          decoration: _dec('سپلائر / ڈیلر کا نام و فون (مثلاً علی موبائل 03001234567)'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                key: ValueKey('mob_ram_$_selectedRamRom'),
                initialValue: _selectedRamRom,
                isExpanded: true,
                decoration: _dec('میموری (RAM / ROM)'),
                items: _ramOptions
                    .map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(r,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13))))
                    .toList(),
                onChanged: (v) =>
                    v != null ? setState(() => _selectedRamRom = v) : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                key: ValueKey('mob_color_$_selectedColor'),
                initialValue: _selectedColor,
                isExpanded: true,
                decoration: _dec('رنگ (Color)'),
                items: _colorOptions
                    .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13))))
                    .toList(),
                onChanged: (v) =>
                    v != null ? setState(() => _selectedColor = v) : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                key: ValueKey('mob_cond_$_selectedCondition'),
                initialValue: _selectedCondition,
                isExpanded: true,
                decoration: _dec('حالت'),
                items: const [
                  DropdownMenuItem(value: 'NEW', child: Text('نیا (Box)')),
                  DropdownMenuItem(value: 'USED', child: Text('پرانا (Used)')),
                ],
                onChanged: (v) =>
                    v != null ? setState(() => _selectedCondition = v) : null,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<int>(
                key: ValueKey('mob_warranty_$_selectedWarranty'),
                initialValue: _selectedWarranty,
                isExpanded: true,
                decoration: _dec('وارنٹی'),
                items: [12, 6, 3, 0]
                    .map((w) => DropdownMenuItem(
                        value: w,
                        child: Text(w == 0 ? 'بغیر وارنٹی' : '$w ماہ',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold))))
                    .toList(),
                onChanged: (v) =>
                    v != null ? setState(() => _selectedWarranty = v) : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryEmerald,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            widget.editingItem != null
                ? 'تبدیلیاں محفوظ کریں'
                : 'اسٹاک میں شامل کریں',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ],
    );
  }
}