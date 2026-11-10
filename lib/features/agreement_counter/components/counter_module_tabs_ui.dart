import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CounterModuleTabsUi extends StatelessWidget {
  final VoidCallback onOpenStampStudio;
  final VoidCallback onOpenPdfEditor;

  const CounterModuleTabsUi({
    super.key,
    required this.onOpenStampStudio,
    required this.onOpenPdfEditor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          // ای-اسٹامپ اسٹوڈیو بٹن
          Expanded(
            child: InkWell(
              onTap: onOpenStampStudio,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade800,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_edu, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'ای-اسٹامپ اسٹوڈیو',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // پی ڈی ایف اسٹوڈیو بٹن
          Expanded(
            child: InkWell(
              onTap: onOpenPdfEditor,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryEmerald,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryEmerald.withAlpha(50),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'پی ڈی ایف اسٹوڈیو',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}