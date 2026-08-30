import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/models/class_schedule_model.dart';
import '../../../../data/models/course_model.dart';
import '../../../providers/courses_provider.dart';
import '../../../providers/schedule_provider.dart';
import '../../../providers/app_settings_provider.dart';
import '../schedule_form_screen.dart';

class ScheduleGridView extends ConsumerWidget {
  final List<ClassSchedule> schedules;

  const ScheduleGridView({super.key, required this.schedules});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (schedules.isEmpty) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildWeekHeader(),
          _buildTimeGrid(context, ref),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
          const SizedBox(height: AppSizes.spacing8),
          Text(
            'Agrega tu primera clase',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekHeader() {
    return Consumer(
      builder: (context, ref, child) {
        final settings = ref.watch(appSettingsProvider);
        final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
        final now = DateTime.now();
        final currentDay = now.weekday;

        // Filtrar días según configuración
        final visibleDays = <int>[];
        for (int i = 0; i < 7; i++) {
          if (i == 5 && !settings.showSaturday) continue; // Sábado
          if (i == 6 && !settings.showSunday) continue; // Domingo
          visibleDays.add(i);
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.spacing8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 60), // Espacio para columna de horas
              ...visibleDays.map((index) {
                final isToday = currentDay == index + 1;
                return Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSizes.spacing8),
                    decoration: isToday
                        ? BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusSmall),
                          )
                        : null,
                    child: Text(
                      days[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                        color: isToday
                            ? AppColors.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeGrid(BuildContext context, WidgetRef ref) {
    const startHour = 7;
    const endHour = 24;
    const hourHeight = 80.0;

    final settings = ref.watch(appSettingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gridBorderColor =
        isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant;

    // Filtrar días según configuración
    final visibleDayIndices = <int>[];
    for (int i = 0; i < 7; i++) {
      if (i == 5 && !settings.showSaturday) continue; // Sábado
      if (i == 6 && !settings.showSunday) continue; // Domingo
      visibleDayIndices.add(i);
    }

    return SizedBox(
      height: (endHour - startHour) * hourHeight,
      child: Stack(
        children: [
          // Grid de fondo
          Row(
            children: [
              // Columna de horas
              SizedBox(
                width: 60,
                child: Column(
                  children: List.generate(endHour - startHour, (index) {
                    final hour = startHour + index;
                    return Container(
                      height: hourHeight,
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${hour.toString().padLeft(2, '0')}:00',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    );
                  }),
                ),
              ),
              // Grid de días
              Expanded(
                child: Row(
                  children: visibleDayIndices.map((dayIndex) {
                    return Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: gridBorderColor,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Column(
                          children:
                              List.generate(endHour - startHour, (hourIndex) {
                            return Container(
                              height: hourHeight,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: gridBorderColor,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          // Clases
          Row(
            children: [
              const SizedBox(width: 60),
              ...visibleDayIndices.map((dayIndex) {
                final day = _getDayOfWeek(dayIndex + 1);
                final daySchedules = schedules
                    .where((s) => s.dayOfWeek == day)
                    .toList()
                  ..sort((a, b) => a.startTime.compareTo(b.startTime));

                return Expanded(
                  child: Stack(
                    children: daySchedules.map((schedule) {
                      return _buildClassBlock(
                        context,
                        ref,
                        schedule,
                        startHour,
                        hourHeight,
                      );
                    }).toList(),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassBlock(
    BuildContext context,
    WidgetRef ref,
    ClassSchedule schedule,
    int startHour,
    double hourHeight,
  ) {
    final course =
        ref.read(coursesProvider.notifier).getCourseById(schedule.courseId);
    if (course == null) return const SizedBox.shrink();

    final currentClass = ref.read(scheduleProvider.notifier).getCurrentClass();
    final isCurrentClass = currentClass?.id == schedule.id;

    final startMinutes =
        schedule.startTime.hour * 60 + schedule.startTime.minute;
    final endMinutes = schedule.endTime.hour * 60 + schedule.endTime.minute;
    final durationMinutes = endMinutes - startMinutes;

    final topOffset = ((schedule.startTime.hour - startHour) * 60 +
            schedule.startTime.minute) /
        60 *
        hourHeight;
    final height = (durationMinutes / 60) * hourHeight;

    return Positioned(
      top: topOffset,
      left: 4,
      right: 4,
      height: height - 4,
      child: GestureDetector(
        onTap: () {
          _showClassDetailSheet(
            context,
            ref,
            schedule,
            course,
            isCurrentClass,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(AppSizes.spacing8),
          decoration: BoxDecoration(
            color: Color(course.colorValue)
                .withValues(alpha: isCurrentClass ? 1.0 : 0.8),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: isCurrentClass
                ? Border.all(color: Colors.white, width: 2)
                : null,
            boxShadow: isCurrentClass
                ? [
                    BoxShadow(
                      color: Color(course.colorValue).withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                course.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (height > 40) ...[
                const SizedBox(height: 2),
                Text(
                  '${schedule.startTime.format()} - ${schedule.endTime.format()}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 10,
                  ),
                ),
              ],
              if (schedule.location != null && height > 60) ...[
                const SizedBox(height: 2),
                Text(
                  schedule.location!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showClassDetailSheet(
    BuildContext context,
    WidgetRef ref,
    ClassSchedule schedule,
    Course course,
    bool isCurrentClass,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.surface;

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(AppSizes.spacing24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barra de arrastre
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSizes.spacing16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Encabezado con color del curso
              Container(
                padding: const EdgeInsets.all(AppSizes.spacing16),
                decoration: BoxDecoration(
                  color: Color(course.colorValue).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(course.colorValue),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacing16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Color(course.colorValue),
                                ),
                          ),
                          const SizedBox(height: AppSizes.spacing4),
                          Text(
                            course.code,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
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
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusFull,
                          ),
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
              ),
              const SizedBox(height: AppSizes.spacing20),

              // Detalles de la clase
              _buildDetailRow(
                context,
                Iconsax.clock,
                '${schedule.startTime.format()} - ${schedule.endTime.format()}',
              ),
              const SizedBox(height: AppSizes.spacing12),
              _buildDetailRow(
                context,
                Iconsax.calendar,
                _getDayName(schedule.dayOfWeek),
              ),
              if (schedule.location != null) ...[
                const SizedBox(height: AppSizes.spacing12),
                _buildDetailRow(
                  context,
                  Iconsax.location,
                  schedule.location!,
                ),
              ],
              if (schedule.professor != null) ...[
                const SizedBox(height: AppSizes.spacing12),
                _buildDetailRow(
                  context,
                  Iconsax.profile_2user,
                  schedule.professor!,
                ),
              ],
              const SizedBox(height: AppSizes.spacing24),

              // Botón Editar
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ScheduleFormScreen(schedule: schedule),
                    ),
                  );
                },
                icon: const Icon(Iconsax.edit),
                label: const Text('Editar'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.spacing8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Icon(
            icon,
            size: AppSizes.iconSmall,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSizes.spacing12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
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

  DayOfWeek _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return DayOfWeek.monday;
      case 2:
        return DayOfWeek.tuesday;
      case 3:
        return DayOfWeek.wednesday;
      case 4:
        return DayOfWeek.thursday;
      case 5:
        return DayOfWeek.friday;
      case 6:
        return DayOfWeek.saturday;
      case 7:
        return DayOfWeek.sunday;
      default:
        return DayOfWeek.monday;
    }
  }
}
