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
          const SizedBox(height: AppSizes.spacing8),
          Wrap(
            spacing: AppSizes.spacing8,
            runSpacing: AppSizes.spacing8,
            children: [
              FilterChip(
                label: const Text('Todos'),
                selected: filters.courseId == null,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(evaluationFiltersProvider.notifier).setCourseFilter(null);
                  }
                },
              ),
              ...courses.map((course) => FilterChip(
                    label: Text(course.code),
                    avatar: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Color(course.colorValue),
                        shape: BoxShape.circle,
                      ),
                    ),
                    selected: filters.courseId == course.id,
                    onSelected: (selected) {
                      ref
                          .read(evaluationFiltersProvider.notifier)
                          .setCourseFilter(selected ? course.id : null);
                    },
                  )),
            ],
          ),
          const SizedBox(height: AppSizes.spacing24),

          // Filtro por Tipo
          Text(
            'Tipo',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSizes.spacing8),
          Wrap(
            spacing: AppSizes.spacing8,
            runSpacing: AppSizes.spacing8,
            children: [
              FilterChip(
                label: const Text('Todos'),
                selected: filters.type == null,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(evaluationFiltersProvider.notifier).setTypeFilter(null);
                  }
                },
              ),
              FilterChip(
                label: const Text('Examen'),
                avatar: const Icon(Iconsax.document_text, size: 16),
                selected: filters.type == EvaluationType.exam,
                onSelected: (selected) {
                  ref
                      .read(evaluationFiltersProvider.notifier)
                      .setTypeFilter(selected ? EvaluationType.exam : null);
                },
              ),
              FilterChip(
                label: const Text('Tarea'),
                avatar: const Icon(Iconsax.task, size: 16),
                selected: filters.type == EvaluationType.task,
                onSelected: (selected) {
                  ref
                      .read(evaluationFiltersProvider.notifier)
                      .setTypeFilter(selected ? EvaluationType.task : null);
                },
              ),
              FilterChip(
                label: const Text('Proyecto'),
                avatar: const Icon(Iconsax.folder, size: 16),
                selected: filters.type == EvaluationType.project,
                onSelected: (selected) {
                  ref
                      .read(evaluationFiltersProvider.notifier)
                      .setTypeFilter(selected ? EvaluationType.project : null);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing24),

          // Filtro por Estado
          Text(
            'Estado',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSizes.spacing8),
          Wrap(
            spacing: AppSizes.spacing8,
            runSpacing: AppSizes.spacing8,
            children: [
              FilterChip(
                label: const Text('Todos'),
                selected: filters.isCompleted == null,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(evaluationFiltersProvider.notifier).setStatusFilter(null);
                  }
                },
              ),
              FilterChip(
                label: const Text('Pendientes'),
                avatar: const Icon(Iconsax.clock, size: 16),
                selected: filters.isCompleted == false,
                onSelected: (selected) {
                  ref
                      .read(evaluationFiltersProvider.notifier)
                      .setStatusFilter(selected ? false : null);
                },
              ),
              FilterChip(
                label: const Text('Completadas'),
                avatar: const Icon(Iconsax.tick_circle, size: 16),
                selected: filters.isCompleted == true,
                onSelected: (selected) {
                  ref
                      .read(evaluationFiltersProvider.notifier)
                      .setStatusFilter(selected ? true : null);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing24),

          // Filtro por Prioridad
          Text(
            'Prioridad',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSizes.spacing8),
          Wrap(
            spacing: AppSizes.spacing8,
            runSpacing: AppSizes.spacing8,
            children: [
              FilterChip(
                label: const Text('Todas'),
                selected: filters.priority == null,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(evaluationFiltersProvider.notifier).setPriorityFilter(null);
                  }
                },
              ),
              FilterChip(
                label: const Text('Crítica'),
                avatar: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.priorityCritical,
                    shape: BoxShape.circle,
                  ),
                ),
                selected: filters.priority == Priority.critical,
                onSelected: (selected) {
                  ref
                      .read(evaluationFiltersProvider.notifier)
                      .setPriorityFilter(selected ? Priority.critical : null);
                },
              ),
              FilterChip(
                label: const Text('Alta'),
                avatar: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.priorityHigh,
                    shape: BoxShape.circle,
                  ),
                ),
                selected: filters.priority == Priority.high,
                onSelected: (selected) {
                  ref
                      .read(evaluationFiltersProvider.notifier)
                      .setPriorityFilter(selected ? Priority.high : null);
                },
              ),
              FilterChip(
                label: const Text('Media'),
                avatar: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.priorityMedium,
                    shape: BoxShape.circle,
                  ),
                ),
                selected: filters.priority == Priority.medium,
                onSelected: (selected) {
                  ref
                      .read(evaluationFiltersProvider.notifier)
                      .setPriorityFilter(selected ? Priority.medium : null);
                },
              ),
              FilterChip(
                label: const Text('Baja'),
                avatar: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.priorityLow,
                    shape: BoxShape.circle,
                  ),
                ),
                selected: filters.priority == Priority.low,
                onSelected: (selected) {
                  ref
                      .read(evaluationFiltersProvider.notifier)
                      .setPriorityFilter(selected ? Priority.low : null);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
