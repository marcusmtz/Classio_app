import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/models/class_schedule_model.dart';
import '../../../providers/courses_provider.dart';
import '../../../providers/schedule_provider.dart';
import '../../../providers/app_settings_provider.dart';
import '../schedule_form_screen.dart';

class ScheduleListView extends ConsumerWidget {
  final List<ClassSchedule> schedules;

  const ScheduleListView({super.key, required this.schedules});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    if (schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSizes.spacing16),
            Text(
              'No hay clases programadas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    // Agrupar por día
    final groupedSchedules = <DayOfWeek, List<ClassSchedule>>{};
    for (final schedule in schedules) {
      groupedSchedules.putIfAbsent(schedule.dayOfWeek, () => []);
      groupedSchedules[schedule.dayOfWeek]!.add(schedule);
    }

    // Ordenar cada grupo por hora
    groupedSchedules.forEach((day, scheduleList) {
      scheduleList.sort((a, b) => a.startTime.compareTo(b.startTime));
    });

    final orderedDays = [
      DayOfWeek.monday,
      DayOfWeek.tuesday,
      DayOfWeek.wednesday,
      DayOfWeek.thursday,
      DayOfWeek.friday,
      if (settings.showSaturday) DayOfWeek.saturday,
      if (settings.showSunday) DayOfWeek.sunday,
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      itemCount: orderedDays.length,
      itemBuilder: (context, index) {
        final day = orderedDays[index];
        final daySchedules = groupedSchedules[day] ?? [];

        if (daySchedules.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.spacing12,
                horizontal: AppSizes.spacing8,
              ),
              child: Text(
                _getDayName(day),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
            ),
            ...daySchedules.map((schedule) => _buildScheduleCard(
                  context,
                  ref,
                  schedule,
                )),
            const SizedBox(height: AppSizes.spacing16),
          ],
        );
      },
    );
  }

  Widget _buildScheduleCard(
    BuildContext context,
    WidgetRef ref,
    ClassSchedule schedule,
  ) {
    final course =
        ref.read(coursesProvider.notifier).getCourseById(schedule.courseId);
    if (course == null) return const SizedBox.shrink();

    final currentClass = ref.watch(scheduleProvider.notifier).getCurrentClass();
    final isCurrentClass = currentClass?.id == schedule.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacing12),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ScheduleFormScreen(schedule: schedule),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: Iconsax.edit,
              label: 'Editar',
            ),
            SlidableAction(
              onPressed: (context) => _confirmDelete(context, ref, schedule),
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
            color: isCurrentClass
                ? Color(course.colorValue).withValues(alpha: 0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(
              color: isCurrentClass
                  ? Color(course.colorValue)
                  : AppColors.surfaceVariant,
              width: isCurrentClass ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(course.colorValue),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
              ),
              const SizedBox(width: AppSizes.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            course.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        if (isCurrentClass)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.spacing8,
                              vertical: AppSizes.spacing4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(course.colorValue),
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusFull),
                            ),
                            child: const Text(
                              'En curso',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacing8),
                    Row(
                      children: [
                        Icon(
                          Iconsax.clock,
                          size: AppSizes.iconSmall,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSizes.spacing8),
                        Text(
                          '${schedule.startTime.format()} - ${schedule.endTime.format()}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                    if (schedule.location != null) ...[
                      const SizedBox(height: AppSizes.spacing4),
                      Row(
                        children: [
                          Icon(
                            Iconsax.location,
                            size: AppSizes.iconSmall,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSizes.spacing8),
                          Text(
                            schedule.location!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, ClassSchedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar clase'),
        content: const Text('¿Estás seguro de que deseas eliminar esta clase?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(scheduleProvider.notifier).deleteSchedule(schedule.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Clase eliminada')),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  String _getDayName(DayOfWeek day) {
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
