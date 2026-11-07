import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import '../../core/constants/app_colors.dart';
import '../../core/constants/box_names.dart';
import '../../core/database/hive_box_manager.dart';
import 'agreement_counter_controller.dart';
import 'components/counter_scanner_bar_ui.dart';
import 'components/counter_template_selector_ui.dart';
import 'components/counter_bucket_badge_ui.dart';
import 'components/counter_print_action_ui.dart';
import '../agreement_bucket_view/bucket_view_page.dart';
import '../template_studio/args/template_studio_args.dart';
import '../template_studio/template_studio_page.dart';
import '../customer_directory/customer_directory_page.dart';

class AgreementCounterPage extends StatefulWidget {
  const AgreementCounterPage({super.key});

  @override
  State<AgreementCounterPage> createState() => _AgreementCounterPageState();
}

class _AgreementCounterPageState extends State<AgreementCounterPage> {
  late final AgreementCounterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AgreementCounterController();
    _controller.addListener(() => setState(() {}));
    _controller.loadDraftFromHive();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pickCustomerStampPdf() {
    if (kIsWeb) {
      final uploadInput = web.document.createElement('input') as web.HTMLInputElement;
      uploadInput.type = 'file';
      uploadInput.accept = '.pdf,application/pdf';
      uploadInput.click();

      uploadInput.onchange = (web.Event e) {
        final files = uploadInput.files;
        if (files == null || files.length == 0) return;
        final file = files.item(0);
        if (file == null) return;

        final reader = web.FileReader();
        reader.readAsArrayBuffer(file);
        reader.onloadend = (web.ProgressEvent pe) {
          final result = reader.result;
          if (result != null && mounted) {
            final arrayBuffer = result as JSArrayBuffer;
            final bytes = arrayBuffer.toDart.asUint8List();

            setState(() {
              _controller.selectedStampPdfBytes = bytes;
              _controller.selectedStampFileName = file.name;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ اصل ای-اسٹامپ پی ڈی ایف منسلک ہو گیا: ${file.name}'),
                backgroundColor: AppColors.successGreen,
              ),
            );
          }
        }.toJS;
      }.toJS;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ای-اسٹامپ اوورلے فعال ہے۔')),
      );
    }
  }

  String _buildCleanPreviewText() {
    String raw = _controller.templateContent;
    if (raw.isEmpty) return 'کوئی معاہدہ منتخب نہیں ہے۔';

    raw = raw.replaceAll('**', '').replaceAll('*', '');
    raw = raw.replaceAll('[center]', '').replaceAll('[/center]', '');
    raw = raw.replaceAll(RegExp(r'^#+\s*', multiLine: true), '');
    raw = raw.replaceAll(RegExp(r'\[space:\s*\d+\]'), '\n');
    raw = raw.replaceAll(RegExp(r'\[signatures:.*?\]'), '');

    for (var f in _controller.requiredFields) {
      final val = _controller.currentFieldValues[f]?.trim();
      final display = (val != null && val.isNotEmpty) ? val : '__________';
      raw = raw.replaceAll('{{$f}}', display);
    }

    raw = raw.replaceAll(RegExp(r'\{\{.*?\}\}'), '__________');
    return raw.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('نایاب قسط پوائنٹ - کاؤنٹر', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          centerTitle: true,
          backgroundColor: AppColors.primaryEmerald,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.people_outline, size: 26),
              tooltip: 'کسٹمر ڈائریکٹری',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomerDirectoryPage()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 26),
              tooltip: 'نیا معاہدہ بنائیں',
              onPressed: () async {
                final res = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TemplateStudioPage()),
                );
                if (res == true) _controller.loadDraftFromHive();
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 26),
              tooltip: 'فارم نیا کریں',
              onPressed: () => _controller.resetCounter(context),
            ),
          ],
        ),
        body: ValueListenableBuilder(
          valueListenable: HiveBoxManager.listenToBox(BoxNames.agreementDraftBox),
          builder: (context, box, child) {
            final isEStampMode = _controller.isEStamp || _controller.paperSize == 'Legal';

            return Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CounterScannerBarUi(
                    onScanProduct: () => _controller.scanProduct(context),
                    onScanCnic: () => _controller.scanCnic(context),
                  ),
                  const SizedBox(height: 10),

                  CounterTemplateSelectorUi(
                    selectedTitle: _controller.selectedTemplateTitle,
                    availableTemplates: _controller.availableTemplates,
                    onTemplateChanged: (t) => _controller.switchTemplate(t),
                    onEditTemplate: () async {
                      final res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TemplateStudioPage(
                            args: TemplateStudioArgs(
                              templateTitle: _controller.selectedTemplateTitle,
                              templateContent: _controller.templateContent,
                              paperSize: _controller.paperSize,
                              isEStamp: _controller.isEStamp,
                              topMargin: _controller.topMargin,
                              subsequentTopMargin: _controller.subsequentTopMargin,
                              bottomMargin: _controller.bottomMargin,
                              sideMargin: _controller.sideMargin,
                            ),
                          ),
                        ),
                      );
                      if (res == true) _controller.loadDraftFromHive();
                    },
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isEStampMode ? const Color(0xFFFFF8E1) : AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isEStampMode ? Colors.amber.shade600 : AppColors.borderLight,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isEStampMode ? Icons.verified_user : Icons.description_outlined,
                              color: isEStampMode ? Colors.brown.shade800 : AppColors.primaryEmerald,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEStampMode ? 'طرزِ دستاویز: پنجاب ای-اسٹامپ (لیگل اوورلے)' : 'طرزِ دستاویز: سادہ دفتری معاہدہ (A4 پیپر)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isEStampMode ? Colors.brown.shade900 : AppColors.textDark,
                                  ),
                                ),
                                if (isEStampMode && _controller.selectedStampFileName != null)
                                  Text(
                                    'فائل: ${_controller.selectedStampFileName}',
                                    style: TextStyle(fontSize: 12, color: Colors.green.shade800, fontWeight: FontWeight.bold),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        if (isEStampMode)
                          ElevatedButton.icon(
                            onPressed: _pickCustomerStampPdf,
                            icon: const Icon(Icons.picture_as_pdf, size: 16),
                            label: Text(
                              _controller.selectedStampPdfBytes != null ? 'اسٹامپ تبدیل کریں' : 'ای-اسٹامپ PDF چنیں',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  CounterBucketBadgeUi(
                    totalFields: _controller.totalFieldsCount,
                    filledFields: _controller.filledFieldsCount,
                    onViewBucketDetails: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BucketViewPage()),
                      );
                      _controller.loadDraftFromHive();
                    },
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade400, width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'پیشگی قانونی نظارہ: ${_controller.selectedTemplateTitle}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryEmerald),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isEStampMode ? Colors.amber.shade100 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: isEStampMode ? Colors.amber.shade400 : Colors.grey.shade300),
                                ),
                                child: Text(
                                  isEStampMode ? 'لیگل ای-اسٹامپ' : 'A4 دفتری کاغذ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isEStampMode ? Colors.brown.shade900 : AppColors.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16, thickness: 1),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                _buildCleanPreviewText(),
                                style: const TextStyle(
                                  fontSize: 17,
                                  height: 2.1,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  CounterPrintActionUi(
                    onPrint: () => _controller.printAgreement(context),
                    onCopyText: () => _controller.copyAgreementText(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}