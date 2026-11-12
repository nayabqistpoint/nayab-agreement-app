import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StampTagsToolbarUi extends StatefulWidget {
  final List<String> pinnedTags;
  final String? activePendingTag;
  final bool isPendingStatic;
  final VoidCallback onSelectStaticToStamp;
  final VoidCallback onSelectEmptyTagToStamp;
  final VoidCallback onShowAddCustomTag;
  final Function(String) onSelectTagToStamp;
  final Function(String) onInsertTagInText;
  final Function(String) onDeleteTag;

  const StampTagsToolbarUi({
    super.key,
    required this.pinnedTags,
    this.activePendingTag,
    this.isPendingStatic = false,
    required this.onSelectStaticToStamp,
    required this.onSelectEmptyTagToStamp,
    required this.onShowAddCustomTag,
    required this.onSelectTagToStamp,
    required this.onInsertTagInText,
    required this.onDeleteTag,
  });

  @override
  State<StampTagsToolbarUi> createState() => _StampTagsToolbarUiState();
}

class _StampTagsToolbarUiState extends State<StampTagsToolbarUi> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: widget.onSelectStaticToStamp,
                  icon: const Icon(Icons.text_fields, size: 14),
                  label: Text(
                    widget.isPendingStatic
                        ? 'تحریر (صفحے پر کلک کریں)'
                        : 'تحریر لکھیں',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isPendingStatic
                        ? Colors.orange.shade800
                        : Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                ),
                const SizedBox(width: 6),
                ElevatedButton.icon(
                  onPressed: widget.onSelectEmptyTagToStamp,
                  icon: const Icon(Icons.data_object, size: 14),
                  label: Text(
                    widget.activePendingTag == '__empty_tag__'
                        ? 'خالی ٹیگ (کلک کریں)'
                        : 'خالی ٹیگ {{ }}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        widget.activePendingTag == '__empty_tag__'
                            ? Colors.orange.shade800
                            : Colors.indigo.shade700,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                ),
                const SizedBox(width: 6),
                ElevatedButton.icon(
                  onPressed: widget.onShowAddCustomTag,
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text(
                    'نیا ٹیگ',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryEmerald,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                ),
                const SizedBox(width: 8),
                Container(height: 20, width: 1, color: Colors.grey.shade300),
                const SizedBox(width: 6),
                const Text(
                  'ٹیگ چُنیں (کلک: باکس / ڈبل کلک: پیراگراف):',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 36,
            child: ReorderableListView(
              scrollDirection: Axis.horizontal,
              buildDefaultDragHandles: false,
              onReorderItem: (int oldIndex, int newIndex) {
                setState(() {
                  final String item = widget.pinnedTags.removeAt(oldIndex);
                  widget.pinnedTags.insert(newIndex, item);
                });
              },
              children: [
                for (int index = 0; index < widget.pinnedTags.length; index++)
                  ReorderableDelayedDragStartListener(
                    key: ValueKey(widget.pinnedTags[index]),
                    index: index,
                    child: Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: widget.activePendingTag ==
                                widget.pinnedTags[index]
                            ? AppColors.primaryEmerald.withAlpha(40)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: widget.activePendingTag ==
                                  widget.pinnedTags[index]
                              ? AppColors.primaryEmerald
                              : const Color(0xFFCBD5E1),
                          width: widget.activePendingTag ==
                                  widget.pinnedTags[index]
                              ? 1.8
                              : 1.1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ReorderableDragStartListener(
                            index: index,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2),
                              child: Icon(
                                Icons.drag_indicator,
                                size: 15,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          InkWell(
                            onTap: () => widget
                                .onSelectTagToStamp(widget.pinnedTags[index]),
                            onDoubleTap: () => widget
                                .onInsertTagInText(widget.pinnedTags[index]),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                widget.pinnedTags[index],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: widget.activePendingTag ==
                                          widget.pinnedTags[index]
                                      ? AppColors.primaryEmerald
                                      : const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () =>
                                widget.onDeleteTag(widget.pinnedTags[index]),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Icon(
                                Icons.close,
                                size: 13,
                                color: Colors.red.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}