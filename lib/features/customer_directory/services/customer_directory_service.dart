import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../../core/models/customer_profile_model.dart';
import '../../../core/time/time_status_service.dart';

class CustomerDirectoryService {
  static List<CustomerProfileModel> getAllActiveProfiles() {
    final box = HiveBoxManager.getBox(BoxNames.customersBox);
    final List<CustomerProfileModel> all = [];

    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        final profile =
            CustomerProfileModel.fromMap(Map<String, dynamic>.from(raw));
        if (!profile.isDeleted) {
          all.add(profile);
        }
      }
    }

    all.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return all;
  }

  static Future<void> deleteCustomersAndDeals(Set<String> customerIds) async {
    if (customerIds.isEmpty) return;
    final now = TimeStatusService.nowUtcIso();

    final custBox = HiveBoxManager.getBox(BoxNames.customersBox);
    final dealsBox = HiveBoxManager.getBox(BoxNames.customerDealsBox);

    final Map<String, dynamic> custUpdates = {};
    final Set<String> targetCnics = {};

    for (final id in customerIds) {
      final raw = custBox.get(id);
      if (raw is Map) {
        final map = Map<String, dynamic>.from(raw);
        final cnic = map['cnic']?.toString().trim() ?? id;
        targetCnics.add(cnic.replaceAll('-', ''));
        map['isDeleted'] = true;
        map['isSynced'] = false;
        map['updatedAt'] = now;
        custUpdates[id] = map;
      }
    }

    final Map<String, dynamic> dealUpdates = {};
    for (final key in dealsBox.keys) {
      final rawDeal = dealsBox.get(key);
      if (rawDeal is Map) {
        final dMap = Map<String, dynamic>.from(rawDeal);
        final dCnic =
            (dMap['customerCnic']?.toString() ?? '').replaceAll('-', '').trim();
        if (targetCnics.contains(dCnic)) {
          dMap['isDeleted'] = true;
          dMap['isSynced'] = false;
          dMap['updatedAt'] = now;
          dealUpdates[key.toString()] = dMap;
        }
      }
    }

    if (custUpdates.isNotEmpty) {
      await HiveBoxManager.putBatch(
        boxName: BoxNames.customersBox,
        entries: custUpdates,
      );
    }
    if (dealUpdates.isNotEmpty) {
      await HiveBoxManager.putBatch(
        boxName: BoxNames.customerDealsBox,
        entries: dealUpdates,
      );
    }
  }
}