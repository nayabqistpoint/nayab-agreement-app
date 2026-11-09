// lib/features/stamp_agreement/components/stamp_tags_toolbar_ui.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StampTagsToolbarUi extends StatelessWidget {
  final List<String> pinnedTags;
  final VoidCallback onBold;
  final VoidCallback onUnderline;
  final VoidCallback onInsertEmSpace;
  final VoidCallback onInsertEmptyTag;
  final VoidCallback onShowAddCustomTag;
  final Function(String) onInsertTag;
  final Function(String) onDeleteTag;

  const StampTagsToolbarUi({
    super.key,
    required this.pinnedTags,
    required this.onBold,
    required this.onUnderline,
    required this.onInsertEmSpace,
    required this.onInsertEmptyTag,
    required this.onShowAddCustomTag,
    required this.onInsertTag,
    required this.onDeleteTag,
  });

  Widget _buildFormatBtn({
    required String text,
    required VoidCallback onTap,
    bool bold = false,
    bool underline = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 34,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: bold ? FontWeight.w900 : FontWeight.bold,
            decoration: underline ? TextDecoration.underline : null,
            color: const Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryEmerald : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isPrimary ? AppColors.primaryEmerald : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isPrimary ? Colors.white : const Color(0xFF1E293B),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isPrimary ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white, // رنگ کو باکس ڈیکوریشن کے اندر منتقل کر دیا گیا ہے
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // رو نمبر 1: فارمیٹنگ، ٹیب اسپیس اور خالی ٹیگ
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFormatBtn(text: 'B', onTap: onBold, bold: true),
                const SizedBox(width: 6),
                _buildFormatBtn(text: 'U', onTap: onUnderline, underline: true),
                const SizedBox(width: 8),
                Container(height: 20, width: 1, color: Colors.grey.shade300),
                const SizedBox(width: 8),
                _buildActionBtn(
                  icon: Icons.space_bar,
                  label: 'اسپیس (Tab)',
                  onTap: onInsertEmSpace,
                ),
                const SizedBox(width: 6),
                _buildActionBtn(
                  icon: Icons.data_object,
                  label: 'خالی ٹیگ {{ }}',
                  onTap: onInsertEmptyTag,
                ),
                const SizedBox(width: 6),
                _buildActionBtn(
                  icon: Icons.add,
                  label: 'نیا ٹیگ',
                  onTap: onShowAddCustomTag,
                  isPrimary: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // رو نمبر 2: محفوظ شدہ ٹیگز چپس
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: pinnedTags.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final t = pinnedTags[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => onInsertTag(t),
                        child: Text(
                          t,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => onDeleteTag(t),
                        child: Icon(Icons.close, size: 13, color: Colors.red.shade600),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}