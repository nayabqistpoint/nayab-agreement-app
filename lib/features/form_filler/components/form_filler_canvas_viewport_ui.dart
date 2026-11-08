import 'package:flutter/material.dart';
import '../form_filler_controller.dart';

class FormFillerCanvasViewportUi extends StatelessWidget {
  final FormFillerController controller;

  const FormFillerCanvasViewportUi({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.renderedPages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf_outlined, size: 70, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'کوئی فارم منتخب نہیں کیا گیا\nاوپر سے PDF یا اسکین تصویر منتخب کریں',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: List.generate(controller.renderedPages.length, (index) {
            final img = controller.renderedPages[index];
            if (img == null) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
              ),
              child: Image.memory(img, fit: BoxFit.contain),
            );
          }),
        ),
      ),
    );
  }
}