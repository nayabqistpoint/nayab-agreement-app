import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/box_names.dart';
import '../../core/database/hive_box_manager.dart';
import '../../core/services/tags_bank_service.dart';
import '../../core/widgets/portable_image_ui.dart';
import '../customer_detail/components/customer_media_viewer_modal_ui.dart';
import '../stock_inventory/stock_inventory_page.dart';
import 'components/order_mirror_invoice_card_ui.dart';
import 'services/order_invoice_calculator_service.dart';
import 'services/pos_pending_orders_service.dart';
class PosOrderFullProfilePage extends StatefulWidget {
  final PosOrderRecord order;
  final ValueChanged<PosOrderRecord> onLoadToCounter;
  final VoidCallback onDismissOrder;
  const PosOrderFullProfilePage({
    super.key,
    required this.order,
    required this.onLoadToCounter,
    required this.onDismissOrder,
  });
  @override
  State<PosOrderFullProfilePage> createState() =>
      _PosOrderFullProfilePageState();
}
class _PosOrderFullProfilePageState extends State<PosOrderFullProfilePage> {
  final PageController _pageController = PageController();
  int _activeSlide = 0;
  PosOrderRecord get _liveOrder {
    final id = widget.order['id']?.toString() ?? '';
    if (id.isNotEmpty) {
      final box = HiveBoxManager.getBox(BoxNames.shopOrdersBox);
      final raw = box.get(id);
      if (raw is Map) {
        return PosOrderRecord.from(raw);
      }
    }
    return widget.order;
  }
  bool _requiresStockPurchase(PosOrderRecord o) {
    final stockId = o['stockId']?.toString().trim() ?? '';
    final sourceMode = (o['sourceMode']?.toString() ?? '').toUpperCase();
    final isCustom = o['isCustomEstimate'] == true ||
        sourceMode == 'CUSTOM_ESTIMATE' ||
        sourceMode == 'ON_ORDER';
    if (stockId.isEmpty || stockId == 'null') return true;
    if (isCustom) {
      final stockBox = HiveBoxManager.getBox(BoxNames.stockBox);
      final rawStock = stockBox.get(stockId);
      if (rawStock is Map) {
        final st = (rawStock['status']?.toString() ?? '').toUpperCase();
        if (st == 'ON_ORDER' || rawStock['isOnOrder'] == true) {
          return true;
        }
        return false;
      }
      return true;
    }
    return false;
  }
  bool _isGeneralCategory(PosOrderRecord o) {
    final cat = (o['productCategory']?.toString() ?? '').toUpperCase();
    final zone = (o['zoneType']?.toString() ?? '').toUpperCase();
    return cat == 'ELECTRONICS' || zone == 'ELECTRONICS';
  }
  Future<void> _openPrefilledStockPurchase(PosOrderRecord o) async {
    final enriched = TagsBankService.enrichOrderWithStock(o);
    final int salePrice = (enriched['baseValue'] as num?)?.toInt() ??
        (enriched['salePrice'] as num?)?.toInt() ??
        (enriched['totalContractAmount'] as num?)?.toInt() ??
        0;
    final Map<String, dynamic> prefill = {
      ...enriched,
      'itemName': o['itemName']?.toString() ?? '',
      'salePrice': salePrice,
      'imeiNo': '',
      'serialNo': '',
      'isOnOrder': false,
    };
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StockInventoryPage(
          prefillOrderData: prefill,
          linkToOrderId: o['id']?.toString(),
          initialCategoryIndex: _isGeneralCategory(o) ? 1 : 0,
        ),
      ),
    );
    if (mounted) setState(() {});
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  List<({String label, String url, IconData fallbackIcon})> _buildPhotoSlides(
    PosOrderRecord o,
  ) {
    final List<({String label, String url, IconData fallbackIcon})> slides = [];
    final custPhoto = o['customerPhotoUrl']?.toString().trim() ?? '';
    slides.add((
      label: 'خریدار کی تصویر (${o['customerName'] ?? ''})',
      url: custPhoto,
      fallbackIcon: Icons.person_rounded,
    ));
    final guarName = o['guarantorName']?.toString().trim() ?? '';
    final guarPhoto = o['guarantorPhotoUrl']?.toString().trim() ?? '';
    if (guarName.isNotEmpty || (guarPhoto.isNotEmpty && guarPhoto != 'null')) {
      slides.add((
        label: 'ضامن کی تصویر ($guarName)',
        url: guarPhoto,
        fallbackIcon: Icons.shield_outlined,
      ));
    }
    return slides;
  }
  Widget _infoTile(String label, String value, {Color? valueColor}) {
    if (value.trim().isEmpty || value == 'null') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: valueColor ?? AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HiveBoxManager.listenToBox(BoxNames.shopOrdersBox),
      builder: (context, _, _) {
        final o = _liveOrder;
        final invoice = OrderInvoiceCalculatorService.buildInvoice(o);
        final slides = _buildPhotoSlides(o);
        final bool needsPurchase = _requiresStockPurchase(o);
        final status = (o['status']?.toString() ?? '').toUpperCase();
        final bool isClosed =
            status == 'AGREEMENT_COMPLETED' || status == 'DISMISSED_BY_COUNTER';
        final bool isHighRisk = o['isRiskOverLimit'] == true ||
            o['adminOverrideApplied'] == true;
        final int netRisk = (o['netRiskAmount'] as num?)?.toInt() ?? 0;
        final int maxRisk = (o['maxRiskLimit'] as num?)?.toInt() ?? 0;
        final String guaranteeLabel =
            o['guaranteeType']?.toString() == 'BANK_CHEQUE'
                ? 'بینک چیک (${o['bankName'] ?? ''} - ${o['chequeNo'] ?? ''})'
                : 'قانونی اسٹام و پرنوٹ';
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              toolbarHeight: 64,
              title: const Text(
                'مکمل آرڈر و کسٹمر پروفائل',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19),
              ),
              backgroundColor: AppColors.primaryEmerald,
              foregroundColor: Colors.white,
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.36,
                    color: AppColors.deepForestEmerald,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: slides.length,
                          onPageChanged: (idx) =>
                              setState(() => _activeSlide = idx),
                          itemBuilder: (context, index) {
                            final slide = slides[index];
                            final hasImg =
                                slide.url.isNotEmpty && slide.url != 'null';
                            return GestureDetector(
                              onTap: hasImg
                                  ? () => CustomerMediaViewerModalUi.show(
                                        context,
                                        title: slide.label,
                                        imagePath: slide.url,
                                      )
                                  : null,
                              child: Container(
                                color: Colors.black87,
                                child: PortableImageUi(
                                  pathOrUrl: slide.url,
                                  fit: BoxFit.contain,
                                  fallbackIcon: slide.fallbackIcon,
                                  fallbackIconSize: 84,
                                  fallbackColor: Colors.white54,
                                ),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          bottom: 8,
                          right: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                color: AppColors.goldHighlight,
                                width: 1.3,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    slides[_activeSlide].label,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                if (slides.length > 1)
                                  Text(
                                    '${_activeSlide + 1} / ${slides.length} (سوائپ کریں)',
                                    style: const TextStyle(
                                      color: AppColors.goldHighlight,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isHighRisk)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                color: AppColors.errorRed,
                                width: 1.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.gpp_maybe_rounded,
                                  color: AppColors.errorRed,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    netRisk > 0 && maxRisk > 0
                                        ? '🚨 ہائی رسک آرڈر الرٹ: اس سودے کی ادھار رقم (Rs. $netRisk) مقررہ رسک حد (Rs. $maxRisk) سے زائد ہے اور ایڈمن PIN سے منظور شدہ ہے۔'
                                        : '🚨 ہائی رسک آرڈر الرٹ: یہ آرڈر مقررہ رسک حد سے زائد ہے اور ایڈمن PIN سے منظور شدہ ہے۔',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.errorRed,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (needsPurchase)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                color: AppColors.pendingOrange,
                                width: 1.6,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.shopping_cart_checkout_rounded,
                                      color: AppColors.pendingOrange,
                                      size: 22,
                                    ),
                                    SizedBox(width: 7),
                                    Expanded(
                                      child: Text(
                                        '🛒 یہ آئٹم ابھی دکان اسٹاک میں درج نہیں ہے؛ پہلے ڈیلر سے خریداری (قیمتِ خرید، سپلائر اور IMEI) اسٹاک میں شامل کریں:',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF9A3412),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _openPrefilledStockPurchase(o),
                                  icon: const Icon(
                                      Icons.add_shopping_cart_rounded,
                                      size: 19),
                                  label: const Text(
                                    'اسٹاک خریداری و انٹری کریں (پری فِلڈ)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.pendingOrange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 11),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        OrderMirrorInvoiceCardUi(
                          invoice: invoice,
                          advance: (o['advance'] as num?)?.toInt() ?? 0,
                          monthly: (o['monthlyAmount'] as num?)?.toInt() ?? 0,
                          totalMonths:
                              (o['totalMonths'] as num?)?.toInt() ?? 0,
                          guaranteeText: guaranteeLabel,
                        ),
                        const SizedBox(height: 9),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '1. خریدار کے مکمل کوائف:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryEmerald,
                                ),
                              ),
                              const Divider(height: 12),
                              _infoTile(
                                  'پورا نام', o['customerName']?.toString() ?? ''),
                              _infoTile('ولدیت / قوم',
                                  '${o['customerFatherName'] ?? ''} (${o['customerCaste'] ?? ''})'),
                              _infoTile('شناختی کارڈ',
                                  o['customerCnic']?.toString() ?? ''),
                              _infoTile('رابطہ نمبر',
                                  o['customerPhone']?.toString() ?? ''),
                              _infoTile('سرپرست فون',
                                  o['guardianPhone']?.toString() ?? ''),
                              _infoTile('رہائشی پتہ',
                                  o['customerAddress']?.toString() ?? ''),
                            ],
                          ),
                        ),
                        if ((o['guarantorName']?.toString().trim() ?? '')
                            .isNotEmpty) ...[
                          const SizedBox(height: 9),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                  color: AppColors.pendingOrange, width: 1.2),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '2. ضامن کے مکمل کوائف:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.pendingOrange,
                                  ),
                                ),
                                const Divider(height: 12),
                                _infoTile('ضامن نام',
                                    o['guarantorName']?.toString() ?? ''),
                                _infoTile('ضامن ولدیت',
                                    o['guarantorFatherName']?.toString() ?? ''),
                                _infoTile('ضامن شناختی کارڈ',
                                    o['guarantorCnic']?.toString() ?? ''),
                                _infoTile('ضامن موبائل',
                                    o['guarantorPhone']?.toString() ?? ''),
                                _infoTile('رشتہ / تعلق',
                                    o['guarantorRelation']?.toString() ?? ''),
                                _infoTile('ضامن پتہ',
                                    o['guarantorAddress']?.toString() ?? ''),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.cardSurface,
                border: Border(top: BorderSide(color: AppColors.borderLight)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: needsPurchase
                            ? () => _openPrefilledStockPurchase(o)
                            : () {
                                Navigator.pop(context);
                                widget.onLoadToCounter(o);
                              },
                        icon: Icon(
                          needsPurchase
                              ? Icons.add_shopping_cart_rounded
                              : Icons.assignment_turned_in_rounded,
                          size: 20,
                        ),
                        label: Text(
                          needsPurchase
                              ? 'پہلے اسٹاک خریداری درج کریں'
                              : 'کاؤنٹر بالٹی میں لوڈ کریں',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: needsPurchase
                              ? AppColors.pendingOrange
                              : AppColors.primaryEmerald,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    if (!isClosed) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onDismissOrder();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.errorRed,
                            side: const BorderSide(
                                color: AppColors.errorRed, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'ختم کریں',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}