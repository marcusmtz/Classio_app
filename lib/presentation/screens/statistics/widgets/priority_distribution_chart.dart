import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/models/evaluation_model.dart';
import '../../../providers/statistics_provider.dart';

class PriorityDistributionChart extends ConsumerWidget {
  const PriorityDistributionChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distributions = ref.watch(priorityDistributionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Verificar si hay datos
    final hasData = distributions.any((d) => d.count > 0);

    if (!hasData) {
      return _buildEmptyState(context, isDark);
    }

    // Calcular el total para las barras
    final maxCount =
        distributions.map((d) => d.count).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(
          color:
              isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.spacing8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: const Icon(
                  Iconsax.flash_1,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSizes.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distribución de Prioridades',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Evaluaciones pendientes por urgencia',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing24),

          // Barras de prioridad
          ...distributions.map((distribution) {
            return _buildPriorityBar(
              context,
              distribution,
              maxCount,
              isDark,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPriorityBar(
    BuildContext context,
    PriorityDistribution distribution,
    int maxCount,
    bool isDark,
  ) {
    final color = _getPriorityColor(distribution.priority);
    final icon = _getPriorityIcon(distribution.priority);
    final label = _getPriorityLabel(distribution.priority);

    // Calcular el ancho de la barra (mínimo 5% si hay datos)
    final barWidth = distribution.count > 0
        ? (distribution.count / maxCount).clamp(0.05, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con icono, label y contador
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: AppSizes.spacing8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacing8,
                  vertical: AppSizes.spacing4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Text(
                  '${distribution.count}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(width: AppSizes.spacing8),
              SizedBox(
                width: 45,
                child: Text(
                  '${distribution.percentage.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing8),

          // Barra de progreso
          Stack(
            children: [
              // Fondo de la barra
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
              ),
              // Barra de progreso
              FractionallySizedBox(
                widthFactor: barWidth,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color,
                        color.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.spacing20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(
          color:
              isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.spacing8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: const Icon(
                  Iconsax.flash_1,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSizes.spacing12),
              Text(
                'Distribución de Prioridades',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing24),
          Icon(
            Iconsax.task_square,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSizes.spacing16),
          Text(
            '¡No hay evaluaciones pendientes!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            'Cuando tengas tareas pendientes,\nverás su distribución por prioridad aquí',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.critical:
        return AppColors.priorityCritical;
      case Priority.high:
        return AppColors.priorityHigh;
      case Priority.medium:
        return AppColors.priorityMedium;
      case Priority.low:
        return AppColors.priorityLow;
    }
  }

  IconData _getPriorityIcon(Priority priority) {
    switch (priority) {
      case Priority.critical:
        return Iconsax.danger;
      case Priority.high:
        return Iconsax.warning_2;
      case Priority.medium:
        return Iconsax.info_circle;
      case Priority.low:
        return Iconsax.tick_circle;
    }
  }

  String _getPriorityLabel(Priority priority) {
    switch (priority) {
      case Priority.critical:
        return 'Crítica';
      case Priority.high:
        return 'Alta';
      case Priority.medium:
        return 'Media';
      case Priority.low:
        return 'Baja';
    }
  }
}
