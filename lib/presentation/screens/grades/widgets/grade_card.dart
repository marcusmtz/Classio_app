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
import '../../../providers/app_settings_provider.dart';
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
    final isPending = grade.isPending;
    final percentage = !isPending ? (grade.score! / grade.maxScore!) * 100 : 0.0;
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
                  if (isPending)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                          ),
                          child: const Text('Pendiente', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600, fontSize: 11)),
                        ),
                        const SizedBox(height: 4),
                        Text('${grade.weight.toStringAsFixed(1)}%', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${grade.score!.toStringAsFixed(1)}',
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _getScoreColor(percentage),
                                  ),
                        ),
                        Text(
                          '/ ${grade.maxScore!.toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.spacing12),
              if (isPending)
                InkWell(
                  onTap: () => _showQuickAddScore(context, ref),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.spacing12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Iconsax.edit, color: AppColors.warning, size: 18),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('Toca para ingresar la nota', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600))),
                        Text('${grade.weight.toStringAsFixed(1)}%', style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )
              else
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
            onPressed: () {
              Navigator.pop(context);
              ref.read(gradesProvider.notifier).deleteGrade(grade.id);
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${grade.title}" eliminada'),
                  action: SnackBarAction(
                    label: 'Deshacer',
                    onPressed: () {
                      ref.read(gradesProvider.notifier).undoDelete(grade.id);
                    },
                  ),
                  duration: const Duration(seconds: 5),
                ),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showQuickAddScore(BuildContext context, WidgetRef ref) {
    final scoreController = TextEditingController();
    final maxController = TextEditingController(text: ref.read(appSettingsProvider).gradeMaxValue.toStringAsFixed(1));
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ingresar nota: ${grade.title}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: scoreController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Nota obtenida', prefixIcon: Icon(Iconsax.star)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  final val = double.tryParse(v);
                  if (val == null) return 'Número inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: maxController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Nota máxima', prefixIcon: Icon(Iconsax.star_1)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  final val = double.tryParse(v);
                  if (val == null || val <= 0) return 'Inválido';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final score = double.parse(scoreController.text);
              final max = double.parse(maxController.text);
              try {
                await ref.read(gradesProvider.notifier).updateGradeScore(gradeId: grade.id, score: score, maxScore: max);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
