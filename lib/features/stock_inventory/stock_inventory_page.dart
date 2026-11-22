import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'components/stock_inventory_list_ui.dart';
import 'components/stock_worth_summary_card_ui.dart';
import 'services/stock_inventory_storage_service.dart';
import 'stock_entry_form_page.dart';
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
    if (widget.linkToOrderId != null || widget.prefillOrderData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _openEntryPage(
          prefillOrderData: widget.prefillOrderData,
          linkToOrderId: widget.linkToOrderId,
          popParentOnSuccess: widget.linkToOrderId != null,
        );
      });
    }
  }
  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }
  Future<void> _openEntryPage({
    StockMap? itemToEdit,
    Map<String, dynamic>? prefillOrderData,
    String? linkToOrderId,
    bool popParentOnSuccess = false,
  }) async {
    if (itemToEdit != null) {
      _controller.startEditing(itemToEdit);
    } else {
      _controller.cancelEdit();
      _controller.currentQuantity = 1;
      _controller.selectedCategoryIndex = widget.initialCategoryIndex;
    }
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => StockEntryFormPage(
          controller: _controller,
          prefillOrderData: prefillOrderData,
          linkToOrderId: linkToOrderId,
        ),
      ),
    );
    if (!mounted) return;
    setState(() {});
    if (popParentOnSuccess && saved == true) {
      Navigator.pop(context, true);
    }
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
            title: const Text(
              'اسٹاک انٹری و مینجمنٹ',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19.5),
            ),
            backgroundColor: AppColors.primaryEmerald,
            foregroundColor: Colors.white,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton.icon(
                  onPressed: () => _openEntryPage(),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 19),
                  label: const Text(
                    'نیا اسٹاک',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldHighlight,
                    foregroundColor: AppColors.textDark,
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.cleaning_services_outlined, size: 23),
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
                  onEdit: (item) => _openEntryPage(itemToEdit: item),
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