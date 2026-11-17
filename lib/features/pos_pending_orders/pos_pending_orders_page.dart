import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/box_names.dart';
import '../../core/database/hive_box_manager.dart';
import 'components/pos_pending_order_card_ui.dart';
import 'pos_pending_orders_controller.dart';
import 'services/pos_pending_orders_service.dart';

class PosPendingOrdersPage extends StatefulWidget {
  const PosPendingOrdersPage({super.key});

  @override
  State<PosPendingOrdersPage> createState() => _PosPendingOrdersPageState();
}

class _PosPendingOrdersPageState extends State<PosPendingOrdersPage> {
  late final PosPendingOrdersController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PosPendingOrdersController();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirmDismiss(String orderId, String customerName) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'آرڈر پینڈنگ لسٹ سے ہٹائیں؟',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Text(
            'کیا آپ "$customerName" کا یہ آرڈر کاؤنٹر کی پینڈنگ لسٹ سے ختم کرنا چاہتے ہیں؟ (ریکارڈ ہسٹری میں محفوظ رہے گا)',
            style: const TextStyle(fontSize: 13.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('منسوخ'),
            ),
            ElevatedButton(
              onPressed: () async {
                final dialogNav = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);
                await _controller.dismissOrder(orderId);
                if (ctx.mounted) dialogNav.pop();
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('آرڈر پینڈنگ لسٹ سے ختم کر دیا گیا ہے'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('ہاں، ختم کریں'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String key, String label, int count) {
    final isSelected = _controller.statusFilter == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => _controller.setStatusFilter(key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryEmerald : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryEmerald
                  : const Color(0xFFCBD5E1),
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$label ($count)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HiveBoxManager.listenToBox(BoxNames.shopOrdersBox),
      builder: (context, _, _) {
        final allOrders = PosPendingOrdersService.getAllOrders();
        final pendingOrders = PosPendingOrdersService.getPendingOrders();
        final int allCount = allOrders.length;
        final int pendingCount = pendingOrders.length;
        final int historyCount =
            allCount > pendingCount ? (allCount - pendingCount) : 0;

        final list = _controller.getFilteredOrders();
        final activeId = _controller.activeOrderId;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              title: const Text(
                'POS آرڈرز و بکنگ لسٹ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              backgroundColor: AppColors.primaryEmerald,
              foregroundColor: Colors.white,
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                  child: TextField(
                    textAlign: TextAlign.right,
                    onChanged: _controller.updateSearch,
                    decoration: InputDecoration(
                      hintText:
                          'کسٹمر، ضامن، شناختی کارڈ، فون یا ماڈل سے تلاش کریں...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
                  child: Row(
                    children: [
                      _buildFilterTab('ALL', 'سب آرڈرز', allCount),
                      const SizedBox(width: 6),
                      _buildFilterTab('PENDING', 'زیرِ التواء', pendingCount),
                      const SizedBox(width: 6),
                      _buildFilterTab('HISTORY', 'مکمل / ہٹائے گئے', historyCount),
                    ],
                  ),
                ),
                Expanded(
                  child: list.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.point_of_sale_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _controller.statusFilter == 'PENDING'
                                    ? 'اس وقت کوئی نیا زیرِ التواء آرڈر نہیں ہے۔'
                                    : 'اس حصے میں کوئی آرڈر ریکارڈ موجود نہیں ہے۔',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final order = list[index];
                            final id = order['id']?.toString() ?? '';
                            final customer =
                                order['customerName']?.toString() ?? 'کسٹمر';
                            return PosPendingOrderCardUi(
                              order: order,
                              isCurrentlyActive: id == activeId,
                              onSelect: () async {
                                final nav = Navigator.of(context);
                                final messenger = ScaffoldMessenger.of(context);
                                await _controller.selectOrderForCounter(order);
                                if (!mounted) return;
                                nav.pop(true);
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '$customer کی معلومات ایگریمنٹ بالٹی میں لوڈ ہو گئی ہیں!',
                                    ),
                                    backgroundColor: AppColors.primaryEmerald,
                                  ),
                                );
                              },
                              onDismiss: () => _confirmDismiss(id, customer),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}