import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/models/grade_model.dart';
import '../../../../data/models/course_model.dart';

class CourseGradeSummary extends ConsumerWidget {
  final Course course;
  final List<Grade> grades;
  final double? average;

  const CourseGradeSummary({
    super.key,
    required this.course,
    required this.grades,
    required this.average,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalWeight = grades.fold<double>(0, (sum, g) => sum + g.weight);
    final completedWeight = grades.where((g) => g.score != null).fold<double>(0, (sum, g) => sum + g.weight);
    final completedCount = grades.where((g) => g.score != null).length;
    final pendingCount = grades.length - completedCount;
    final remainingWeight = 100 - totalWeight;
    final weightStatusColor = totalWeight > 100 ? Colors.red.shade200 : totalWeight == 100 ? Colors.white : Colors.white.withValues(alpha: 0.9);

    return Container(
      margin: const EdgeInsets.all(AppSizes.spacing16),
      padding: const EdgeInsets.all(AppSizes.spacing20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(course.colorValue),
            Color(course.colorValue).withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Color(course.colorValue).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.spacing12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: const Icon(
                  Iconsax.chart,
                  color: Colors.white,
                  size: AppSizes.iconMedium,
                ),
              ),
              const SizedBox(width: AppSizes.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      course.code,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  label: 'Promedio',
                  value: average != null ? average!.toStringAsFixed(2) : '—',
                  icon: Iconsax.chart_1,
                ),
              ),
              const SizedBox(width: AppSizes.spacing12),
              Expanded(
                child: _buildStatCard(
                  context,
                  label: 'Evaluaciones',
                  value: '${grades.length}',
                  icon: Iconsax.clipboard_text,
                ),
              ),
              const SizedBox(width: AppSizes.spacing12),
              Expanded(
                child: _buildStatCard(
                  context,
                  label: 'Pendientes',
                  value: '$pendingCount',
                  icon: Iconsax.clock,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            '$completedCount calificadas • $pendingCount pendientes',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: AppSizes.spacing12),
          const SizedBox(height: AppSizes.spacing12),
          Container(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ponderación planificada',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    Text(
                      '${totalWeight.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: weightStatusColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacing8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  child: Stack(
                    children: [
                      LinearProgressIndicator(
                        value: (totalWeight / 100).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          totalWeight > 100 ? AppColors.error : Colors.white,
                        ),
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final completedFraction = totalWeight > 0 ? (completedWeight / totalWeight).clamp(0.0, 1.0) : 0.0;
                          return Container(
                            height: 8,
                            width: constraints.maxWidth * completedFraction * (totalWeight / 100).clamp(0.0, 1.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.spacing6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Calificado ${completedWeight.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                    Text(
                      remainingWeight >= 0
                          ? 'Restante ${remainingWeight.toStringAsFixed(1)}%'
                          : 'Excedido ${(remainingWeight.abs()).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: remainingWeight < 0 ? Colors.red.shade200 : Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                if (totalWeight != 100)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      totalWeight < 100
                          ? 'Falta planificar ${(100 - totalWeight).toStringAsFixed(1)}% para completar 100%'
                          : 'Revisa pesos: superas 100%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.95), fontStyle: FontStyle.italic),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: AppSizes.iconMedium,
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSizes.spacing4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
          ),
        ],
      ),
    );
  }
}
