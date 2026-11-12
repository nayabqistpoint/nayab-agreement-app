import 'dart:io';
import 'package:flutter/material.dart';

class CustomerMediaViewerModalUi extends StatelessWidget {
  final String title;
  final String imagePath;

  const CustomerMediaViewerModalUi({
    super.key,
    required this.title,
    required this.imagePath,
  });

  static void show(BuildContext context, {required String title, required String imagePath}) {
    showDialog(
      context: context,
      builder: (_) => CustomerMediaViewerModalUi(title: title, imagePath: imagePath),
    );
  }

  @override
  Widget build(BuildContext context) {
    final file = File(imagePath);
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
                child: file.existsSync()
                    ? Image.file(file, fit: BoxFit.contain)
                    : const Center(
                        child: Text(
                          'تصویر فائل ڈیوائس پر نہیں ملی',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.black54,
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
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