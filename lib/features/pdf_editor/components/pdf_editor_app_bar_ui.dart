import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PdfEditorAppBarUi extends StatelessWidget implements PreferredSizeWidget {
  final String paperSize;
  final Function(String) onPaperSizeChanged;
  final VoidCallback onSave;

  const PdfEditorAppBarUi({
    super.key,
    required this.paperSize,
    required this.onPaperSizeChanged,
    required this.onSave,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.5,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1E293B),
      title: const Text(
        'پی ڈی ایف ٹیمپلیٹ اسٹوڈیو',
        style: TextStyle(fontFamily: 'jameel', fontSize: 20, fontWeight: FontWeight.bold),
      ),
      actions: [
        DropdownButton<String>(
          value: paperSize,
          underline: const SizedBox(),
          items: const [
            DropdownMenuItem(value: 'A4', child: Text('A4 پیپر', style: TextStyle(fontWeight: FontWeight.bold))),
            DropdownMenuItem(value: 'Legal', child: Text('Legal پیپر', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          onChanged: (val) {
            if (val != null) onPaperSizeChanged(val);
          },
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: ElevatedButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.check_circle_outline, size: 16),
            label: const Text('محفوظ کریں', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryEmerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
          ),
        ),
      ],
    );
  }
}