import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../pos_remote_control/pos_remote_page.dart';
import '../pos_remote_control/services/pos_remote_config_service.dart';
import 'components/general_stock_form_ui.dart';
import 'components/mobile_stock_form_ui.dart';
import 'components/stock_inventory_list_ui.dart';
import 'components/stock_worth_summary_card_ui.dart';
import 'services/stock_inventory_storage_service.dart';
import 'stock_inventory_controller.dart';

class StockInventoryPage extends StatefulWidget {
  final Map<String, dynamic>? prefillOrderData;
  final String? linkToOrderId;
  final int initialCategoryIndex;

  const StockInventoryPage({
    super.key,
    this.prefillOrderData,
    this.linkToOrderId,
    this.initialCategoryIndex = 0,
  });

  @override
  State<StockInventoryPage> createState() => _StockInventoryPageState();
}

class _StockInventoryPageState extends State<StockInventoryPage> {
  late final StockInventoryController _controller;

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _controller = StockInventoryController();
    _controller.selectedCategoryIndex = widget.initialCategoryIndex;
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _confirmPurge() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('ڈیٹا صفائی و ری سیٹ',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          content: const Text(
            'آپ صرف حذف شدہ کچرا صاف کرنا چاہتے ہیں یا ٹیسٹنگ کا تمام ڈیٹا (موجودہ، بُک شدہ اور فروخت شدہ) ختم کر کے دوبارہ STK_001 سے شروع کرنا چاہتے ہیں؟',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('منسوخ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
            ),
            OutlinedButton(
              onPressed: () async {
                final nav = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);
                final count = await _controller.purgeDeleted();
                if (ctx.mounted) nav.pop();
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content:
                        Text('✅ $count ڈیلیٹڈ ریکارڈز مستقل صاف کر دیے گئے!'),
                    backgroundColor: AppColors.primaryEmerald,
                  ),
                );
              },
              child: const Text('صرف ڈیلیٹ شدہ صاف کریں',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            ),
            ElevatedButton(
              onPressed: () async {
                final nav = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);
                final count = await _controller.resetAllToZero();
                if (ctx.mounted) nav.pop();
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                        '✅ تمام $count ریکارڈز صاف ہو گئے؛ اب اگلا اسٹاک STK_001 سے شروع ہوگا!'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('مکمل ری سیٹ (STK_001)',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBtn(int index, String label, IconData icon) {
    final sel = _controller.selectedCategoryIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _controller.setCategory(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: sel
                ? AppColors.primaryEmerald
                : AppColors.warmSubtleSurface,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: sel ? AppColors.primaryEmerald : AppColors.borderLight,
              width: 1.6,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: sel ? Colors.white : AppColors.textDark),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    color: sel ? Colors.white : AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleStepButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isPrimary,
  }) {
    final bool enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: !enabled
              ? Colors.grey.shade200
              : (isPrimary ? AppColors.primaryEmerald : Colors.white),
          border: Border.all(
            color: !enabled
                ? Colors.grey.shade400
                : AppColors.primaryEmerald,
            width: 1.8,
          ),
        ),
        child: Icon(
          icon,
          size: 23,
          color: !enabled
              ? Colors.grey.shade500
              : (isPrimary ? Colors.white : AppColors.primaryEmerald),
        ),
      ),
    );
  }

  Widget _buildQuantityStepper() {
    final qty = _controller.currentQuantity;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.warmTintEmerald,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.emeraldPillBorder,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCircleStepButton(
            icon: Icons.add_rounded,
            isPrimary: true,
            onTap: qty < 50 ? _controller.incrementQuantity : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Text(
              '$qty',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryEmerald,
              ),
            ),
          ),
          _buildCircleStepButton(
            icon: Icons.remove_rounded,
            isPrimary: false,
            onTap: qty > 1 ? _controller.decrementQuantity : null,
          ),
        ],
      ),
    );
  }

  Widget _buildFullWidthFilterBtn(String key, String label, int count) {
    final isSel = _controller.statusFilter == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => _controller.setStatusFilter(key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSel ? AppColors.primaryEmerald : Colors.white,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: isSel
                  ? AppColors.primaryEmerald
                  : AppColors.emeraldPillBorder,
              width: 1.6,
            ),
            boxShadow: isSel
                ? [
                    BoxShadow(
                      color: AppColors.primaryEmerald.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '$label ($count)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: isSel ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stockList = _controller.getFilteredStock();
    final allStock = StockInventoryStorageService.getAllStockItems();
    final isOrderPurchaseFlow = widget.linkToOrderId != null;
    final bool isMobSelected = _controller.selectedCategoryIndex == 0;
    final groupingHint = PosRemoteConfigService.getActiveGroupingSummaryText(
      isMobile: isMobSelected,
    );

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.16),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            toolbarHeight: 64,
            title: Text(
              isOrderPurchaseFlow
                  ? 'آرڈر اسٹاک خریداری و انٹری'
                  : 'اسٹاک انٹری و مینجمنٹ',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
            ),
            backgroundColor: AppColors.primaryEmerald,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.cleaning_services_outlined, size: 24),
                tooltip: 'صفائی و مکمل ری سیٹ',
                onPressed: _confirmPurge,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StockWorthSummaryCardUi(allStockItems: allStock),
                if (isOrderPurchaseFlow)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.pendingOrange, width: 1.5),
                    ),
                    child: const Text(
                      '🛒 پینڈنگ آرڈر کی تفصیلات نیچے پہلے سے بھر دی گئی ہیں؛ قیمتِ خرید، سپلائر اور IMEI درج کر کے محفوظ کریں۔',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF9A3412),
                      ),
                    ),
                  ),
                Row(
                  children: [
                    _buildTabBtn(0, 'موبائل اسٹاک انٹری', Icons.phone_android),
                    const SizedBox(width: 6),
                    _buildTabBtn(1, 'جنرل اشیاء انٹری', Icons.kitchen_outlined),
                  ],
                ),
                const SizedBox(height: 11),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight, width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          if (_controller.editingItem == null) ...[
                            _buildQuantityStepper(),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              isMobSelected
                                  ? (_controller.editingItem != null
                                      ? 'موبائل اسٹاک میں ترمیم'
                                      : 'نیا موبائل اسٹاک درج کریں')
                                  : (_controller.editingItem != null
                                      ? 'جنرل آئٹم میں ترمیم'
                                      : 'نئی جنرل آئٹم درج کریں'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                                color: AppColors.primaryEmerald,
                              ),
                            ),
                          ),
                          if (_controller.editingItem != null)
                            TextButton(
                              onPressed: _controller.cancelEdit,
                              child: const Text('منسوخ',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PosRemotePage(),
                            ),
                          ).then((_) {
                            if (mounted) setState(() {});
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warmTintEmerald,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.emeraldPillBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.layers_outlined,
                                size: 16,
                                color: AppColors.primaryEmerald,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'کارڈ گروپنگ معیار: $groupingHint',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryEmerald,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.tune_rounded,
                                size: 16,
                                color: AppColors.primaryEmerald,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 11),
                      if (isMobSelected)
                        MobileStockFormUi(
                          editingItem: _controller.editingItem,
                          prefillData: widget.prefillOrderData,
                          quantity: _controller.currentQuantity,
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
                            required bool isOnOrder,
                            required int quantity,
                            required Map<String, String> dynamicFields,
                            required Map<String, List<String>> perUnitOverrides,
                            required List<String> images,
                            required List<List<String>> perUnitImages,
                          }) async {
                            final messenger = ScaffoldMessenger.of(context);
                            final nav = Navigator.of(context);
                            final res = await _controller.saveStockItem(
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
                              isOnOrder: isOnOrder,
                              quantity: quantity,
                              dynamicFields: dynamicFields,
                              perUnitOverrides: perUnitOverrides,
                              images: images,
                              perUnitImages: perUnitImages,
                              linkToOrderId: widget.linkToOrderId,
                            );
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(res.count > 1
                                    ? '✅ ${res.count} منفرد موبائل کارڈز کامیابی سے شامل کر دیے گئے!'
                                    : '✅ موبائل اسٹاک (${res.firstStockId}) محفوظ ہو گیا!'),
                                backgroundColor: AppColors.successGreen,
                              ),
                            );
                            if (isOrderPurchaseFlow) {
                              nav.pop(true);
                            }
                          },
                        )
                      else
                        GeneralStockFormUi(
                          editingItem: _controller.editingItem,
                          prefillData: widget.prefillOrderData,
                          quantity: _controller.currentQuantity,
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
                            required bool isOnOrder,
                            required int quantity,
                            required Map<String, String> dynamicFields,
                            required Map<String, List<String>> perUnitOverrides,
                            required List<String> images,
                            required List<List<String>> perUnitImages,
                          }) async {
                            final messenger = ScaffoldMessenger.of(context);
                            final nav = Navigator.of(context);
                            final res = await _controller.saveStockItem(
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
                              isOnOrder: isOnOrder,
                              quantity: quantity,
                              dynamicFields: dynamicFields,
                              perUnitOverrides: perUnitOverrides,
                              images: images,
                              perUnitImages: perUnitImages,
                              linkToOrderId: widget.linkToOrderId,
                            );
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(res.count > 1
                                    ? '✅ ${res.count} منفرد اسٹاک کارڈز کامیابی سے شامل کر دیے گئے!'
                                    : '✅ جنرل آئٹم (${res.firstStockId}) محفوظ ہو گئی!'),
                                backgroundColor: AppColors.successGreen,
                              ),
                            );
                            if (isOrderPurchaseFlow) {
                              nav.pop(true);
                            }
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildFullWidthFilterBtn(
                        'ACTIVE', 'زندہ اسٹاک', _controller.activeCount),
                    const SizedBox(width: 8),
                    _buildFullWidthFilterBtn(
                        'SOLD', 'فروخت شدہ', _controller.soldCount),
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
      ),
    );
  }
}