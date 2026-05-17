import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/models/course_model.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(course.colorValue);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacing12),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onEdit(),
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
              icon: Iconsax.edit,
              label: 'Editar',
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppSizes.radiusMedium),
              ),
            ),
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              icon: Iconsax.trash,
              label: 'Eliminar',
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(AppSizes.radiusMedium),
              ),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
              border: Border.all(
                color: AppColors.surfaceVariant,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Color indicator
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                ),
                const SizedBox(width: AppSizes.spacing16),

                // Course icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                  child: Center(
                    child: Icon(
                      Iconsax.book_1,
                      color: color,
                      size: AppSizes.iconMedium,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.spacing16),

                // Course info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSizes.spacing4),
                      Text(
                        'Desliza para ver detalles',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Icon(
                  Iconsax.arrow_right_3,
                  color: AppColors.textTertiary,
                  size: AppSizes.iconSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
