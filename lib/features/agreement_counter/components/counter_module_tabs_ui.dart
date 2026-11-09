import 'package:flutter/material.dart';

class CounterModuleTabsUi extends StatelessWidget {
  final VoidCallback onOpenStampStudio;

  const CounterModuleTabsUi({
    super.key,
    required this.onOpenStampStudio,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.edit_document, size: 20),
              label: const Text(
                'ای-اسٹامپ پیپر اسٹوڈیو',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: onOpenStampStudio,
            ),
          ),
        ],
      ),
    );
  }
}