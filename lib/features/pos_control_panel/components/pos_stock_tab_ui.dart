import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../services/pos_control_storage_service.dart';
import 'pos_stock_form_ui.dart';

class PosStockTabUi extends StatefulWidget {
  const PosStockTabUi({super.key});
  @override
  State<PosStockTabUi> createState() => _PosStockTabUiState();
}

class _PosStockTabUiState extends State<PosStockTabUi> {
  ControlDataMap? _editingItem;
  String _statusFilter = 'ACTIVE'; // ACTIVE (AVAILABLE + RESERVED) یا SOLD

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'RESERVED':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        label = 'بُک شدہ (زیرِ معاہدہ)';
        break;
      case 'SOLD':
        bgColor = Colors.blueGrey.shade100;
        textColor = Colors.blueGrey.shade800;
        label = 'فروخت شدہ (Sold)';
        break;
      default:
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        label = 'موجود (Available)';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, int count) {
    final isSelected = _statusFilter == value;
    return ChoiceChip(
      label: Text(
        '$label ($count)',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : Colors.black87,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primaryEmerald,
      onSelected: (_) => setState(() => _statusFilter = value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PosStockFormUi(
            editingItem: _editingItem,
            onCancelEdit: () => setState(() => _editingItem = null),
            onSavedSuccess: () => setState(() => _editingItem = null),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder(
            valueListenable: HiveBoxManager.listenToBox(BoxNames.stockBox),
            builder: (context, box, _) {
              final allItems = PosControlStorageService.getAllStockItems();
              final activeItems = allItems
                  .where((i) =>
                      (i['status']?.toString() ?? 'AVAILABLE').toUpperCase() !=
                      'SOLD')
                  .toList();
              final soldItems = allItems
                  .where((i) =>
                      (i['status']?.toString() ?? '').toUpperCase() == 'SOLD')
                  .toList();

              final displayedItems =
                  _statusFilter == 'SOLD' ? soldItems : activeItems;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      _buildFilterChip(
                          'ACTIVE', 'زندہ اسٹاک', activeItems.length),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                          'SOLD', 'فروخت شدہ', soldItems.length),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (displayedItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          _statusFilter == 'SOLD'
                              ? 'ابھی تک کوئی موبائل فروخت شدہ نہیں ہے۔'
                              : 'اس وقت دکان میں کوئی زندہ اسٹاک موجود نہیں ہے۔',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    )
                  else
                    ...displayedItems.map((item) {
                      final id = item['id']?.toString() ?? '';
                      final name = item['itemName']?.toString() ?? '';
                      final imei = item['imeiNo']?.toString() ?? '';
                      final purchasePrice =
                          item['purchasePrice']?.toString() ?? '0';
                      final salePrice = item['salePrice']?.toString() ?? '0';
                      final supplier =
                          item['supplierInfo']?.toString() ?? '';
                      final ramRom = item['ramRom']?.toString() ?? '';
                      final color = item['color']?.toString() ?? '';
                      final cond = item['conditionType']?.toString() ?? 'NEW';
                      final status =
                          (item['status']?.toString() ?? 'AVAILABLE')
                              .toUpperCase();
                      final isLocked =
                          status == 'RESERVED' || status == 'SOLD';

                      final reservedInfo =
                          item['reservedCustomerInfo']?.toString() ?? '';
                      final soldToName = item['soldToName']?.toString() ?? '';
                      final soldToCnic = item['soldToCnic']?.toString() ?? '';

                      String extraOwnerLine = '';
                      if (status == 'RESERVED' && reservedInfo.isNotEmpty) {
                        extraOwnerLine = '\nبُک برائے: $reservedInfo';
                      } else if (status == 'SOLD' && soldToName.isNotEmpty) {
                        extraOwnerLine =
                            '\nخریدار: $soldToName ${soldToCnic.isNotEmpty ? "($soldToCnic)" : ""}';
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: isLocked ? Colors.grey.shade50 : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: cond == 'NEW'
                                        ? AppColors.successGreen.withAlpha(25)
                                        : Colors.orange.withAlpha(30),
                                    child: Icon(
                                      Icons.phone_android,
                                      size: 20,
                                      color: cond == 'NEW'
                                          ? AppColors.successGreen
                                          : AppColors.pendingOrange,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '$name ($ramRom${color.isNotEmpty ? " - $color" : ""})',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                  ),
                                  _buildStatusBadge(status),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'ID: $id | IMEI: $imei\nخرید: $purchasePrice | فروخت: $salePrice روپے ($cond)'
                                '${supplier.isNotEmpty ? "\nسپلائر: $supplier" : ""}'
                                '$extraOwnerLine',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black87),
                              ),
                              if (!isLocked) ...[
                                const Divider(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () =>
                                          setState(() => _editingItem = item),
                                      icon: const Icon(Icons.edit_outlined,
                                          size: 16,
                                          color: AppColors.primaryEmerald),
                                      label: const Text('ترمیم',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.primaryEmerald)),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      onPressed: () async {
                                        final messenger =
                                            ScaffoldMessenger.of(context);
                                        final ok =
                                            await PosControlStorageService
                                                .softDeleteStockItem(id);
                                        if (!mounted) return;
                                        if (ok) {
                                          messenger.showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'موبائل اسٹاک سے حذف کر دیا گیا'),
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.delete_outline,
                                          size: 16, color: AppColors.errorRed),
                                      label: const Text('حذف',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.errorRed)),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}