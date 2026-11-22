import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../pos_remote_controller.dart';
class MobileRatesConfigUi extends StatelessWidget {
  final PosRemoteController controller;
  const MobileRatesConfigUi({super.key, required this.controller});
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
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _numField(
                'ماہانہ اضافہ (Increment)',
                controller.mobIncrementCtrl,
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
                controller.mobProfitCheckCtrl,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _numField(
                'منافع بغیر چیک',
                controller.mobProfitNoCheckCtrl,
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
                controller.mobDueDayCtrl,
                isDecimal: false,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _numField(
                'رعایتی دن (Grace)',
                controller.mobGraceDaysCtrl,
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
                controller.mobFeeCtrl,
                isDecimal: false,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _numField(
                'راؤنڈ آف (Round To)',
                controller.mobRoundCtrl,
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
                'موبائل سیکیورٹی، کٹوتی اور رسک حد:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
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
                      controller.mobMdmFeeCtrl,
                      isDecimal: false,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: _numField(
                      'میکس ادھار رسک حد',
                      controller.mobMaxRiskCtrl,
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
                      initialValue: controller.mobOpenBoxType,
                      isExpanded: true,
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: 'ڈبہ کھلنے پر کٹوتی',
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
                        if (v != null) controller.setMobOpenBoxType(v);
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
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
              const SizedBox(height: 8),
              _numField(
                'انتظامی خصوصی منظوری PIN',
                controller.adminPinCtrl,
                isDecimal: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
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
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove, size: 19),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => controller.adjustMobMaxMonth(-1),
                  ),
                  Text(
                    '3 تا ${controller.mobMaxMonth} ماہ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: AppColors.primaryEmerald,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 19),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => controller.adjustMobMaxMonth(1),
                  ),
                ],
              ),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: months.map((m) {
                  final sel = controller.mobDurations.contains(m);
                  return FilterChip(
                    visualDensity: VisualDensity.compact,
                    label: Text('$m ماہ',
                        style: TextStyle(
                            fontSize: 12.5,
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
        const SizedBox(height: 4),
        SwitchListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          title: const Text('کمپاؤنڈنگ منافع (موبائل)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          value: controller.mobCompounding,
          activeTrackColor: AppColors.primaryEmerald,
          onChanged: controller.setMobCompounding,
        ),
        SwitchListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          title: const Text('پروسیسنگ فیس اصل رقم میں شامل کریں',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          value: controller.mobAddFeeToPrincipal,
          activeTrackColor: AppColors.primaryEmerald,
          onChanged: controller.setMobAddFee,
        ),
      ],
    );
  }
}