import 'package:flutter/material.dart';
import '../../core/models/customer_deal_model.dart';
import '../../core/models/customer_profile_model.dart';
import 'args/customer_detail_args.dart';
import 'services/customer_detail_service.dart';

class CustomerDetailController extends ChangeNotifier {
  final CustomerDetailArgs args;

  CustomerDetailController(this.args);

  CustomerProfileModel? get profile =>
      CustomerDetailService.getProfileById(args.customerId);

  List<CustomerDealModel> get deals =>
      CustomerDetailService.getDealsByCnic(args.customerCnic);

  Future<void> deleteSingleDeal(String dealId) async {
    await CustomerDetailService.deleteSingleDeal(dealId);
    notifyListeners();
  }

  Future<void> deleteEntireProfile() async {
    await CustomerDetailService.deleteProfileAndDeals(
      args.customerId,
      args.customerCnic,
    );
  }

  Future<void> loadDealToCounter(CustomerDealModel deal) async {
    await CustomerDetailService.loadDealIntoDraft(deal, asLegalNotice: false);
  }

  Future<void> prepareNoticeToCounter(CustomerDealModel deal) async {
    await CustomerDetailService.loadDealIntoDraft(deal, asLegalNotice: true);
  }
}