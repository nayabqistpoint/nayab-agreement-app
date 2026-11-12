import 'package:flutter/material.dart';
import '../../core/constants/box_names.dart';
import '../../core/database/hive_box_manager.dart';
import '../../core/models/customer_deal_model.dart';
import '../../core/models/customer_profile_model.dart';
import 'services/customer_deal_history_service.dart';
import 'services/customer_notice_generator_service.dart';

class CustomerDirectoryController extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  List<CustomerProfileModel> allCustomers = [];
  List<CustomerProfileModel> filteredCustomers = [];
  bool isLoading = false;

  List<CustomerProfileModel> get filteredProfiles => filteredCustomers;

  void init() {
    loadCustomers();
    searchController.addListener(_onSearchChanged);
  }

  void loadProfiles() => loadCustomers();

  void updateSearch(String query) {
    searchController.text = query;
  }

  void loadCustomers() {
    isLoading = true;
    notifyListeners();

    try {
      final box = HiveBoxManager.getBox(BoxNames.customersBox);
      final List<CustomerProfileModel> loaded = [];

      for (var key in box.keys) {
        final raw = box.get(key);
        if (raw is Map) {
          final profile = CustomerProfileModel.fromMap(Map<String, dynamic>.from(raw));
          if (!profile.isDeleted) {
            loaded.add(profile);
          }
        }
      }

      allCustomers = loaded;
      _applyFilter();
    } catch (e) {
      debugPrint('Error loading customers: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  void _onSearchChanged() {
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      filteredCustomers = List.from(allCustomers);
    } else {
      filteredCustomers = allCustomers.where((c) {
        final nameMatch = c.fullName.toLowerCase().contains(query);
        final cnicMatch = c.cnic.replaceAll('-', '').contains(query.replaceAll('-', ''));
        final phoneMatch = c.phone.contains(query);
        return nameMatch || cnicMatch || phoneMatch;
      }).toList();
    }
  }

  List<CustomerDealModel> fetchDealsForCustomer(String cnic) {
    return CustomerDealHistoryService.getCustomerDeals(cnic);
  }

  Future<void> createNoticeForDeal(CustomerDealModel deal) async {
    await CustomerNoticeGeneratorService.prepareNoticeInDraft(deal);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
}