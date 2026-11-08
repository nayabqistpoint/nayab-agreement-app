import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'bucket_view_controller.dart';
import 'components/dynamic_bucket_field_list_ui.dart';
import 'components/whatsapp_dispatcher_card_ui.dart';

class BucketViewPage extends StatefulWidget {
  const BucketViewPage({super.key});

  @override
  State<BucketViewPage> createState() => _BucketViewPageState();
}

class _BucketViewPageState extends State<BucketViewPage> {
  late final BucketViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BucketViewController();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<String, dynamic> _parseQrData(String? raw) {
    if (raw == null || raw.trim().isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return {'raw': raw};
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text(
            'معلومات کی بالٹی (ان پٹ بکٹ)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: AppColors.primaryEmerald,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'تمام ڈیٹا صاف کریں',
              onPressed: () {
                _controller.clearAllFields();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('بالٹی کا تمام ڈیٹا صاف کر دیا گیا ہے')),
                );
              },
            ),
          ],
        ),
        body: _controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    WhatsappDispatcherCardUi(
                      phoneController: _controller.phoneController,
                      onSendQuestions: () => _controller.sendQuestionsOnWhatsapp(),
                      onPasteAnswers: () => _controller.pasteAndParseFromClipboard(),
                    ),
                    const SizedBox(height: 12),
                    DynamicBucketFieldListUi(
                      fields: _controller.fields,
                      controllers: _controller.controllers,
                      qrSourceData: _parseQrData(_controller.qrSourceData),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}