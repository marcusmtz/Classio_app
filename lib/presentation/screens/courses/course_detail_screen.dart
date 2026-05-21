import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/class_schedule_model.dart';
import '../../../data/models/course_model.dart';
import '../../providers/evaluations_provider.dart';
import '../../providers/grades_provider.dart';
import '../../providers/schedule_provider.dart';
import '../evaluations/evaluation_detail_screen.dart';

class CourseDetailScreen extends ConsumerWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedules = ref
        .watch(scheduleProvider)
        .where((item) => item.courseId == course.id)
        .toList()
      ..sort((a, b) {
        final dayCompare = a.dayOfWeek.index.compareTo(b.dayOfWeek.index);
        if (dayCompare != 0) return dayCompare;
        return a.startTime.compareTo(b.startTime);
      });

    final evaluations = ref
        .watch(evaluationsProvider)
        .where((item) => item.courseId == course.id)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final pendingEvaluations =
        evaluations.where((item) => !item.isCompleted).toList();
    final grades = ref.watch(gradesByCourseProvider(course.id));
    final average = ref.watch(courseAverageProvider(course.id));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(course.name),
            Text(
              course.code,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        children: [
          _buildHeaderCard(context),
          const SizedBox(height: AppSizes.spacing16),
          _buildSummaryRow(
            context,
            schedulesCount: schedules.length,
            evaluationsCount: pendingEvaluations.length,
            gradesCount: grades.length,
            average: average,
          ),
          const SizedBox(height: AppSizes.spacing24),
          _buildSectionTitle(context, 'Horario del curso'),
          const SizedBox(height: AppSizes.spacing8),
          if (schedules.isEmpty)
            _buildEmptyCard(
                context, 'No hay clases registradas para este curso')
          else
            ...schedules
                .map((schedule) => _buildScheduleItem(context, schedule)),
          const SizedBox(height: AppSizes.spacing24),
          _buildSectionTitle(context, 'Evaluaciones'),
          const SizedBox(height: AppSizes.spacing8),
          if (evaluations.isEmpty)
            _buildEmptyCard(context, 'No hay evaluaciones para este curso')
          else
            ...evaluations.map((evaluation) {
              return Card(
                margin: const EdgeInsets.only(bottom: AppSizes.spacing8),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EvaluationDetailScreen(
                          evaluation: evaluation,
                        ),
                      ),
                    );
                  },
                  leading: Icon(
                    evaluation.isCompleted
                        ? Iconsax.tick_circle5
                        : Iconsax.clock,
                    color: evaluation.isCompleted
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                  title: Text(evaluation.title),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy, HH:mm', 'es_ES')
                        .format(evaluation.dueDate),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: Color(course.colorValue).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border:
            Border.all(color: Color(course.colorValue).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Color(course.colorValue),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: const Icon(Iconsax.book_1, color: Colors.white),
          ),
          const SizedBox(width: AppSizes.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  course.code,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required int schedulesCount,
    required int evaluationsCount,
    required int gradesCount,
    required double? average,
  }) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
              context, Iconsax.calendar_1, '$schedulesCount', 'Clases'),
        ),
        const SizedBox(width: AppSizes.spacing8),
        Expanded(
          child: _summaryCard(
              context, Iconsax.task_square, '$evaluationsCount', 'Pendientes'),
        ),
        const SizedBox(width: AppSizes.spacing8),
        Expanded(
          child: _summaryCard(
            context,
            Iconsax.chart,
            average != null ? average.toStringAsFixed(2) : '--',
            'Promedio',
          ),
        ),
        const SizedBox(width: AppSizes.spacing8),
        Expanded(
          child: _summaryCard(
              context, Iconsax.clipboard_text, '$gradesCount', 'Notas'),
        ),
      ],
    );
  }

  Widget _summaryCard(
      BuildContext context, IconData icon, String value, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing8,
        vertical: AppSizes.spacing12,
      ),
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
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildEmptyCard(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color:
              isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        ),
      ),
      child: Text(
        message,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildScheduleItem(BuildContext context, ClassSchedule schedule) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacing8),
      child: ListTile(
        leading: const Icon(Iconsax.clock, color: AppColors.primary),
        title: Text(_dayName(schedule.dayOfWeek)),
        subtitle: Text(
          '${schedule.startTime.format()} - ${schedule.endTime.format()}'
          '${schedule.location != null ? ' • ${schedule.location}' : ''}',
        ),
      ),
    );
  }

  String _dayName(DayOfWeek day) {
    switch (day) {
      case DayOfWeek.monday:
        return 'Lunes';
      case DayOfWeek.tuesday:
        return 'Martes';
      case DayOfWeek.wednesday:
        return 'Miércoles';
      case DayOfWeek.thursday:
        return 'Jueves';
      case DayOfWeek.friday:
        return 'Viernes';
      case DayOfWeek.saturday:
        return 'Sábado';
      case DayOfWeek.sunday:
        return 'Domingo';
    }
  }
}
