import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/qr_scanner.dart';
import '../services/pos_control_storage_service.dart';
import 'pos_stock_photo_picker_ui.dart';

class PosStockFormUi extends StatefulWidget {
  final ControlDataMap? editingItem;
  final VoidCallback onCancelEdit;
  final VoidCallback onSavedSuccess;

  const PosStockFormUi({
    super.key,
    required this.editingItem,
    required this.onCancelEdit,
    required this.onSavedSuccess,
  });

  @override
  State<PosStockFormUi> createState() => _PosStockFormUiState();
}

class _PosStockFormUiState extends State<PosStockFormUi> {
  final TextEditingController _modelCtrl = TextEditingController();
  final TextEditingController _imeiCtrl = TextEditingController();
  final TextEditingController _serialCtrl = TextEditingController();
  final TextEditingController _specsSummaryCtrl = TextEditingController();
  final TextEditingController _purchasePriceCtrl = TextEditingController();
  final TextEditingController _salePriceCtrl = TextEditingController();
  final TextEditingController _supplierCtrl = TextEditingController();

  String _productCategory = 'MOBILE'; // 'MOBILE' یا 'ELECTRONICS'
  List<String> _selectedImages = [];
  bool _isSaving = false;

  static const List<String> _ramRomOptions = [
    '2GB / 32GB',
    '3GB / 32GB',
    '3GB / 64GB',
    '4GB / 64GB',
    '4GB / 128GB',
    '6GB / 128GB',
    '8GB / 128GB',
    '8GB / 256GB',
    '12GB / 256GB',
    '12GB / 512GB',
    '16GB / 512GB',
  ];

  static const List<String> _colorOptions = [
    'کالا (Black)',
    'سفید (White)',
    'نیلا (Blue)',
    'سبز (Green)',
    'سنہری (Gold)',
    'سلور (Silver)',
    'جامنی (Purple)',
    'سرمئی (Grey)',
    'سرخ (Red)',
  ];

  static const List<String> _ratingOptions = [
    '10/10',
    '9/10',
    '8/10',
    '7/10',
    '6/10',
    '5/10',
    '4/10',
    '3/10',
    '2/10',
    '1/10',
  ];

  static const List<int> _warrantyOptions = [
    12,
    11,
    10,
    9,
    8,
    7,
    6,
    5,
    4,
    3,
    2,
    1,
    0,
  ];

  String _selectedRamRom = '8GB / 256GB';
  String _selectedColor = 'کالا (Black)';
  String _selectedCondition = 'NEW';
  String _selectedRating = '10/10';
  int _selectedWarranty = 12;

  @override
  void didUpdateWidget(covariant PosStockFormUi oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editingItem != oldWidget.editingItem) {
      if (widget.editingItem != null) {
        _populateFromItem(widget.editingItem!);
      } else {
        _resetFields();
      }
    }
  }

  void _populateFromItem(ControlDataMap item) {
    _productCategory =
        (item['productCategory']?.toString() ?? 'MOBILE') == 'ELECTRONICS'
            ? 'ELECTRONICS'
            : 'MOBILE';
    _modelCtrl.text = item['itemName']?.toString() ?? '';
    _imeiCtrl.text = item['imeiNo']?.toString() ?? '';
    _serialCtrl.text = item['serialNo']?.toString() ?? '';
    _specsSummaryCtrl.text = item['specsSummary']?.toString() ?? '';
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
    _selectedRamRom =
        _ramRomOptions.contains(ram) ? ram : _ramRomOptions.first;
    final col = item['color']?.toString() ?? 'کالا (Black)';
    _selectedColor = _colorOptions.contains(col) ? col : _colorOptions.first;
    final cond = item['conditionType']?.toString() ?? 'NEW';
    _selectedCondition = (cond == 'USED') ? 'USED' : 'NEW';
    final rat = item['conditionRating']?.toString() ?? '10/10';
    _selectedRating =
        _ratingOptions.contains(rat) ? rat : _ratingOptions.first;
    final war = int.tryParse(item['warranty']?.toString() ?? '12') ?? 12;
    _selectedWarranty = _warrantyOptions.contains(war) ? war : 12;
  }

  void _resetFields() {
    _productCategory = 'MOBILE';
    _modelCtrl.clear();
    _imeiCtrl.clear();
    _serialCtrl.clear();
    _specsSummaryCtrl.clear();
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
    _serialCtrl.dispose();
    _specsSummaryCtrl.dispose();
    _purchasePriceCtrl.dispose();
    _salePriceCtrl.dispose();
    _supplierCtrl.dispose();
    super.dispose();
  }

  Future<void> _scanCode() async {
    final isMobile = _productCategory == 'MOBILE';
    final res = await QrScanner.scan(
      context,
      title: isMobile
          ? 'موبائل ڈبے کا IMEI اسکین کریں'
          : 'پراڈکٹ سیریل / بارکوڈ اسکین کریں',
    );
    if (res != null && res.trim().isNotEmpty) {
      setState(() {
        if (isMobile) {
          _imeiCtrl.text = res.trim();
        } else {
          _serialCtrl.text = res.trim();
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    final isMobile = _productCategory == 'MOBILE';
    final model = _modelCtrl.text.trim();
    final imei = isMobile ? _imeiCtrl.text.trim() : '';
    final serial = !isMobile ? _serialCtrl.text.trim() : '';
    final specs = !isMobile ? _specsSummaryCtrl.text.trim() : '';
    final purchasePrice = int.tryParse(_purchasePriceCtrl.text.trim()) ?? 0;
    final salePrice = int.tryParse(_salePriceCtrl.text.trim()) ?? 0;

    if (model.isEmpty || salePrice <= 0 || (isMobile && imei.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isMobile
                ? 'براہ کرم موبائل ماڈل، IMEI نمبر اور نقد قیمت فروخت درج کریں!'
                : 'براہ کرم پراڈکٹ کا نام/ماڈل اور نقد قیمت فروخت درج کریں!',
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final editingId = widget.editingItem?['id']?.toString();
    final stockId =
        editingId ?? PosControlStorageService.generateNextStockId();

    await PosControlStorageService.saveStockItem(
      stockId: stockId,
      productCategory: _productCategory,
      itemName: model,
      imeiNo: imei,
      serialNo: serial,
      ramRom: isMobile ? _selectedRamRom : specs,
      specsSummary: specs,
      color: _selectedColor,
      purchasePrice: purchasePrice,
      salePrice: salePrice,
      supplierInfo: _supplierCtrl.text.trim(),
      conditionType: _selectedCondition,
      conditionRating: _selectedRating,
      warrantyMonths: _selectedWarranty,
      images: _selectedImages,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);
    _resetFields();
    widget.onSavedSuccess();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '✅ اسٹاک ($stockId - $model) محفوظ ہو کر POS ایپ پر سنک ہو گیا!'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  InputDecoration _boldInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F172A),
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF94A3B8), width: 1.2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildCategoryTab(String cat, String label, IconData icon) {
    final selected = _productCategory == cat;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _productCategory = cat),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryEmerald : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: selected
                  ? AppColors.primaryEmerald
                  : const Color(0xFFCBD5E1),
              width: 1.3,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : const Color(0xFF334155),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editingId = widget.editingItem?['id']?.toString();
    final isMobile = _productCategory == 'MOBILE';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                editingId != null ? Icons.edit : Icons.add_box_outlined,
                color: AppColors.primaryEmerald,
              ),
              const SizedBox(width: 6),
              Text(
                editingId != null
                    ? 'اسٹاک ترمیم: $editingId'
                    : 'نیا اسٹاک درج کریں (${PosControlStorageService.generateNextStockId()})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.5,
                  color: AppColors.primaryEmerald,
                ),
              ),
              const Spacer(),
              if (editingId != null)
                TextButton(
                  onPressed: widget.onCancelEdit,
                  child: const Text('منسوخ',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildCategoryTab(
                'MOBILE',
                'موبائل فون (Mobile)',
                Icons.phone_android_rounded,
              ),
              const SizedBox(width: 8),
              _buildCategoryTab(
                'ELECTRONICS',
                'الیکٹرانکس / دیگر اشیاء',
                Icons.kitchen_outlined,
              ),
            ],
          ),
          const SizedBox(height: 14),
          PosStockPhotoPickerUi(
            imagePaths: _selectedImages,
            onImagesChanged: (imgs) => setState(() => _selectedImages = imgs),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _modelCtrl,
            style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A)),
            decoration: _boldInputDecoration(
              isMobile
                  ? 'موبائل کمپنی و ماڈل (مثلاً Vivo Y200)'
                  : 'پراڈکٹ نام و ماڈل (مثلاً Dawlance فریج / ہونڈا 70)',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: isMobile ? _imeiCtrl : _serialCtrl,
                  keyboardType:
                      isMobile ? TextInputType.number : TextInputType.text,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A)),
                  decoration: _boldInputDecoration(
                    isMobile
                        ? 'IMEI نمبر (لازمی - 15 ہندسے)'
                        : 'سیریل / چیسز نمبر (اختیاری)',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _scanCode,
                icon: const Icon(Icons.qr_code_scanner, size: 20),
                label: const Text('اسکین',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade800,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _purchasePriceCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A)),
                  decoration: _boldInputDecoration('قیمتِ خرید (روپے)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _salePriceCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A)),
                  decoration: _boldInputDecoration('نقد قیمت فروخت (لازمی)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _supplierCtrl,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A)),
            decoration:
                _boldInputDecoration('سپلائر / ڈیلر کا نام و فون'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: isMobile
                    ? DropdownButtonFormField<String>(
                        initialValue: _selectedRamRom,
                        isExpanded: true,
                        decoration: _boldInputDecoration('میموری (RAM / ROM)'),
                        items: _ramRomOptions
                            .map((r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(r,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A))),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedRamRom = v);
                        },
                      )
                    : TextField(
                        controller: _specsSummaryCtrl,
                        style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A)),
                        decoration: _boldInputDecoration(
                            'تفصیل / سائز (مثلاً 14 کیوبک فٹ انورٹر)'),
                      ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedColor,
                  isExpanded: true,
                  decoration: _boldInputDecoration('رنگ (Color)'),
                  items: _colorOptions
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A))),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedColor = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCondition,
                  isExpanded: true,
                  decoration: _boldInputDecoration('حالت'),
                  items: const [
                    DropdownMenuItem(
                        value: 'NEW',
                        child: Text('نیا (Box)',
                            style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A)))),
                    DropdownMenuItem(
                        value: 'USED',
                        child: Text('پرانا (Used)',
                            style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A)))),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedCondition = v);
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedRating,
                  isExpanded: true,
                  decoration: _boldInputDecoration('ریٹنگ'),
                  items: _ratingOptions
                      .map((rt) => DropdownMenuItem(
                            value: rt,
                            child: Text(rt,
                                style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A))),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedRating = v);
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<int>(
                  initialValue: _selectedWarranty,
                  isExpanded: true,
                  decoration: _boldInputDecoration('وارنٹی'),
                  items: _warrantyOptions
                      .map((w) => DropdownMenuItem(
                            value: w,
                            child: Text(
                              w == 0 ? 'بغیر وارنٹی' : '$w ماہ',
                              style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A)),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedWarranty = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _submit,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(
              _isSaving
                  ? 'تصاویر اپلوڈ اور محفوظ ہو رہی ہیں...'
                  : (editingId != null
                      ? 'تبدیلیاں محفوظ کریں'
                      : 'اسٹاک میں شامل کریں اور POS پر بھیجیں'),
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryEmerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}