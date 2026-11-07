import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/box_names.dart';
import '../../core/database/hive_box_manager.dart';
import '../../shared_services/agreement_storage_handler_service.dart';
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
  List<Uint8List?> _cachedStampPages = [];
  bool _isRenderingStamp = false;
  String? _lastLoadedTemplate;

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
      _loadTemplateStampFromHive();
    }
    setState(() {});
  }

  Future<void> _loadTemplateStampFromHive() async {
    final title = _controller.selectedTemplateTitle;
    if (title.isEmpty) return;
    final all = AgreementStorageHandlerService.getAllTemplates();
    if (all.containsKey(title)) {
      final t = all[title]!;
      final b64 = t['base64Pdf']?.toString();
      if (b64 != null && b64.isNotEmpty) {
        try {
          final bytes = base64Decode(b64);
          _controller.selectedStampPdfBytes = bytes;
          _controller.selectedStampFileName = "ٹیمپلیٹ کا محفوظ اسٹامپ";
          await _renderStampPdfToCache(bytes);
          return;
        } catch (_) {}
      }
    }
    if (_controller.selectedStampPdfBytes == null) {
      setState(() {
        _cachedStampPages.clear();
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _renderStampPdfToCache(Uint8List pdfBytes) async {
    setState(() => _isRenderingStamp = true);
    try {
      List<Uint8List?> pages = [];
      await for (final page in Printing.raster(pdfBytes, dpi: 110)) {
        final png = await page.toPng();
        pages.add(png);
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

  // تحریر کو حقیقت پسندانہ انداز میں بغیر کسی زبردستی کے پیجز میں تقسیم کرنا
  List<String> _paginateText(String fullText) {
    if (fullText.isEmpty) return [""];

    const double totalPoints = 1008.0;
    final double lineH = _controller.fontSize * 1.95; // لائن کی اونچائی

    // صفحہ 1 کی دستیاب اونچائی
    final double p1H = (totalPoints - _controller.topMargin - _controller.bottomMargin).clamp(100.0, totalPoints);
    final int p1MaxLines = (p1H / lineH).floor();

    // باقی صفحات کی دستیاب اونچائی
    final double subH = (totalPoints - _controller.subsequentTopMargin - _controller.bottomMargin).clamp(100.0, totalPoints);
    final int subMaxLines = (subH / lineH).floor();

    // ایک لائن میں حروف کی گنجائش (چوڑائی 612pt مائنس حاشیے)
    final double availableWidth = 612.0 - (_controller.sideMargin * 2);
    // جمیل نوری نستعلیق کے حروف کی اوسط گنجائش
    final int charsPerLine = (availableWidth / (_controller.fontSize * 0.48)).floor().clamp(60, 95);

    final rawLines = fullText.split('\n');
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

    // صفحہ 1
    int linesForP1 = visualLines.length > p1MaxLines ? p1MaxLines : visualLines.length;
    pages.add(visualLines.sublist(0, linesForP1).join('\n'));
    lineIndex = linesForP1;

    // بقیہ صفحات (صفحہ 2، 3 وغیرہ)
    while (lineIndex < visualLines.length) {
      int remaining = visualLines.length - lineIndex;
      int take = remaining > subMaxLines ? subMaxLines : remaining;
      pages.add(visualLines.sublist(lineIndex, lineIndex + take).join('\n'));
      lineIndex += take;
    }

    return pages;
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
                if (res == true) {
                  _controller.loadDraftFromHive();
                  _loadTemplateStampFromHive();
                }
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
            final isEStampMode = _controller.isEStamp || _controller.paperSize == 'Legal' || _controller.selectedTemplateTitle.isNotEmpty;
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
                        _loadTemplateStampFromHive();
                      }
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
                                  isEStampMode ? 'طرزِ دستاویز: پنجاب ای-اسٹامپ (لیگل اوورلے)' : 'طرزِ دستاویز: سادہ کاغذ (A4)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isEStampMode ? Colors.brown.shade900 : AppColors.textDark,
                                  ),
                                ),
                                if (isEStampMode && _controller.selectedStampFileName != null)
                                  Text(
                                    'اسٹامپ: ${_controller.selectedStampFileName}',
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
                              _controller.selectedStampPdfBytes != null ? 'اسٹامپ تبدیل کریں' : 'اصل ای-اسٹامپ PDF چنیں',
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

                  // ٹول بار: لائیو فونٹ سائز ایڈجسٹر
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'پیشگی حقیقی نظارہ (کل صفحات: ${dynamicPages.length}):',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryEmerald),
                        ),
                        Row(
                          children: [
                            const Text('سائز: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.teal),
                              tooltip: 'فونٹ چھوٹا کریں',
                              onPressed: () => _controller.setFontSize(_controller.fontSize - 0.5),
                              visualDensity: VisualDensity.compact,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${_controller.fontSize} pt',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.teal),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 20, color: Colors.teal),
                              tooltip: 'فونٹ بڑا کریں',
                              onPressed: () => _controller.setFontSize(_controller.fontSize + 0.5),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // لائیو رینڈرنگ کینوس
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
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
                                          _buildInteractiveCounterSheet(
                                            topM: topM,
                                            botM: _controller.bottomMargin,
                                            sideM: _controller.sideMargin,
                                            textContent: dynamicPages[index],
                                            bgImage: bgImg,
                                            isFirstPage: isP1,
                                            fontSize: _controller.fontSize,
                                            onTopDrag: (delta) {
                                              if (isP1) {
                                                _controller.setTopMargin(_controller.topMargin + (delta * (1008.0 / 593.0)));
                                              } else {
                                                _controller.setSubsequentTopMargin(_controller.subsequentTopMargin + (delta * (1008.0 / 593.0)));
                                              }
                                            },
                                            onBotDrag: (delta) => _controller.setBottomMargin(_controller.bottomMargin - (delta * (1008.0 / 593.0))),
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

  Widget _buildInteractiveCounterSheet({
    required double topM,
    required double botM,
    required double sideM,
    required String textContent,
    required Uint8List? bgImage,
    required bool isFirstPage,
    required double fontSize,
    required Function(double) onTopDrag,
    required Function(double) onBotDrag,
    required Function(double) onSideDrag,
  }) {
    const double sheetWidth = 360.0;
    const double sheetHeight = 593.0;
    const double scale = sheetHeight / 1008.0;

    final scaledTop = topM * scale;
    final scaledBot = botM * scale;
    final scaledSide = (sideM * scale).clamp(8.0, 40.0);
    final boxW = (sheetWidth - (scaledSide * 2)).clamp(100.0, sheetWidth);
    final boxH = (sheetHeight - scaledTop - scaledBot).clamp(50.0, sheetHeight);

    return Container(
      width: sheetWidth,
      height: sheetHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 10, spreadRadius: 2, offset: Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          if (bgImage != null)
            Positioned.fill(
              child: Image.memory(bgImage, fit: BoxFit.fill),
            )
          else
            Center(
              child: Opacity(
                opacity: 0.12,
                child: Text(
                  isFirstPage ? "سرکاری ای-اسٹامپ پیپر" : "اضافی سادہ ورق",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          // ریڈ باکس بغیر کسی اندرونی سکرول کے
          Positioned(
            top: scaledTop,
            left: scaledSide,
            width: boxW,
            height: boxH,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red.shade700, width: 1.5),
                color: Colors.white.withAlpha(140),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                    child: Text(
                      textContent,
                      textAlign: TextAlign.justify,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'JameelNoori',
                        fontSize: fontSize * 0.88,
                        height: 1.85,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111111),
                      ),
                    ),
                  ),

                  // اوپر کا ڈریگ ہینڈل
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 12,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onVerticalDragUpdate: (d) => onTopDrag(d.delta.dy),
                      child: Container(
                        color: Colors.red.withAlpha(80),
                        alignment: Alignment.center,
                        child: const Icon(Icons.drag_handle, size: 10, color: Colors.white),
                      ),
                    ),
                  ),

                  // نیچے کا ڈریگ ہینڈل
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 12,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onVerticalDragUpdate: (d) => onBotDrag(d.delta.dy),
                      child: Container(
                        color: Colors.red.withAlpha(80),
                        alignment: Alignment.center,
                        child: const Icon(Icons.drag_handle, size: 10, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}