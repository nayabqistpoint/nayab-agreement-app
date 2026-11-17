import 'dart:convert';
import 'package:flutter/material.dart';

class CustomerMediaViewerModalUi extends StatelessWidget {
  final String title;
  final String imagePath;

  const CustomerMediaViewerModalUi({
    super.key,
    required this.title,
    required this.imagePath,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String imagePath,
  }) {
    showDialog(
      context: context,
      builder: (_) =>
          CustomerMediaViewerModalUi(title: title, imagePath: imagePath),
    );
  }

  Widget _buildImage() {
    if (imagePath.startsWith('data:image')) {
      try {
        final commaIdx = imagePath.indexOf(',');
        final bytes = base64Decode(imagePath.substring(commaIdx + 1));
        return Image.memory(bytes, fit: BoxFit.contain);
      } catch (_) {
        return const Text(
          'تصویر پڑھنے میں مسئلہ پیش آیا',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        );
      }
    }
    return Image.network(
      imagePath,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const Text(
        'تصویر فائل دستیاب نہیں ہے',
        style: TextStyle(color: Colors.white70, fontSize: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: _buildImage(),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.black54,
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}