import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/customer_profile_model.dart';

class CustomerProfileTileUi extends StatelessWidget {
  final CustomerProfileModel customer;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CustomerProfileTileUi({
    super.key,
    required this.customer,
    this.isSelectionMode = false,
    this.isSelected = false,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final bool isGuarantor = customer.role.startsWith('ضامن');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      elevation: 1,
      color: isSelected ? AppColors.primaryEmerald.withAlpha(22) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppColors.primaryEmerald : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: isSelectionMode
            ? Checkbox(
                value: isSelected,
                activeColor: AppColors.primaryEmerald,
                onChanged: (_) => onTap(),
              )
            : CircleAvatar(
                backgroundColor: isGuarantor
                    ? Colors.indigo.shade50
                    : AppColors.primaryEmerald.withAlpha(30),
                child: Icon(
                  isGuarantor ? Icons.shield_outlined : Icons.person,
                  color: isGuarantor
                      ? Colors.indigo.shade700
                      : AppColors.primaryEmerald,
                ),
              ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                customer.fullName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color:
                    isGuarantor ? Colors.indigo.shade50 : Colors.teal.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isGuarantor ? 'ضامن' : 'گاہک',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: isGuarantor
                      ? Colors.indigo.shade800
                      : AppColors.primaryEmerald,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          'شناختی کارڈ: ${customer.cnic} | فون: ${customer.phone}',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 14, color: Colors.black38),
      ),
    );
  }
}