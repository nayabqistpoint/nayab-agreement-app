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
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        helperText: helper,
        helperStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
        helperMaxLines: 2,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
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
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11.5, color: Colors.black54),
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
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryEmerald.withAlpha(110),
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
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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
                'پروسیسنگ فیس (Rs)',
                controller.custFeeCtrl,
                isDecimal: false,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _numField(
                'کسٹم میکس رسک حد',
                controller.custMaxRiskCtrl,
                helper: '(قیمت - ایڈوانس) 0 = کوئی حد نہیں',
                isDecimal: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
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
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'کسٹم تخمینہ اقساط کے مہینے:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => controller.adjustCustMaxMonth(-1),
                  ),
                  Text(
                    '3 تا ${controller.custMaxMonth} ماہ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
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
                            fontWeight: FontWeight.bold,
                            color: sel ? Colors.white : Colors.black87)),
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
              style: TextStyle(fontWeight: FontWeight.bold)),
          value: controller.custCompounding,
          activeTrackColor: AppColors.primaryEmerald,
          onChanged: controller.setCustCompounding,
        ),
      ],
    );
  }
}