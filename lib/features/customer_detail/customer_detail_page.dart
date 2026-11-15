import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/box_names.dart';
import '../../core/database/hive_box_manager.dart';
import 'args/customer_detail_args.dart';
import 'components/customer_deal_card_ui.dart';
import 'components/customer_detail_header_ui.dart';
import 'customer_detail_controller.dart';

class CustomerDetailPage extends StatefulWidget {
  final CustomerDetailArgs args;

  const CustomerDetailPage({super.key, required this.args});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  late final CustomerDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CustomerDetailController(widget.args);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirmDeleteProfile() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'مکمل ریکارڈ حذف کریں؟',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: const Text(
            'کیا آپ واقعی اس فرد اور اس کے تمام منسلک معاہدات کو ہمیشہ کے لیے حذف کرنا چاہتے ہیں؟',
            style: TextStyle(fontSize: 13.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('منسوخ'),
            ),
            ElevatedButton(
              onPressed: () async {
                final dialogNav = Navigator.of(ctx);
                final pageNav = Navigator.of(context);
                await _controller.deleteEntireProfile();
                if (ctx.mounted) dialogNav.pop();
                if (mounted) pageNav.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('ہاں، حذف کریں'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteDeal(String dealId) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'معاہدہ حذف کریں؟',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: const Text(
            'کیا آپ واقعی یہ معاہدہ حذف کرنا چاہتے ہیں؟',
            style: TextStyle(fontSize: 13.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('منسوخ'),
            ),
            ElevatedButton(
              onPressed: () async {
                final dialogNav = Navigator.of(ctx);
                await _controller.deleteSingleDeal(dealId);
                if (ctx.mounted) dialogNav.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('حذف کریں'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text(
            'مکمل کسٹمر پروفائل و معاہدات',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: AppColors.primaryEmerald,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_forever_outlined),
              tooltip: 'مکمل پروفائل حذف کریں',
              onPressed: _confirmDeleteProfile,
            ),
          ],
        ),
        body: ValueListenableBuilder(
          valueListenable: HiveBoxManager.listenToBox(BoxNames.customersBox),
          builder: (context, custBox, child) {
            final customer = _controller.profile;
            if (customer == null) {
              return const Center(
                child: Text(
                  'یہ ریکارڈ دستیاب نہیں ہے یا حذف کر دیا گیا ہے۔',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              );
            }

            return ValueListenableBuilder(
              valueListenable:
                  HiveBoxManager.listenToBox(BoxNames.customerDealsBox),
              builder: (context, dealsBox, child) {
                final deals = _controller.deals;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomerDetailHeaderUi(customer: customer),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.receipt_long_outlined,
                              size: 18, color: AppColors.primaryEmerald),
                          const SizedBox(width: 6),
                          Text(
                            'سابقہ خریداری و اقساط معاہدات (${deals.length})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (deals.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.folder_open_outlined,
                                  size: 45, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              const Text(
                                'اس فرد کے نام پر کوئی معاہدہ درج نہیں ہے',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        )
                      else
                        ...deals.map(
                          (deal) => CustomerDealCardUi(
                            deal: deal,
                            onLoadIntoBucket: () async {
                              final nav = Navigator.of(context);
                              await _controller.loadDealToCounter(deal);
                              if (!mounted) return;
                              nav.popUntil((route) => route.isFirst);
                            },
                            onGenerateNotice: () async {
                              final nav = Navigator.of(context);
                              await _controller.prepareNoticeToCounter(deal);
                              if (!mounted) return;
                              nav.popUntil((route) => route.isFirst);
                            },
                            onDeleteDeal: () => _confirmDeleteDeal(deal.id),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}