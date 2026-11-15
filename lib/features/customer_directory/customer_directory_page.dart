import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/box_names.dart';
import '../../core/database/hive_box_manager.dart';
import '../../core/models/customer_profile_model.dart';
import '../customer_detail/args/customer_detail_args.dart';
import '../customer_detail/customer_detail_page.dart';
import 'components/customer_profile_tile_ui.dart';
import 'services/customer_directory_service.dart';

class CustomerDirectoryPage extends StatefulWidget {
  const CustomerDirectoryPage({super.key});

  @override
  State<CustomerDirectoryPage> createState() => _CustomerDirectoryPageState();
}

class _CustomerDirectoryPageState extends State<CustomerDirectoryPage> {
  String _searchQuery = '';
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  List<CustomerProfileModel> _getFilteredList() {
    final all = CustomerDirectoryService.getAllActiveProfiles();
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return all;

    return all.where((c) {
      final nameMatch = c.fullName.toLowerCase().contains(q);
      final cnicMatch =
          c.cnic.replaceAll('-', '').contains(q.replaceAll('-', ''));
      final phoneMatch = c.phone.contains(q);
      return nameMatch || cnicMatch || phoneMatch;
    }).toList();
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedIds.add(id);
        _isSelectionMode = true;
      }
    });
  }

  void _selectAll(List<CustomerProfileModel> visibleList) {
    setState(() {
      _isSelectionMode = true;
      _selectedIds.addAll(visibleList.map((e) => e.id));
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedIds.clear();
    });
  }

  void _confirmBatchDelete() {
    if (_selectedIds.isEmpty) return;
    final count = _selectedIds.length;
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            '$count منتخب ریکارڈز حذف کریں؟',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: const Text(
            'کیا آپ واقعی منتخب کردہ تمام افراد اور ان کے منسلک معاہدات کو ہمیشہ کے لیے حذف کرنا چاہتے ہیں؟',
            style: TextStyle(fontSize: 13.5),
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
                final toDelete = Set<String>.from(_selectedIds);
                await CustomerDirectoryService.deleteCustomersAndDeals(
                    toDelete);
                if (ctx.mounted) dialogNav.pop();
                if (!mounted) return;
                _exitSelectionMode();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('✅ $count ریکارڈز کامیابی سے حذف کر دیے گئے'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('ہاں، حذف کریں'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HiveBoxManager.listenToBox(BoxNames.customersBox),
      builder: (context, custBox, child) {
        final list = _getFilteredList();

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              title: Text(
                _isSelectionMode
                    ? '${_selectedIds.length} منتخب شدہ'
                    : 'کسٹمر و ضامن ڈائریکٹری (${list.length})',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              backgroundColor: _isSelectionMode
                  ? Colors.blueGrey.shade800
                  : AppColors.primaryEmerald,
              foregroundColor: Colors.white,
              leading: _isSelectionMode
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _exitSelectionMode,
                    )
                  : null,
              actions: [
                if (_isSelectionMode) ...[
                  IconButton(
                    icon: const Icon(Icons.select_all),
                    tooltip: 'سب منتخب کریں',
                    onPressed: () => _selectAll(list),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'منتخب حذف کریں',
                    onPressed: _confirmBatchDelete,
                  ),
                ] else if (list.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.checklist_rtl),
                    tooltip: 'ملٹی سلیکٹ / حذف موڈ',
                    onPressed: () => setState(() => _isSelectionMode = true),
                  ),
              ],
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    textAlign: TextAlign.right,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'نام، شناختی کارڈ یا فون سے تلاش کریں...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: list.isEmpty
                      ? const Center(
                          child: Text(
                            'کوئی ریکارڈ نہیں ملا۔',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        )
                      : ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final p = list[index];
                            final isSelected = _selectedIds.contains(p.id);
                            return CustomerProfileTileUi(
                              customer: p,
                              isSelectionMode: _isSelectionMode,
                              isSelected: isSelected,
                              onLongPress: () => _toggleSelection(p.id),
                              onTap: () {
                                if (_isSelectionMode) {
                                  _toggleSelection(p.id);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CustomerDetailPage(
                                        args: CustomerDetailArgs(
                                          customerId: p.id,
                                          customerCnic: p.cnic,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
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