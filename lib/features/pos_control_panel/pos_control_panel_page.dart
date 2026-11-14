import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'components/pos_config_tab_ui.dart';
import 'components/pos_stock_tab_ui.dart';

class PosControlPanelPage extends StatelessWidget {
  const PosControlPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: const Text(
              'POS کنٹرول پینل (اسٹاک و شرائط)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            backgroundColor: AppColors.primaryEmerald,
            foregroundColor: Colors.white,
            bottom: const TabBar(
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: [
                Tab(
                  icon: Icon(Icons.inventory_2_outlined),
                  text: 'موبائل اسٹاک انٹری',
                ),
                Tab(
                  icon: Icon(Icons.tune_rounded),
                  text: 'کیلکولیٹر ریٹس و شرائط',
                ),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              PosStockTabUi(),
              PosConfigTabUi(),
            ],
          ),
        ),
      ),
    );
  }
}