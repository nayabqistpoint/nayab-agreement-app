import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class FormFillerAppBarUi extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSave;

  const FormFillerAppBarUi({super.key, required this.onSave});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'اسکول و دفتری فارم فلر اسٹوڈیو',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      backgroundColor: Colors.indigo.shade800,
      foregroundColor: Colors.white,
      actions: [
        ElevatedButton.icon(
          onPressed: onSave,
          icon: const Icon(Icons.check, color: Colors.white, size: 18),
          label: const Text(
            'محفوظ کریں',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}