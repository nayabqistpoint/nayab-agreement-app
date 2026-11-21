import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../pos_control_panel/components/pos_stock_photo_picker_ui.dart';

class SplittablePhotoPickerUi extends StatelessWidget {
  final List<String> sharedImages;
  final ValueChanged<List<String>> onSharedImagesChanged;
  final int quantity;
  final List<String> upcomingStockIds;
  final bool isSplitActive;
  final List<List<String>> perUnitImages;
  final VoidCallback onToggleSplit;
  final void Function(int index, List<String> imgs) onUnitImagesChanged;

  const SplittablePhotoPickerUi({
    super.key,
    required this.sharedImages,
    required this.onSharedImagesChanged,
    required this.quantity,
    required this.upcomingStockIds,
    required this.isSplitActive,
    required this.perUnitImages,
    required this.onToggleSplit,
    required this.onUnitImagesChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (quantity <= 1) {
      return PosStockPhotoPickerUi(
        imagePaths: sharedImages,
        onImagesChanged: onSharedImagesChanged,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: isSplitActive
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 13,
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
                        '📷 پراڈکٹ تصاویر ($quantity یونٹس کیلئے الگ الگ):',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryEmerald,
                        ),
                      ),
                    )
                  : PosStockPhotoPickerUi(
                      imagePaths: sharedImages,
                      onImagesChanged: onSharedImagesChanged,
                    ),
            ),
            const SizedBox(width: 6),
            Tooltip(
              message: isSplitActive
                  ? 'سب یونٹس کیلئے ایک ہی تصاویر رکھیں'
                  : '$quantity یونٹس کیلئے الگ الگ تصاویر لگائیں',
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
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.emeraldPillBorder,
                width: 1.2,
              ),
            ),
            child: Column(
              children: List.generate(perUnitImages.length, (idx) {
                final stkId = idx < upcomingStockIds.length
                    ? upcomingStockIds[idx]
                    : 'STK_${idx + 1}';
                final imgs = perUnitImages[idx];
                final bool hasNext = idx < perUnitImages.length - 1;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: idx == perUnitImages.length - 1 ? 0 : 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryEmerald,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$stkId کی تصاویر',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (hasNext && imgs.isNotEmpty) ...[
                            InkWell(
                              onTap: () => onUnitImagesChanged(
                                idx + 1,
                                List<String>.from(imgs),
                              ),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warmTintEmerald,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.emeraldPillBorder,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.arrow_downward_rounded,
                                  size: 15,
                                  color: AppColors.primaryEmerald,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            InkWell(
                              onTap: () {
                                for (int j = idx + 1;
                                    j < perUnitImages.length;
                                    j++) {
                                  onUnitImagesChanged(
                                    j,
                                    List<String>.from(imgs),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warmSubtleSurface,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.borderLight,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.keyboard_double_arrow_down_rounded,
                                  size: 15,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                      PosStockPhotoPickerUi(
                        imagePaths: imgs,
                        onImagesChanged: (updated) =>
                            onUnitImagesChanged(idx, updated),
                      ),
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