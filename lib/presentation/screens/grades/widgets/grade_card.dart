import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/models/grade_model.dart';
import '../../../../data/models/course_model.dart';
import '../../../providers/grades_provider.dart';
import '../grade_form_screen.dart';

class GradeCard extends ConsumerWidget {
  final Grade grade;
  final Course course;

  const GradeCard({
    super.key,
    required this.grade,
    required this.course,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final percentage = (grade.score / grade.maxScore) * 100;
    final dateFormat = DateFormat('d MMM yyyy', 'es_ES');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacing12),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => _editGrade(context),
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              icon: Iconsax.edit,
              label: 'Editar',
            ),
            SlidableAction(
              onPressed: (_) => _deleteGrade(context, ref),
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              icon: Iconsax.trash,
              label: 'Eliminar',
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurface
                : AppColors.surface,
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
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(course.colorValue),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          grade.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: AppSizes.spacing4),
                        Row(
                          children: [
                            Icon(
                              _getTypeIcon(grade.type),
                              size: AppSizes.iconSmall,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSizes.spacing4),
                            Text(
                              _getTypeName(grade.type),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                            const SizedBox(width: AppSizes.spacing8),
                            const Text('•'),
                            const SizedBox(width: AppSizes.spacing8),
                            Text(
                              dateFormat.format(grade.date),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${grade.score.toStringAsFixed(1)}',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getScoreColor(percentage),
                                ),
                      ),
                      Text(
                        '/ ${grade.maxScore.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacing12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Porcentaje: ',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _getScoreColor(percentage),
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.spacing4),
                        Row(
                          children: [
                            Text(
                              'Ponderación: ',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '${grade.weight.toStringAsFixed(1)}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.spacing12,
                      vertical: AppSizes.spacing6,
                    ),
                    decoration: BoxDecoration(
                      color: _getScoreColor(percentage).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: Text(
                      _getScoreLabel(percentage),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: _getScoreColor(percentage),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              if (grade.notes != null && grade.notes!.isNotEmpty) ...[
                const SizedBox(height: AppSizes.spacing12),
                Container(
                  padding: const EdgeInsets.all(AppSizes.spacing12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Iconsax.note_text,
                        size: AppSizes.iconSmall,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSizes.spacing8),
                      Expanded(
                        child: Text(
                          grade.notes!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
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
    );
  }

  IconData _getTypeIcon(GradeType type) {
    switch (type) {
      case GradeType.exam:
        return Iconsax.clipboard_text;
      case GradeType.quiz:
        return Iconsax.document_text;
      case GradeType.homework:
        return Iconsax.task_square;
      case GradeType.project:
        return Iconsax.folder_2;
      case GradeType.participation:
        return Iconsax.people;
      case GradeType.other:
        return Iconsax.note;
    }
  }

  String _getTypeName(GradeType type) {
    switch (type) {
      case GradeType.exam:
        return 'Examen';
      case GradeType.quiz:
        return 'Prueba';
      case GradeType.homework:
        return 'Tarea';
      case GradeType.project:
        return 'Proyecto';
      case GradeType.participation:
        return 'Participación';
      case GradeType.other:
        return 'Otro';
    }
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 90) return AppColors.priorityLow;
    if (percentage >= 70) return AppColors.secondary;
    if (percentage >= 60) return AppColors.priorityMedium;
    return AppColors.priorityCritical;
  }

  String _getScoreLabel(double percentage) {
    if (percentage >= 90) return 'Excelente';
    if (percentage >= 70) return 'Bueno';
    if (percentage >= 60) return 'Suficiente';
    return 'Insuficiente';
  }

  void _editGrade(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GradeFormScreen(
          courseId: course.id,
          grade: grade,
        ),
      ),
    );
  }

  void _deleteGrade(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Nota'),
        content: Text('¿Estás seguro de eliminar "${grade.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(gradesProvider.notifier).deleteGrade(grade.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nota eliminada')),
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
