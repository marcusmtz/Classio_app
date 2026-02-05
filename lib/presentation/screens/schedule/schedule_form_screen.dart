import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/models/class_schedule_model.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/courses_provider.dart';

class ScheduleFormScreen extends ConsumerStatefulWidget {
  final ClassSchedule? schedule;

  const ScheduleFormScreen({super.key, this.schedule});

  @override
  ConsumerState<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends ConsumerState<ScheduleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();

  String? _selectedCourseId;
  DayOfWeek? _selectedDay;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  bool get _isEditing => widget.schedule != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _selectedCourseId = widget.schedule!.courseId;
      _selectedDay = widget.schedule!.dayOfWeek;
      _startTime = TimeOfDay(
        hour: widget.schedule!.startTime.hour,
        minute: widget.schedule!.startTime.minute,
      );
      _endTime = TimeOfDay(
        hour: widget.schedule!.endTime.hour,
        minute: widget.schedule!.endTime.minute,
      );
      _locationController.text = widget.schedule!.location ?? '';
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courses = ref.watch(activeCoursesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Clase' : 'Nueva Clase'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          children: [
            // Selector de curso
            DropdownButtonFormField<String>(
              value: _selectedCourseId,
              decoration: const InputDecoration(
                labelText: 'Curso',
                prefixIcon: Icon(Iconsax.book),
              ),
              items: courses.map((course) {
                return DropdownMenuItem(
                  value: course.id,
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Color(course.colorValue),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacing12),
                      Text(course.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCourseId = value),
              validator: (value) =>
                  value == null ? 'Selecciona un curso' : null,
            ),
            const SizedBox(height: AppSizes.spacing16),

            // Selector de día
            DropdownButtonFormField<DayOfWeek>(
              value: _selectedDay,
              decoration: const InputDecoration(
                labelText: 'Día',
                prefixIcon: Icon(Iconsax.calendar),
              ),
              items: DayOfWeek.values.map((day) {
                return DropdownMenuItem(
                  value: day,
                  child: Text(_getDayName(day)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedDay = value),
              validator: (value) => value == null ? 'Selecciona un día' : null,
            ),
            const SizedBox(height: AppSizes.spacing16),

            // Hora de inicio
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Iconsax.clock),
              title: const Text('Hora de inicio'),
              subtitle: Text(
                _startTime != null
                    ? _startTime!.format(context)
                    : 'Seleccionar',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _selectTime(context, true),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                side: BorderSide(color: AppColors.surfaceVariant),
              ),
            ),
            const SizedBox(height: AppSizes.spacing16),

            // Hora de fin
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Iconsax.clock),
              title: const Text('Hora de fin'),
              subtitle: Text(
                _endTime != null ? _endTime!.format(context) : 'Seleccionar',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _selectTime(context, false),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                side: BorderSide(color: AppColors.surfaceVariant),
              ),
            ),
            const SizedBox(height: AppSizes.spacing16),

            // Ubicación
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Ubicación (opcional)',
                hintText: 'Ej: Aula 301, Edificio A',
                prefixIcon: Icon(Iconsax.location),
              ),
            ),
            const SizedBox(height: AppSizes.spacing32),

            // Botón guardar
            FilledButton.icon(
              onPressed: _saveSchedule,
              icon: const Icon(Iconsax.tick_circle),
              label: Text(_isEditing ? 'Actualizar' : 'Guardar'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(AppSizes.spacing16),
              ),
            ),

            if (_isEditing) ...[
              const SizedBox(height: AppSizes.spacing12),
              OutlinedButton.icon(
                onPressed: _deleteSchedule,
                icon: const Icon(Iconsax.trash),
                label: const Text('Eliminar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.all(AppSizes.spacing16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_startTime ?? const TimeOfDay(hour: 8, minute: 0))
          : (_endTime ?? const TimeOfDay(hour: 10, minute: 0)),
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _saveSchedule() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona las horas de inicio y fin')),
      );
      return;
    }

    // Validar que las clases estén entre 7am y 11pm
    if (_startTime!.hour < 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las clases no pueden empezar antes de las 7:00 AM'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_endTime!.hour > 23 || (_endTime!.hour == 23 && _endTime!.minute > 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Las clases no pueden terminar después de las 11:00 PM'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validar que la hora de fin sea después de la de inicio
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;

    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La hora de fin debe ser después de la hora de inicio'),
        ),
      );
      return;
    }

    try {
      if (_isEditing) {
        final updatedSchedule = widget.schedule!.copyWith(
          courseId: _selectedCourseId!,
          dayOfWeek: _selectedDay!,
          startTime: TimeOfDayModel(
            hour: _startTime!.hour,
            minute: _startTime!.minute,
          ),
          endTime: TimeOfDayModel(
            hour: _endTime!.hour,
            minute: _endTime!.minute,
          ),
          location: _locationController.text.isEmpty
              ? null
              : _locationController.text,
        );

        await ref
            .read(scheduleProvider.notifier)
            .updateSchedule(updatedSchedule);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Clase actualizada')),
          );
          Navigator.pop(context);
        }
      } else {
        await ref.read(scheduleProvider.notifier).addSchedule(
              courseId: _selectedCourseId!,
              dayOfWeek: _selectedDay!,
              startTime: TimeOfDayModel(
                hour: _startTime!.hour,
                minute: _startTime!.minute,
              ),
              endTime: TimeOfDayModel(
                hour: _endTime!.hour,
                minute: _endTime!.minute,
              ),
              location: _locationController.text.isEmpty
                  ? null
                  : _locationController.text,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Clase agregada')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _deleteSchedule() {
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
            onPressed: () async {
              await ref
                  .read(scheduleProvider.notifier)
                  .deleteSchedule(widget.schedule!.id);

              if (mounted) {
                Navigator.pop(context); // Cerrar diálogo
                Navigator.pop(context); // Cerrar formulario
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Clase eliminada')),
                );
              }
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
