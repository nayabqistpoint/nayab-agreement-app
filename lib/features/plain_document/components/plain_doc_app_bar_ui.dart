import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PlainDocAppBarUi extends StatelessWidget implements PreferredSizeWidget {
  final bool isZoomFit;
  final VoidCallback onToggleZoom;
  final VoidCallback onSave;

  const PlainDocAppBarUi({
    super.key,
    required this.isZoomFit,
    required this.onToggleZoom,
    required this.onSave,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'سادہ رسید و دستاویزی اسٹوڈیو (A4)',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      backgroundColor: Colors.teal.shade800,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: Icon(isZoomFit ? Icons.zoom_in : Icons.zoom_out_map),
          tooltip: isZoomFit ? 'اصل سائز' : 'پورا صفحہ سکرین پر لائیں',
          onPressed: onToggleZoom,
        ),
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