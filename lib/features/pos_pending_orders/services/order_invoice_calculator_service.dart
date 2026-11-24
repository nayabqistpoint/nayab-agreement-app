import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import 'pos_pending_orders_service.dart';
class OrderInvoiceLine {
  final String itemName;
  final String hashBadge;
  final int quantity;
  final int unitCashPrice;
  final int lineCashSubTotal;
  final int unitPurchasePrice;
  final int unitCashProfit;
  final int lineCashProfit;
  const OrderInvoiceLine({
    required this.itemName,
    required this.hashBadge,
    required this.quantity,
    required this.unitCashPrice,
    required this.lineCashSubTotal,
    required this.unitPurchasePrice,
    required this.unitCashProfit,
    required this.lineCashProfit,
  });
}
class OrderInvoiceSummary {
  final String combinedHashBadge;
  final List<OrderInvoiceLine> lines;
  final int totalPieces;
  final int totalCashBase;
  final int totalPurchaseCost;
  final int totalCashProfit;
  final int installmentMarkupProfit;
  final int totalContractAmount;
  final int grandNetProfit;
  final bool hasPurchaseData;
  const OrderInvoiceSummary({
    required this.combinedHashBadge,
    required this.lines,
    required this.totalPieces,
    required this.totalCashBase,
    required this.totalPurchaseCost,
    required this.totalCashProfit,
    required this.installmentMarkupProfit,
    required this.totalContractAmount,
    required this.grandNetProfit,
    required this.hasPurchaseData,
  });
}
class OrderInvoiceCalculatorService {
  static String formatHashBadge(List<String> stockIds) {
    final clean = stockIds
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e != 'null' && e != 'MULTI_CART')
        .toList();
    if (clean.isEmpty) return '';
    final nums = clean.map((id) {
      final m = RegExp(r'(\d+)').firstMatch(id);
      if (m != null) {
        final v = int.tryParse(m.group(1) ?? '');
        if (v != null) return '#$v';
      }
      return '#$id';
    }).toList();
    return nums.join(', ');
  }
  static PosOrderRecord? _findStockById(String id) {
    final clean = id.trim();
    if (clean.isEmpty || clean == 'null' || clean == 'MULTI_CART') return null;
    try {
      final box = HiveBoxManager.getBox(BoxNames.stockBox);
      final direct = box.get(clean);
      if (direct is Map) return PosOrderRecord.from(direct);
      for (final k in box.keys) {
        final raw = box.get(k);
        if (raw is Map &&
            (raw['stockId']?.toString().trim() == clean ||
                raw['id']?.toString().trim() == clean)) {
          return PosOrderRecord.from(raw);
        }
      }
    } catch (_) {}
    return null;
  }
  static OrderInvoiceSummary buildInvoice(PosOrderRecord order) {
    final int totalContract =
        (order['totalContractAmount'] as num?)?.toInt() ?? 0;
    final List<String> allStockIds = (order['stockIds'] is List)
        ? (order['stockIds'] as List)
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty && e != 'null' && e != 'MULTI_CART')
            .toList()
        : <String>[];
    final singleId = order['stockId']?.toString().trim() ?? '';
    if (allStockIds.isEmpty &&
        singleId.isNotEmpty &&
        singleId != 'null' &&
        singleId != 'MULTI_CART') {
      allStockIds.add(singleId);
    }
    final List<OrderInvoiceLine> lines = [];
    if (order['itemsBreakdown'] is List &&
        (order['itemsBreakdown'] as List).isNotEmpty) {
      for (final rawLine in (order['itemsBreakdown'] as List)) {
        if (rawLine is! Map) continue;
        final name = rawLine['itemName']?.toString().trim() ?? 'آئٹم';
        final int qty =
            ((rawLine['quantity'] as num?)?.toInt() ?? 1).clamp(1, 999);
        final int uSale = (rawLine['unitSalePrice'] as num?)?.toInt() ?? 0;
        int uPurch = (rawLine['unitPurchasePrice'] as num?)?.toInt() ?? 0;
        final lineIds = (rawLine['stockIds'] is List)
            ? (rawLine['stockIds'] as List)
                .map((e) => e.toString().trim())
                .where((e) => e.isNotEmpty)
                .toList()
            : <String>[];
        if (uPurch <= 0 && lineIds.isNotEmpty) {
          final st = _findStockById(lineIds.first);
          if (st != null) {
            uPurch = (st['purchasePrice'] as num?)?.toInt() ?? 0;
          }
        }
        final int subSale = uSale * qty;
        final int uProfit = uPurch > 0 ? (uSale - uPurch) : 0;
        final int lineProfit = uProfit * qty;
        lines.add(OrderInvoiceLine(
          itemName: name,
          hashBadge: formatHashBadge(lineIds),
          quantity: qty,
          unitCashPrice: uSale,
          lineCashSubTotal: subSale,
          unitPurchasePrice: uPurch,
          unitCashProfit: uProfit,
          lineCashProfit: lineProfit,
        ));
      }
    } else if (allStockIds.length > 1) {
      final Map<String, List<PosOrderRecord>> groupedUnits = {};
      for (final sid in allStockIds) {
        final st = _findStockById(sid);
        final name = st?['itemName']?.toString().trim() ?? 'آئٹم';
        final uSale = (st?['salePrice'] as num?)?.toInt() ?? 0;
        final uPurch = (st?['purchasePrice'] as num?)?.toInt() ?? 0;
        final key = '$name|$uSale|$uPurch';
        groupedUnits.putIfAbsent(key, () => <PosOrderRecord>[]).add({
          'stockId': sid,
          'itemName': name,
          'unitSalePrice': uSale,
          'unitPurchasePrice': uPurch,
        });
      }
      for (final group in groupedUnits.values) {
        final first = group.first;
        final int qty = group.length;
        final int uSale = first['unitSalePrice'] as int;
        final int uPurch = first['unitPurchasePrice'] as int;
        final ids = group.map((e) => e['stockId'].toString()).toList();
        final int uProfit = uPurch > 0 ? (uSale - uPurch) : 0;
        lines.add(OrderInvoiceLine(
          itemName: first['itemName'].toString(),
          hashBadge: formatHashBadge(ids),
          quantity: qty,
          unitCashPrice: uSale,
          lineCashSubTotal: uSale * qty,
          unitPurchasePrice: uPurch,
          unitCashProfit: uProfit,
          lineCashProfit: uProfit * qty,
        ));
      }
    } else {
      final String name =
          (order['itemName']?.toString().trim() ?? 'آئٹم').replaceAll(
        RegExp(r'\s*\(×\d+\s*پیس\)\s*$'),
        '',
      );
      final int qty = ((order['quantity'] as num?)?.toInt() ?? 1).clamp(1, 999);
      final st =
          allStockIds.isNotEmpty ? _findStockById(allStockIds.first) : null;
      final int totalBase = (order['baseValue'] as num?)?.toInt() ?? 0;
      int uSale = (st?['salePrice'] as num?)?.toInt() ?? 0;
      if (uSale <= 0 && totalBase > 0) {
        uSale = totalBase ~/ qty;
      }
      final int uPurch = (st?['purchasePrice'] as num?)?.toInt() ??
          (order['purchasePrice'] as num?)?.toInt() ??
          0;
      final int uProfit = uPurch > 0 ? (uSale - uPurch) : 0;
      lines.add(OrderInvoiceLine(
        itemName: name,
        hashBadge: formatHashBadge(allStockIds),
        quantity: qty,
        unitCashPrice: uSale,
        lineCashSubTotal: uSale * qty,
        unitPurchasePrice: uPurch,
        unitCashProfit: uProfit,
        lineCashProfit: uProfit * qty,
      ));
    }
    int sumPieces = 0;
    int sumCashBase = 0;
    int sumPurchase = 0;
    int sumCashProfit = 0;
    bool anyPurchase = false;
    for (final l in lines) {
      sumPieces += l.quantity;
      sumCashBase += l.lineCashSubTotal;
      if (l.unitPurchasePrice > 0) {
        anyPurchase = true;
        sumPurchase += (l.unitPurchasePrice * l.quantity);
        sumCashProfit += l.lineCashProfit;
      }
    }
    final int markupProfit = (totalContract - sumCashBase) > 0
        ? (totalContract - sumCashBase)
        : 0;
    final int grandProfit = anyPurchase
        ? (totalContract - sumPurchase)
        : markupProfit;
    return OrderInvoiceSummary(
      combinedHashBadge: formatHashBadge(allStockIds),
      lines: lines,
      totalPieces: sumPieces,
      totalCashBase: sumCashBase,
      totalPurchaseCost: sumPurchase,
      totalCashProfit: sumCashProfit,
      installmentMarkupProfit: markupProfit,
      totalContractAmount: totalContract,
      grandNetProfit: grandProfit,
      hasPurchaseData: anyPurchase,
    );
  }
}