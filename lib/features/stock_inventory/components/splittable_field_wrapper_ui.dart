import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/qr_scanner.dart';

class SplittableFieldWrapperUi extends StatelessWidget {
  final Widget singleFieldChild;
  final int quantity;
  final List<String> upcomingStockIds;
  final String fieldLabel;
  final bool isSplitActive;
  final bool forceSplit;
  final List<TextEditingController> perUnitControllers;
  final List<FocusNode>? perUnitFocusNodes;
  final Set<int> invalidUnitIndexes;
  final VoidCallback onToggleSplit;
  final bool enableScanner;
  final bool allowCopyDown;
  final TextInputType keyboardType;
  final TextAlign textAlign;

  const SplittableFieldWrapperUi({
    super.key,
    required this.singleFieldChild,
    required this.quantity,
    required this.upcomingStockIds,
    required this.fieldLabel,
    required this.isSplitActive,
    this.forceSplit = false,
    required this.perUnitControllers,
    this.perUnitFocusNodes,
    this.invalidUnitIndexes = const {},
    required this.onToggleSplit,
    this.enableScanner = false,
    this.allowCopyDown = true,
    this.keyboardType = TextInputType.text,
    this.textAlign = TextAlign.right,
  });

  Future<void> _scanInto(
    BuildContext context,
    TextEditingController ctrl,
    String stkId,
  ) async {
    final res = await QrScanner.scan(
      context,
      title: '$stkId — $fieldLabel اسکین کریں',
    );
    if (res != null && res.trim().isNotEmpty) {
      ctrl.text = res.trim();
    }
  }

  void _copyToNext(int index) {
    if (index + 1 >= perUnitControllers.length) return;
    perUnitControllers[index + 1].text = perUnitControllers[index].text;
  }

  void _fillAllBelow(int index) {
    final val = perUnitControllers[index].text;
    for (int j = index + 1; j < perUnitControllers.length; j++) {
      perUnitControllers[j].text = val;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (quantity <= 1) {
      return singleFieldChild;
    }

    final bool effectiveSplit = forceSplit || isSplitActive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: effectiveSplit
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: invalidUnitIndexes.isNotEmpty
                            ? const Color(0xFFFEF2F2)
                            : AppColors.warmTintEmerald,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: invalidUnitIndexes.isNotEmpty
                              ? AppColors.errorRed
                              : AppColors.primaryEmerald,
                          width: 1.4,
                        ),
                      ),
                      child: Text(
                        forceSplit
                            ? '$fieldLabel (ہر $quantity موبائل کا الگ لازمی):'
                            : '$fieldLabel ($quantity یونٹس):',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: invalidUnitIndexes.isNotEmpty
                              ? AppColors.errorRed
                              : AppColors.primaryEmerald,
                        ),
                      ),
                    )
                  : singleFieldChild,
            ),
            if (!forceSplit) ...[
              const SizedBox(width: 6),
              Tooltip(
                message: isSplitActive
                    ? 'سب یونٹس کیلئے ایک ہی ویلیو رکھیں'
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
          ],
        ),
        if (effectiveSplit) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: invalidUnitIndexes.isNotEmpty
                    ? AppColors.errorRed
                    : AppColors.emeraldPillBorder,
                width: 1.3,
              ),
            ),
            child: Column(
              children: List.generate(perUnitControllers.length, (idx) {
                final stkId = idx < upcomingStockIds.length
                    ? upcomingStockIds[idx]
                    : 'STK_${idx + 1}';
                final ctrl = perUnitControllers[idx];
                final fNode = (perUnitFocusNodes != null &&
                        idx < perUnitFocusNodes!.length)
                    ? perUnitFocusNodes![idx]
                    : null;
                final bool isInvalid = invalidUnitIndexes.contains(idx);
                final bool hasNext = idx < perUnitControllers.length - 1;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: idx == perUnitControllers.length - 1 ? 0 : 7,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: isInvalid
                              ? AppColors.errorRed
                              : AppColors.primaryEmerald,
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
                        child: TextField(
                          controller: ctrl,
                          focusNode: fNode,
                          keyboardType: keyboardType,
                          textAlign: textAlign,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: isInvalid
                                ? AppColors.errorRed
                                : AppColors.textDark,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: isInvalid
                                ? '⚠️ منفرد $fieldLabel درج کریں'
                                : '$fieldLabel ($stkId)',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: isInvalid
                                  ? AppColors.errorRed
                                  : Colors.black38,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: isInvalid
                                    ? AppColors.errorRed
                                    : const Color(0xFFCBD5E1),
                                width: isInvalid ? 1.8 : 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: isInvalid
                                    ? AppColors.errorRed
                                    : AppColors.primaryEmerald,
                                width: 2.0,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: isInvalid
                                ? const Color(0xFFFEF2F2)
                                : Colors.white,
                          ),
                        ),
                      ),
                      if (enableScanner) ...[
                        const SizedBox(width: 4),
                        Tooltip(
                          message: 'اسکین کریں',
                          child: InkWell(
                            onTap: () => _scanInto(context, ctrl, stkId),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(8.5),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade800,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.qr_code_scanner,
                                size: 17,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (allowCopyDown && hasNext) ...[
                        const SizedBox(width: 4),
                        Tooltip(
                          message: 'اگلے یونٹ میں کاپی کریں',
                          child: InkWell(
                            onTap: () => _copyToNext(idx),
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
                            onTap: () => _fillAllBelow(idx),
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