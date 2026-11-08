import 'package:flutter/material.dart';

class PlainDocHeaderToolbarUi extends StatelessWidget {
  final TextEditingController titleController;
  final double fontSize;
  final Function(double) onFontSizeChanged;

  const PlainDocHeaderToolbarUi({
    super.key,
    required this.titleController,
    required this.fontSize,
    required this.onFontSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          SizedBox(
            width: 220,
            child: TextField(
              controller: titleController,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                labelText: 'رسید / دستاویز کا نام',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => onFontSizeChanged(fontSize - 0.5),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.remove, size: 16, color: Colors.teal),
                  ),
                ),
                Text(
                  '$fontSize pt',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: () => onFontSizeChanged(fontSize + 0.5),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.add, size: 16, color: Colors.teal),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          const Text(
            'کاغذ کا سائز: A4 (8.27 x 11.69 انچ)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}