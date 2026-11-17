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
    _selectedRamRom = item['ramRom']?.toString() ?? '8GB / 256GB';
    _selectedColor = item['color']?.toString() ?? 'کالا (Black)';
    _selectedCondition = item['conditionType']?.toString() ?? 'NEW';
    _selectedRating = item['conditionRating']?.toString() ?? '10/10';
    _selectedWarranty = int.tryParse(item['warranty']?.toString() ?? '12') ?? 12;
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
    final res = await QrScanner.scan(context, title: 'موبائل ڈبے کا IMEI اسکین کریں');
    if (res != null && res.trim().isNotEmpty) {
      setState(() => _imeiCtrl.text = res.trim());
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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                decoration: _dec('IMEI نمبر (15 ہندسے)'),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _scanImei,
              icon: const Icon(Icons.qr_code_scanner, size: 18),
              label: const Text('اسکین', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                decoration: _dec('قیمتِ خرید (روپے)'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _salePriceCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.left,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                decoration: _dec('نقد قیمت فروخت (لازمی)'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _supplierCtrl,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          decoration: _dec('سپلائر / ڈیلر کا نام و فون'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedRamRom,
                isExpanded: true,
                decoration: _dec('میموری (RAM / ROM)'),
                items: [
                  '2GB / 32GB',
                  '3GB / 32GB',
                  '4GB / 64GB',
                  '4GB / 128GB',
                  '6GB / 128GB',
                  '8GB / 128GB',
                  '8GB / 256GB',
                  '12GB / 256GB'
                ]
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
                initialValue: _selectedColor,
                isExpanded: true,
                decoration: _dec('رنگ (Color)'),
                items: ['کالا (Black)', 'سفید (White)', 'نیلا (Blue)', 'سبز (Green)', 'سنہری (Gold)']
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
                initialValue: _selectedWarranty,
                isExpanded: true,
                decoration: _dec('وارنٹی'),
                items: [12, 6, 3, 0]
                    .map((w) => DropdownMenuItem(
                        value: w,
                        child: Text(w == 0 ? 'بغیر وارنٹی' : '$w ماہ',
                            style: const TextStyle(fontWeight: FontWeight.bold))))
                    .toList(),
                onChanged: (v) =>
                    v != null ? setState(() => _selectedWarranty = v) : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            widget.onSave(
              stockId: widget.editingItem?['id']?.toString() ?? '',
              itemName: _modelCtrl.text.trim(),
              imei: _imeiCtrl.text.trim(),
              ramRom: _selectedRamRom,
              color: _selectedColor,
              purchasePrice: int.tryParse(_purchasePriceCtrl.text.trim()) ?? 0,
              salePrice: int.tryParse(_salePriceCtrl.text.trim()) ?? 0,
              supplier: _supplierCtrl.text.trim(),
              conditionType: _selectedCondition,
              conditionRating: _selectedRating,
              warranty: _selectedWarranty,
              images: _selectedImages,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryEmerald,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            widget.editingItem != null ? 'تبدیلیاں محفوظ کریں' : 'اسٹاک میں شامل کریں',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ],
    );
  }
}