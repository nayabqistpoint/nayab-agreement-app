import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../stamp_agreement/stamp_studio_controller.dart';

class FormFillerStudioPage extends StatefulWidget {
  final String? initialTitle;
  const FormFillerStudioPage({super.key, this.initialTitle});

  @override
  State<FormFillerStudioPage> createState() => _FormFillerStudioPageState();
}

class _FormFillerStudioPageState extends State<FormFillerStudioPage> {
  late final StampStudioController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StampStudioController();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _controller.initFromTemplate(widget.initialTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFE0E0E0),
        appBar: AppBar(
          title: const Text('اسکول و دفتری فارم فلر اسٹوڈیو', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          backgroundColor: Colors.indigo.shade800,
          foregroundColor: Colors.white,
          actions: [
            ElevatedButton.icon(
              onPressed: () async {
                final isSaved = await _controller.saveTemplate();
                if (!context.mounted) return;
                if (isSaved) {
                  Navigator.pop(context, true);
                }
              },
              icon: const Icon(Icons.check, color: Colors.white, size: 18),
              label: const Text('محفوظ کریں', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit_document, size: 60, color: Colors.indigo.shade400),
              const SizedBox(height: 16),
              const Text('فارم فلر ماڈیول کا مقفل اسٹوڈیو چالو ہے', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _controller.pickPdf(),
                icon: const Icon(Icons.upload_file),
                label: Text(_controller.loadedPdfFileName ?? 'اسکول فارم PDF چنیں'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade700, foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}