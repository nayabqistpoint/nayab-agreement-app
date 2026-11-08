import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../agreement_bucket_view/bucket_view_page.dart';
import '../form_filler/form_filler_studio_page.dart';
import '../plain_document/plain_doc_studio_page.dart';
import '../stamp_agreement/stamp_studio_page.dart';
import 'agreement_counter_controller.dart';
import 'components/counter_app_bar_ui.dart';
import 'components/counter_bucket_summary.dart';
import 'components/counter_canvas_viewer_ui.dart';
import 'components/counter_module_tabs_ui.dart';
import 'components/counter_print_action_ui.dart';
import 'components/counter_quick_toolbar.dart';
import 'components/counter_scanner_bar_ui.dart';
import 'components/counter_template_selector_ui.dart';
import 'services/counter_navigation_service.dart';
import 'services/counter_render_service.dart';
import 'services/counter_storage_handler_service.dart';

class AgreementCounterPage extends StatefulWidget {
  const AgreementCounterPage({super.key});

  @override
  State<AgreementCounterPage> createState() => _AgreementCounterPageState();
}

class _AgreementCounterPageState extends State<AgreementCounterPage> {
  late final AgreementCounterController _controller;
  final List<GlobalKey> _boundaryKeys = [];

  @override
  void initState() {
    super.initState();
    _controller = AgreementCounterController();
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

  Future<void> _handleStudioReturn(Future<bool?> navAction) async {
    final res = await navAction;
    if (res == true) {
      _controller.loadTemplates();
      _controller.refreshStampPages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: CounterAppBarUi(
          onOpenCustomerDirectory: () => CounterNavigationService.openCustomerDirectory(context),
          onReset: () => _controller.loadDraft(),
        ),
        body: ValueListenableBuilder(
          valueListenable: CounterStorageHandlerService.listenToDraft(),
          builder: (context, box, child) {
            final pages = _controller.getPages();
            while (_boundaryKeys.length < pages.length) {
              _boundaryKeys.add(GlobalKey());
            }
            if (_boundaryKeys.length > pages.length) {
              _boundaryKeys.removeRange(pages.length, _boundaryKeys.length);
            }

            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  CounterScannerBarUi(onScanProduct: () {}, onScanCnic: () {}),
                  const SizedBox(height: 8),
                  CounterModuleTabsUi(
                    onOpenStampStudio: () => _handleStudioReturn(CounterNavigationService.openStudio(context, const StampStudioPage(initialTitle: ''))),
                    onOpenPlainDocStudio: () => _handleStudioReturn(CounterNavigationService.openStudio(context, const PlainDocStudioPage(initialTitle: ''))),
                    onOpenFormFillerStudio: () => _handleStudioReturn(CounterNavigationService.openStudio(context, const FormFillerStudioPage(initialTitle: ''))),
                  ),
                  const SizedBox(height: 8),
                  CounterTemplateSelectorUi(
                    selectedTitle: _controller.selectedTemplateTitle,
                    availableTemplates: _controller.availableTemplates,
                    onTemplateChanged: (t) => _controller.switchTemplate(t),
                    onEditTemplate: () => _handleStudioReturn(CounterNavigationService.openEditor(context, _controller.selectedTemplateTitle)),
                  ),
                  const SizedBox(height: 8),
                  CounterBucketSummary(
                    totalFields: _controller.requiredFields.length,
                    filledFields: _controller.currentFieldValues.length,
                    onViewDetails: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BucketViewPage())),
                    onResetBucket: () => _controller.loadDraft(),
                  ),
                  const SizedBox(height: 8),
                  CounterQuickToolbar(
                    currentMode: _controller.currentDocMode,
                    stampFileName: _controller.selectedStampFileName,
                    fontSize: _controller.fontSize,
                    totalPages: pages.length,
                    onPickCustomerStamp: () => _controller.handlePickStamp(),
                    onFontSizeChanged: (s) => _controller.setFontSize(s),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: CounterCanvasViewerUi(
                      isLoading: _controller.isRenderingStamp,
                      pages: pages,
                      cachedStampPages: _controller.cachedStampPages,
                      pageBoundaryKeys: _boundaryKeys,
                      topMargin: _controller.topMargin,
                      subsequentTopMargin: _controller.subsequentTopMargin,
                      bottomMargin: _controller.bottomMargin,
                      sideMargin: _controller.sideMargin,
                      fontSize: _controller.fontSize,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CounterPrintActionUi(
                    onPrint: () => CounterRenderService.printDocument(_boundaryKeys, _controller.selectedTemplateTitle),
                    onCopyText: () {},
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