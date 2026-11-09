import 'package:flutter/material.dart';

class StampEditingToolbarUi extends StatelessWidget {
  final VoidCallback onAlignRight;
  final VoidCallback onAlignCenter;
  final VoidCallback onAlignLeft;
  final VoidCallback onInsertBullet;

  const StampEditingToolbarUi({
    super.key,
    required this.onAlignRight,
    required this.onAlignCenter,
    required this.onAlignLeft,
    required this.onInsertBullet,
  });

  Widget _buildButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 17, color: color ?? Colors.blueGrey.shade800),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'الائنمنٹ:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ),
            _buildButton(
              icon: Icons.format_align_right,
              tooltip: 'دائیں طرف (عام اردو)',
              onTap: onAlignRight,
            ),
            _buildButton(
              icon: Icons.format_align_center,
              tooltip: 'درمیان میں (سینٹر)',
              onTap: onAlignCenter,
            ),
            _buildButton(
              icon: Icons.format_align_left,
              tooltip: 'بائیں طرف (دستخط/تاریخ)',
              onTap: onAlignLeft,
            ),
            const SizedBox(width: 8),
            Container(height: 18, width: 1, color: Colors.grey.shade300),
            const SizedBox(width: 8),
            _buildButton(
              icon: Icons.stars_rounded,
              tooltip: 'شرائط کیلئے سٹار بلٹ پوائنٹ (❖)',
              onTap: onInsertBullet,
              color: Colors.amber.shade900,
            ),
          ],
        ),
      ),
    );
  }
}