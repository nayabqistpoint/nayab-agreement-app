import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'bucket_view_controller.dart';
import 'components/bucket_customer_block_ui.dart';
import 'components/bucket_stats_header_ui.dart';
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
    final int total = _controller.fields.length;
    final int filled = _controller.fields.where((f) => (_controller.controllers[f]?.text.trim() ?? '').isNotEmpty).length;
    final int missing = total > filled ? (total - filled) : 0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text(
            'معلومات کی بالٹی (ڈیٹا بکٹ)',
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
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryEmerald))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    BucketStatsHeaderUi(
                      totalCount: total,
                      filledCount: filled,
                      missingCount: missing,
                    ),
                    BucketCustomerBlockUi(controllers: _controller.controllers),
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
                      onFieldChanged: () {
                        _controller.persistDraft();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              onPressed: () {
                _controller.persistDraft();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check_circle_outline, size: 22),
              label: const Text(
                'معلومات محفوظ کریں اور کاؤنٹر پر جائیں',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryEmerald,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}