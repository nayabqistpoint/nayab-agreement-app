import '../../../../core/constants/box_names.dart';
import '../../../../core/database/hive_box_manager.dart';
import '../../../../core/models/customer_deal_model.dart';

class CustomerDealHistoryService {
  static List<CustomerDealModel> getCustomerDeals(String cnic) {
    final cleanCnic = cnic.trim();
    if (cleanCnic.isEmpty) return [];

    try {
      final box = HiveBoxManager.getBox(BoxNames.customerDealsBox);
      final List<CustomerDealModel> deals = [];

      for (var key in box.keys) {
        final raw = box.get(key);
        if (raw is Map) {
          final deal = CustomerDealModel.fromMap(raw);
          if (deal.customerCnic.replaceAll('-', '') == cleanCnic.replaceAll('-', '') && !deal.isDeleted) {
            deals.add(deal);
          }
        }
      }

      deals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return deals;
    } catch (_) {
      return [];
    }
  }
}