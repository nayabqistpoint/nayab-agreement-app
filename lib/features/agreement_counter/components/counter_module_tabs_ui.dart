import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CounterModuleTabsUi extends StatelessWidget {
  final VoidCallback onOpenStampStudio;
  final VoidCallback onOpenPlainDocStudio;
  final VoidCallback onOpenFormFillerStudio;

  const CounterModuleTabsUi({
    super.key,
    required this.onOpenStampStudio,
    required this.onOpenPlainDocStudio,
    required this.onOpenFormFillerStudio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: _buildActionTab(
              icon: Icons.description,
              label: 'ای-اسٹامپ نیا',
              color: AppColors.primaryEmerald,
              onTap: onOpenStampStudio,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionTab(
              icon: Icons.receipt_long,
              label: 'سادہ رسید / A4',
              color: Colors.teal.shade700,
              onTap: onOpenPlainDocStudio,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionTab(
              icon: Icons.edit_document,
              label: 'فارم فلر نیا',
              color: Colors.indigo.shade700,
              onTap: onOpenFormFillerStudio,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTab({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}