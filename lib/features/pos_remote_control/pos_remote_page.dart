import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'components/custom_rates_config_ui.dart';
import 'components/device_license_config_ui.dart';
import 'components/general_rates_config_ui.dart';
import 'components/mobile_rates_config_ui.dart';
import 'components/store_branding_config_ui.dart';
import 'pos_remote_controller.dart';
class PosRemotePage extends StatefulWidget {
  const PosRemotePage({super.key});
  @override
  State<PosRemotePage> createState() => _PosRemotePageState();
}
class _PosRemotePageState extends State<PosRemotePage> {
  late final PosRemoteController _controller;
  void _onControllerChanged() {
    if (mounted) setState(() {});
  }
  @override
  void initState() {
    super.initState();
    _controller = PosRemoteController();
    _controller.addListener(_onControllerChanged);
  }
  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }
  Widget _buildZonePill(int index, String label, IconData icon) {
    final isSelected = _controller.selectedZoneIndex == index;
    return GestureDetector(
      onTap: () => _controller.setZone(index),
      child: Container(
        margin: const EdgeInsets.only(left: 5),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 11),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryEmerald
              : AppColors.warmSubtleSurface,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color:
                isSelected ? AppColors.primaryEmerald : AppColors.borderLight,
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 17,
              color: isSelected ? Colors.white : AppColors.textDark,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          toolbarHeight: 58,
          title: const Text(
            'POS ریموٹ کنٹرول، ریٹس و سیکیورٹی',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          backgroundColor: AppColors.primaryEmerald,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(5, 7, 5, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildZonePill(
                      0,
                      'موبائل زون',
                      Icons.phone_android_rounded,
                    ),
                    _buildZonePill(
                      1,
                      'جنرل اشیاء زون',
                      Icons.kitchen_outlined,
                    ),
                    _buildZonePill(
                      2,
                      'کسٹم تخمینہ زون',
                      Icons.calculate_outlined,
                    ),
                    _buildZonePill(
                      3,
                      'برانڈنگ و ڈسپلے',
                      Icons.storefront_outlined,
                    ),
                    _buildZonePill(
                      4,
                      'ڈیوائسز و سیکیورٹی',
                      Icons.phonelink_lock_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (_controller.selectedZoneIndex == 0)
                MobileRatesConfigUi(controller: _controller)
              else if (_controller.selectedZoneIndex == 1)
                GeneralRatesConfigUi(controller: _controller)
              else if (_controller.selectedZoneIndex == 2)
                CustomRatesConfigUi(controller: _controller)
              else if (_controller.selectedZoneIndex == 3)
                StoreBrandingConfigUi(controller: _controller)
              else
                DeviceLicenseConfigUi(controller: _controller),
              if (_controller.statusMessage != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                  decoration: BoxDecoration(
                    color: _controller.isStatusError
                        ? const Color(0xFFFEF2F2)
                        : AppColors.warmTintEmerald,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: _controller.isStatusError
                          ? AppColors.errorRed
                          : AppColors.primaryEmerald,
                    ),
                  ),
                  child: Text(
                    _controller.statusMessage!,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: _controller.isStatusError
                          ? AppColors.errorRed
                          : AppColors.primaryEmerald,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
          decoration: const BoxDecoration(
            color: AppColors.cardSurface,
            border: Border(
              top: BorderSide(color: AppColors.borderLight, width: 1.2),
            ),
          ),
          child: SafeArea(
            top: false,
            child: ElevatedButton.icon(
              onPressed: _controller.saveAllSettings,
              icon: const Icon(Icons.cloud_upload_outlined, size: 20),
              label: const Text(
                'تمام ریموٹ سیٹنگز محفوظ کریں اور POS پر بھیجیں',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryEmerald,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}