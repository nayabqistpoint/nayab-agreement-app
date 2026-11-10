import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PdfEditorTagsBarUi extends StatelessWidget {
  final TextEditingController titleController;
  final String? loadedFileName;
  final VoidCallback onPickPdf;
  final VoidCallback onScanCamera; // نیا کیمرہ سکین کال بیک
  final List<String> availableTags;
  final String? activePendingTag;
  final bool isPendingStatic;
  final Function(String) onSelectTagToStamp;
  final Function(String) onDeleteTag;
  final Function(int oldIndex, int newIndex) onReorderTags;
  final VoidCallback onShowAddCustomTagDialog;
  final VoidCallback onSelectStaticToStamp;
  final VoidCallback onSelectEmptyTagToStamp;

  const PdfEditorTagsBarUi({
    super.key,
    required this.titleController,
    required this.loadedFileName,
    required this.onPickPdf,
    required this.onScanCamera,
    required this.availableTags,
    this.activePendingTag,
    this.isPendingStatic = false,
    required this.onSelectTagToStamp,
    required this.onDeleteTag,
    required this.onReorderTags,
    required this.onShowAddCustomTagDialog,
    required this.onSelectStaticToStamp,
    required this.onSelectEmptyTagToStamp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                flex: 4,
                child: TextField(
                  controller: titleController,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    labelText: 'ٹیمپلیٹ کا عنوان',
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // پی ڈی ایف چننے کا بٹن
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: onPickPdf,
                  icon: const Icon(Icons.picture_as_pdf, size: 15),
                  label: Text(
                    loadedFileName ?? 'انوائس PDF',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // کیمرہ سکینر کا نیا بٹن
              InkWell(
                onTap: onScanCamera,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryEmerald,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.document_scanner, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'سکین',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: onSelectStaticToStamp,
                  icon: const Icon(Icons.text_fields, size: 14),
                  label: Text(
                    isPendingStatic ? 'تحریر (کلک کریں)' : 'تحریر لکھیں',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPendingStatic ? Colors.orange.shade800 : Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                ),
                const SizedBox(width: 6),
                ElevatedButton.icon(
                  onPressed: onSelectEmptyTagToStamp,
                  icon: const Icon(Icons.data_object, size: 14),
                  label: Text(
                    activePendingTag == '__empty_tag__' ? 'خالی ٹیگ (کلک کریں)' : 'خالی ٹیگ {{ }}',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activePendingTag == '__empty_tag__' ? Colors.orange.shade800 : Colors.indigo.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                ),
                const SizedBox(width: 6),
                ElevatedButton.icon(
                  onPressed: onShowAddCustomTagDialog,
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('نیا ٹیگ', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryEmerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                ),
                const SizedBox(width: 8),
                Container(height: 20, width: 1, color: Colors.grey.shade300),
                const SizedBox(width: 6),
                const Text(
                  'ٹیگ منتخب کریں:',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.blueGrey),
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
              onReorderItem: onReorderTags,
              children: [
                for (int index = 0; index < availableTags.length; index++)
                  ReorderableDelayedDragStartListener(
                    key: ValueKey(availableTags[index]),
                    index: index,
                    child: Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: activePendingTag == availableTags[index]
                            ? AppColors.primaryEmerald.withAlpha(40)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: activePendingTag == availableTags[index]
                              ? AppColors.primaryEmerald
                              : const Color(0xFFCBD5E1),
                          width: activePendingTag == availableTags[index] ? 1.8 : 1.1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ReorderableDragStartListener(
                            index: index,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2),
                              child: Icon(Icons.drag_indicator, size: 15, color: Color(0xFF94A3B8)),
                            ),
                          ),
                          const SizedBox(width: 2),
                          InkWell(
                            onTap: () => onSelectTagToStamp(availableTags[index]),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                availableTags[index],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: activePendingTag == availableTags[index]
                                      ? AppColors.primaryEmerald
                                      : const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () => onDeleteTag(availableTags[index]),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Icon(Icons.close, size: 13, color: Colors.red.shade600),
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