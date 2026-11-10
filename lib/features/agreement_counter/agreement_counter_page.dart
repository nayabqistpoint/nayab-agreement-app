import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/qr_scanner.dart';
import '../agreement_bucket_view/bucket_view_page.dart';
import '../customer_directory/customer_directory_page.dart';
import '../stamp_agreement/stamp_studio_page.dart';
import 'agreement_counter_controller.dart';
import 'components/counter_app_bar_ui.dart';
import 'components/counter_bucket_badge_ui.dart';
import 'components/counter_canvas_viewer_ui.dart';
import 'components/counter_module_tabs_ui.dart';
import 'components/counter_print_action_ui.dart';
import 'components/counter_quick_toolbar.dart';
import 'components/counter_scanner_bar_ui.dart';
import 'components/counter_template_selector_ui.dart';
import 'services/counter_navigation_service.dart';
import 'services/counter_render_service.dart';

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

  Future<void> _scan(String key, String title) async {
    final res = await QrScanner.scan(context, title: title);
    if (res != null && res.trim().isNotEmpty) {
      _c.currentFieldValues[key] = res.trim();
      _c.persistState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = _c.getPages();
    _syncKeys(pages.length);

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
                    onScanProduct: () => _scan('IMEI نمبر', 'پروڈکٹ QR اسکین'),
                    onScanCnic: () => _scan('شناختی کارڈ', 'شناختی کارڈ اسکین'),
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
                  CounterTemplateSelectorUi(
                    selectedTitle: _c.selectedTemplateTitle,
                    availableTemplates: _c.availableTemplates,
                    onTemplateChanged: _c.switchTemplate,
                    onOpenEditor: () => CounterNavigationService.openEditor(
                      context,
                      _c.selectedTemplateTitle,
                    ).then((v) => v == true ? _c.init() : null),
                    onDeleteTemplate: (title) async {
                      final ok = await _c.deleteCurrentTemplate(title);
                      if (ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('ٹیمپلیٹ "$title" حذف کر دیا گیا')),
                        );
                      }
                    },
                  ),
                  CounterBucketBadgeUi(
                    filledCount: _c.currentFieldValues.length,
                    totalCount: _c.requiredFields.length,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BucketViewPage()),
                    ).then((_) => _c.loadDraft()),
                  ),
                  CounterQuickToolbar(
                    currentMode: _c.currentDocMode,
                    fontSize: _c.fontSize,
                    onFontSizeChanged: _c.setFontSize,
                    onPickCustomerStamp: _c.handlePickStamp,
                    stampFileName: _c.selectedStampFileName,
                    totalPages: pages.length,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.black12),
            Expanded(
              child: CounterCanvasViewerUi(
                pages: pages,
                pageBoundaryKeys: _canvasKeys,
                cachedStampPages: _c.cachedStampPages,
                isLoading: _c.isRenderingStamp,
                fontSize: _c.fontSize,
                topMargin: _c.topMargin,
                subsequentTopMargin: _c.subsequentTopMargin,
                bottomMargin: _c.bottomMargin,
                sideMargin: _c.sideMargin,
              ),
            ),
          ],
        ),
        bottomNavigationBar: CounterPrintActionUi(
          onPrint: () => CounterRenderService.printDocument(
            _canvasKeys,
            _c.selectedTemplateTitle,
          ),
          onCopyText: () => Clipboard.setData(
            ClipboardData(text: pages.join('\n\n')),
          ),
        ),
      ),
    );
  }
}