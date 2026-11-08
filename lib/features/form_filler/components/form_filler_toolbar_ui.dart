import 'package:flutter/material.dart';

class FormFillerToolbarUi extends StatelessWidget {
  final TextEditingController titleController;
  final String? loadedFileName;
  final VoidCallback onPickFile;

  const FormFillerToolbarUi({
    super.key,
    required this.titleController,
    required this.loadedFileName,
    required this.onPickFile,
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
                labelText: 'فارم کا نام',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: onPickFile,
            icon: const Icon(Icons.upload_file, size: 16),
            label: Text(loadedFileName ?? 'فارم PDF / تصویر منتخب کریں'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade700,
              foregroundColor: Colors.white,
            ),
          ),
          const Spacer(),
          const Text(
            'ماڈیول: پوزیشن مارکر',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}