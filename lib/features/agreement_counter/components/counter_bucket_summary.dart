import 'package:flutter/material.dart';

class CounterBucketSummary extends StatelessWidget {
  final Map<String, String> fieldValues;
  final VoidCallback onOpenBucket;

  const CounterBucketSummary({
    super.key,
    required this.fieldValues,
    required this.onOpenBucket,
  });

  @override
  Widget build(BuildContext context) {
    if (fieldValues.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: Colors.grey.shade100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 16, color: Colors.black54),
            const SizedBox(width: 6),
            ...fieldValues.entries.take(4).map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Chip(
                  label: Text(
                    '${e.key}: ${e.value}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            if (fieldValues.length > 4)
              TextButton(
                onPressed: onOpenBucket,
                child: Text('+ مزید ${fieldValues.length - 4} فیلڈز', style: const TextStyle(fontSize: 11)),
              ),
          ],
        ),
      ),
    );
  }
}