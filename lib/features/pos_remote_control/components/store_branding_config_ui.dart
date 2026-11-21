import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/box_names.dart';
import '../../../core/database/hive_box_manager.dart';
import '../../../core/widgets/portable_image_ui.dart';
import '../pos_remote_controller.dart';
import '../services/pos_remote_config_service.dart';

class StoreBrandingConfigUi extends StatefulWidget {
  final PosRemoteController controller;
  const StoreBrandingConfigUi({super.key, required this.controller});

  @override
  State<StoreBrandingConfigUi> createState() => _StoreBrandingConfigUiState();
}

class _StoreBrandingConfigUiState extends State<StoreBrandingConfigUi> {
  bool _isGroupingExpanded = false;
  int _groupingCategoryTab = 0;

  Future<void> _pickImage(
    ImageSource source,
    ValueChanged<String> onPicked,
  ) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (file == null) return;
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        onPicked('data:image/jpeg;base64,${base64Encode(bytes)}');
      } else {
        onPicked(file.path);
      }
    } catch (_) {}
  }

  Widget _imagePickerCard({
    required String title,
    required String subtitle,
    required String currentUrl,
    required bool isVisible,
    required ValueChanged<bool> onToggleVisible,
    required ValueChanged<String> onUrlChanged,
    required VoidCallback onClear,
    required IconData fallbackIcon,
    required bool isPassport,
  }) {
    final hasImg = currentUrl.trim().isNotEmpty && currentUrl != 'null';
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(isPassport ? 8 : 10),
                child: Container(
                  width: isPassport ? 54 : 58,
                  height: isPassport ? 64 : 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    border: Border.all(
                      color: AppColors.primaryEmerald,
                      width: 1.3,
                    ),
                    borderRadius: BorderRadius.circular(isPassport ? 8 : 10),
                  ),
                  child: PortableImageUi(
                    pathOrUrl: currentUrl,
                    fit: BoxFit.cover,
                    fallbackIcon: fallbackIcon,
                    fallbackIconSize: 28,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () =>
                              _pickImage(ImageSource.gallery, onUrlChanged),
                          icon: const Icon(Icons.photo_library_outlined,
                              size: 14),
                          label: const Text('گیلری',
                              style: TextStyle(fontSize: 11.5)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryEmerald,
                            foregroundColor: Colors.white,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              _pickImage(ImageSource.camera, onUrlChanged),
                          icon: const Icon(Icons.camera_alt_outlined, size: 14),
                          label: const Text('کیمرہ',
                              style: TextStyle(fontSize: 11.5)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryEmerald,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        if (hasImg)
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                size: 18, color: AppColors.errorRed),
                            tooltip: 'تصویر ہٹائیں',
                            visualDensity: VisualDensity.compact,
                            onPressed: onClear,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text(
              'POS اسکرین پر یہ تصویر دکھائیں',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            value: isVisible,
            activeTrackColor: AppColors.primaryEmerald,
            onChanged: onToggleVisible,
          ),
        ],
      ),
    );
  }

  Widget _buildCashSaleControlCard() {
    final c = widget.controller;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: c.cashSaleEnabled
              ? AppColors.primaryEmerald
              : const Color(0xFF94A3B8),
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              '💵 نقد فروخت (Direct Cash Sale) سہولت آن رکھیں',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14.5,
                color: AppColors.textDark,
              ),
            ),
            subtitle: const Text(
              'بند کرنے پر POS ایپ میں نقد فروخت کا بٹن مکمل غائب ہو جائے گا',
              style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
            ),
            value: c.cashSaleEnabled,
            activeTrackColor: AppColors.primaryEmerald,
            onChanged: c.setCashSaleEnabled,
          ),
          if (c.cashSaleEnabled) ...[
            const Divider(height: 14),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    initialValue: c.cashMarkupType,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'نقد قیمت میں اضافہ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'NONE',
                        child: Text('کوئی اضافہ نہیں (Base Price)'),
                      ),
                      DropdownMenuItem(
                        value: 'PERCENT',
                        child: Text('فیصد (%) اضافہ'),
                      ),
                      DropdownMenuItem(
                        value: 'FIXED',
                        child: Text('فکس روپے (Rs) اضافہ'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) c.setCashMarkupType(v);
                    },
                  ),
                ),
                if (c.cashMarkupType != 'NONE') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: c.cashMarkupValCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        labelText: c.cashMarkupType == 'PERCENT'
                            ? 'اضافہ (%)'
                            : 'اضافہ (Rs)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text(
                'سیلز مین کو POS ایپ پر نقد قیمت کم/زیادہ کرنے کی اجازت دیں',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              value: c.allowCashPriceEdit,
              activeTrackColor: AppColors.primaryEmerald,
              onChanged: c.setAllowCashPriceEdit,
            ),
          ],
        ],
      ),
    );
  }

  String _buildLiveSummary(FieldDefList allOptions, List<String> activeKeys) {
    final labelMap = {
      for (final o in allOptions) o['key']!: o['urduLabel']!.split(' (').first,
    };
    final List<String> activeLabels = [];
    for (final k in activeKeys) {
      final lbl = labelMap[k];
      if (lbl != null && lbl.isNotEmpty) {
        activeLabels.add(lbl);
      }
    }
    return activeLabels.isEmpty ? 'صرف کیٹگری' : activeLabels.join(' + ');
  }

  Widget _buildCategoryTabBtn(int idx, String label, IconData icon) {
    final isSel = _groupingCategoryTab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _groupingCategoryTab = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          decoration: BoxDecoration(
            color: isSel ? AppColors.primaryEmerald : Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: isSel
                  ? AppColors.primaryEmerald
                  : AppColors.emeraldPillBorder,
              width: 1.3,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSel ? Colors.white : AppColors.primaryEmerald,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: isSel ? Colors.white : AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onToggleAndAutoSync({
    required bool isMobile,
    required String key,
    required bool selected,
  }) async {
    widget.controller.toggleCategoryGroupingKey(
      isMobile: isMobile,
      key: key,
      selected: selected,
    );
    await PosRemoteConfigService.saveFullConfig({
      'mobileGroupingMatchKeys':
          List<String>.from(widget.controller.mobileGroupingMatchKeys),
      'generalGroupingMatchKeys':
          List<String>.from(widget.controller.generalGroupingMatchKeys),
    });
  }

  Widget _buildCollapsibleGroupingCard() {
    return ValueListenableBuilder(
      valueListenable: HiveBoxManager.listenToBox(BoxNames.appConfigBox),
      builder: (context, _, _) {
        final bool isMobTab = _groupingCategoryTab == 0;
        final mobOptions =
            PosRemoteConfigService.getGroupingOptionsForCategory(isMobile: true);
        final genOptions =
            PosRemoteConfigService.getGroupingOptionsForCategory(isMobile: false);

        final currentOptions = isMobTab ? mobOptions : genOptions;
        final currentKeys = isMobTab
            ? widget.controller.mobileGroupingMatchKeys
            : widget.controller.generalGroupingMatchKeys;

        final mobSummary = _buildLiveSummary(
            mobOptions, widget.controller.mobileGroupingMatchKeys);
        final genSummary = _buildLiveSummary(
            genOptions, widget.controller.generalGroupingMatchKeys);

        return Container(
          decoration: BoxDecoration(
            color: AppColors.warmTintEmerald,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryEmerald,
              width: _isGroupingExpanded ? 1.6 : 1.3,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () => setState(
                    () => _isGroupingExpanded = !_isGroupingExpanded),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.primaryEmerald,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.layers_outlined,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    '📦 مارکیٹ کارڈ گروپنگ رولز',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14.5,
                                      color: AppColors.primaryEmerald,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.emeraldPillBorder,
                                    ),
                                  ),
                                  child: Text(
                                    '📱 ${widget.controller.mobileGroupingMatchKeys.length} | 🧊 ${widget.controller.generalGroupingMatchKeys.length}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryEmerald,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'موبائل: $mobSummary',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              'جنرل: $genSummary',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        _isGroupingExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primaryEmerald,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              if (_isGroupingExpanded) ...[
                const Divider(height: 1, color: AppColors.emeraldPillBorder),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          _buildCategoryTabBtn(
                            0,
                            'موبائل گروپنگ (${widget.controller.mobileGroupingMatchKeys.length}/${mobOptions.length})',
                            Icons.phone_android_rounded,
                          ),
                          const SizedBox(width: 6),
                          _buildCategoryTabBtn(
                            1,
                            'جنرل اشیاء گروپنگ (${widget.controller.generalGroupingMatchKeys.length}/${genOptions.length})',
                            Icons.kitchen_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'جن فیلڈز پر ٹِک (✅) ہوگا، ان کے یکساں ہونے پر ہی یونٹس ایک کارڈ میں جمع ہوں گے؛ اگر وہ مختلف ہوئیں تو الگ کارڈ بنے گا (فوری آٹو سیو):',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...currentOptions.map((opt) {
                        final key = opt['key']!;
                        final label = opt['urduLabel']!;
                        final isChecked = currentKeys.contains(key);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isChecked
                                  ? AppColors.primaryEmerald
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: CheckboxListTile(
                            dense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            activeColor: AppColors.primaryEmerald,
                            value: isChecked,
                            title: Text(
                              label,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDark,
                              ),
                            ),
                            subtitle: Text(
                              isChecked
                                  ? 'یکساں ہونا ضروری (مختلف ہونے پر الگ کارڈ بنے گا)'
                                  : 'مختلف ہونے پر بھی ایک ہی کارڈ میں گروپ ہو جائے گا',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isChecked
                                    ? AppColors.primaryEmerald
                                    : AppColors.textMuted,
                              ),
                            ),
                            onChanged: (val) => _onToggleAndAutoSync(
                              isMobile: isMobTab,
                              key: key,
                              selected: val ?? false,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF94A3B8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'دکان کا نام و عنوان (POS ایپ بار):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller.shopNameCtrl,
                textAlign: TextAlign.right,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'دکان کا مرکزی نام',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller.shopSubtitleCtrl,
                textAlign: TextAlign.right,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'ذیلی عنوان / شہر (مثلاً قائم پور / آسان اقساط)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _imagePickerCard(
          title: 'دکان کا لوگو (Shop Logo)',
          subtitle: 'POS ایپ بار کے دائیں کونے میں ظاہر ہوگا',
          currentUrl: controller.shopLogoUrl,
          isVisible: controller.showShopLogo,
          onToggleVisible: controller.setShowShopLogo,
          onUrlChanged: controller.setShopLogoUrl,
          onClear: () => controller.setShopLogoUrl(''),
          fallbackIcon: Icons.storefront_rounded,
          isPassport: false,
        ),
        const SizedBox(height: 10),
        _imagePickerCard(
          title: 'مالک کی پاسپورٹ سائز تصویر (Owner Photo)',
          subtitle: 'POS ایپ بار میں آپ کی شناختی تصویر کے طور پر نظر آئے گی',
          currentUrl: controller.ownerPhotoUrl,
          isVisible: controller.showOwnerPhoto,
          onToggleVisible: controller.setShowOwnerPhoto,
          onUrlChanged: controller.setOwnerPhotoUrl,
          onClear: () => controller.setOwnerPhotoUrl(''),
          fallbackIcon: Icons.person_rounded,
          isPassport: true,
        ),
        const SizedBox(height: 12),
        _buildCashSaleControlCard(),
        const SizedBox(height: 12),
        _buildCollapsibleGroupingCard(),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade700, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'لائیو چلنے والی نیوز ٹِکر پٹی (Ticker Bar) آن رکھیں',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                value: controller.tickerEnabled,
                activeTrackColor: AppColors.primaryEmerald,
                onChanged: controller.setTickerEnabled,
              ),
              TextField(
                controller: controller.tickerTextCtrl,
                textAlign: TextAlign.right,
                maxLines: 2,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'ٹِکر پٹی پر چلنے والا پیغام / اشتہار',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF94A3B8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'POS مارکیٹ لسٹ میں آئٹمز کی نمائش کا کنٹرول:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  '📦 آرڈر پر دستیاب (On-Order) آئٹمز دکھائیں',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                value: controller.showOnOrderItems,
                activeTrackColor: AppColors.primaryEmerald,
                onChanged: controller.setShowOnOrderItems,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  '🔒 بُک شدہ (Reserved) آئٹمز مع منتخب پیکج دکھائیں',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                value: controller.showReservedItems,
                activeTrackColor: AppColors.primaryEmerald,
                onChanged: controller.setShowReservedItems,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  '✅ فروخت شدہ (Sold) آئٹمز مع فروخت شدہ پیکج دکھائیں',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                value: controller.showSoldItems,
                activeTrackColor: AppColors.primaryEmerald,
                onChanged: controller.setShowSoldItems,
              ),
            ],
          ),
        ),
      ],
    );
  }
}