import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StampCustomTagDialogUi extends StatefulWidget {
  final Function(String) onTagCreated;
  const StampCustomTagDialogUi({super.key, required this.onTagCreated});

  static Future<void> show(BuildContext context, Function(String) onTagCreated) {
    return showDialog(
      context: context,
      builder: (_) => StampCustomTagDialogUi(onTagCreated: onTagCreated),
    );
  }

  @override
  State<StampCustomTagDialogUi> createState() => _StampCustomTagDialogUiState();
}

class _StampCustomTagDialogUiState extends State<StampCustomTagDialogUi> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('نیا کسٹم ٹیگ بنائیں', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'مثلاً: گواہ کا نام، بقایا رقم وغیرہ',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('منسوخ')),
          ElevatedButton(
            onPressed: () {
              final val = _ctrl.text.trim();
              if (val.isNotEmpty) widget.onTagCreated(val);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryEmerald),
            child: const Text('ٹیگ لگائیں', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}