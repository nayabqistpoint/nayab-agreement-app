import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../pos_remote_controller.dart';

class GeneralRatesConfigUi extends StatelessWidget {
  final PosRemoteController controller;
  const GeneralRatesConfigUi({super.key, required this.controller});

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

  @override
  Widget build(BuildContext context) {
    final months =
        List.generate((controller.genMaxMonth - 3) + 1, (i) => 3 + i);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          title: const Text(
            'جنرل کیٹیگری (الیکٹرانکس / دیگر اشیاء) فعال رکھیں',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
          value: controller.genEnabled,
          activeTrackColor: AppColors.primaryEmerald,
          onChanged: controller.setGenEnabled,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _numField(
                'جنرل ایڈوانس شرح',
                controller.genAdvanceCtrl,
                helper: 'مثلاً 0.75 = 25% ایڈوانس',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _numField(
                'ماہانہ اضافہ (Increment)',
                controller.genIncrementCtrl,
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
                controller.genProfitCheckCtrl,
                helper: 'مثلاً 0.25 = 25%',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _numField(
                'منافع بغیر چیک',
                controller.genProfitNoCheckCtrl,
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
                controller.genDueDayCtrl,
                isDecimal: false,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _numField(
                'رعایتی دن (Grace)',
                controller.genGraceDaysCtrl,
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
                controller.genFeeCtrl,
                isDecimal: false,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _numField(
                'راؤنڈ آف (Round To)',
                controller.genRoundCtrl,
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
                'جنرل آئٹم سیکیورٹی، کٹوتی اور رسک حد:',
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
                      controller.genMdmFeeCtrl,
                      isDecimal: false,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _numField(
                      'میکس ادھار رسک حد',
                      controller.genMaxRiskCtrl,
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
                      initialValue: controller.genOpenBoxType,
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
                        if (v != null) controller.setGenOpenBoxType(v);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: _numField(
                      controller.genOpenBoxType == 'PERCENT'
                          ? 'شرح (%)'
                          : 'رقم (Rs)',
                      controller.genOpenBoxValCtrl,
                      isDecimal: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _numField(
                'انتظامی خصوصی منظوری PIN',
                controller.genAdminPinCtrl,
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
                      'جنرل اشیاء کی اقساط کے مہینے:',
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => controller.adjustGenMaxMonth(-1),
                  ),
                  Text(
                    '3 تا ${controller.genMaxMonth} ماہ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryEmerald,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => controller.adjustGenMaxMonth(1),
                  ),
                ],
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: months.map((m) {
                  final sel = controller.genDurations.contains(m);
                  return FilterChip(
                    label: Text('$m ماہ',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: sel ? Colors.white : AppColors.textDark)),
                    selected: sel,
                    selectedColor: AppColors.primaryEmerald,
                    checkmarkColor: Colors.white,
                    onSelected: (v) => controller.toggleGenDuration(m, v),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SwitchListTile(
          title: const Text('کمپاؤنڈنگ منافع (جنرل اشیاء)',
              style: TextStyle(fontWeight: FontWeight.w900)),
          value: controller.genCompounding,
          activeTrackColor: AppColors.primaryEmerald,
          onChanged: controller.setGenCompounding,
        ),
        SwitchListTile(
          title: const Text('پروسیسنگ فیس اصل رقم میں شامل کریں (جنرل)',
              style: TextStyle(fontWeight: FontWeight.w900)),
          value: controller.genAddFeeToPrincipal,
          activeTrackColor: AppColors.primaryEmerald,
          onChanged: controller.setGenAddFee,
        ),
        SwitchListTile(
          title: const Text(
            'گاہک کے ذاتی اینڈرائیڈ موبائل پر MDM لاک شرط لازمی رکھیں',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
          ),
          value: controller.genRequireCustomerMdm,
          activeTrackColor: AppColors.primaryEmerald,
          onChanged: controller.setGenRequireCustomerMdm,
        ),
      ],
    );
  }
}