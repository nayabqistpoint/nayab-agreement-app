import 'package:flutter/material.dart';
import '../../core/constants/box_names.dart';
import '../../core/database/hive_box_manager.dart';
import 'services/pos_pending_orders_service.dart';

class PosPendingOrdersController extends ChangeNotifier {
  late bool showAllHistory;
  String searchQuery = '';

  PosPendingOrdersController() {
    final pendingCount = PosPendingOrdersService.getPendingOrders().length;
    final allCount = PosPendingOrdersService.getAllOrders().length;
    // اگر پینڈنگ آرڈرز صفر ہوں لیکن ہسٹری میں ریکارڈ موجود ہو تو سیدھا تمام آرڈرز دکھائیں
    showAllHistory = pendingCount == 0 && allCount > 0;
  }

  String? get activeOrderId {
    final draftBox = HiveBoxManager.getBox(BoxNames.agreementDraftBox);
    return draftBox.get('activePosOrderId')?.toString();
  }

  void toggleHistoryFilter(bool showAll) {
    showAllHistory = showAll;
    notifyListeners();
  }

  void updateSearch(String q) {
    searchQuery = q;
    notifyListeners();
  }

  List<PosOrderRecord> getFilteredOrders() {
    final baseList = showAllHistory
        ? PosPendingOrdersService.getAllOrders()
        : PosPendingOrdersService.getPendingOrders();

    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return baseList;

    return baseList.where((order) {
      final name = (order['customerName']?.toString() ?? '').toLowerCase();
      final cnic = (order['customerCnic']?.toString() ?? '')
          .replaceAll('-', '')
          .toLowerCase();
      final phone = (order['customerPhone']?.toString() ?? '').toLowerCase();
      final model = (order['itemName']?.toString() ?? '').toLowerCase();
      final cleanQ = q.replaceAll('-', '');
      return name.contains(q) ||
          cnic.contains(cleanQ) ||
          phone.contains(q) ||
          model.contains(q);
    }).toList();
  }

  Future<void> selectOrderForCounter(PosOrderRecord order) async {
    await PosPendingOrdersService.applyOrderToDraftBucket(order);
  }

  Future<void> dismissOrder(String orderId) async {
    await PosPendingOrdersService.dismissOrder(orderId);
    notifyListeners();
  }
}