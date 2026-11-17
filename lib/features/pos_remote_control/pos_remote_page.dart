import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'components/custom_rates_config_ui.dart';
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryEmerald : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                isSelected ? AppColors.primaryEmerald : const Color(0xFFCBD5E1),
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : const Color(0xFF334155),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF0F172A),
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
            'POS ریموٹ کنٹرول و ریٹس پینل',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: AppColors.primaryEmerald,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
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
                      'برانڈنگ، ٹِکر و ڈسپلے',
                      Icons.storefront_outlined,
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
              else
                StoreBrandingConfigUi(controller: _controller),
              if (_controller.statusMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: _controller.isStatusError
                        ? const Color(0xFFFEF2F2)
                        : const Color(0xFFECFDF5),
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
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
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
                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
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