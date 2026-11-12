import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/customer_profile_model.dart';
import 'components/customer_detail_sheet_ui.dart';
import 'components/customer_profile_tile_ui.dart';
import 'customer_directory_controller.dart';

class CustomerDirectoryPage extends StatefulWidget {
  const CustomerDirectoryPage({super.key});

  @override
  State<CustomerDirectoryPage> createState() => _CustomerDirectoryPageState();
}

class _CustomerDirectoryPageState extends State<CustomerDirectoryPage> {
  late final CustomerDirectoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CustomerDirectoryController();
    _controller.addListener(() => setState(() {}));
    _controller.loadProfiles();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openCustomerDetails(CustomerProfileModel customer) {
    final deals = _controller.fetchDealsForCustomer(customer.cnic);
    CustomerDetailSheetUi.show(
      context: context,
      customer: customer,
      deals: deals,
      onGenerateNotice: (deal) async {
        final nav = Navigator.of(context);
        await _controller.createNoticeForDeal(deal);
        if (!mounted) return;
        nav.pop(); // باٹم شیٹ بند
        nav.pop(); // کاؤنٹر پر واپسی
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _controller.filteredProfiles;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('کسٹمر و ضامن ڈائریکٹری', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
          backgroundColor: AppColors.primaryEmerald,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                textAlign: TextAlign.right,
                onChanged: _controller.updateSearch,
                decoration: InputDecoration(
                  hintText: 'نام، شناختی کارڈ یا فون سے تلاش کریں...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? const Center(
                      child: Text('کوئی ریکارڈ نہیں ملا۔', style: TextStyle(color: AppColors.textMuted)),
                    )
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final p = list[index];
                        return CustomerProfileTileUi(
                          customer: p,
                          onTap: () => _openCustomerDetails(p),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}