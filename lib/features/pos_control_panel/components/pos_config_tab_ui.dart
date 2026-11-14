import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../services/pos_control_storage_service.dart';

class PosConfigTabUi extends StatefulWidget {
  const PosConfigTabUi({super.key});

  @override
  State<PosConfigTabUi> createState() => _PosConfigTabUiState();
}

class _PosConfigTabUiState extends State<PosConfigTabUi> {
  late final TextEditingController _advanceCtrl;
  late final TextEditingController _profitCheckCtrl;
  late final TextEditingController _profitNoCheckCtrl;
  late final TextEditingController _incrementCtrl;
  late final TextEditingController _dueDayCtrl;
  late final TextEditingController _graceDaysCtrl;
  late final TextEditingController _feeCtrl;
  late final TextEditingController _roundCtrl;

  bool _isCompounding = false;
  bool _addFeeToPrincipal = false;
  List<int> _selectedDurations = [6, 7, 8, 9, 10, 11, 12];
  final List<int> _allPossibleMonths = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 15, 18, 24];

  @override
  void initState() {
    super.initState();
    final cfg = PosControlStorageService.getCalculatorConfig();

    _advanceCtrl = TextEditingController(
      text: ((cfg['advancePercentage'] as num?)?.toDouble() ?? 0.8).toString(),
    );
    _profitCheckCtrl = TextEditingController(
      text: ((cfg['profitWithCheck'] as num?)?.toDouble() ?? 0.25).toString(),
    );
    _profitNoCheckCtrl = TextEditingController(
      text: ((cfg['profitWithoutCheck'] as num?)?.toDouble() ?? 0.35).toString(),
    );
    _incrementCtrl = TextEditingController(
      text: ((cfg['perMonthIncrement'] as num?)?.toDouble() ?? 0.05).toString(),
    );
    _dueDayCtrl = TextEditingController(
      text: ((cfg['installmentDueDay'] as num?)?.toInt() ?? 5).toString(),
    );
    _graceDaysCtrl = TextEditingController(
      text: ((cfg['gracePeriodDays'] as num?)?.toInt() ?? 15).toString(),
    );
    _feeCtrl = TextEditingController(
      text: ((cfg['processingFee'] as num?)?.toInt() ?? 0).toString(),
    );
    _roundCtrl = TextEditingController(
      text: ((cfg['roundToNearest'] as num?)?.toInt() ?? 100).toString(),
    );

    _isCompounding = cfg['isCompoundingProfit'] == true;
    _addFeeToPrincipal = cfg['addProcessingFeeToPrincipal'] == true;

    final rawDurations = cfg['allowedDurations'];
    if (rawDurations is List && rawDurations.isNotEmpty) {
      _selectedDurations = rawDurations
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .where((e) => e > 0)
          .toList()
        ..sort();
    }
  }

  @override
  void dispose() {
    _advanceCtrl.dispose();
    _profitCheckCtrl.dispose();
    _profitNoCheckCtrl.dispose();
    _incrementCtrl.dispose();
    _dueDayCtrl.dispose();
    _graceDaysCtrl.dispose();
    _feeCtrl.dispose();
    _roundCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveConfig() async {
    if (_selectedDurations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('کم از کم ایک مدت (ماہ) منتخب کریں!')),
      );
      return;
    }

    await PosControlStorageService.saveCalculatorConfig(
      advancePercentage: double.tryParse(_advanceCtrl.text.trim()) ?? 0.8,
      profitWithCheck: double.tryParse(_profitCheckCtrl.text.trim()) ?? 0.25,
      profitWithoutCheck: double.tryParse(_profitNoCheckCtrl.text.trim()) ?? 0.35,
      perMonthIncrement: double.tryParse(_incrementCtrl.text.trim()) ?? 0.05,
      gracePeriodDays: int.tryParse(_graceDaysCtrl.text.trim()) ?? 15,
      installmentDueDay: int.tryParse(_dueDayCtrl.text.trim()) ?? 5,
      processingFee: int.tryParse(_feeCtrl.text.trim()) ?? 0,
      roundToNearest: int.tryParse(_roundCtrl.text.trim()) ?? 100,
      isCompoundingProfit: _isCompounding,
      addProcessingFeeToPrincipal: _addFeeToPrincipal,
      allowedDurations: _selectedDurations..sort(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ کیلکولیٹر سیٹنگز محفوظ ہو کر POS ایپ پر سنک ہو گئیں!'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  Widget _buildNumberField(
    String label,
    TextEditingController ctrl, {
    String? helper,
    bool isDecimal = true,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
      textAlign: TextAlign.left,
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        helperMaxLines: 2,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryEmerald.withAlpha(80)),
            ),
            child: const Row(
              children: [
                Icon(Icons.sync_alt, color: AppColors.primaryEmerald),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'یہاں سے محفوظ کی گئی شرائط فوری طور پر دکان کی POS کیلکولیٹر ایپ پر لاگو ہو جائیں گی۔',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  'ایڈوانس شرح (Advance %)',
                  _advanceCtrl,
                  helper: 'مثلاً 0.8 = 20% ایڈوانس',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildNumberField(
                  'ماہانہ اضافہ (Increment)',
                  _incrementCtrl,
                  helper: 'مثلاً 0.05 = 5% فی ماہ',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  'منافع مع چیک (With Check)',
                  _profitCheckCtrl,
                  helper: 'مثلاً 0.25 = 25%',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildNumberField(
                  'منافع بغیر چیک (Without Check)',
                  _profitNoCheckCtrl,
                  helper: 'مثلاً 0.35 = 35%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  'قسط کی مقررہ تاریخ (Due Day)',
                  _dueDayCtrl,
                  helper: 'ہر ماہ کی تاریخ (مثلاً 5)',
                  isDecimal: false,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildNumberField(
                  'رعایتی دن (Grace Days)',
                  _graceDaysCtrl,
                  helper: 'مثلاً 15 دن',
                  isDecimal: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  'پروسیسنگ فیس (روپے)',
                  _feeCtrl,
                  isDecimal: false,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildNumberField(
                  'راؤنڈ آف (Round To)',
                  _roundCtrl,
                  helper: 'مثلاً 100 روپے',
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
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'اجازت شدہ اقساط کے مہینے (Allowed Durations):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _allPossibleMonths.map((month) {
                    final isSelected = _selectedDurations.contains(month);
                    return FilterChip(
                      label: Text(
                        '$month ماہ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primaryEmerald,
                      checkmarkColor: Colors.white,
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _selectedDurations.add(month);
                          } else {
                            _selectedDurations.remove(month);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text(
              'کمپاؤنڈنگ منافع (Compounding Profit)',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
            ),
            value: _isCompounding,
            activeTrackColor: AppColors.primaryEmerald,
            onChanged: (v) => setState(() => _isCompounding = v),
          ),
          SwitchListTile(
            title: const Text(
              'پروسیسنگ فیس اصل رقم میں شامل کریں',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
            ),
            value: _addFeeToPrincipal,
            activeTrackColor: AppColors.primaryEmerald,
            onChanged: (v) => setState(() => _addFeeToPrincipal = v),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _saveConfig,
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text(
              'کیلکولیٹر سیٹنگز محفوظ اور سنک کریں',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryEmerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}