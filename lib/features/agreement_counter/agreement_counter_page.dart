import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/qr_scanner.dart';
import '../agreement_bucket_view/bucket_view_page.dart';
import '../customer_directory/customer_directory_page.dart';
import '../stamp_agreement/stamp_studio_page.dart';
import 'agreement_counter_controller.dart';
import 'components/counter_app_bar_ui.dart';
import 'components/counter_bucket_badge_ui.dart';
import 'components/counter_bundle_selector_ui.dart';
import 'components/counter_canvas_viewer_ui.dart';
import 'components/counter_delivery_modal_ui.dart';
import 'components/counter_module_tabs_ui.dart';
import 'components/counter_print_action_ui.dart';
import 'components/counter_quick_toolbar.dart';
import 'components/counter_scanner_bar_ui.dart';
import 'services/counter_navigation_service.dart';
import 'services/counter_render_service.dart';
import 'services/counter_storage_handler_service.dart';

class AgreementCounterPage extends StatefulWidget {
  const AgreementCounterPage({super.key});

  @override
  State<AgreementCounterPage> createState() => _AgreementCounterPageState();
}

class _AgreementCounterPageState extends State<AgreementCounterPage> {
  late final AgreementCounterController _c;
  final List<GlobalKey> _canvasKeys = [];

  @override
  void initState() {
    super.initState();
    _c = AgreementCounterController();
    _c.addListener(() => mounted ? setState(() {}) : null);
    _c.init();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _syncKeys(int count) {
    if (_canvasKeys.length != count) {
      _canvasKeys
        ..clear()
        ..addAll(List.generate(count, (_) => GlobalKey()));
    }
  }

  Future<void> _scan(String title) async {
    final res = await QrScanner.scan(context, title: title);
    if (res != null && res.trim().isNotEmpty) {
      _c.applyScannedData(res.trim());
    }
  }

  Future<void> _handleDeleteTemplate(String title) async {
    final ok = await CounterStorageHandlerService.deleteTemplate(title);
    if (ok && mounted) {
      _c.loadTemplates();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ٹیمپلیٹ "$title" کامیابی سے ڈیلیٹ ہو گیا')),
      );
    }
  }

  Future<void> _printLegalTray() async {
    await _c.commitDeal();
    final List<int> indexes = [];
    for (int i = 0; i < _c.bundlePages.length; i++) {
      if (_c.bundlePages[i].originalPaperSize.toLowerCase().contains('legal')) {
        indexes.add(i);
      }
    }
    await CounterRenderService.printSelectivePages(
      allKeys: _canvasKeys,
      pageIndexesToPrint: indexes,
      docTitle: 'ای-اسٹامپ قانونی دستاویزات',
      targetFormat: PdfPageFormat.legal,
    );
  }

  Future<void> _printA4Tray() async {
    await _c.commitDeal();
    final List<int> indexes = [];
    for (int i = 0; i < _c.bundlePages.length; i++) {
      if (!_c.bundlePages[i].originalPaperSize.toLowerCase().contains('legal')) {
        indexes.add(i);
      }
    }
    await CounterRenderService.printSelectivePages(
      allKeys: _canvasKeys,
      pageIndexesToPrint: indexes,
      docTitle: 'دفتری رسیدیں و واؤچرز',
      targetFormat: PdfPageFormat.a4,
    );
  }

  Future<void> _printAllPagesAsA4() async {
    await _c.commitDeal();
    final List<int> allIndexes = List.generate(_c.bundlePages.length, (i) => i);
    await CounterRenderService.printSelectivePages(
      allKeys: _canvasKeys,
      pageIndexesToPrint: allIndexes,
      docTitle: 'مکمل قسط فائل (تمام صفحات A4)',
      targetFormat: PdfPageFormat.a4,
    );
  }

  void _openDeliveryModalManually() {
    final customerName = _c.currentFieldValues['کسٹمر کا نام'] ?? 'گاہک';
    CounterDeliveryModalUi.show(
      context: context,
      dealId: _c.activeDeal?.id ?? 'NEW_DEAL',
      customerName: customerName,
      deliveryPhotoPath: _c.activeDeal?.deliveryPhotoPath,
      signedDocPhotoPath: _c.activeDeal?.signedDocPhotoPath,
      onCaptureDeliveryPhoto: () async {
        await _c.captureDeliveryPhoto();
        setState(() {});
      },
      onCaptureSignedDocPhoto: () async {
        await _c.captureSignedDocPhoto();
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _syncKeys(_c.bundlePages.length);

    final int filled = _c.requiredFields.where((f) => (_c.currentFieldValues[f] ?? '').isNotEmpty).length;

    final Map<String, bool> hasStampsMap = {};
    for (var t in _c.availableTemplates) {
      hasStampsMap[t] = _c.customTemplateStamps.containsKey(t);
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: CounterAppBarUi(
          onOpenCustomerDirectory: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CustomerDirectoryPage()),
          ),
          onReset: _c.init,
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CounterScannerBarUi(
                    onScanProduct: () => _scan('پروڈکٹ QR اسکین'),
                    onScanCnic: () => _scan('شناختی کارڈ اسکین'),
                  ),
                  CounterModuleTabsUi(
                    onOpenStampStudio: () => CounterNavigationService.openStudio(
                      context,
                      const StampStudioPage(),
                    ).then((_) => _c.init()),
                    onOpenPdfEditor: () => CounterNavigationService.openPdfEditor(
                      context,
                    ).then((_) => _c.init()),
                  ),
                  CounterBundleSelectorUi(
                    availableTemplates: _c.availableTemplates,
                    selectedTemplates: _c.selectedTemplates,
                    templateModelsMap: _c.templateModelsMap,
                    templateHasCustomStamp: hasStampsMap,
                    onToggleTemplate: _c.toggleTemplateSelection,
                    onSelectAll: _c.selectAllTemplates,
                    onClearAll: _c.clearAllSelectedTemplates,
                    onOpenSingleEditor: (t) => CounterNavigationService.openEditor(context, t).then((_) => _c.init()),
                    onDeleteTemplate: _handleDeleteTemplate,
                    onAttachStampToTemplate: _c.attachStampToTemplate,
                  ),
                  CounterBucketBadgeUi(
                    filledCount: filled,
                    totalCount: _c.requiredFields.length,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BucketViewPage()),
                    ).then((_) => _c.loadDraft()),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    child: InkWell(
                      onTap: _openDeliveryModalManually,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _c.activeDeal?.deliveryPhotoPath != null
                              ? AppColors.successGreen.withAlpha(20)
                              : Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _c.activeDeal?.deliveryPhotoPath != null
                                ? AppColors.successGreen
                                : Colors.amber.shade700,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _c.activeDeal?.deliveryPhotoPath != null
                                  ? Icons.verified
                                  : Icons.camera_alt_outlined,
                              size: 18,
                              color: _c.activeDeal?.deliveryPhotoPath != null
                                  ? AppColors.successGreen
                                  : Colors.amber.shade900,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _c.activeDeal?.deliveryPhotoPath != null
                                  ? 'تصاویر محفوظ ہیں (دوبارہ دیکھنے یا بدلنے کے لیے کلک کریں)'
                                  : 'موبائل حوالگی / سائن شدہ اسٹامپ کی تصویر بنائیں (اختیاری)',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: _c.activeDeal?.deliveryPhotoPath != null
                                    ? AppColors.successGreen
                                    : Colors.amber.shade900,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.black45),
                          ],
                        ),
                      ),
                    ),
                  ),
                  CounterQuickToolbar(
                    selectedDocsCount: _c.selectedTemplates.length,
                    totalPages: _c.bundlePages.length,
                    legalPagesCount: _c.legalPagesCount,
                    a4PagesCount: _c.a4PagesCount,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.black12),
            Expanded(
              child: CounterCanvasViewerUi(
                pages: _c.bundlePages,
                pageBoundaryKeys: _canvasKeys,
                isLoading: _c.isRenderingStamp,
                fontSize: _c.fontSize,
              ),
            ),
          ],
        ),
        bottomNavigationBar: CounterPrintActionUi(
          legalPageCount: _c.legalPagesCount,
          a4PageCount: _c.a4PagesCount,
          onPrintLegal: _printLegalTray,
          onPrintA4: _printA4Tray,
          onPrintAllAsA4: _printAllPagesAsA4,
        ),
      ),
    );
  }
}