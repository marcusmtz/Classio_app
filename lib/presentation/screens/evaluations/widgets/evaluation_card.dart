import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/evaluation_model.dart';
import '../../../../data/models/course_model.dart';
import '../../../providers/evaluations_provider.dart';
import '../../../providers/courses_provider.dart';
import '../evaluation_detail_screen.dart';

class EvaluationCard extends ConsumerWidget {
  final Evaluation evaluation;
  final VoidCallback onTap;

  const EvaluationCard({
    super.key,
    required this.evaluation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(coursesProvider);
    Course? course;
    for (final item in courses) {
      if (item.id == evaluation.courseId) {
        course = item;
        break;
      }
    }

    if (course == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onTap(),
            backgroundColor: AppColors.info,
            foregroundColor: Colors.white,
            icon: Iconsax.edit,
            label: 'Editar',
          ),
          SlidableAction(
            onPressed: (_) => _showDeleteDialog(context, ref),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Iconsax.trash,
            label: 'Eliminar',
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Opacity(
          opacity: evaluation.isCompleted ? 0.55 : 1.0,
          child: Material(
            color: Colors.transparent,
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
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(course.colorValue),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              evaluation.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: evaluation.isCompleted
                                    ? FontWeight.w500
                                    : FontWeight.w600,
                                decoration: evaluation.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: isDark
                                    ? (evaluation.isCompleted
                                        ? AppColors.darkTextSecondary
                                        : AppColors.darkTextPrimary)
                                    : (evaluation.isCompleted
                                        ? AppColors.textSecondary
                                        : AppColors.textPrimary),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              course.name,
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(course.colorValue),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildPriorityBadge(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildTypeBadge(),
                      const SizedBox(width: 12),
                      Icon(
                        Iconsax.calendar,
                        size: 16,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(evaluation.dueDate),
                        style: TextStyle(
                          fontSize: 13,
                          decoration: evaluation.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      if (evaluation.subtasks != null &&
                          evaluation.subtasks!.isNotEmpty)
                        _buildProgressIndicator(isDark),
                    ],
                  ),
                  if (evaluation.isCompleted) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.tick_circle5,
                            size: 16,
                            color: AppColors.success,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Completada',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge() {
    IconData icon;
    Color color;
    String label;

    switch (evaluation.type) {
      case EvaluationType.exam:
        icon = Iconsax.document_text;
        color = AppColors.examColor;
        label = 'Examen';
        break;
      case EvaluationType.task:
        icon = Iconsax.task;
        color = AppColors.taskColor;
        label = 'Tarea';
        break;
      case EvaluationType.project:
        icon = Iconsax.folder;
        color = AppColors.projectColor;
        label = 'Proyecto';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge() {
    Color color;
    String label;

    switch (evaluation.priority) {
      case Priority.critical:
        color = AppColors.priorityCritical;
        label = 'Crítica';
        break;
      case Priority.high:
        color = AppColors.priorityHigh;
        label = 'Alta';
        break;
      case Priority.medium:
        color = AppColors.priorityMedium;
        label = 'Media';
        break;
      case Priority.low:
        color = AppColors.priorityLow;
        label = 'Baja';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    final progress = evaluation.progress;
    final completed = (evaluation.subtasks!.where((s) => s.isCompleted).length);
    final total = evaluation.subtasks!.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            children: [
              CircularProgressIndicator(
                value: progress,
                backgroundColor: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.surfaceVariant,
                valueColor: const AlwaysStoppedAnimation(AppColors.success),
                strokeWidth: 3,
              ),
              Center(
                child: Text(
                  '$completed',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '/$total',
          style: TextStyle(
            fontSize: 12,
            color:
                isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hoy ${DateFormat('HH:mm').format(date)}';
    } else if (dateOnly == tomorrow) {
      return 'Mañana ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('dd MMM, HH:mm', 'es').format(date);
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar evaluación?'),
        content: const Text('Podrás deshacer durante 5 segundos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(evaluationsProvider.notifier).deleteEvaluation(evaluation.id);
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${evaluation.title}" eliminada'),
                  action: SnackBarAction(
                    label: 'Deshacer',
                    onPressed: () => ref.read(evaluationsProvider.notifier).undoDelete(evaluation.id),
                  ),
                  duration: const Duration(seconds: 5),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
