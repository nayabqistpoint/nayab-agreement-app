import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../pos_remote_controller.dart';

class MobileRatesConfigUi extends StatelessWidget {
  final PosRemoteController controller;
  const MobileRatesConfigUi({super.key, required this.controller});

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
        List.generate((controller.mobMaxMonth - 3) + 1, (i) => 3 + i);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _numField(
                'موبائل ایڈوانس شرح',
                controller.mobAdvanceCtrl,
                helper: 'مثلاً 0.8 = 20% ایڈوانس',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _numField(
                'ماہانہ اضافہ (Increment)',
                controller.mobIncrementCtrl,
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
                controller.mobProfitCheckCtrl,
                helper: 'مثلاً 0.25 = 25%',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _numField(
                'منافع بغیر چیک',
                controller.mobProfitNoCheckCtrl,
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
                controller.mobDueDayCtrl,
                isDecimal: false,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _numField(
                'رعایتی دن (Grace)',
                controller.mobGraceDaysCtrl,
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
                controller.mobFeeCtrl,
                isDecimal: false,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _numField(
                'راؤنڈ آف (Round To)',
                controller.mobRoundCtrl,
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
                'موبائل سیکیورٹی، کٹوتی اور رسک حد:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
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
                      controller.mobMdmFeeCtrl,
                      isDecimal: false,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _numField(
                      'میکس ادھار رسک حد',
                      controller.mobMaxRiskCtrl,
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
                      initialValue: controller.mobOpenBoxType,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'ڈبہ کھلنے پر کٹوتی',
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
                        if (v != null) controller.setMobOpenBoxType(v);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: _numField(
                      controller.mobOpenBoxType == 'PERCENT'
                          ? 'شرح (%)'
                          : 'رقم (Rs)',
                      controller.mobOpenBoxValCtrl,
                      isDecimal: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _numField(
                'انتظامی خصوصی منظوری PIN',
                controller.adminPinCtrl,
                isDecimal: false,
              ),
            ],
          ),
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
                      'موبائل اقساط کے مہینے:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => controller.adjustMobMaxMonth(-1),
                  ),
                  Text(
                    '3 تا ${controller.mobMaxMonth} ماہ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryEmerald,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => controller.adjustMobMaxMonth(1),
                  ),
                ],
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: months.map((m) {
                  final sel = controller.mobDurations.contains(m);
                  return FilterChip(
                    label: Text('$m ماہ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: sel ? Colors.white : Colors.black87)),
                    selected: sel,
                    selectedColor: AppColors.primaryEmerald,
                    checkmarkColor: Colors.white,
                    onSelected: (v) => controller.toggleMobDuration(m, v),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        SwitchListTile(
          title: const Text('کمپاؤنڈنگ منافع (موبائل)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          value: controller.mobCompounding,
          activeTrackColor: AppColors.primaryEmerald,
          onChanged: controller.setMobCompounding,
        ),
        SwitchListTile(
          title: const Text('پروسیسنگ فیس اصل رقم میں شامل کریں',
              style: TextStyle(fontWeight: FontWeight.bold)),
          value: controller.mobAddFeeToPrincipal,
          activeTrackColor: AppColors.primaryEmerald,
          onChanged: controller.setMobAddFee,
        ),
      ],
    );
  }
}