import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/models/evaluation_model.dart';
import '../../../providers/statistics_provider.dart';

class TypeDistributionChart extends ConsumerWidget {
  const TypeDistributionChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distributions = ref.watch(typeDistributionProvider);

    if (distributions.isEmpty) {
      return _buildEmptyState(context);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          Text(
            'Distribución por Tipo',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            'Todas las evaluaciones por tipo',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSizes.spacing24),
          // Gráfico de torta centrado
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: distributions.map((dist) {
                    final color = _getColorForType(dist.type);
                    return PieChartSectionData(
                      value: dist.count.toDouble(),
                      title: '${dist.percentage.toStringAsFixed(0)}%',
                      color: color,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacing16),
          // Leyenda
          ...distributions.map((dist) {
            return _buildLegendItem(
              context,
              type: dist.type,
              count: dist.count,
              color: _getColorForType(dist.type),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context, {
    required EvaluationType type,
    required int count,
    required Color color,
  }) {
    String label;

    switch (type) {
      case EvaluationType.exam:
        label = 'Exámenes';
        break;
      case EvaluationType.project:
        label = 'Proyectos';
        break;
      case EvaluationType.task:
        label = 'Tareas';
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacing12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSizes.spacing8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                '$count',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorForType(EvaluationType type) {
    switch (type) {
      case EvaluationType.exam:
        return AppColors.examColor;
      case EvaluationType.project:
        return AppColors.projectColor;
      case EvaluationType.task:
        return AppColors.taskColor;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          Text(
            'Distribución por Tipo',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.spacing24),
          Icon(
            Icons.pie_chart_rounded,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSizes.spacing16),
          Text(
            'No hay evaluaciones registradas',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
