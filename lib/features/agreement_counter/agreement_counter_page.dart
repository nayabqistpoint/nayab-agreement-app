import 'package:flutter/material.dart';
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

  /// تمام فالتو کوڈز اور ڈبل اسٹارز (** ) کو مکمل صاف کر کے اصل قانونی نظارہ بنانا
  String _buildCleanPreviewText() {
    String raw = _controller.templateContent;
    if (raw.isEmpty) return 'کوئی معاہدہ منتخب نہیں ہے۔';

    // 1. تمام ڈبل اور سنگل اسٹارز کا مکمل خاتمہ
    raw = raw.replaceAll('**', '').replaceAll('*', '');

    // 2. پرانے مارک ڈاؤن اور فارمیٹنگ کوڈز کی صفائی
    raw = raw.replaceAll('[center]', '').replaceAll('[/center]', '');
    raw = raw.replaceAll(RegExp(r'^#+\s*', multiLine: true), '');
    raw = raw.replaceAll(RegExp(r'\[space:\s*\d+\]'), '\n');
    raw = raw.replaceAll(RegExp(r'\[signatures:.*?\]'), '');

    // 3. ٹیگز کی تبدیلی: بھری ہوئی ویلیو یا صاف ستھری لکیر
    for (var f in _controller.requiredFields) {
      final val = _controller.currentFieldValues[f]?.trim();
      final display = (val != null && val.isNotEmpty) ? val : '__________';
      raw = raw.replaceAll('{{$f}}', display);
    }

    // اگر کوئی اضافی خالی ٹیگ رہ گیا ہو تو اس کی جگہ بھی لکیر
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
            final isA4 = _controller.paperSize == 'A4';

            return Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. پروڈکٹ QR اور شناختی کارڈ اسکین بار
                  CounterScannerBarUi(
                    onScanProduct: () => _controller.scanProduct(context),
                    onScanCnic: () => _controller.scanCnic(context),
                  ),
                  const SizedBox(height: 10),

                  // 2. معاہدہ منتخب کرنے کا ڈراپ ڈاؤن مع ایڈیٹ بٹن
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
                              topMargin: _controller.topMargin,
                            ),
                          ),
                        ),
                      );
                      if (res == true) _controller.loadDraftFromHive();
                    },
                  ),
                  const SizedBox(height: 10),

                  // 3. پیپر سائز کا انتخاب (A4 بنام لیگل اسٹامپ)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('کاغذ کا سائز:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('A4 کاغذ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              selected: isA4,
                              onSelected: (val) {
                                if (val) {
                                  _controller.paperSize = 'A4';
                                  setState(() {});
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('لیگل اسٹامپ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              selected: !isA4,
                              onSelected: (val) {
                                if (val) {
                                  _controller.paperSize = 'Legal';
                                  setState(() {});
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 4. ڈیٹا بکٹ بیج
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

                  // 5. بالکل صاف ستھرا پیشگی قانونی نظارہ (بغیر اسٹارز اور بغیر ٹیگز کے)
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
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Text(
                                  isA4 ? 'A4 کاغذ' : 'لیگل اسٹامپ',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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

                  // 6. پرنٹ اور کاپی ایکشن بار
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