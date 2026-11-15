import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../../core/models/tag_bank_item_model.dart';
import '../../../core/services/tags_bank_service.dart';
import '../../../core/time/time_status_service.dart';

class PdfEditorTagsBarUi extends StatelessWidget {
  final TextEditingController titleController;
  final String? loadedFileName;
  final VoidCallback onPickPdf;
  final VoidCallback onScanCamera;
  final String? activePendingTag;
  final bool isPendingStatic;
  final Function(String) onSelectTagToStamp;
  final VoidCallback onSelectStaticToStamp;
  final VoidCallback onSelectEmptyTagToStamp;

  const PdfEditorTagsBarUi({
    super.key,
    required this.titleController,
    required this.loadedFileName,
    required this.onPickPdf,
    required this.onScanCamera,
    this.activePendingTag,
    this.isPendingStatic = false,
    required this.onSelectTagToStamp,
    required this.onSelectStaticToStamp,
    required this.onSelectEmptyTagToStamp,
  });

  void _showAddCustomTagDialog(BuildContext context) {
    final textCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'نیا کسٹم / واٹس ایپ ٹیگ شامل کریں',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: TextField(
            controller: textCtrl,
            autofocus: true,
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              hintText: 'مثلاً: والد کا نام یا گواہ کا فون',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('منسوخ'),
            ),
            ElevatedButton(
              onPressed: () async {
                final clean = textCtrl.text
                    .replaceAll('{{', '')
                    .replaceAll('}}', '')
                    .trim();
                if (clean.isNotEmpty) {
                  final id = 'cst_${DateTime.now().millisecondsSinceEpoch}';
                  await TagsBankService.saveTagItem(
                    TagBankItemModel(
                      id: id,
                      urduName: clean,
                      source: TagSourceType.custom,
                      isEnabled: true,
                      isSynced: false,
                      updatedAt: TimeStatusService.nowUtcIso(),
                    ),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  onSelectTagToStamp('{{$clean}}');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryEmerald,
                foregroundColor: Colors.white,
              ),
              child: const Text('شامل کریں'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCustomTag(TagBankItemModel item) async {
    await TagsBankService.saveTagItem(
      TagBankItemModel(
        id: item.id,
        urduName: item.urduName,
        source: item.source,
        rawKey: item.rawKey,
        isEnabled: false,
        valueTranslations: item.valueTranslations,
        isSynced: false,
        updatedAt: TimeStatusService.nowUtcIso(),
        isDeleted: true,
      ),
    );
  }

  Widget _buildTagChip(TagBankItemModel item, int index) {
    final String fullTag = '{{${item.urduName}}}';
    final bool isSelected = activePendingTag == fullTag;
    final bool isPos = item.source == TagSourceType.pos;

    final Color baseColor =
        isPos ? Colors.blue.shade800 : AppColors.primaryEmerald;
    final Color bgColor = isSelected
        ? baseColor.withAlpha(45)
        : (isPos ? Colors.blue.shade50 : const Color(0xFFF0FDF4));
    final Color borderColor = isSelected
        ? baseColor
        : (isPos ? Colors.blue.shade300 : const Color(0xFF86EFAC));

    return ReorderableDelayedDragStartListener(
      key: ValueKey(item.id),
      index: index,
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.8 : 1.1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ReorderableDragStartListener(
              index: index,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  Icons.drag_indicator,
                  size: 15,
                  color: isPos ? Colors.blue.shade400 : const Color(0xFF94A3B8),
                ),
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              isPos ? Icons.point_of_sale_rounded : Icons.label_outline,
              size: 13,
              color: baseColor,
            ),
            const SizedBox(width: 3),
            InkWell(
              onTap: () => onSelectTagToStamp(fullTag),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Text(
                  fullTag,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: baseColor,
                  ),
                ),
              ),
            ),
            if (!isPos) ...[
              const SizedBox(width: 3),
              InkWell(
                onTap: () => _deleteCustomTag(item),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child:
                      Icon(Icons.close, size: 13, color: Colors.red.shade600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

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
                  onPressed: () => _showAddCustomTagDialog(context),
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
                  'نیلا: POS | سبز: کسٹم (ڈریگ سے ترتیب بدلیں)',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ValueListenableBuilder(
            valueListenable: HiveBoxManager.listenToBox(BoxNames.tagsBox),
            builder: (context, box, _) {
              final allTags = TagsBankService.getAllActiveTags();
              return SizedBox(
                height: 36,
                child: ReorderableListView(
                  scrollDirection: Axis.horizontal,
                  buildDefaultDragHandles: false,
                  onReorderItem: (int oldIndex, int newIndex) async {
                    final updatedList = List<TagBankItemModel>.from(allTags);
                    final item = updatedList.removeAt(oldIndex);
                    updatedList.insert(newIndex, item);
                    await TagsBankService.saveReorderedTags(updatedList);
                  },
                  children: [
                    for (int i = 0; i < allTags.length; i++)
                      _buildTagChip(allTags[i], i),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}