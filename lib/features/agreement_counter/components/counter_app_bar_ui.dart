import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CounterAppBarUi extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onOpenStockInventory;
  final VoidCallback onOpenPosRemote;
  final VoidCallback onOpenCustomerDirectory;
  final VoidCallback onReset;

  const CounterAppBarUi({
    super.key,
    required this.onOpenStockInventory,
    required this.onOpenPosRemote,
    required this.onOpenCustomerDirectory,
    required this.onReset,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'نایاب قسط پوائنٹ - کاؤنٹر',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
      ),
      backgroundColor: AppColors.primaryEmerald,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.inventory_2_outlined),
          tooltip: 'اسٹاک انٹری و مینجمنٹ',
          onPressed: onOpenStockInventory,
        ),
        IconButton(
          icon: const Icon(Icons.tune_rounded),
          tooltip: 'POS ریموٹ کنٹرول و ریٹس',
          onPressed: onOpenPosRemote,
        ),
        IconButton(
          icon: const Icon(Icons.people_outline),
          tooltip: 'کسٹمر ڈائریکٹری',
          onPressed: onOpenCustomerDirectory,
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'ری سیٹ',
          onPressed: onReset,
        ),
      ],
    );
  }
}