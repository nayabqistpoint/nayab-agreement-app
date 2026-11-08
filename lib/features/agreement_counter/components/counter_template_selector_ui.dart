import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CounterTemplateSelectorUi extends StatelessWidget {
  final String selectedTitle;
  final List<String> availableTemplates;
  final Function(String) onTemplateChanged;
  final VoidCallback onOpenEditor;

  const CounterTemplateSelectorUi({
    super.key,
    required this.selectedTitle,
    required this.availableTemplates,
    required this.onTemplateChanged,
    required this.onOpenEditor,
  });

  @override
  Widget build(BuildContext context) {
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
                value: availableTemplates.contains(selectedTitle) ? selectedTitle : null,
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
        ],
      ),
    );
  }
}