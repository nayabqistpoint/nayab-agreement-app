import 'package:flutter/material.dart';

class StampTagsToolbarUi extends StatelessWidget {
  final List<String> pinnedTags;
  final Function(String) onInsertFormatting;
  final Function(int) onInsertSpacer;
  final VoidCallback onShowAddCustomTag;
  final Function(String) onInsertTag;

  const StampTagsToolbarUi({
    super.key,
    required this.pinnedTags,
    required this.onInsertFormatting,
    required this.onInsertSpacer,
    required this.onShowAddCustomTag,
    required this.onInsertTag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Colors.grey.shade200,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.format_bold, size: 18),
              tooltip: 'بولڈ',
              onPressed: () => onInsertFormatting('B'),
            ),
            IconButton(
              icon: const Icon(Icons.format_underlined, size: 18),
              tooltip: 'انڈر لائن',
              onPressed: () => onInsertFormatting('U'),
            ),
            const SizedBox(width: 6),
            ElevatedButton.icon(
              onPressed: () => onInsertSpacer(72),
              icon: const Icon(Icons.space_bar, size: 14),
              label: const Text('1 انچ جگہ', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            ElevatedButton.icon(
              onPressed: () => onInsertSpacer(36),
              icon: const Icon(Icons.space_bar, size: 14),
              label: const Text('آدھا انچ جگہ', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onShowAddCustomTag,
              icon: const Icon(Icons.add, size: 14),
              label: const Text('+ نیا ٹیگ', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade800,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            ...pinnedTags.map(
              (tag) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: ActionChip(
                  label: Text(tag, style: const TextStyle(fontSize: 11)),
                  backgroundColor: Colors.white,
                  onPressed: () => onInsertTag(tag),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}