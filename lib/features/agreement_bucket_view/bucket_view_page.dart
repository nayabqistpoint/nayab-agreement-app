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
    _controller.addListener(() => setState(() {}));
    _controller.loadFromDraft();
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
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('ڈیٹا بکٹ تفصیلات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
          backgroundColor: AppColors.primaryEmerald,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WhatsappDispatcherCardUi(
                phoneController: _controller.phoneController,
                onSendQuestions: () => _controller.sendQuestionsOnWhatsapp(context),
                onPasteAnswers: () => _controller.pasteAndParseFromClipboard(context),
              ),
              const SizedBox(height: 16),
              const Text(
                'ضروری کوائف و تفصیلات:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DynamicBucketFieldListUi(
                fields: _controller.fields,
                controllers: _controller.controllers,
                qrSourceData: _controller.qrSourceData,
              ),
            ],
          ),
        ),
      ),
    );
  }
}