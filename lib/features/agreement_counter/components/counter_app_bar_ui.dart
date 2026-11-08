import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CounterAppBarUi extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onOpenCustomerDirectory;
  final VoidCallback onReset;

  const CounterAppBarUi({
    super.key,
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
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      backgroundColor: AppColors.primaryEmerald,
      foregroundColor: Colors.white,
      actions: [
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