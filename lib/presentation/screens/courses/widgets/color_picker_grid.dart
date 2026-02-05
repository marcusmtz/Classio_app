import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class ColorPickerGrid extends StatelessWidget {
  final int selectedColorValue;
  final Function(int) onColorSelected;

  const ColorPickerGrid({
    super.key,
    required this.selectedColorValue,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.spacing12,
      runSpacing: AppSizes.spacing12,
      children: AppColors.courseColors.map((color) {
        final isSelected = color.value == selectedColorValue;
        return GestureDetector(
          onTap: () => onColorSelected(color.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: isSelected
                ? const Icon(
                    Iconsax.tick_circle5,
                    color: Colors.white,
                    size: AppSizes.iconMedium,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
