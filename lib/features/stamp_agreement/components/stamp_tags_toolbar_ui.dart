import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StampTagsToolbarUi extends StatelessWidget {
  final List<String> pinnedTags;
  final Function(String) onInsertFormatting, onInsertTag, onDeleteTag;
  final VoidCallback onInsertForcedSpace, onInsertEmptyTag, onShowAddCustomTag;
  final Function(int, int) onReorderTags;

  const StampTagsToolbarUi({
    super.key,
    required this.pinnedTags,
    required this.onInsertFormatting,
    required this.onInsertForcedSpace,
    required this.onInsertEmptyTag,
    required this.onShowAddCustomTag,
    required this.onInsertTag,
    required this.onReorderTags,
    required this.onDeleteTag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _toolBtn('B', () => onInsertFormatting('b'), bold: true),
                const SizedBox(width: 5),
                _toolBtn('U', () => onInsertFormatting('u'), under: true),
                const SizedBox(width: 8),
                _actionBtn(Icons.space_bar, 'اسپیس بڑھائیں', onInsertForcedSpace),
                const SizedBox(width: 6),
                _actionBtn(Icons.data_object, 'خالی ٹیگ {{ }}', onInsertEmptyTag),
                const SizedBox(width: 6),
                _actionBtn(Icons.add, 'نیا ٹیگ', onShowAddCustomTag, isPrimary: true),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 42,
            child: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: ReorderableListView(
                scrollDirection: Axis.horizontal,
                buildDefaultDragHandles: true,
                onReorderItem: onReorderTags,
                children: pinnedTags.map((t) => Container(
                  key: ValueKey(t),
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => onDeleteTag(t),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                          child: Icon(Icons.close, size: 14, color: Colors.red.shade600),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolBtn(String txt, VoidCallback tap, {bool bold = false, bool under = false}) => InkWell(
    onTap: tap,
    child: Container(
      width: 32, height: 32, alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.grey.shade100, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)),
      child: Text(txt, style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.bold : FontWeight.normal, decoration: under ? TextDecoration.underline : null)),
    ),
  );

  Widget _actionBtn(IconData icon, String label, VoidCallback tap, {bool isPrimary = false}) => InkWell(
    onTap: tap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primaryEmerald : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isPrimary ? AppColors.primaryEmerald : Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: isPrimary ? Colors.white : Colors.black87),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isPrimary ? Colors.white : Colors.black87)),
        ],
      ),
    ),
  );
}