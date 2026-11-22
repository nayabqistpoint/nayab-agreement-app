import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../pos_remote_control/pos_remote_page.dart';
import '../pos_remote_control/services/pos_remote_config_service.dart';
import '../stock_inventory/components/general_stock_form_ui.dart';
import '../stock_inventory/components/mobile_stock_form_ui.dart';
import 'args/stock_entry_args.dart';
import 'components/stock_entry_submit_bar_ui.dart';
import 'stock_entry_controller.dart';
class StockEntryPage extends StatefulWidget {
  final StockEntryArgs args;
  const StockEntryPage({
    super.key,
    this.args = const StockEntryArgs(),
  });
  @override
  State<StockEntryPage> createState() => _StockEntryPageState();
}
class _StockEntryPageState extends State<StockEntryPage> {
  late final StockEntryController _controller;
  final GlobalKey<MobileStockFormUiState> _mobileFormKey = GlobalKey();
  final GlobalKey<GeneralStockFormUiState> _generalFormKey = GlobalKey();
  void _onControllerChanged() {
    if (mounted) setState(() {});
  }
  @override
  void initState() {
    super.initState();
    _controller = StockEntryController(
      editingItem: widget.args.editingItem,
      selectedCategoryIndex: widget.args.initialCategoryIndex,
    );
    _controller.addListener(_onControllerChanged);
  }
  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }
  void _triggerFrozenSubmit() {
    if (_controller.selectedCategoryIndex == 0) {
      _mobileFormKey.currentState?.triggerSubmit();
    } else {
      _generalFormKey.currentState?.triggerSubmit();
    }
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
  @override
  Widget build(BuildContext context) {
    final bool isEditing = _controller.editingItem != null;
    final bool isMobSelected = _controller.selectedCategoryIndex == 0;
    final bool isOrderPurchaseFlow = widget.args.linkToOrderId != null;
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
                  : (isEditing
                      ? 'اسٹاک آئٹم میں ترمیم'
                      : 'نیا اسٹاک درج کریں'),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19.5),
            ),
            backgroundColor: AppColors.primaryEmerald,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(6, 10, 6, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                if (!isEditing) ...[
                  Row(
                    children: [
                      _buildTabBtn(0, 'موبائل اسٹاک انٹری', Icons.phone_android),
                      const SizedBox(width: 6),
                      _buildTabBtn(
                          1, 'جنرل اشیاء انٹری', Icons.kitchen_outlined),
                    ],
                  ),
                  const SizedBox(height: 11),
                ],
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
                          if (!isEditing) ...[
                            _buildQuantityStepper(),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              isMobSelected
                                  ? (isEditing
                                      ? 'موبائل اسٹاک میں ترمیم (${_controller.editingItem!['id']})'
                                      : 'نیا موبائل اسٹاک درج کریں')
                                  : (isEditing
                                      ? 'جنرل آئٹم میں ترمیم (${_controller.editingItem!['id']})'
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
                          key: _mobileFormKey,
                          showInlineSubmitButton: false,
                          editingItem: _controller.editingItem,
                          prefillData: widget.args.prefillOrderData,
                          quantity: _controller.currentQuantity,
                          onCancelEdit: () => Navigator.pop(context),
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
                              linkToOrderId: widget.args.linkToOrderId,
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
                            nav.pop(true);
                          },
                        )
                      else
                        GeneralStockFormUi(
                          key: _generalFormKey,
                          showInlineSubmitButton: false,
                          editingItem: _controller.editingItem,
                          prefillData: widget.args.prefillOrderData,
                          quantity: _controller.currentQuantity,
                          onCancelEdit: () => Navigator.pop(context),
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
                              linkToOrderId: widget.args.linkToOrderId,
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
                            nav.pop(true);
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: StockEntrySubmitBarUi(
            isEditing: isEditing,
            isMobile: isMobSelected,
            quantity: _controller.currentQuantity,
            onPressed: _triggerFrozenSubmit,
          ),
        ),
      ),
    );
  }
}