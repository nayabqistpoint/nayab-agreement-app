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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HiveBoxManager.listenToBox(BoxNames.shopOrdersBox),
      builder: (context, _, _) {
        final pendingCount = PosPendingOrdersService.getPendingOrders().length;
        final allCount = PosPendingOrdersService.getAllOrders().length;
        final list = _controller.getFilteredOrders();
        final activeId = _controller.activeOrderId;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              title: Text(
                _controller.showAllHistory
                    ? 'تمام POS آرڈرز ($allCount)'
                    : 'زیرِ التواء POS آرڈرز ($pendingCount)',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              backgroundColor: AppColors.primaryEmerald,
              foregroundColor: Colors.white,
              actions: [
                TextButton.icon(
                  onPressed: () => _controller
                      .toggleHistoryFilter(!_controller.showAllHistory),
                  icon: Icon(
                    _controller.showAllHistory
                        ? Icons.pending_actions
                        : Icons.history,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Text(
                    _controller.showAllHistory
                        ? 'پینڈنگ ($pendingCount)'
                        : 'ہسٹری ($allCount)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    textAlign: TextAlign.right,
                    onChanged: _controller.updateSearch,
                    decoration: InputDecoration(
                      hintText: 'کسٹمر نام، شناختی کارڈ، فون یا موبائل سے تلاش کریں...',
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
                                _controller.showAllHistory
                                    ? 'کوئی POS آرڈر ریکارڈ موجود نہیں ہے۔'
                                    : 'اس وقت کوئی نیا پینڈنگ آرڈر نہیں ہے۔',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 14,
                                ),
                              ),
                              if (!_controller.showAllHistory && allCount > 0)
                                TextButton(
                                  onPressed: () =>
                                      _controller.toggleHistoryFilter(true),
                                  child: Text(
                                    'تمام پرانے آرڈرز دیکھیں ($allCount)',
                                    style: const TextStyle(
                                      color: AppColors.primaryEmerald,
                                      fontWeight: FontWeight.bold,
                                    ),
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