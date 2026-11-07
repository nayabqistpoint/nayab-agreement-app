import 'package:file_picker/file_picker.dart';
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

  Future<void> _pickCustomerStampPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _controller.selectedStampPdfBytes = result.files.single.bytes;
        _controller.selectedStampFileName = result.files.single.name;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ اصل ای-اسٹامپ منسلک ہو گیا: ${result.files.single.name}'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    }
  }

  String _buildProcessedText() {
    String raw = _controller.templateContent;
    if (raw.isEmpty) return '';
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

  Map<String, List<String>> _splitForLivePreview(String fullText) {
    if (fullText.isEmpty) return {"page1": [], "page2": []};

    const double totalHeight = 1008.0;
    final double p1Height = (totalHeight - _controller.topMargin - _controller.bottomMargin).clamp(100.0, totalHeight);
    final double p2Height = (totalHeight - _controller.subsequentTopMargin - _controller.bottomMargin).clamp(100.0, totalHeight);

    const double lineH = 18.0;
    final int p1LinesLimit = (p1Height / lineH).floor();
    final int p2LinesLimit = (p2Height / lineH).floor();

    final rawLines = fullText.split('\n');
    final List<String> allLines = [];

    for (var l in rawLines) {
      final t = l.trim();
      if (t.isEmpty) {
        allLines.add("");
        continue;
      }
      final words = t.split(' ');
      String cur = "";
      for (var w in words) {
        if ((cur + w).length > 48) {
          allLines.add(cur.trim());
          cur = "$w ";
        } else {
          cur += "$w ";
        }
      }
      if (cur.isNotEmpty) allLines.add(cur.trim());
    }

    final List<String> p1 = [];
    final List<String> p2 = [];

    for (int i = 0; i < allLines.length; i++) {
      if (i < p1LinesLimit) {
        p1.add(allLines[i]);
      } else if (i < (p1LinesLimit + p2LinesLimit)) {
        p2.add(allLines[i]);
      }
    }

    return {"page1": p1, "page2": p2};
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
            final processedText = _buildProcessedText();
            final previewSplit = _splitForLivePreview(processedText);
            final p1Lines = previewSplit["page1"]!;
            final p2Lines = previewSplit["page2"]!;

            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CounterScannerBarUi(
                    onScanProduct: () => _controller.scanProduct(context),
                    onScanCnic: () => _controller.scanCnic(context),
                  ),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 8),
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
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEStampMode ? 'طرزِ دستاویز: پنجاب ای-اسٹامپ (لیگل اوورلے)' : 'طرزِ دستاویز: سادہ دفتری کاغذ (A4)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isEStampMode ? Colors.brown.shade900 : AppColors.textDark,
                                  ),
                                ),
                                if (isEStampMode && _controller.selectedStampFileName != null)
                                  Text(
                                    'فائل: ${_controller.selectedStampFileName}',
                                    style: TextStyle(fontSize: 11, color: Colors.green.shade800, fontWeight: FontWeight.bold),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        if (isEStampMode)
                          ElevatedButton.icon(
                            onPressed: _pickCustomerStampPdf,
                            icon: const Icon(Icons.picture_as_pdf, size: 15),
                            label: Text(
                              _controller.selectedStampPdfBytes != null ? 'اسٹامپ تبدیل کریں' : 'ای-اسٹامپ PDF چنیں',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 8),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Column(
                              children: [
                                const Text("— صفحہ نمبر 1 (اصل لے آؤٹ) —", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                                const SizedBox(height: 6),
                                _buildPaperSheet(
                                  topM: _controller.topMargin,
                                  botM: _controller.bottomMargin,
                                  sideM: _controller.sideMargin,
                                  lines: p1Lines,
                                  isFirstPage: true,
                                ),
                                if (p2Lines.isNotEmpty) ...[
                                  const SizedBox(height: 20),
                                  const Text("— صفحہ نمبر 2 (بقیہ تحریر) —", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                                  const SizedBox(height: 6),
                                  _buildPaperSheet(
                                    topM: _controller.subsequentTopMargin,
                                    botM: _controller.bottomMargin,
                                    sideM: _controller.sideMargin,
                                    lines: p2Lines,
                                    isFirstPage: false,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
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

  Widget _buildPaperSheet({
    required double topM,
    required double botM,
    required double sideM,
    required List<String> lines,
    required bool isFirstPage,
  }) {
    const double sheetWidth = 330.0;
    const double sheetHeight = 540.0;
    const double scale = sheetHeight / 1008.0;

    final scaledTop = topM * scale;
    final scaledBot = botM * scale;
    final scaledSide = (sideM * scale).clamp(10.0, 35.0);

    return Container(
      width: sheetWidth,
      height: sheetHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 1, offset: Offset(0, 3)),
        ],
      ),
      child: Stack(
        children: [
          if (isFirstPage && _controller.isEStamp)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: scaledTop,
              child: Container(
                color: Colors.amber.shade100.withAlpha(190),
                alignment: Alignment.center,
                child: Text(
                  'سرکاری ہیڈر اور مونوگرام کی محفوظ جگہ\n(${topM.toInt()} pt)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Colors.brown, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          if (_controller.isEStamp)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: scaledBot,
              child: Container(
                color: Colors.red.shade100.withAlpha(190),
                alignment: Alignment.center,
                child: Text(
                  'کیو آر کوڈ و بارکوڈ کی محفوظ جگہ (${botM.toInt()} pt)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          Positioned(
            top: scaledTop,
            bottom: scaledBot,
            left: scaledSide,
            right: scaledSide,
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: lines.map((l) {
                if (l.isEmpty) return const SizedBox(height: 4);
                return Text(
                  l,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'JameelNoori',
                    fontSize: 11.5,
                    height: 1.45,
                    color: Color(0xFF1A1A1A),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}