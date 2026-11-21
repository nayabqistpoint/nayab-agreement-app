import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SplittableDropdownWrapperUi<T> extends StatelessWidget {
  final Widget singleDropdownChild;
  final int quantity;
  final List<String> upcomingStockIds;
  final String fieldLabel;
  final bool isSplitActive;
  final List<T> perUnitValues;
  final List<DropdownMenuItem<T>> items;
  final VoidCallback onToggleSplit;
  final void Function(int index, T newValue) onUnitValueChanged;

  const SplittableDropdownWrapperUi({
    super.key,
    required this.singleDropdownChild,
    required this.quantity,
    required this.upcomingStockIds,
    required this.fieldLabel,
    required this.isSplitActive,
    required this.perUnitValues,
    required this.items,
    required this.onToggleSplit,
    required this.onUnitValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (quantity <= 1) {
      return singleDropdownChild;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: isSplitActive
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warmTintEmerald,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primaryEmerald,
                          width: 1.3,
                        ),
                      ),
                      child: Text(
                        '$fieldLabel ($quantity یونٹس):',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryEmerald,
                        ),
                      ),
                    )
                  : singleDropdownChild,
            ),
            const SizedBox(width: 6),
            Tooltip(
              message: isSplitActive
                  ? 'سب یونٹس کیلئے ایک ہی انتخاب رکھیں'
                  : '$quantity یونٹس میں الگ الگ تقسیم کریں',
              child: InkWell(
                onTap: onToggleSplit,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 44,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSplitActive
                        ? AppColors.primaryEmerald
                        : AppColors.warmSubtleSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSplitActive
                          ? AppColors.primaryEmerald
                          : AppColors.borderLight,
                      width: 1.4,
                    ),
                  ),
                  child: Icon(
                    Icons.call_split_rounded,
                    size: 21,
                    color: isSplitActive
                        ? Colors.white
                        : AppColors.primaryEmerald,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (isSplitActive) ...[
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.emeraldPillBorder,
                width: 1.2,
              ),
            ),
            child: Column(
              children: List.generate(perUnitValues.length, (idx) {
                final stkId = idx < upcomingStockIds.length
                    ? upcomingStockIds[idx]
                    : 'STK_${idx + 1}';
                final currentVal = perUnitValues[idx];
                final bool hasNext = idx < perUnitValues.length - 1;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: idx == perUnitValues.length - 1 ? 0 : 7,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryEmerald,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          stkId,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: DropdownButtonFormField<T>(
                          key: ValueKey(
                              'split_dd_${fieldLabel}_${idx}_$currentVal'),
                          initialValue: currentVal,
                          isExpanded: true,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 9,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: items,
                          onChanged: (v) {
                            if (v != null) {
                              onUnitValueChanged(idx, v);
                            }
                          },
                        ),
                      ),
                      if (hasNext) ...[
                        const SizedBox(width: 4),
                        Tooltip(
                          message: 'اگلے یونٹ میں کاپی کریں',
                          child: InkWell(
                            onTap: () =>
                                onUnitValueChanged(idx + 1, currentVal),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(8.5),
                              decoration: BoxDecoration(
                                color: AppColors.warmTintEmerald,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.emeraldPillBorder,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_downward_rounded,
                                size: 17,
                                color: AppColors.primaryEmerald,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Tooltip(
                          message: 'نیچے تمام یونٹس میں بھریں',
                          child: InkWell(
                            onTap: () {
                              for (int j = idx + 1;
                                  j < perUnitValues.length;
                                  j++) {
                                onUnitValueChanged(j, currentVal);
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(8.5),
                              decoration: BoxDecoration(
                                color: AppColors.warmSubtleSurface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.borderLight,
                                ),
                              ),
                              child: const Icon(
                                Icons.keyboard_double_arrow_down_rounded,
                                size: 17,
                                color: AppColors.textDark,
                              ),
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
    );
  }
}