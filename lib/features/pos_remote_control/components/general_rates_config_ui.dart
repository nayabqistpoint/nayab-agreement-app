import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../pos_remote_controller.dart';
import 'general_fields_builder_ui.dart';

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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
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
                'پروسیسنگ فیس (Rs)',
                controller.genFeeCtrl,
                isDecimal: false,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _numField(
                'جنرل میکس رسک حد',
                controller.genMaxRiskCtrl,
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
                      'جنرل اشیاء کی اقساط کے مہینے:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => controller.adjustGenMaxMonth(-1),
                  ),
                  Text(
                    '3 تا ${controller.genMaxMonth} ماہ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
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
                            fontWeight: FontWeight.bold,
                            color: sel ? Colors.white : Colors.black87)),
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
              style: TextStyle(fontWeight: FontWeight.bold)),
          value: controller.genCompounding,
          activeTrackColor: AppColors.primaryEmerald,
          onChanged: controller.setGenCompounding,
        ),
        SwitchListTile(
          title: const Text(
            'گاہک کے ذاتی اینڈرائیڈ موبائل پر MDM لاک شرط لازمی رکھیں',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
          ),
          value: controller.genRequireCustomerMdm,
          activeTrackColor: AppColors.primaryEmerald,
          onChanged: controller.setGenRequireCustomerMdm,
        ),
        const SizedBox(height: 12),
        GeneralFieldsBuilderUi(
          fields: controller.genCustomFields,
          onAddField: controller.addGeneralField,
          onRenameField: controller.renameGeneralField,
          onRemoveField: controller.removeGeneralField,
        ),
      ],
    );
  }
}