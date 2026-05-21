import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../providers/statistics_provider.dart';

class CourseLoadChart extends ConsumerWidget {
  const CourseLoadChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseLoads = ref.watch(courseLoadProvider);

    if (courseLoads.isEmpty) {
      return _buildEmptyState(context);
    }

    // Tomar solo los primeros 5 cursos
    final topCourses = courseLoads.take(5).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? Colors.white70 : Colors.black54;

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
            'Carga por Curso',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            'Evaluaciones pendientes por curso',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSizes.spacing24),
          Center(
            child: SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (topCourses
                              .map((e) => e.evaluationCount)
                              .reduce((a, b) => a > b ? a : b) +
                          2)
                      .toDouble(),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final course = topCourses[groupIndex];
                        return BarTooltipItem(
                          '${course.courseName}\n${course.evaluationCount} evaluaciones',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= topCourses.length) {
                            return const SizedBox.shrink();
                          }
                          final course = topCourses[value.toInt()];
                          final shortName = course.courseName.length > 8
                              ? '${course.courseName.substring(0, 8)}...'
                              : course.courseName;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              shortName,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: labelColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: labelColor,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.surfaceVariant,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: topCourses.asMap().entries.map((entry) {
                    final index = entry.key;
                    final course = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: course.evaluationCount.toDouble(),
                          color: Color(course.colorValue),
                          width: 30,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
            'Carga por Curso',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.spacing24),
          Icon(
            Icons.bar_chart_rounded,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSizes.spacing16),
          Text(
            'No hay evaluaciones pendientes',
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
