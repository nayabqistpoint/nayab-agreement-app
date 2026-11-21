import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../pos_remote_controller.dart';
import '../services/pos_remote_config_service.dart';

class DeviceLicenseConfigUi extends StatelessWidget {
  final PosRemoteController controller;
  const DeviceLicenseConfigUi({super.key, required this.controller});

  Future<void> _openGoogleMaps(
    BuildContext context,
    double lat,
    double lng,
  ) async {
    final uri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('گوگل میپس کھولنے میں مسئلہ پیش آیا۔'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  void _confirmDeleteDevice(
    BuildContext context,
    String deviceId,
    String displayName,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'ڈیوائس کارڈ مستقل حذف کریں؟',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          content: Text(
            'کیا آپ واقعی "$displayName" ($deviceId) کو اس فہرست اور سرور سے مستقل صاف کرنا چاہتے ہیں؟',
            style: const TextStyle(fontSize: 13.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('منسوخ'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final nav = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);
                await PosRemoteConfigService.deleteRegisteredDevice(deviceId);
                if (ctx.mounted) nav.pop();
                if (context.mounted) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('🗑️ ڈیوائس کارڈ مستقل صاف کر دیا گیا!'),
                      backgroundColor: AppColors.primaryEmerald,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.delete_forever_rounded, size: 18),
              label: const Text('ہاں، صاف کریں'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameAndApproveDialog(
    BuildContext context,
    String deviceId,
    String currentLabel,
  ) {
    final nameCtrl = TextEditingController(text: currentLabel);
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'ملازم / ڈیوائس کا نام لکھ کر فعال کریں',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ڈیوائس ID: $deviceId',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryEmerald,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'ملازم کا نام / برانچ (مثلاً علی سیلز مین)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('منسوخ'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final nav = Navigator.of(ctx);
                await PosRemoteConfigService.setDeviceStatus(
                  deviceId: deviceId,
                  status: 'ACTIVE',
                  customLabel: nameCtrl.text.trim(),
                );
                if (ctx.mounted) nav.pop();
              },
              icon: const Icon(Icons.check_circle_rounded, size: 18),
              label: const Text('منظور و فعال کریں'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryEmerald,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warmTintEmerald,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.emeraldPillBorder, width: 1.3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  '🔐 ڈیوائس لائسنس لاک (Anti-Leak Security) آن رکھیں',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: AppColors.textDark,
                  ),
                ),
                subtitle: const Text(
                  'آن ہونے پر کوئی بھی نئی انسٹالیشن اس وقت تک نہیں کھلے گی جب تک آپ یہاں سے منظور نہ کریں۔',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                ),
                value: controller.requireDeviceActivation,
                activeTrackColor: AppColors.primaryEmerald,
                onChanged: controller.setRequireDeviceActivation,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ValueListenableBuilder(
          valueListenable: HiveBoxManager.listenToBox(BoxNames.posDevicesBox),
          builder: (context, _, _) {
            final devices = PosRemoteConfigService.getRegisteredDevices();
            if (devices.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.phonelink_lock_rounded,
                      size: 44,
                      color: AppColors.primaryEmerald,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'ابھی تک کسی موبائل سے رسائی کی درخواست موصول نہیں ہوئی۔',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'جیسے ہی کسی موبائل پر POS ایپ انسٹال ہو کر کھلے گی، اس کی ID اور ماڈل خودکار یہاں ظاہر ہو جائے گا۔',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'رجسٹرڈ موبائلز و ٹیبز کی فہرست (${devices.length}):',
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                ...devices.map((dev) {
                  final id = dev['deviceId']?.toString() ?? '';
                  final model =
                      dev['deviceModel']?.toString() ?? 'Android Device';
                  final label = dev['employeeLabel']?.toString() ?? '';
                  final displayTitle =
                      label.isNotEmpty ? '$label ($model)' : model;
                  final status =
                      (dev['status']?.toString() ?? 'PENDING').toUpperCase();
                  final isActive = status == 'ACTIVE';
                  final isRevoked = status == 'REVOKED';

                  final double? lat = (dev['latitude'] as num?)?.toDouble();
                  final double? lng = (dev['longitude'] as num?)?.toDouble();
                  final bool hasGps =
                      lat != null && lng != null && (lat != 0.0 || lng != 0.0);
                  final String locError =
                      dev['locationError']?.toString().trim() ?? '';

                  Color badgeBg = Colors.orange.shade100;
                  Color badgeText = Colors.orange.shade900;
                  String statusLabel = '⏳ منظوری کا منتظر';
                  if (isActive) {
                    badgeBg = AppColors.warmTintEmerald;
                    badgeText = AppColors.primaryEmerald;
                    statusLabel = '🟢 فعال (Active)';
                  } else if (isRevoked) {
                    badgeBg = const Color(0xFFFEE2E2);
                    badgeText = AppColors.errorRed;
                    statusLabel = '🔴 بلاک شدہ (Revoked)';
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive
                            ? AppColors.primaryEmerald
                            : (isRevoked
                                ? AppColors.errorRed
                                : AppColors.borderLight),
                        width: 1.4,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.smartphone_rounded,
                              color: badgeText,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayTitle,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  Text(
                                    'Device ID: $id',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: badgeText,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () => _confirmDeleteDevice(
                                context,
                                id,
                                displayTitle,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                  ),
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (hasGps)
                          InkWell(
                            onTap: () => _openGoogleMaps(context, lat, lng),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade300),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 18,
                                    color: Colors.blue.shade800,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '📍 گوگل میپس پر لوکیشن دیکھیں (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.open_in_new_rounded,
                                    size: 15,
                                    color: Colors.blue.shade800,
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_off_outlined,
                                  size: 16,
                                  color: Colors.black54,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    locError.isNotEmpty
                                        ? 'GPS اطلاع: $locError'
                                        : 'GPS لوکیشن ابھی موصول نہیں ہوئی (موبائل/براؤزر پر Allow Location کریں)',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const Divider(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showRenameAndApproveDialog(
                                  context,
                                  id,
                                  label,
                                ),
                                icon: const Icon(Icons.verified_rounded,
                                    size: 17),
                                label: Text(
                                  isActive
                                      ? 'نام تبدیل کریں'
                                      : 'فعال کریں (Activate)',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryEmerald,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            if (!isRevoked) ...[
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await PosRemoteConfigService.setDeviceStatus(
                                    deviceId: id,
                                    status: 'REVOKED',
                                  );
                                },
                                icon: const Icon(Icons.block_rounded, size: 17),
                                label: const Text(
                                  'بلاک کریں',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.errorRed,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }
}