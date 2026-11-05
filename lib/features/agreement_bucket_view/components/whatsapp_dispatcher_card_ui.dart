import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class WhatsappDispatcherCardUi extends StatelessWidget {
  final TextEditingController phoneController;
  final VoidCallback onSendQuestions;
  final VoidCallback onPasteAnswers;

  const WhatsappDispatcherCardUi({
    super.key,
    required this.phoneController,
    required this.onSendQuestions,
    required this.onPasteAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'گاہک سے بذریعہ واٹس ایپ کوائف منگوائیں',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Icon(Icons.chat_bubble_outline, color: Colors.green, size: 22),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              labelText: 'گاہک کا واٹس ایپ نمبر (اختیاری)',
              hintText: '03001234567',
              prefixIcon: const Icon(Icons.phone_android, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onSendQuestions,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('سوالات واٹس ایپ کریں', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPasteAnswers,
                  icon: const Icon(Icons.content_paste, size: 18),
                  label: const Text('جواب آٹو فل کریں', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}