import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'components/pos_config_tab_ui.dart';
import 'components/pos_stock_tab_ui.dart';
import 'services/pos_control_storage_service.dart';

class PosControlPanelPage extends StatefulWidget {
  const PosControlPanelPage({super.key});

  @override
  State<PosControlPanelPage> createState() => _PosControlPanelPageState();
}

class _PosControlPanelPageState extends State<PosControlPanelPage> {
  int _selectedTabIndex = 0;

  void _confirmPurgeDeleted(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'ڈیلیٹڈ ریکارڈز مستقل صاف کریں؟',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: const Text(
            'اس سے تمام حذف شدہ (Deleted) اسٹاک، کسٹمرز اور ڈیلز لوکل میموری اور کلاؤڈ سرور دونوں سے ہمیشہ کے لیے مٹ جائیں گے تاکہ جگہ خالی رہے۔',
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
                final messenger = ScaffoldMessenger.of(context);
                final count =
                    await PosControlStorageService.purgeAllDeletedRecords();
                if (ctx.mounted) dialogNav.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                        '✅ $count پرانے ڈیلیٹڈ ریکارڈز مستقل طور پر صاف کر دیے گئے!'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('ہاں، مستقل صاف کریں'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPill({
    required int index,
    required String label,
    required IconData icon,
    required Color activeColor,
  }) {
    final bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withAlpha(65),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                  ),
                  overflow: TextOverflow.ellipsis,
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text(
            'POS کنٹرول پینل',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: AppColors.primaryEmerald,
          foregroundColor: Colors.white,
          elevation: 1,
          actions: [
            IconButton(
              icon: const Icon(Icons.cleaning_services_outlined),
              tooltip: 'ڈیلیٹڈ کچرا مستقل صاف کریں (Purge)',
              onPressed: () => _confirmPurgeDeleted(context),
            ),
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    _buildTabPill(
                      index: 0,
                      label: 'موبائل اسٹاک انٹری',
                      icon: Icons.inventory_2_outlined,
                      activeColor: AppColors.primaryEmerald,
                    ),
                    const SizedBox(width: 6),
                    _buildTabPill(
                      index: 1,
                      label: 'کیلکولیٹر ریٹس و شرائط',
                      icon: Icons.tune_rounded,
                      activeColor: const Color(0xFF0F766E),
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: IndexedStack(
            index: _selectedTabIndex,
            children: const [
              PosStockTabUi(),
              PosConfigTabUi(),
            ],
          ),
        ),
      ),
    );
  }
}