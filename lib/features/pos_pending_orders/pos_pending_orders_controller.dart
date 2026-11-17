import 'package:flutter/material.dart';
import '../../core/constants/box_names.dart';
import '../../core/database/hive_box_manager.dart';
import 'services/pos_pending_orders_service.dart';

class PosPendingOrdersController extends ChangeNotifier {
  /// 'ALL' = سب آرڈرز, 'PENDING' = صرف پینڈنگ, 'HISTORY' = مکمل / ہٹائے گئے
  String statusFilter = 'ALL';
  String searchQuery = '';

  PosPendingOrdersController() {
    final pendingCount = PosPendingOrdersService.getPendingOrders().length;
    statusFilter = pendingCount > 0 ? 'PENDING' : 'ALL';
  }

  String? get activeOrderId {
    final draftBox = HiveBoxManager.getBox(BoxNames.agreementDraftBox);
    return draftBox.get('activePosOrderId')?.toString();
  }

  void setStatusFilter(String filter) {
    statusFilter = filter;
    notifyListeners();
  }

  void updateSearch(String q) {
    searchQuery = q;
    notifyListeners();
  }

  List<PosOrderRecord> getFilteredOrders() {
    final all = PosPendingOrdersService.getAllOrders();
    List<PosOrderRecord> baseList;
    if (statusFilter == 'PENDING') {
      baseList = PosPendingOrdersService.getPendingOrders();
    } else if (statusFilter == 'HISTORY') {
      baseList = all.where((map) {
        final st = (map['status']?.toString() ?? '').trim().toUpperCase();
        return st == 'AGREEMENT_COMPLETED' ||
            st == 'DISMISSED_BY_COUNTER' ||
            st == 'CANCELLED';
      }).toList();
    } else {
      baseList = all;
    }

    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return baseList;
    final cleanQ = q.replaceAll('-', '');

    return baseList.where((order) {
      final name = (order['customerName']?.toString() ?? '').toLowerCase();
      final cnic = (order['customerCnic']?.toString() ?? '')
          .replaceAll('-', '')
          .toLowerCase();
      final gName = (order['guarantorName']?.toString() ?? '').toLowerCase();
      final gCnic = (order['guarantorCnic']?.toString() ?? '')
          .replaceAll('-', '')
          .toLowerCase();
      final phone = (order['customerPhone']?.toString() ?? '').toLowerCase();
      final model = (order['itemName']?.toString() ?? '').toLowerCase();
      final stkId = (order['stockId']?.toString() ?? '').toLowerCase();

      return name.contains(q) ||
          cnic.contains(cleanQ) ||
          gName.contains(q) ||
          gCnic.contains(cleanQ) ||
          phone.contains(q) ||
          model.contains(q) ||
          stkId.contains(q);
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