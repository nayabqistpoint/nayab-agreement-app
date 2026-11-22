import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/box_names.dart';
import '../../core/database/hive_box_manager.dart';
import 'components/pos_pending_order_card_ui.dart';
import 'pos_order_full_profile_page.dart';
import 'pos_pending_orders_controller.dart';
import 'services/pos_pending_orders_service.dart';
class PosPendingOrdersPage extends StatefulWidget {
  final String? initialFilter;
  const PosPendingOrdersPage({super.key, this.initialFilter});
  @override
  State<PosPendingOrdersPage> createState() => _PosPendingOrdersPageState();
}
class _PosPendingOrdersPageState extends State<PosPendingOrdersPage> {
  late final PosPendingOrdersController _controller;
  @override
  void initState() {
    super.initState();
    _controller =
        PosPendingOrdersController(initialFilter: widget.initialFilter);
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  bool _requiresStockPurchaseFirst(PosOrderRecord order) {
    final stockId = order['stockId']?.toString().trim() ?? '';
    final sourceMode = (order['sourceMode']?.toString() ?? '').toUpperCase();
    final isCustom = order['isCustomEstimate'] == true ||
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
  Future<void> _handleOrderSelection(PosOrderRecord selectedOrder) async {
    final id = selectedOrder['id']?.toString() ?? '';
    final customer = selectedOrder['customerName']?.toString() ?? 'کسٹمر';
    if (_requiresStockPurchaseFirst(selectedOrder)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PosOrderFullProfilePage(
            order: selectedOrder,
            onLoadToCounter: (updatedOrder) =>
                _handleOrderSelection(updatedOrder),
            onDismissOrder: () => _confirmDismiss(id, customer),
          ),
        ),
      );
      return;
    }
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await _controller.selectOrderForCounter(selectedOrder);
    if (!mounted) return;
    nav.pop(true);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '$customer کی معلومات ایگریمنٹ بالٹی میں لوڈ ہو گئی ہیں!',
        ),
        backgroundColor: AppColors.primaryEmerald,
      ),
    );
  }
  void _confirmDismiss(String orderId, String customerName) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'آرڈر پینڈنگ لسٹ سے ہٹائیں؟',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Text(
            'کیا آپ "$customerName" کا یہ آرڈر کاؤنٹر کی پینڈنگ لسٹ سے ختم کرنا چاہتے ہیں؟ (ریکارڈ ہسٹری میں محفوظ رہے گا)',
            style: const TextStyle(fontSize: 13.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('منسوخ'),
            ),
            ElevatedButton(
              onPressed: () async {
                final dialogNav = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);
                await _controller.dismissOrder(orderId);
                if (ctx.mounted) dialogNav.pop();
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('آرڈر پینڈنگ لسٹ سے ختم کر دیا گیا ہے'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('ہاں، ختم کریں'),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildFilterTab(
    String key,
    String label,
    int count, {
    int badgeCount = 0,
  }) {
    final isSelected = _controller.statusFilter == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => _controller.setStatusFilter(key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryEmerald : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryEmerald
                  : (badgeCount > 0
                      ? Colors.amber.shade700
                      : const Color(0xFFCBD5E1)),
              width: badgeCount > 0 ? 1.6 : 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  '$label ($count)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ),
              if (badgeCount > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  Widget _invoiceRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: isBold ? 14.5 : 13,
                fontWeight: isBold ? FontWeight.w900 : FontWeight.w800,
                color: valueColor ?? AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCashSaleCard(PosOrderRecord order) {
    final id = order['id']?.toString() ?? '';
    final itemName = order['itemName']?.toString() ?? 'آئٹم';
    final stockId = order['stockId']?.toString() ?? '';
    final imei = order['imeiNo']?.toString() ?? '';
    final int qty = (order['quantity'] as num?)?.toInt() ?? 1;
    final int unitPrice = (order['unitCashPrice'] as num?)?.toInt() ??
        ((int.tryParse(order['totalContractAmount']?.toString() ?? '0') ?? 0) ~/
            (qty > 0 ? qty : 1));
    final int totalSale =
        (order['totalContractAmount'] as num?)?.toInt() ?? (unitPrice * qty);
    final int totalBaseSalePrice =
        (order['totalBaseSalePrice'] as num?)?.toInt() ?? 0;
    final int totalPurchase =
        (order['totalPurchasePrice'] as num?)?.toInt() ?? 0;
    final int netProfit = totalPurchase > 0 ? (totalSale - totalPurchase) : 0;
    final int baseDiff =
        totalBaseSalePrice > 0 ? (totalSale - totalBaseSalePrice) : 0;
    final customer = order['customerName']?.toString() ?? 'نقد کسٹمر';
    final phone = order['customerPhone']?.toString() ?? '';
    final sellerLabel = order['soldByLabel']?.toString() ??
        (order['soldByDeviceId']?.toString() ?? 'POS کاؤنٹر');
    final createdAt = (order['createdAt']?.toString() ?? '').split('T').first;
    final bool isRead = order['isCashSaleRead'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? AppColors.cardSurface : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isRead ? AppColors.borderLight : Colors.amber.shade700,
          width: isRead ? 1.3 : 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color:
                  isRead ? AppColors.primaryEmerald : const Color(0xFF004D40),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12.5),
                topRight: Radius.circular(12.5),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.goldHighlight,
                  size: 20,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نقد فروخت انوائس ($id)',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'تاریخ: $createdAt • سیلز مین: $sellerLabel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.goldHighlight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isRead ? Colors.white : AppColors.errorRed,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isRead ? '✓ تصدیق شدہ' : '● نئی انوائس',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: isRead ? AppColors.primaryEmerald : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.warmTintEmerald,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: AppColors.emeraldPillBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              itemName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryEmerald,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$qty پیس',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (stockId.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'اسٹاک IDs: $stockId',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryEmerald,
                          ),
                        ),
                      ],
                      if (imei.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'IMEI / سیریل: $imei',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _invoiceRow('فی پیس نقد قیمت:', 'Rs. $unitPrice'),
                if (totalBaseSalePrice > 0) ...[
                  _invoiceRow('کل بیس سیل پرائس:', 'Rs. $totalBaseSalePrice'),
                  if (baseDiff != 0)
                    _invoiceRow(
                      baseDiff > 0 ? 'بیس سے زائد وصولی:' : 'بیس سے دی گئی رعایت:',
                      baseDiff > 0 ? '+ Rs. $baseDiff' : '- Rs. ${baseDiff.abs()}',
                      valueColor: baseDiff > 0
                          ? AppColors.successGreen
                          : AppColors.pendingOrange,
                      isBold: true,
                    ),
                ],
                if (totalPurchase > 0) ...[
                  _invoiceRow('کل قیمتِ خرید (لاگت):', 'Rs. $totalPurchase'),
                  _invoiceRow(
                    'خالص نقد منافع:',
                    'Rs. $netProfit',
                    valueColor: netProfit >= 0
                        ? AppColors.successGreen
                        : AppColors.errorRed,
                    isBold: true,
                  ),
                ],
                const Divider(height: 12, color: AppColors.borderLight),
                _invoiceRow(
                  'کل نقد وصولی ($qty پیس):',
                  'Rs. $totalSale',
                  valueColor: AppColors.primaryEmerald,
                  isBold: true,
                ),
                _invoiceRow(
                  'خریدار:',
                  phone.isNotEmpty ? '$customer ($phone)' : customer,
                ),
                if (!isRead) ...[
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () =>
                        PosPendingOrdersService.markCashSaleAsRead(id),
                    icon: const Icon(Icons.done_all_rounded, size: 18),
                    label: const Text(
                      'تصدیق کریں / پڑھ لیا (بیج صاف کریں)',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w900),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryEmerald,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                ],
              ],
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
        final installmentOrders =
            PosPendingOrdersService.getInstallmentOrders();
        final pendingOrders = PosPendingOrdersService.getPendingOrders();
        final cashOrders = PosPendingOrdersService.getCashSaleOrders();
        final int unreadCashCount =
            PosPendingOrdersService.getUnreadCashSalesCount();
        final int allCount = installmentOrders.length;
        final int pendingCount = pendingOrders.length;
        final int historyCount =
            allCount > pendingCount ? (allCount - pendingCount) : 0;
        final list = _controller.getFilteredOrders();
        final activeId = _controller.activeOrderId;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              title: const Text(
                'POS آرڈرز و نقد سیل ریکارڈ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              backgroundColor: AppColors.primaryEmerald,
              foregroundColor: Colors.white,
              actions: [
                if (_controller.statusFilter == 'CASH' && unreadCashCount > 0)
                  TextButton.icon(
                    onPressed: () =>
                        PosPendingOrdersService.markAllCashSalesAsRead(),
                    icon: const Icon(Icons.done_all_rounded,
                        color: AppColors.goldHighlight, size: 19),
                    label: const Text(
                      'سب پڑھ لیے',
                      style: TextStyle(
                        color: AppColors.goldHighlight,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                  child: TextField(
                    textAlign: TextAlign.right,
                    onChanged: _controller.updateSearch,
                    decoration: InputDecoration(
                      hintText:
                          'کسٹمر، ضامن، شناختی کارڈ، فون یا ماڈل سے تلاش کریں...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 2, 10, 8),
                  child: Row(
                    children: [
                      _buildFilterTab('PENDING', 'زیرِ التواء', pendingCount),
                      const SizedBox(width: 5),
                      _buildFilterTab(
                        'CASH',
                        'نقد سیلز',
                        cashOrders.length,
                        badgeCount: unreadCashCount,
                      ),
                      const SizedBox(width: 5),
                      _buildFilterTab('HISTORY', 'مکمل قسط', historyCount),
                      const SizedBox(width: 5),
                      _buildFilterTab('ALL', 'سب قسط', allCount),
                    ],
                  ),
                ),
                Expanded(
                  child: list.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.point_of_sale_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _controller.statusFilter == 'CASH'
                                    ? 'ابھی تک کوئی نقد فروخت ریکارڈ نہیں ہوئی۔'
                                    : (_controller.statusFilter == 'PENDING'
                                        ? 'اس وقت کوئی نیا زیرِ التواء آرڈر نہیں ہے۔'
                                        : 'اس حصے میں کوئی آرڈر ریکارڈ موجود نہیں ہے۔'),
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final order = list[index];
                            if (PosPendingOrdersService.isCashSaleRecord(
                                order)) {
                              return _buildCashSaleCard(order);
                            }
                            final id = order['id']?.toString() ?? '';
                            final customer =
                                order['customerName']?.toString() ?? 'کسٹمر';
                            return PosPendingOrderCardUi(
                              order: order,
                              isCurrentlyActive: id == activeId,
                              onSelect: _handleOrderSelection,
                              onDismiss: () => _confirmDismiss(id, customer),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}