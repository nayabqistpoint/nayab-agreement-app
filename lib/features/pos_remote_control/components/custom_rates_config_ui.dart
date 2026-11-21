import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../pos_remote_controller.dart';

class CustomRatesConfigUi extends StatelessWidget {
  final PosRemoteController controller;
  const CustomRatesConfigUi({super.key, required this.controller});

  Widget _numField(
    String label,
    TextEditingController ctrl, {
    String? helper,
    bool isDecimal = true,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
      textAlign: TextAlign.left,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: AppColors.textDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: AppColors.textDark,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        helperText: helper,
        helperStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        helperMaxLines: 2,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: AppColors.cardSurface,
      ),
    );
  }

  Widget _zoneOptionTile(String zoneKey, String title, String subtitle) {
    final selected = controller.customAllowedZones.contains(zoneKey);
    return CheckboxListTile(
      value: selected,
      activeColor: AppColors.primaryEmerald,
      dense: true,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
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
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: AppColors.warmTintEmerald,
            borderRadius: BorderRadius.circular(12),
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
                      color: AppColors.primaryEmerald, size: 20),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'POS کسٹم تخمینہ کیلکولیٹر میں دکھائے جانے والے آپشنز:',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14.5,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _zoneOptionTile(
                'CUSTOM_ESTIMATE',
                '⭐ کسٹم تخمینہ ریٹ (تھرڈ زون ریٹ)',
                'اس نیچے دیے گئے مخصوص کسٹم ریٹ کے مطابق حساب لگائے گا',
              ),
              _zoneOptionTile(
                'MOBILE',
                '📱 موبائل زون ریٹ',
                'موبائل والے ریٹ شیڈول کے مطابق حساب لگانے کا آپشن',
              ),
              _zoneOptionTile(
                'ELECTRONICS',
                '🧊 جنرل آئٹم زون ریٹ',
                'جنرل اشیاء والے ریٹ شیڈول کے مطابق حساب لگانے کا آپشن',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _numField(
                'کسٹم ایڈوانس شرح',
                controller.custAdvanceCtrl,
                helper: 'مثلاً 0.8 = 20% ایڈوانس',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _numField(
                'ماہانہ اضافہ (Increment)',
                controller.custIncrementCtrl,
                helper: 'مثلاً 0.05 = 5% فی ماہ',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _numField(
                'منافع مع چیک',
                controller.custProfitCheckCtrl,
                helper: 'مثلاً 0.25 = 25%',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _numField(
                'منافع بغیر چیک',
                controller.custProfitNoCheckCtrl,
                helper: 'مثلاً 0.35 = 35%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _numField(
                'قسط کی تاریخ (ہر ماہ)',
                controller.custDueDayCtrl,
                isDecimal: false,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _numField(
                'رعایتی دن (Grace)',
                controller.custGraceDaysCtrl,
                isDecimal: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _numField(
                'پروسیسنگ فیس (Rs)',
                controller.custFeeCtrl,
                isDecimal: false,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _numField(
                'راؤنڈ آف (Round To)',
                controller.custRoundCtrl,
                isDecimal: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade600, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'کسٹم تخمینہ سیکیورٹی، کٹوتی اور رسک حد:',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14.5,
                  color: Colors.amber.shade900,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _numField(
                      'MDM لاک فیس (Rs)',
                      controller.custMdmFeeCtrl,
                      isDecimal: false,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _numField(
                      'میکس ادھار رسک حد',
                      controller.custMaxRiskCtrl,
                      helper: '(قیمت - ایڈوانس) 0 = کوئی حد نہیں',
                      isDecimal: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      initialValue: controller.custOpenBoxType,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'ڈبہ / سیل کھلنے پر کٹوتی',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
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
                  const SizedBox(width: 10),
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
              const SizedBox(height: 12),
              _numField(
                'انتظامی خصوصی منظوری PIN',
                controller.custAdminPinCtrl,
                isDecimal: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(12),
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
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => controller.adjustCustMaxMonth(-1),
                  ),
                  Text(
                    '3 تا ${controller.custMaxMonth} ماہ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryEmerald,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => controller.adjustCustMaxMonth(1),
                  ),
                ],
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: months.map((m) {
                  final sel = controller.custDurations.contains(m);
                  return FilterChip(
                    label: Text('$m ماہ',
                        style: TextStyle(
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
        const SizedBox(height: 10),
        SwitchListTile(
          title: const Text('کمپاؤنڈنگ منافع (کسٹم تخمینہ)',
              style: TextStyle(fontWeight: FontWeight.w900)),
          value: controller.custCompounding,
          activeTrackColor: AppColors.primaryEmerald,
          onChanged: controller.setCustCompounding,
        ),
        SwitchListTile(
          title: const Text('پروسیسنگ فیس اصل رقم میں شامل کریں (کسٹم)',
              style: TextStyle(fontWeight: FontWeight.w900)),
          value: controller.custAddFeeToPrincipal,
          activeTrackColor: AppColors.primaryEmerald,
          onChanged: controller.setCustAddFee,
        ),
        SwitchListTile(
          title: const Text(
            'کسٹمر کے ذاتی اینڈرائیڈ موبائل پر MDM لاک شرط لازمی رکھیں',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
          ),
          value: controller.custRequireCustomerMdm,
          activeTrackColor: AppColors.primaryEmerald,
          onChanged: controller.setCustRequireCustomerMdm,
        ),
      ],
    );
  }
}