import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../providers/statistics_provider.dart';

class SummaryCards extends StatelessWidget {
  final StatisticsSummary summary;

  const SummaryCards({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primera fila
        Row(
          children: [
            Expanded(
              child: _buildCard(
                context,
                icon: Iconsax.task_square,
                label: 'Total',
                value: '${summary.totalEvaluations}',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSizes.spacing12),
            Expanded(
              child: _buildCard(
                context,
                icon: Iconsax.tick_circle,
                label: 'Completadas',
                value: '${summary.completedEvaluations}',
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing12),

        // Segunda fila
        Row(
          children: [
            Expanded(
              child: _buildCard(
                context,
                icon: Iconsax.clock,
                label: 'Pendientes',
                value: '${summary.pendingEvaluations}',
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: AppSizes.spacing12),
            Expanded(
              child: _buildCard(
                context,
                icon: Iconsax.chart_success,
                label: 'Completitud',
                value: '${(summary.completionRate * 100).toStringAsFixed(0)}%',
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing12),

        // Tercera fila
        Row(
          children: [
            Expanded(
              child: _buildCard(
                context,
                icon: Iconsax.book,
                label: 'Cursos',
                value: '${summary.totalCourses}',
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: AppSizes.spacing12),
            Expanded(
              child: _buildCard(
                context,
                icon: Iconsax.warning_2,
                label: 'Críticas',
                value: '${summary.criticalPriorityCount}',
                color: AppColors.priorityCritical,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing12),

        // Cuarta fila
        Row(
          children: [
            Expanded(
              child: _buildCard(
                context,
                icon: Iconsax.calendar_2,
                label: 'Esta Semana',
                value: '${summary.thisWeekCount}',
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(width: AppSizes.spacing12),
            Expanded(
              child: _buildCard(
                context,
                icon: Iconsax.calendar_1,
                label: 'Este Mes',
                value: '${summary.thisMonthCount}',
                color: AppColors.secondaryLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: AppSizes.iconLarge),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: AppSizes.spacing4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
