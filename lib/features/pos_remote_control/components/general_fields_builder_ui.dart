import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../services/pos_remote_config_service.dart';

class GeneralFieldsBuilderUi extends StatelessWidget {
  final FieldDefList fields;
  final ValueChanged<String> onAddField;
  final void Function(int index, String newLabel) onRenameField;
  final ValueChanged<int> onRemoveField;

  const GeneralFieldsBuilderUi({
    super.key,
    required this.fields,
    required this.onAddField,
    required this.onRenameField,
    required this.onRemoveField,
  });

  void _showFieldDialog(
    BuildContext context, {
    int? editIndex,
    String initialText = '',
  }) {
    final ctrl = TextEditingController(text: initialText);
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            editIndex == null
                ? 'نئی جنرل فیلڈ شامل کریں'
                : 'فیلڈ کا نام تبدیل کریں',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              labelText: 'فیلڈ کی ہیڈنگ (اردو یا انگلش)',
              hintText: 'مثلاً: چیسز نمبر، سائز، کمپریسر وارنٹی',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('منسوخ'),
            ),
            ElevatedButton(
              onPressed: () {
                final val = ctrl.text.trim();
                if (val.isNotEmpty) {
                  if (editIndex == null) {
                    onAddField(val);
                  } else {
                    onRenameField(editIndex, val);
                  }
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryEmerald,
                foregroundColor: Colors.white,
              ),
              child: const Text('محفوظ کریں'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryEmerald.withAlpha(110),
          width: 1.3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.dynamic_form_outlined,
                  color: AppColors.primaryEmerald, size: 20),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'جنرل اشیاء کی ڈائنامک فیلڈز (کارڈ و معاہدے کیلئے):',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: fields.length >= 8
                    ? null
                    : () => _showFieldDialog(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('نئی فیلڈ', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryEmerald,
                  foregroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'یہ فیلڈز جنرل اسٹاک انٹری، POS کارڈ بیجز اور ایگریمنٹ ٹیگز بینک میں خودکار ظاہر ہوں گی:',
            style: TextStyle(fontSize: 11.5, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          ...List.generate(fields.length, (i) {
            final item = fields[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.primaryEmerald,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item['urduLabel'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        size: 18, color: AppColors.primaryEmerald),
                    tooltip: 'ہیڈنگ تبدیل کریں',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _showFieldDialog(
                      context,
                      editIndex: i,
                      initialText: item['urduLabel'] ?? '',
                    ),
                  ),
                  if (fields.length > 1)
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 18, color: AppColors.errorRed),
                      tooltip: 'حذف کریں',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => onRemoveField(i),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}