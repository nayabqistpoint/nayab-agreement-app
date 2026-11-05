import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StudioTagToolbarUi extends StatelessWidget {
  final List<String> tags;
  final Function(String) onTagSelected;

  const StudioTagToolbarUi({
    super.key,
    required this.tags,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        border: Border.symmetric(horizontal: BorderSide(color: Colors.grey.shade300)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final tag = tags[index];
          return ActionChip(
            label: Text(tag, style: const TextStyle(fontSize: 13)),
            backgroundColor: Colors.teal.shade50,
            onPressed: () => onTagSelected(tag),
          );
        },
      ),
    );
  }
}