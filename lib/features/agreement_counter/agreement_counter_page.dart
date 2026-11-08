import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/box_names.dart';
import '../../core/database/hive_box_manager.dart';
import '../../core/models/document_template_model.dart';
import '../../shared_services/agreement_pagination_service.dart';
import '../../shared_services/agreement_storage_handler_service.dart';
import '../../shared_services/native_pdf_capture_service.dart';

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
  bool _isGeneratingPdf = false;
  String? _lastLoadedTemplate;
  DocumentMode _currentDocMode = DocumentMode.stampOverlay;
  List<String> _lockedStudioPages = [];

  final List<GlobalKey> _pageBoundaryKeys = [];

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

  Future<void> _handleTemplateSwitched() async {
    final title = _controller.selectedTemplateTitle;
    if (title.isEmpty) {
      setState(() {
        _cachedStampPages.clear();
        _lockedStudioPages.clear();
        _currentDocMode = DocumentMode.stampOverlay;
      });
      return;
    }

    final all = AgreementStorageHandlerService.getAllTemplates();
    if (all.containsKey(title)) {
      final doc = DocumentTemplateModel.fromMap(all[title]!);
      _currentDocMode = doc.mode;
      _lockedStudioPages = List<String>.from(doc.pages);

      if (doc.mode == DocumentMode.plainDocument) {
        setState(() {
          _controller.selectedStampPdfBytes = null;
          _controller.selectedStampFileName = null;
          _cachedStampPages.clear();
        });
        return;
      }

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
      await for (final page in Printing.raster(pdfBytes, dpi: 300)) {
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
      final fileName = result.files.single.name;

      setState(() {
        _controller.selectedStampPdfBytes = bytes;
        _controller.selectedStampFileName = fileName;
      });

      try {
        final box = HiveBoxManager.getBox(BoxNames.agreementDraftBox);
        box.put('selectedStampFileName', fileName);
        box.put('selectedStampPdfBytes', bytes);
      } catch (_) {}

      await _renderStampPdfToCache(bytes);
    }
  }

  String _replaceTagsInText(String text) {
    if (text.isEmpty) return '';
    String raw = text;
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

  List<String> _getFinalPages() {
    if (_lockedStudioPages.isNotEmpty) {
      return _lockedStudioPages.map((pageText) => _replaceTagsInText(pageText)).toList();
    }

    final processed = _replaceTagsInText(_controller.templateContent);
    return AgreementPaginationService.paginate(
      fullText: processed,
      fontSize: _controller.fontSize,
      p1TopMargin: _controller.topMargin,
      subsequentTopMargin: _controller.subsequentTopMargin,
      bottomMargin: _controller.bottomMargin,
      sideMargin: _controller.sideMargin,
    );
  }

  Future<void> _generateDirectNativePdf() async {
    if (_pageBoundaryKeys.isEmpty) return;

    setState(() => _isGeneratingPdf = true);

    try {
      final docName = _controller.selectedTemplateTitle.isNotEmpty
          ? _controller.selectedTemplateTitle
          : 'معاہدہ_نایاب_قسط_پوائنٹ';

      final pdfBytes = await NativePdfCaptureService.generatePdfFromBoundaries(
        pageKeys: _pageBoundaryKeys,
        paperSize: _controller.paperSize,
        docTitle: docName,
      );

      if (mounted) {
        setState(() => _isGeneratingPdf = false);
        await NativePdfCaptureService.previewAndSavePdf(
          context: context,
          pdfBytes: pdfBytes,
          fileName: '$docName.pdf',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('پی ڈی ایف بنانے میں خرابی: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _openTemplateStudio() async {
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
              tooltip: 'نیا معاہدہ / ٹیمپلیٹ بنائیں',
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
            final finalPages = _getFinalPages();

            while (_pageBoundaryKeys.length < finalPages.length) {
              _pageBoundaryKeys.add(GlobalKey());
            }
            if (_pageBoundaryKeys.length > finalPages.length) {
              _pageBoundaryKeys.removeRange(finalPages.length, _pageBoundaryKeys.length);
            }

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
                    onEditTemplate: _openTemplateStudio,
                  ),
                  const SizedBox(height: 8),

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

                  CounterQuickToolbar(
                    currentMode: _currentDocMode,
                    stampFileName: _controller.selectedStampFileName,
                    fontSize: _controller.fontSize,
                    totalPages: finalPages.length,
                    onPickCustomerStamp: _pickCustomerStampPdf,
                    onFontSizeChanged: (s) => _controller.setFontSize(s),
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _isRenderingStamp || _isGeneratingPdf
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CircularProgressIndicator(),
                                    const SizedBox(height: 12),
                                    Text(
                                      _isGeneratingPdf
                                          ? 'سچی ایچ ڈی کوالٹی کی PDF تیار ہو رہی ہے...'
                                          : 'اسٹامپ لوڈ ہو رہا ہے...',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              )
                            : SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: Column(
                                    children: List.generate(finalPages.length, (index) {
                                      final isP1 = (index == 0);
                                      final topM = isP1 ? _controller.topMargin : _controller.subsequentTopMargin;
                                      final bgImg = (index < _cachedStampPages.length) ? _cachedStampPages[index] : null;

                                      return Column(
                                        children: [
                                          Text(
                                            isP1 ? "— صفحہ نمبر 1 (اصل قانونی لے آؤٹ) —" : "— صفحہ نمبر ${index + 1} (بقیہ شرائط) —",
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                                          ),
                                          const SizedBox(height: 6),
                                          RepaintBoundary(
                                            key: _pageBoundaryKeys[index],
                                            child: CounterPaperPreview(
                                              topMargin: topM,
                                              bottomMargin: _controller.bottomMargin,
                                              sideMargin: _controller.sideMargin,
                                              textContent: finalPages[index],
                                              bgImage: bgImg,
                                              isFirstPage: isP1,
                                              fontSize: _controller.fontSize,
                                              mode: _currentDocMode,
                                              bucketValues: _controller.currentFieldValues,
                                            ),
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

                  CounterPrintActionUi(
                    onPrint: _generateDirectNativePdf,
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