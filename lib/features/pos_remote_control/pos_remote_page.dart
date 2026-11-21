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
        margin: const EdgeInsets.only(left: 7),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryEmerald
              : AppColors.warmSubtleSurface,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color:
                isSelected ? AppColors.primaryEmerald : AppColors.borderLight,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 19,
              color: isSelected ? Colors.white : AppColors.textDark,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
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
          title: const Text(
            'POS ریموٹ کنٹرول، ریٹس و سیکیورٹی',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18.5),
          ),
          backgroundColor: AppColors.primaryEmerald,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
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
              const SizedBox(height: 16),
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
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: _controller.isStatusError
                        ? const Color(0xFFFEF2F2)
                        : AppColors.warmTintEmerald,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _controller.isStatusError
                          ? AppColors.errorRed
                          : AppColors.primaryEmerald,
                    ),
                  ),
                  child: Text(
                    _controller.statusMessage!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: _controller.isStatusError
                          ? AppColors.errorRed
                          : AppColors.primaryEmerald,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _controller.saveAllSettings,
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text(
                  'تمام ریموٹ سیٹنگز محفوظ کریں اور POS پر بھیجیں',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryEmerald,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}