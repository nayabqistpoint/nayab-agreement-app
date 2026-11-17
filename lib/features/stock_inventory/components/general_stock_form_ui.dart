import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/qr_scanner.dart';
import '../../pos_control_panel/components/pos_stock_photo_picker_ui.dart';

class GeneralStockFormUi extends StatefulWidget {
  final Map<String, dynamic>? editingItem;
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
    required List<String> images,
  }) onSave;

  const GeneralStockFormUi({
    super.key,
    required this.editingItem,
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

  List<String> _selectedImages = [];
  String _selectedColor = 'کالا (Black)';
  String _selectedCondition = 'NEW';
  int _selectedWarranty = 12;

  @override
  void didUpdateWidget(covariant GeneralStockFormUi oldWidget) {
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
    _serialCtrl.text = item['serialNo']?.toString() ?? '';
    _specsCtrl.text = item['specsSummary']?.toString() ?? '';
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
    _selectedColor = item['color']?.toString() ?? 'کالا (Black)';
    _selectedCondition = item['conditionType']?.toString() ?? 'NEW';
    _selectedWarranty = int.tryParse(item['warranty']?.toString() ?? '12') ?? 12;
  }

  void _reset() {
    _modelCtrl.clear();
    _serialCtrl.clear();
    _specsCtrl.clear();
    _purchasePriceCtrl.clear();
    _salePriceCtrl.clear();
    _supplierCtrl.clear();
    _selectedImages = [];
    _selectedColor = 'کالا (Black)';
    _selectedCondition = 'NEW';
    _selectedWarranty = 12;
  }

  @override
  void dispose() {
    _modelCtrl.dispose();
    _serialCtrl.dispose();
    _specsCtrl.dispose();
    _purchasePriceCtrl.dispose();
    _salePriceCtrl.dispose();
    _supplierCtrl.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    final res = await QrScanner.scan(context, title: 'سیریل / بارکوڈ اسکین کریں');
    if (res != null && res.trim().isNotEmpty) {
      setState(() => _serialCtrl.text = res.trim());
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
          decoration: _dec('آئٹم کا نام (مثلاً Dawlance فریج / ہونڈا 70 بائیک)'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _serialCtrl,
                textAlign: TextAlign.left,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                decoration: _dec('سیریل / چیسز نمبر (اختیاری)'),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _scanBarcode,
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
        TextField(
          controller: _specsCtrl,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          decoration: _dec('سائز و تفصیل (مثلاً 14 کیوبک فٹ انورٹر)'),
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
                initialValue: _selectedColor,
                isExpanded: true,
                decoration: _dec('رنگ (Color)'),
                items: ['کالا (Black)', 'سفید (White)', 'نیلا (Blue)', 'سرخ (Red)', 'سلور (Silver)']
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
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: _selectedWarranty,
                isExpanded: true,
                decoration: _dec('وارنٹی'),
                items: [12, 24, 36, 0]
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
              serialNo: _serialCtrl.text.trim(),
              specsSummary: _specsCtrl.text.trim(),
              color: _selectedColor,
              purchasePrice: int.tryParse(_purchasePriceCtrl.text.trim()) ?? 0,
              salePrice: int.tryParse(_salePriceCtrl.text.trim()) ?? 0,
              supplier: _supplierCtrl.text.trim(),
              conditionType: _selectedCondition,
              conditionRating: '10/10',
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