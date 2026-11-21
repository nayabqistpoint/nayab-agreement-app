import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../../core/models/customer_profile_model.dart';
import '../../../core/widgets/portable_image_ui.dart';
import '../../customer_detail/components/customer_media_viewer_modal_ui.dart';

class CustomerProfileTileUi extends StatelessWidget {
  final CustomerProfileModel customer;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<String>? onCnicTap;

  const CustomerProfileTileUi({
    super.key,
    required this.customer,
    this.isSelectionMode = false,
    this.isSelected = false,
    required this.onTap,
    required this.onLongPress,
    this.onCnicTap,
  });

  Map<String, String> _resolveLinkedGuarantor() {
    try {
      final custBox = HiveBoxManager.getBox(BoxNames.customersBox);
      final raw = custBox.get(customer.id);
      if (raw is Map) {
        final gName = raw['linkedGuarantorName']?.toString().trim() ?? '';
        final gCnic = raw['linkedGuarantorCnic']?.toString().trim() ?? '';
        String gPhoto = raw['linkedGuarantorPhotoUrl']?.toString().trim() ?? '';
        if (gPhoto.isEmpty && gCnic.isNotEmpty) {
          final gProfile = custBox.get(gCnic);
          if (gProfile is Map) {
            gPhoto = gProfile['photoUrl']?.toString().trim() ?? '';
          }
        }
        if (gName.isNotEmpty) {
          return {'name': gName, 'cnic': gCnic, 'photo': gPhoto};
        }
      }
    } catch (_) {}
    return {};
  }

  Widget _buildPassportThumbnail(
    BuildContext context,
    String? photoUrl,
    String personName, {
    bool isGuarantor = false,
  }) {
    final url = photoUrl?.trim() ?? '';
    final bool hasImg = url.isNotEmpty && url != 'null';
    return GestureDetector(
      onTap: hasImg
          ? () => CustomerMediaViewerModalUi.show(
                context,
                title: personName,
                imagePath: url,
              )
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 68,
          height: 78,
          decoration: BoxDecoration(
            color: isGuarantor
                ? Colors.indigo.shade50
                : AppColors.warmTintEmerald,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isGuarantor
                  ? Colors.indigo.shade400
                  : AppColors.primaryEmerald,
              width: 1.5,
            ),
          ),
          child: PortableImageUi(
            pathOrUrl: url,
            fit: BoxFit.cover,
            fallbackIcon: isGuarantor ? Icons.shield_outlined : Icons.person,
            fallbackIconSize: 38,
            fallbackColor: isGuarantor
                ? Colors.indigo.shade700
                : AppColors.primaryEmerald,
          ),
        ),
      ),
    );
  }

  Widget _buildClickableCnicBadge(String cnic, Color color) {
    if (cnic.isEmpty) return const SizedBox.shrink();
    return InkWell(
      onTap: onCnicTap != null ? () => onCnicTap!(cnic) : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 15, color: color),
            const SizedBox(width: 4),
            Text(
              cnic,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: color,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isGuarantor = customer.role.startsWith('ضامن');
    final linkedGuarantor =
        isGuarantor ? <String, String>{} : _resolveLinkedGuarantor();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 1.5,
      color: isSelected ? AppColors.warmTintEmerald : AppColors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color:
              isSelected ? AppColors.primaryEmerald : AppColors.borderLight,
          width: isSelected ? 2.0 : 1.2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isSelectionMode) ...[
                    Checkbox(
                      value: isSelected,
                      activeColor: AppColors.primaryEmerald,
                      onChanged: (_) => onTap(),
                    ),
                    const SizedBox(width: 4),
                  ],
                  _buildPassportThumbnail(
                    context,
                    customer.photoUrl,
                    customer.fullName,
                    isGuarantor: isGuarantor,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                customer.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 17.5,
                                  color: AppColors.textDark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isGuarantor
                                    ? Colors.indigo.shade50
                                    : AppColors.warmTintEmerald,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isGuarantor ? 'ضامن' : 'گاہک',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  color: isGuarantor
                                      ? Colors.indigo.shade800
                                      : AppColors.primaryEmerald,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (customer.fatherName.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'ولدیت: ${customer.fatherName}',
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 5,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _buildClickableCnicBadge(
                              customer.cnic,
                              isGuarantor
                                  ? Colors.indigo.shade800
                                  : AppColors.primaryEmerald,
                            ),
                            if (customer.phone.isNotEmpty)
                              Text(
                                'فون: ${customer.phone}',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textDark,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
              if (linkedGuarantor.isNotEmpty) ...[
                const SizedBox(height: 9),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.indigo.shade200),
                  ),
                  child: Row(
                    children: [
                      _buildPassportThumbnail(
                        context,
                        linkedGuarantor['photo'],
                        linkedGuarantor['name'] ?? 'ضامن',
                        isGuarantor: true,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'منسلک ضامن: ${linkedGuarantor['name']}',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.indigo.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildClickableCnicBadge(
                              linkedGuarantor['cnic'] ?? '',
                              Colors.indigo.shade800,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}