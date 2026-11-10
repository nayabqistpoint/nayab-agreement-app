import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CounterTemplateSelectorUi extends StatelessWidget {
  final String selectedTitle;
  final List<String> availableTemplates;
  final Function(String) onTemplateChanged;
  final VoidCallback onOpenEditor;
  final Function(String) onDeleteTemplate;

  const CounterTemplateSelectorUi({
    super.key,
    required this.selectedTitle,
    required this.availableTemplates,
    required this.onTemplateChanged,
    required this.onOpenEditor,
    required this.onDeleteTemplate,
  });

  void _confirmAndDelete(BuildContext context, String titleToDelete) {
    if (titleToDelete.trim().isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'ٹیمپلیٹ ڈیلیٹ کریں؟',
            style: TextStyle(fontFamily: 'JameelNoori', fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'کیا آپ واقعی "$titleToDelete" کو ہمیشہ کے لیے ڈیلیٹ کرنا چاہتے ہیں؟',
            style: const TextStyle(fontFamily: 'JameelNoori', fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('منسوخ کریں', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                onDeleteTemplate(titleToDelete);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
              child: const Text('ڈیلیٹ کریں', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = availableTemplates.contains(selectedTitle);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: hasSelection ? selectedTitle : null,
                hint: const Text(
                  'ٹیمپلیٹ منتخب کریں',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
                items: availableTemplates.map((t) {
                  return DropdownMenuItem<String>(
                    value: t,
                    child: Text(
                      t,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) onTemplateChanged(val);
                },
              ),
            ),
          ),
          const SizedBox(width: 6),
          // ایڈیٹ بٹن
          InkWell(
            onTap: onOpenEditor,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryEmerald.withAlpha(25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.edit_note, size: 20, color: AppColors.primaryEmerald),
            ),
          ),
          const SizedBox(width: 6),
          // ڈیلیٹ بٹن
          InkWell(
            onTap: hasSelection ? () => _confirmAndDelete(context, selectedTitle) : null,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: hasSelection ? Colors.red.withAlpha(25) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.delete_outline,
                size: 20,
                color: hasSelection ? Colors.red.shade700 : Colors.grey.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}