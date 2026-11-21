import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../pos_remote_control/services/pos_remote_config_service.dart';

class DynamicStockFieldsCardUi extends StatelessWidget {
  final FieldDefList fieldDefs;
  final Map<String, TextEditingController> controllers;
  final int quantity;
  final List<String> upcomingStockIds;
  final Set<String> activeSplitKeys;
  final Map<String, List<TextEditingController>> splitControllersMap;
  final ValueChanged<String> onToggleSplit;
  final ValueChanged<String> onAddField;
  final ValueChanged<int> onRemoveField;

  const DynamicStockFieldsCardUi({
    super.key,
    required this.fieldDefs,
    required this.controllers,
    required this.quantity,
    required this.upcomingStockIds,
    required this.activeSplitKeys,
    required this.splitControllersMap,
    required this.onToggleSplit,
    required this.onAddField,
    required this.onRemoveField,
  });

  void _showAddFieldDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'نئی ڈائنامک فیلڈ شامل کریں',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
          ),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            decoration: const InputDecoration(
              labelText: 'فیلڈ کا نام (اردو یا انگلش)',
              hintText: 'مثلاً: چارجر، ڈبہ حالت، انجن نمبر، PTA اسٹیٹس',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('منسوخ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final val = ctrl.text.trim();
                if (val.isNotEmpty) {
                  onAddField(val);
                }
                Navigator.pop(ctx);
              },
              icon: const Icon(Icons.add, size: 19),
              label: const Text('شامل کریں',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryEmerald,
                foregroundColor: Colors.white,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.warmTintEmerald,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: AppColors.emeraldPillBorder,
          width: 1.3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.dynamic_form_rounded,
                color: AppColors.primaryEmerald,
                size: 21,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'ڈائنامک فیلڈز (اختیاری):',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: AppColors.primaryEmerald,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: fieldDefs.length >= 10
                    ? null
                    : () => _showAddFieldDialog(context),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text(
                  'نئی فیلڈ',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryEmerald,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          if (fieldDefs.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...List.generate(fieldDefs.length, (i) {
              final def = fieldDefs[i];
              final key = def['key']!;
              final label = def['urduLabel']!;
              final ctrl = controllers[key];
              final isSplit = activeSplitKeys.contains(key);
              final unitCtrls = splitControllersMap[key] ?? const [];

              return Padding(
                padding: EdgeInsets.only(
                  bottom: i == fieldDefs.length - 1 ? 0 : 9,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: isSplit
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.primaryEmerald,
                                      width: 1.4,
                                    ),
                                  ),
                                  child: Text(
                                    '$label ($quantity یونٹس):',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryEmerald,
                                    ),
                                  ),
                                )
                              : TextField(
                                  controller: ctrl,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15.5,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: label,
                                    labelStyle: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textDark,
                                    ),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                        ),
                        if (quantity > 1) ...[
                          const SizedBox(width: 5),
                          Tooltip(
                            message: isSplit
                                ? 'سب یونٹس کیلئے ایک ہی ویلیو رکھیں'
                                : '$quantity یونٹس میں الگ الگ تقسیم کریں',
                            child: InkWell(
                              onTap: () => onToggleSplit(key),
                              borderRadius: BorderRadius.circular(9),
                              child: Container(
                                width: 42,
                                height: 46,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSplit
                                      ? AppColors.primaryEmerald
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(
                                    color: AppColors.primaryEmerald,
                                    width: 1.4,
                                  ),
                                ),
                                child: Icon(
                                  Icons.call_split_rounded,
                                  size: 20,
                                  color: isSplit
                                      ? Colors.white
                                      : AppColors.primaryEmerald,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 5),
                        Tooltip(
                          message: 'یہ فیلڈ حذف کریں',
                          child: InkWell(
                            onTap: () => onRemoveField(i),
                            borderRadius: BorderRadius.circular(9),
                            child: Container(
                              width: 42,
                              height: 46,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(
                                  color:
                                      AppColors.errorRed.withValues(alpha: 0.5),
                                ),
                              ),
                              child: const Icon(
                                Icons.remove_circle_outline,
                                size: 20,
                                color: AppColors.errorRed,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (quantity > 1 && isSplit) ...[
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primaryEmerald,
                            width: 1.3,
                          ),
                        ),
                        child: Column(
                          children: List.generate(unitCtrls.length, (idx) {
                            final stkId = idx < upcomingStockIds.length
                                ? upcomingStockIds[idx]
                                : 'STK_${idx + 1}';
                            final uCtrl = unitCtrls[idx];
                            final bool hasNext = idx < unitCtrls.length - 1;
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: idx == unitCtrls.length - 1 ? 0 : 7,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryEmerald,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      stkId,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: TextField(
                                      controller: uCtrl,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                      ),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        hintText: '$label ($stkId)',
                                        hintStyle: const TextStyle(
                                          fontSize: 12.5,
                                          color: Colors.black38,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 11,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFFF8FAFC),
                                      ),
                                    ),
                                  ),
                                  if (hasNext) ...[
                                    const SizedBox(width: 4),
                                    InkWell(
                                      onTap: () {
                                        unitCtrls[idx + 1].text = uCtrl.text;
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.all(8.5),
                                        decoration: BoxDecoration(
                                          color: AppColors.warmTintEmerald,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color:
                                                AppColors.emeraldPillBorder,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_downward_rounded,
                                          size: 18,
                                          color: AppColors.primaryEmerald,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    InkWell(
                                      onTap: () {
                                        for (int j = idx + 1;
                                            j < unitCtrls.length;
                                            j++) {
                                          unitCtrls[j].text = uCtrl.text;
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.all(8.5),
                                        decoration: BoxDecoration(
                                          color: AppColors.warmSubtleSurface,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: AppColors.borderLight,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons
                                              .keyboard_double_arrow_down_rounded,
                                          size: 18,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}