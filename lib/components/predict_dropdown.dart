import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Reusable premium dropdown component for car specification inputs.
class PredictDropdown<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final T? selectedValue;
  final ValueChanged<T?> onChanged;
  final bool disabled;
  final IconData? icon;
  final String? hint;

  const PredictDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.disabled = false,
    this.icon,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedValue != null && items.contains(selectedValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 15,
                  color: disabled
                      ? AppColors.iconGrey
                      : (isSelected ? AppColors.primary : AppColors.textLight),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: disabled ? AppColors.iconGrey : AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        DropdownButtonFormField<T>(
          isExpanded: true,
          value: isSelected ? selectedValue : null,
          hint: Text(
            disabled
                ? 'Select prior option'
                : (hint ?? 'Select ${label.toLowerCase()}'),
            style: TextStyle(
              fontSize: 14,
              color: disabled ? AppColors.iconGrey : AppColors.textGrey,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: disabled ? AppColors.iconGrey : AppColors.primary,
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: disabled
                ? Colors.grey.shade100
                : (isSelected
                    ? AppColors.primarySurface.withValues(alpha: 0.4)
                    : AppColors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isSelected
                    ? AppColors.primaryBorder
                    : Colors.grey.shade300,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2.0,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    item.toString(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: disabled ? null : onChanged,
        ),
      ],
    );
  }
}
