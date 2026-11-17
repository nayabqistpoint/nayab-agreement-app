import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'components/general_stock_form_ui.dart';
import 'components/mobile_stock_form_ui.dart';
import 'components/stock_inventory_list_ui.dart';
import 'stock_inventory_controller.dart';

class StockInventoryPage extends StatefulWidget {
  const StockInventoryPage({super.key});

  @override
  State<StockInventoryPage> createState() => _StockInventoryPageState();
}

class _StockInventoryPageState extends State<StockInventoryPage> {
  late final StockInventoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StockInventoryController();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildTabBtn(int index, String label, IconData icon) {
    final sel = _controller.selectedCategoryIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _controller.setCategory(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: sel ? AppColors.primaryEmerald : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: sel ? AppColors.primaryEmerald : const Color(0xFFCBD5E1),
              width: 1.4,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: sel ? Colors.white : Colors.black87),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: sel ? Colors.white : const Color(0xFF0F172A),
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
    final stockList = _controller.getAllStock();
    final activeCount = stockList
        .where((i) => (i['status']?.toString() ?? '').toUpperCase() != 'SOLD')
        .length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text(
            'اسٹاک انٹری و مینجمنٹ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: AppColors.primaryEmerald,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _buildTabBtn(0, 'موبائل اسٹاک انٹری', Icons.phone_android),
                  const SizedBox(width: 8),
                  _buildTabBtn(1, 'جنرل اشیاء انٹری', Icons.kitchen_outlined),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _controller.selectedCategoryIndex == 0
                          ? (_controller.editingItem != null
                              ? 'موبائل اسٹاک میں ترمیم'
                              : 'نیا موبائل اسٹاک درج کریں')
                          : (_controller.editingItem != null
                              ? 'جنرل آئٹم میں ترمیم'
                              : 'نئی جنرل آئٹم درج کریں'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primaryEmerald,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_controller.selectedCategoryIndex == 0)
                      MobileStockFormUi(
                        editingItem: _controller.editingItem,
                        onCancelEdit: _controller.cancelEdit,
                        onSave: ({
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
                        }) async {
                          final messenger = ScaffoldMessenger.of(context);
                          await _controller.saveStockItem(
                            stockId: stockId,
                            itemName: itemName,
                            imeiOrSerial: imei,
                            specsOrRam: ramRom,
                            color: color,
                            purchasePrice: purchasePrice,
                            salePrice: salePrice,
                            supplier: supplier,
                            conditionType: conditionType,
                            conditionRating: conditionRating,
                            warranty: warranty,
                            images: images,
                          );
                          if (!mounted) return;
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('✅ موبائل اسٹاک کامیابی سے محفوظ ہو گیا!'),
                              backgroundColor: AppColors.successGreen,
                            ),
                          );
                        },
                      )
                    else
                      GeneralStockFormUi(
                        editingItem: _controller.editingItem,
                        onCancelEdit: _controller.cancelEdit,
                        onSave: ({
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
                        }) async {
                          final messenger = ScaffoldMessenger.of(context);
                          await _controller.saveStockItem(
                            stockId: stockId,
                            itemName: itemName,
                            imeiOrSerial: serialNo,
                            specsOrRam: specsSummary,
                            color: color,
                            purchasePrice: purchasePrice,
                            salePrice: salePrice,
                            supplier: supplier,
                            conditionType: conditionType,
                            conditionRating: conditionRating,
                            warranty: warranty,
                            images: images,
                          );
                          if (!mounted) return;
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('✅ جنرل آئٹم کامیابی سے محفوظ ہو گئی!'),
                              backgroundColor: AppColors.successGreen,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'دکان کا موجودہ کل اسٹاک:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryEmerald,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$activeCount آئٹمز',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              StockInventoryListUi(
                items: stockList,
                onEdit: _controller.startEditing,
                onDelete: (id) async {
                  final messenger = ScaffoldMessenger.of(context);
                  final ok = await _controller.deleteStockItem(id);
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(ok
                          ? '🗑️ اسٹاک حذف کر دیا گیا'
                          : '⚠️ بُک یا فروخت شدہ آئٹم حذف نہیں ہو سکتا!'),
                      backgroundColor:
                          ok ? AppColors.primaryEmerald : AppColors.errorRed,
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}