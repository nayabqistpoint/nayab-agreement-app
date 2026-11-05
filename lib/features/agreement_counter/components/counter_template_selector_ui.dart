import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CounterTemplateSelectorUi extends StatelessWidget {
  final String selectedTitle;
  final List<String> availableTemplates;
  final Function(String) onTemplateChanged;
  final VoidCallback onEditTemplate;

  const CounterTemplateSelectorUi({
    super.key,
    required this.selectedTitle,
    required this.availableTemplates,
    required this.onTemplateChanged,
    required this.onEditTemplate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: availableTemplates.contains(selectedTitle) ? selectedTitle : null,
                isExpanded: true,
                hint: const Text('معاہدہ منتخب کریں', style: TextStyle(fontSize: 15)),
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryEmerald),
                items: availableTemplates.map((title) {
                  return DropdownMenuItem<String>(
                    value: title,
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) onTemplateChanged(val);
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_note, color: AppColors.primaryEmerald, size: 24),
            tooltip: 'معاہدہ ایڈیٹ کریں / تحریر دیکھیں',
            onPressed: onEditTemplate,
          ),
        ],
      ),
    );
  }
}