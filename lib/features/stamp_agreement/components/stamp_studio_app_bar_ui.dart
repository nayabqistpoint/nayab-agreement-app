import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StampStudioAppBarUi extends StatelessWidget implements PreferredSizeWidget {
  final String paperSize;
  final bool isZoomFit;
  final Function(String) onPaperSizeChanged;
  final VoidCallback onToggleZoom;
  final VoidCallback onSave;

  const StampStudioAppBarUi({
    super.key,
    required this.paperSize,
    required this.isZoomFit,
    required this.onPaperSizeChanged,
    required this.onToggleZoom,
    required this.onSave,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final bool isA4 = paperSize.toUpperCase() == 'A4';

    return AppBar(
      title: const Text(
        'پنجاب ای-اسٹامپ اسٹوڈیو',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      backgroundColor: AppColors.primaryEmerald,
      foregroundColor: Colors.white,
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white70),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () => onPaperSizeChanged('Legal'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: !isA4 ? Colors.white : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(5),
                      bottomRight: Radius.circular(5),
                    ),
                  ),
                  child: Text(
                    'Legal (اسٹامپ)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: !isA4 ? AppColors.primaryEmerald : Colors.white,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => onPaperSizeChanged('A4'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isA4 ? Colors.white : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      bottomLeft: Radius.circular(5),
                    ),
                  ),
                  child: Text(
                    'A4 (سادہ)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isA4 ? AppColors.primaryEmerald : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
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