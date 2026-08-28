import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/models/evaluation_model.dart';
import '../../../providers/evaluation_filters_provider.dart';
import '../../../providers/courses_provider.dart';

class EvaluationFiltersSheet extends ConsumerWidget {
  const EvaluationFiltersSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(evaluationFiltersProvider);
    final courses = ref.watch(activeCoursesProvider);

    return Container(
      padding: EdgeInsets.only(
        top: AppSizes.spacing24,
        left: AppSizes.spacing24,
        right: AppSizes.spacing24,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.spacing24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.spacing12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: const Icon(
                  Iconsax.filter,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filtros',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (filters.hasActiveFilters)
                      Text(
                        '${filters.activeFilterCount} filtro${filters.activeFilterCount > 1 ? 's' : ''} activo${filters.activeFilterCount > 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                  ],
                ),
              ),
              if (filters.hasActiveFilters)
                TextButton(
                  onPressed: () {
                    ref.read(evaluationFiltersProvider.notifier).clearFilters();
                  },
                  child: const Text('Limpiar'),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing24),

          // Filtro por Curso
          Text(
            'Curso',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSizes.spacing12),
          DropdownMenu<String>(
            expandedInsets: EdgeInsets.zero,
            width: double.infinity,
            label: const Text('Curso'),
            initialSelection: filters.courseId ?? 'all',
            dropdownMenuEntries: [
              const DropdownMenuEntry(value: 'all', label: 'Todos'),
              ...courses.map((course) => DropdownMenuEntry(
                    value: course.id,
                    label: course.code,
                    leadingIcon: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Color(course.colorValue),
                        shape: BoxShape.circle,
                      ),
                    ),
                  )),
            ],
            onSelected: (value) {
              ref
                  .read(evaluationFiltersProvider.notifier)
                  .setCourseFilter(value == null || value == 'all' ? null : value);
            },
          ),
          const SizedBox(height: AppSizes.spacing24),

          // Filtro por Tipo
          Text(
            'Tipo',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSizes.spacing12),
          DropdownMenu<String>(
            expandedInsets: EdgeInsets.zero,
            width: double.infinity,
            label: const Text('Tipo'),
            initialSelection: filters.type == null
                ? 'all'
                : filters.type == EvaluationType.exam
                    ? 'exam'
                    : filters.type == EvaluationType.task
                        ? 'task'
                        : 'project',
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: 'all', label: 'Todos'),
              DropdownMenuEntry(
                value: 'exam',
                label: 'Examen',
                leadingIcon: Icon(Iconsax.document_text, size: 18),
              ),
              DropdownMenuEntry(
                value: 'task',
                label: 'Tarea',
                leadingIcon: Icon(Iconsax.task, size: 18),
              ),
              DropdownMenuEntry(
                value: 'project',
                label: 'Proyecto',
                leadingIcon: Icon(Iconsax.folder, size: 18),
              ),
            ],
            onSelected: (value) {
              EvaluationType? type;
              switch (value) {
                case 'exam':
                  type = EvaluationType.exam;
                  break;
                case 'task':
                  type = EvaluationType.task;
                  break;
                case 'project':
                  type = EvaluationType.project;
                  break;
                default:
                  type = null;
              }
              ref
                  .read(evaluationFiltersProvider.notifier)
                  .setTypeFilter(type);
            },
          ),
          const SizedBox(height: AppSizes.spacing24),

          // Filtro por Estado
          Text(
            'Estado',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSizes.spacing12),
          DropdownMenu<String>(
            expandedInsets: EdgeInsets.zero,
            width: double.infinity,
            label: const Text('Estado'),
            initialSelection: filters.isCompleted == null
                ? 'all'
                : filters.isCompleted!
                    ? 'completed'
                    : 'pending',
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: 'all', label: 'Todos'),
              DropdownMenuEntry(
                value: 'pending',
                label: 'Pendientes',
                leadingIcon: Icon(Iconsax.clock, size: 18),
              ),
              DropdownMenuEntry(
                value: 'completed',
                label: 'Completadas',
                leadingIcon: Icon(Iconsax.tick_circle, size: 18),
              ),
            ],
            onSelected: (value) {
              bool? status;
              if (value == 'pending') status = false;
              if (value == 'completed') status = true;
              ref
                  .read(evaluationFiltersProvider.notifier)
                  .setStatusFilter(status);
            },
          ),
          const SizedBox(height: AppSizes.spacing24),

          // Filtro por Prioridad
          Text(
            'Prioridad',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSizes.spacing12),
          DropdownMenu<String>(
            expandedInsets: EdgeInsets.zero,
            width: double.infinity,
            label: const Text('Prioridad'),
            initialSelection: filters.priority == null
                ? 'all'
                : filters.priority == Priority.critical
                    ? 'critical'
                    : filters.priority == Priority.high
                        ? 'high'
                        : filters.priority == Priority.medium
                            ? 'medium'
                            : 'low',
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: 'all', label: 'Todas'),
              DropdownMenuEntry(
                value: 'critical',
                label: 'Crítica',
                leadingIcon: _PriorityDot(color: AppColors.priorityCritical),
              ),
              DropdownMenuEntry(
                value: 'high',
                label: 'Alta',
                leadingIcon: _PriorityDot(color: AppColors.priorityHigh),
              ),
              DropdownMenuEntry(
                value: 'medium',
                label: 'Media',
                leadingIcon: _PriorityDot(color: AppColors.priorityMedium),
              ),
              DropdownMenuEntry(
                value: 'low',
                label: 'Baja',
                leadingIcon: _PriorityDot(color: AppColors.priorityLow),
              ),
            ],
            onSelected: (value) {
              Priority? priority;
              switch (value) {
                case 'critical':
                  priority = Priority.critical;
                  break;
                case 'high':
                  priority = Priority.high;
                  break;
                case 'medium':
                  priority = Priority.medium;
                  break;
                case 'low':
                  priority = Priority.low;
                  break;
                default:
                  priority = null;
              }
              ref
                  .read(evaluationFiltersProvider.notifier)
                  .setPriorityFilter(priority);
            },
          ),
        ],
      ),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  final Color color;

  const _PriorityDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
