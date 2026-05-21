import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/models/evaluation_model.dart';
import '../../../providers/courses_provider.dart';
import '../../../providers/critical_week_provider.dart';
import '../../evaluations/evaluation_detail_screen.dart';

class CriticalWeekDetailScreen extends ConsumerWidget {
  final CriticalWeekInfo info;

  const CriticalWeekDetailScreen({
    super.key,
    required this.info,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semana Crítica'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(context),
            const SizedBox(height: AppSizes.spacing24),
            _buildStatsGrid(context),
            const SizedBox(height: AppSizes.spacing24),
            Text(
              'Evaluaciones de esta semana',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.spacing16),
            ...info.evaluations.map((evaluation) {
              return _buildEvaluationCard(context, ref, evaluation);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Iconsax.warning_2,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: AppSizes.spacing16),
          Text(
            '¡Semana Crítica!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            info.message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Iconsax.clipboard_text,
            label: 'Exámenes',
            value: '${info.examsCount}',
            color: AppColors.examColor,
          ),
        ),
        const SizedBox(width: AppSizes.spacing12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Iconsax.folder_2,
            label: 'Proyectos',
            value: '${info.projectsCount}',
            color: AppColors.projectColor,
          ),
        ),
        const SizedBox(width: AppSizes.spacing12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Iconsax.task_square,
            label: 'Tareas',
            value: '${info.tasksCount}',
            color: AppColors.taskColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color:
              isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        ),
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

  Widget _buildEvaluationCard(
    BuildContext context,
    WidgetRef ref,
    Evaluation evaluation,
  ) {
    final course =
        ref.read(coursesProvider.notifier).getCourseById(evaluation.courseId);
    if (course == null) return const SizedBox.shrink();

    final dateFormat = DateFormat('EEEE d \'de\' MMMM', 'es_ES');
    final timeFormat = DateFormat('HH:mm');
    final formattedDate = dateFormat.format(evaluation.dueDate);
    final capitalizedDate =
        formattedDate[0].toUpperCase() + formattedDate.substring(1);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color priorityColor;
    switch (evaluation.priority) {
      case Priority.critical:
        priorityColor = AppColors.priorityCritical;
        break;
      case Priority.high:
        priorityColor = AppColors.priorityHigh;
        break;
      case Priority.medium:
        priorityColor = AppColors.priorityMedium;
        break;
      case Priority.low:
        priorityColor = AppColors.priorityLow;
        break;
    }

    IconData typeIcon;
    Color typeColor;
    switch (evaluation.type) {
      case EvaluationType.exam:
        typeIcon = Iconsax.clipboard_text;
        typeColor = AppColors.examColor;
        break;
      case EvaluationType.project:
        typeIcon = Iconsax.folder_2;
        typeColor = AppColors.projectColor;
        break;
      case EvaluationType.task:
        typeIcon = Iconsax.task_square;
        typeColor = AppColors.taskColor;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacing12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EvaluationDetailScreen(evaluation: evaluation),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(
              color: Color(course.colorValue).withValues(alpha: 0.3),
              width: 2,
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
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: Icon(
                      typeIcon,
                      color: typeColor,
                      size: AppSizes.iconMedium,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          evaluation.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: AppSizes.spacing4),
                        Text(
                          course.name,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacing12),
              Row(
                children: [
                  Icon(
                    Iconsax.calendar,
                    size: AppSizes.iconSmall,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSizes.spacing8),
                  Text(
                    '$capitalizedDate a las ${timeFormat.format(evaluation.dueDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
