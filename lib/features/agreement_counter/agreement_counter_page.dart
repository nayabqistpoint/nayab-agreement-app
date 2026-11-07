import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/box_names.dart';
import '../../core/database/hive_box_manager.dart';
import '../../core/models/document_template_model.dart';
import '../../shared_services/agreement_storage_handler_service.dart';
import '../agreement_bucket_view/bucket_view_page.dart';
import '../customer_directory/customer_directory_page.dart';
import '../template_studio/args/template_studio_args.dart';
import '../template_studio/template_studio_page.dart';
import 'agreement_counter_controller.dart';
import 'components/counter_bucket_summary.dart';
import 'components/counter_paper_preview.dart';
import 'components/counter_print_action_ui.dart';
import 'components/counter_quick_toolbar.dart';
import 'components/counter_scanner_bar_ui.dart';
import 'components/counter_template_selector_ui.dart';

class AgreementCounterPage extends StatefulWidget {
  const AgreementCounterPage({super.key});

  @override
  State<AgreementCounterPage> createState() => _AgreementCounterPageState();
}

class _AgreementCounterPageState extends State<AgreementCounterPage> {
  late final AgreementCounterController _controller;
  List<Uint8List?> _cachedStampPages = [];
  bool _isRenderingStamp = false;
  String? _lastLoadedTemplate;
  DocumentMode _currentDocMode = DocumentMode.stampOverlay;

  @override
  void initState() {
    super.initState();
    _controller = AgreementCounterController();
    _controller.addListener(_onControllerUpdate);
    _controller.loadDraftFromHive();
  }

  void _onControllerUpdate() {
    if (_controller.selectedTemplateTitle != _lastLoadedTemplate) {
      _lastLoadedTemplate = _controller.selectedTemplateTitle;
      _handleTemplateSwitched();
    }
    if (mounted) setState(() {});
  }

  // زیرو اسٹیٹ: جب نیا ٹیمپلیٹ منتخب ہو تو پچھلی تفصیلات صاف کر کے تازہ لوڈ کرنا
  Future<void> _handleTemplateSwitched() async {
    final title = _controller.selectedTemplateTitle;
    if (title.isEmpty) {
      setState(() {
        _cachedStampPages.clear();
        _currentDocMode = DocumentMode.stampOverlay;
      });
      return;
    }

    final all = AgreementStorageHandlerService.getAllTemplates();
    if (all.containsKey(title)) {
      final doc = DocumentTemplateModel.fromMap(all[title]!);
      _currentDocMode = doc.mode;

      // اگر موڈ سادہ دستاویزی کاغذ ہے تو پرانا اسٹامپ فوراً ختم
      if (doc.mode == DocumentMode.plainDocument) {
        setState(() {
          _controller.selectedStampPdfBytes = null;
          _controller.selectedStampFileName = null;
          _cachedStampPages.clear();
        });
        return;
      }

      // اگر ای-اسٹامپ یا فارم فلر ہے تو محفوظ شدہ PDF بائٹس لائیں
      if (doc.base64Pdf != null && doc.base64Pdf!.isNotEmpty) {
        try {
          final bytes = base64Decode(doc.base64Pdf!);
          _controller.selectedStampPdfBytes = bytes;
          _controller.selectedStampFileName = doc.stampFileName ?? "ٹیمپلیٹ کا محفوظ اسٹامپ";
          await _renderStampPdfToCache(bytes);
          return;
        } catch (_) {}
      }
    }

    setState(() {
      _cachedStampPages.clear();
    });
  }

  Future<void> _renderStampPdfToCache(Uint8List pdfBytes) async {
    setState(() => _isRenderingStamp = true);
    try {
      List<Uint8List?> pages = [];
      await for (final page in Printing.raster(pdfBytes, dpi: 110)) {
        pages.add(await page.toPng());
      }
      if (mounted) {
        setState(() {
          _cachedStampPages = pages;
          _isRenderingStamp = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isRenderingStamp = false);
    }
  }

  Future<void> _pickCustomerStampPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      final bytes = result.files.single.bytes!;
      setState(() {
        _controller.selectedStampPdfBytes = bytes;
        _controller.selectedStampFileName = result.files.single.name;
      });
      await _renderStampPdfToCache(bytes);
    }
  }

  String _buildProcessedAgreementText() {
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

  List<String> _paginateText(String fullText) {
    if (fullText.isEmpty) return [""];

    final paragraphs = fullText.split(RegExp(r'\n\s*\n'));
    List<String> cleanedParas = [];
    for (var p in paragraphs) {
      var lines = p.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty);
      cleanedParas.add(lines.join(' '));
    }
    final normalized = cleanedParas.join('\n\n');

    const double totalPoints = 1008.0;
    final double lineH = _controller.fontSize * 1.95;

    final double p1H = (totalPoints - _controller.topMargin - _controller.bottomMargin).clamp(100.0, totalPoints);
    final int p1MaxLines = (p1H / lineH).floor();

    final double subH = (totalPoints - _controller.subsequentTopMargin - _controller.bottomMargin).clamp(100.0, totalPoints);
    final int subMaxLines = (subH / lineH).floor();

    final double availableWidth = 612.0 - (_controller.sideMargin * 2);
    final int charsPerLine = (availableWidth / (_controller.fontSize * 0.44)).floor().clamp(65, 110);

    final rawLines = normalized.split('\n');
    List<String> visualLines = [];

    for (var r in rawLines) {
      if (r.trim().isEmpty) {
        visualLines.add("");
        continue;
      }
      final words = r.split(' ');
      String current = "";
      for (var w in words) {
        if ((current + w).length > charsPerLine) {
          visualLines.add(current.trim());
          current = "$w ";
        } else {
          current += "$w ";
        }
      }
      if (current.isNotEmpty) visualLines.add(current.trim());
    }

    List<String> pages = [];
    int lineIndex = 0;

    int linesForP1 = visualLines.length > p1MaxLines ? p1MaxLines : visualLines.length;
    pages.add(visualLines.sublist(0, linesForP1).join('\n'));
    lineIndex = linesForP1;

    while (lineIndex < visualLines.length) {
      int remaining = visualLines.length - lineIndex;
      int take = remaining > subMaxLines ? subMaxLines : remaining;
      pages.add(visualLines.sublist(lineIndex, lineIndex + take).join('\n'));
      lineIndex += take;
    }

    return pages;
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
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
          title: const Text('نایاب قسط پوائنٹ - کاؤنٹر', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          centerTitle: true,
          backgroundColor: AppColors.primaryEmerald,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.people_outline, size: 24),
              tooltip: 'کسٹمر ڈائریکٹری',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomerDirectoryPage()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 24),
              tooltip: 'نیا معاہدہ بنائیں',
              onPressed: () async {
                final res = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TemplateStudioPage()),
                );
                if (res == true) {
                  _controller.loadDraftFromHive();
                  _handleTemplateSwitched();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 24),
              tooltip: 'فارم نیا کریں',
              onPressed: () => _controller.resetCounter(context),
            ),
          ],
        ),
        body: ValueListenableBuilder(
          valueListenable: HiveBoxManager.listenToBox(BoxNames.agreementDraftBox),
          builder: (context, box, child) {
            final processedText = _buildProcessedAgreementText();
            final dynamicPages = _paginateText(processedText);

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
                      if (res == true) {
                        _controller.loadDraftFromHive();
                        _handleTemplateSwitched();
                      }
                    },
                  ),
                  const SizedBox(height: 8),

                  // بکٹ کا لائیو خلاصہ
                  CounterBucketSummary(
                    totalFields: _controller.totalFieldsCount,
                    filledFields: _controller.filledFieldsCount,
                    onViewDetails: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BucketViewPage()),
                      );
                      _controller.loadDraftFromHive();
                    },
                    onResetBucket: () => _controller.resetCounter(context),
                  ),
                  const SizedBox(height: 8),

                  // ٹول بار مع فونٹ سائز و گاہک کا اسٹامپ
                  CounterQuickToolbar(
                    currentMode: _currentDocMode,
                    stampFileName: _controller.selectedStampFileName,
                    fontSize: _controller.fontSize,
                    totalPages: dynamicPages.length,
                    onPickCustomerStamp: _pickCustomerStampPdf,
                    onFontSizeChanged: (s) => _controller.setFontSize(s),
                  ),
                  const SizedBox(height: 8),

                  // کینوس: لائیو ملٹی پیج رینڈرنگ
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _isRenderingStamp
                            ? const Center(child: CircularProgressIndicator())
                            : SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: Column(
                                    children: List.generate(dynamicPages.length, (index) {
                                      final isP1 = (index == 0);
                                      final topM = isP1 ? _controller.topMargin : _controller.subsequentTopMargin;
                                      final bgImg = (index < _cachedStampPages.length) ? _cachedStampPages[index] : null;

                                      return Column(
                                        children: [
                                          Text(
                                            isP1 ? "— صفحہ نمبر 1 (اصل لے آؤٹ) —" : "— صفحہ نمبر ${index + 1} (بقیہ شرائط) —",
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                                          ),
                                          const SizedBox(height: 6),
                                          CounterPaperPreview(
                                            topMargin: topM,
                                            bottomMargin: _controller.bottomMargin,
                                            sideMargin: _controller.sideMargin,
                                            textContent: dynamicPages[index],
                                            bgImage: bgImg,
                                            isFirstPage: isP1,
                                            fontSize: _controller.fontSize,
                                            mode: _currentDocMode,
                                            bucketValues: _controller.currentFieldValues,
                                            onTopDrag: (delta) {
                                              if (isP1) {
                                                _controller.setTopMargin(_controller.topMargin + (delta * (1008.0 / 593.0)));
                                              } else {
                                                _controller.setSubsequentTopMargin(_controller.subsequentTopMargin + (delta * (1008.0 / 593.0)));
                                              }
                                            },
                                            onBottomDrag: (delta) => _controller.setBottomMargin(_controller.bottomMargin - (delta * (1008.0 / 593.0))),
                                            onSideDrag: (delta) => _controller.setSideMargin(_controller.sideMargin - (delta * (1008.0 / 593.0))),
                                          ),
                                          const SizedBox(height: 24),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // پرنٹ اور کاپی ایکشن بار
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