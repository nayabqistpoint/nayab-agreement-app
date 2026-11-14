import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../../core/utils/qr_scanner.dart';
import '../services/pos_control_storage_service.dart';

class PosStockTabUi extends StatefulWidget {
  const PosStockTabUi({super.key});

  @override
  State<PosStockTabUi> createState() => _PosStockTabUiState();
}

class _PosStockTabUiState extends State<PosStockTabUi> {
  final TextEditingController _modelCtrl = TextEditingController();
  final TextEditingController _imeiCtrl = TextEditingController();
  final TextEditingController _ramRomCtrl = TextEditingController(text: '8GB / 256GB');
  final TextEditingController _colorCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _ratingCtrl = TextEditingController(text: '10/10');
  final TextEditingController _warrantyCtrl = TextEditingController(text: '12');

  String _conditionType = 'NEW';
  String? _editingStockId;

  @override
  void dispose() {
    _modelCtrl.dispose();
    _imeiCtrl.dispose();
    _ramRomCtrl.dispose();
    _colorCtrl.dispose();
    _priceCtrl.dispose();
    _ratingCtrl.dispose();
    _warrantyCtrl.dispose();
    super.dispose();
  }

  void _clearForm() {
    _editingStockId = null;
    _modelCtrl.clear();
    _imeiCtrl.clear();
    _ramRomCtrl.text = '8GB / 256GB';
    _colorCtrl.clear();
    _priceCtrl.clear();
    _ratingCtrl.text = '10/10';
    _warrantyCtrl.text = '12';
    _conditionType = 'NEW';
    setState(() {});
  }

  void _loadItemForEdit(ControlDataMap item) {
    _editingStockId = item['id']?.toString();
    _modelCtrl.text = item['itemName']?.toString() ?? '';
    _imeiCtrl.text = item['imeiNo']?.toString() ?? '';
    _ramRomCtrl.text = item['ramRom']?.toString() ?? '8GB / 256GB';
    _colorCtrl.text = item['color']?.toString() ?? '';
    _priceCtrl.text = item['salePrice']?.toString() ?? '';
    _conditionType = item['conditionType']?.toString() ?? 'NEW';
    _ratingCtrl.text = item['conditionRating']?.toString() ?? '10/10';
    _warrantyCtrl.text = item['warranty']?.toString() ?? '12';
    setState(() {});
  }

  Future<void> _scanImei() async {
    final res = await QrScanner.scan(context, title: 'موبائل ڈبے کا IMEI اسکین کریں');
    if (res != null && res.trim().isNotEmpty) {
      setState(() {
        _imeiCtrl.text = res.trim();
      });
    }
  }

  Future<void> _submitStock() async {
    final model = _modelCtrl.text.trim();
    final price = int.tryParse(_priceCtrl.text.trim()) ?? 0;

    if (model.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('براہ کرم موبائل ماڈل اور درست نقد قیمت درج کریں!'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final stockId = _editingStockId ?? PosControlStorageService.generateNextStockId();

    await PosControlStorageService.saveStockItem(
      stockId: stockId,
      itemName: model,
      imeiNo: _imeiCtrl.text.trim(),
      ramRom: _ramRomCtrl.text.trim(),
      color: _colorCtrl.text.trim(),
      salePrice: price,
      conditionType: _conditionType,
      conditionRating: _ratingCtrl.text.trim(),
      warrantyMonths: int.tryParse(_warrantyCtrl.text.trim()) ?? 12,
    );

    _clearForm();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ اسٹاک ($stockId - $model) محفوظ ہو کر POS ایپ پر سنک ہو گیا!'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
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
                      _editingStockId != null ? Icons.edit : Icons.add_box_outlined,
                      color: AppColors.primaryEmerald,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _editingStockId != null
                          ? 'اسٹاک ترمیم: $_editingStockId'
                          : 'نیا موبائل اسٹاک درج کریں',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.primaryEmerald,
                      ),
                    ),
                    const Spacer(),
                    if (_editingStockId != null)
                      TextButton(
                        onPressed: _clearForm,
                        child: const Text('منسوخ', style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _modelCtrl,
                  decoration: InputDecoration(
                    labelText: 'موبائل کمپنی و ماڈل (مثلاً Vivo Y200)',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _imeiCtrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          labelText: 'IMEI نمبر (15 ہندسے)',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _scanImei,
                      icon: const Icon(Icons.qr_code_scanner, size: 18),
                      label: const Text('اسکین'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          labelText: 'نقد قیمت فروخت (روپے)',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _ramRomCtrl,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          labelText: 'میموری (RAM / ROM)',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _colorCtrl,
                        decoration: InputDecoration(
                          labelText: 'رنگ (Color)',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _conditionType,
                        decoration: InputDecoration(
                          labelText: 'حالت',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'NEW', child: Text('نیا (Box Pack)')),
                          DropdownMenuItem(value: 'USED', child: Text('استعمال شدہ (Used)')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _conditionType = v);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ratingCtrl,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          labelText: 'کنڈیشن ریٹنگ (مثلاً 10/10)',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _warrantyCtrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          labelText: 'وارنٹی (ماہ)',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _submitStock,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(
                    _editingStockId != null
                        ? 'تبدیلیاں محفوظ کریں'
                        : 'اسٹاک میں شامل کریں اور POS پر بھیجیں',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryEmerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder(
            valueListenable: HiveBoxManager.listenToBox(BoxNames.stockBox),
            builder: (context, box, _) {
              final items = PosControlStorageService.getAllStockItems();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'دکان کا موجودہ لائیو اسٹاک (${items.length} سیٹ)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'اس وقت اسٹاک میں کوئی موبائل موجود نہیں ہے۔',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    )
                  else
                    ...items.map((item) {
                      final id = item['id']?.toString() ?? '';
                      final name = item['itemName']?.toString() ?? '';
                      final imei = item['imeiNo']?.toString() ?? '';
                      final price = item['salePrice']?.toString() ?? '0';
                      final ramRom = item['ramRom']?.toString() ?? '';
                      final cond = item['conditionType']?.toString() ?? 'NEW';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: cond == 'NEW'
                                ? AppColors.successGreen.withAlpha(25)
                                : Colors.orange.withAlpha(30),
                            child: Icon(
                              Icons.phone_android,
                              color: cond == 'NEW'
                                  ? AppColors.successGreen
                                  : AppColors.pendingOrange,
                            ),
                          ),
                          title: Text(
                            '$name ($ramRom)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            'ID: $id | IMEI: $imei\nنقد قیمت: $price روپے ($cond)',
                            style: const TextStyle(fontSize: 12),
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: AppColors.primaryEmerald),
                                tooltip: 'ترمیم کریں',
                                onPressed: () => _loadItemForEdit(item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.errorRed),
                                tooltip: 'حذف کریں',
                                onPressed: () => PosControlStorageService.softDeleteStockItem(id),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}