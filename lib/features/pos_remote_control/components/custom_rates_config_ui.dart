import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../pos_remote_controller.dart';
class CustomRatesConfigUi extends StatelessWidget {
  final PosRemoteController controller;
  const CustomRatesConfigUi({super.key, required this.controller});
  Widget _numField(
    String label,
    TextEditingController ctrl, {
    bool isDecimal = true,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
      textAlign: TextAlign.left,
      style: const TextStyle(
        fontSize: 15.5,
        fontWeight: FontWeight.w900,
        color: AppColors.textDark,
      ),
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w900,
          color: AppColors.textDark,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: AppColors.cardSurface,
      ),
    );
  }
  Widget _zoneOptionTile(String zoneKey, String title) {
    final selected = controller.customAllowedZones.contains(zoneKey);
    return CheckboxListTile(
      value: selected,
      activeColor: AppColors.primaryEmerald,
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
      ),
      onChanged: (v) => controller.toggleCustomAllowedZone(zoneKey, v ?? false),
    );
  }
  @override
  Widget build(BuildContext context) {
    final months =
        List.generate((controller.custMaxMonth - 3) + 1, (i) => 3 + i);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.warmTintEmerald,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.emeraldPillBorder,
              width: 1.3,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.calculate_outlined,
                      color: AppColors.primaryEmerald, size: 18),
                  SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'POS کسٹم تخمینہ کیلکولیٹر میں دکھائے جانے والے آپشنز:',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _zoneOptionTile(
                'CUSTOM_ESTIMATE',
                '⭐ کسٹم تخمینہ ریٹ (تھرڈ زون ریٹ)',
              ),
              _zoneOptionTile(
                'MOBILE',
                '📱 موبائل زون ریٹ',
              ),
              _zoneOptionTile(
                'ELECTRONICS',
                '🧊 جنرل آئٹم زون ریٹ',
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _numField(
                'کسٹم ایڈوانس شرح',
                controller.custAdvanceCtrl,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _numField(
                'ماہانہ اضافہ (Increment)',
                controller.custIncrementCtrl,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _numField(
                'منافع مع چیک',
                controller.custProfitCheckCtrl,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _numField(
                'منافع بغیر چیک',
                controller.custProfitNoCheckCtrl,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _numField(
                'قسط کی تاریخ (ہر ماہ)',
                controller.custDueDayCtrl,
                isDecimal: false,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _numField(
                'رعایتی دن (Grace)',
                controller.custGraceDaysCtrl,
                isDecimal: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _numField(
                'پروسیسنگ فیس (Rs)',
                controller.custFeeCtrl,
                isDecimal: false,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _numField(
                'راؤنڈ آف (Round To)',
                controller.custRoundCtrl,
                isDecimal: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.shade600, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'کسٹم تخمینہ سیکیورٹی، کٹوتی اور رسک حد:',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: Colors.amber.shade900,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _numField(
                      'MDM لاک فیس (Rs)',
                      controller.custMdmFeeCtrl,
                      isDecimal: false,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: _numField(
                      'میکس ادھار رسک حد',
                      controller.custMaxRiskCtrl,
                      isDecimal: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      initialValue: controller.custOpenBoxType,
                      isExpanded: true,
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: 'ڈبہ / سیل کھلنے پر کٹوتی',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'PERCENT', child: Text('فیصد (%) کٹوتی')),
                        DropdownMenuItem(
                            value: 'FIXED', child: Text('فکس روپے کٹوتی')),
                      ],
                      onChanged: (v) {
                        if (v != null) controller.setCustOpenBoxType(v);
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 2,
                    child: _numField(
                      controller.custOpenBoxType == 'PERCENT'
                          ? 'شرح (%)'
                          : 'رقم (Rs)',
                      controller.custOpenBoxValCtrl,
                      isDecimal: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _numField(
                'انتظامی خصوصی منظوری PIN',
                controller.custAdminPinCtrl,
                isDecimal: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'کسٹم تخمینہ اقساط کے مہینے:',
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove, size: 19),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => controller.adjustCustMaxMonth(-1),
                  ),
                  Text(
                    '3 تا ${controller.custMaxMonth} ماہ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                      color: AppColors.primaryEmerald,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 19),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => controller.adjustCustMaxMonth(1),
                  ),
                ],
              ),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: months.map((m) {
                  final sel = controller.custDurations.contains(m);
                  return FilterChip(
                    visualDensity: VisualDensity.compact,
                    label: Text('$m ماہ',
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: sel ? Colors.white : AppColors.textDark)),
                    selected: sel,
                    selectedColor: AppColors.primaryEmerald,
                    checkmarkColor: Colors.white,
                    onSelected: (v) => controller.toggleCustDuration(m, v),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SwitchListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          title: const Text('کمپاؤنڈنگ منافع (کسٹم تخمینہ)',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          value: controller.custCompounding,
          activeTrackColor: AppColors.primaryEmerald,
          onChanged: controller.setCustCompounding,
        ),
        SwitchListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          title: const Text('پروسیسنگ فیس اصل رقم میں شامل کریں (کسٹم)',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          value: controller.custAddFeeToPrincipal,
          activeTrackColor: AppColors.primaryEmerald,
          onChanged: controller.setCustAddFee,
        ),
        SwitchListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          title: const Text(
            'کسٹمر کے ذاتی اینڈرائیڈ موبائل پر MDM لاک شرط لازمی رکھیں',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
          ),
          value: controller.custRequireCustomerMdm,
          activeTrackColor: AppColors.primaryEmerald,
          onChanged: controller.setCustRequireCustomerMdm,
        ),
      ],
    );
  }
}