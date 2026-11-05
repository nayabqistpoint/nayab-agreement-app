import 'package:flutter/material.dart';
import '../../core/constants/box_names.dart';
import '../../core/database/hive_box_manager.dart';
import '../../shared_models/customer_profile_model.dart';
import '../../shared_services/agreement_storage_handler_service.dart';
import '../../shared_services/payload_builders/agreement_payload_builder.dart';

class CustomerDirectoryController extends ChangeNotifier {
  List<CustomerProfileModel> profiles = [];
  String searchQuery = '';

  void loadProfiles() {
    final box = HiveBoxManager.getBox(BoxNames.customerProfilesBox);
    profiles = box.values
        .whereType()
        .map((m) => CustomerProfileModel.fromMap(Map<String, dynamic>.from(m)))
        .where((p) => !p.isDeleted)
        .toList();
    notifyListeners();
  }

  List<CustomerProfileModel> get filteredProfiles {
    if (searchQuery.trim().isEmpty) return profiles;
    return profiles.where((p) {
      return p.fullName.contains(searchQuery) ||
          p.cnic.contains(searchQuery) ||
          p.phone.contains(searchQuery);
    }).toList();
  }

  void updateSearch(String q) {
    searchQuery = q;
    notifyListeners();
  }

  Future<void> saveProfile(CustomerProfileModel profile) async {
    final payload = AgreementPayloadBuilder.buildProfilePayload(profile);
    await AgreementStorageHandlerService.saveCustomerProfile(payload);
    loadProfiles();
  }
}