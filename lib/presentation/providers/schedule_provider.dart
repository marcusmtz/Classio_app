import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/class_schedule_model.dart';
import '../../data/repositories/class_schedule_repository.dart';

final scheduleRepositoryProvider = Provider((ref) => ClassScheduleRepository());

final scheduleProvider =
    StateNotifierProvider<ScheduleNotifier, List<ClassSchedule>>((ref) {
  return ScheduleNotifier(ref.read(scheduleRepositoryProvider));
});

final scheduleByDayProvider =
    Provider.family<List<ClassSchedule>, DayOfWeek>((ref, day) {
  final allSchedules = ref.watch(scheduleProvider);
  return allSchedules.where((s) => s.dayOfWeek == day).toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
});

class ScheduleNotifier extends StateNotifier<List<ClassSchedule>> {
  final ClassScheduleRepository _repository;
  final _uuid = const Uuid();

  ScheduleNotifier(this._repository) : super([]) {
    _loadSchedules();
  }

  void _loadSchedules() {
    state = _repository.getAll();
  }

  Future<void> addSchedule({
    required String courseId,
    required DayOfWeek dayOfWeek,
    required TimeOfDayModel startTime,
    required TimeOfDayModel endTime,
    String? location,
  }) async {
    // Validar solapamiento
    if (_hasOverlap(dayOfWeek, startTime, endTime, null)) {
      throw Exception('Ya existe una clase en este horario');
    }

    final schedule = ClassSchedule(
      id: _uuid.v4(),
      courseId: courseId,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      location: location,
      createdAt: DateTime.now(),
    );

    await _repository.add(schedule);
    state = [...state, schedule];
  }

  Future<void> updateSchedule(ClassSchedule schedule) async {
    // Validar solapamiento (excluyendo el schedule actual)
    if (_hasOverlap(schedule.dayOfWeek, schedule.startTime, schedule.endTime,
        schedule.id)) {
      throw Exception('Ya existe una clase en este horario');
    }

    await _repository.update(schedule);
    state = [
      for (final s in state)
        if (s.id == schedule.id) schedule else s,
    ];
  }

  Future<void> deleteSchedule(String id) async {
    await _repository.delete(id);
    state = state.where((s) => s.id != id).toList();
  }

  bool _hasOverlap(DayOfWeek day, TimeOfDayModel start, TimeOfDayModel end,
      String? excludeId) {
    final schedulesOnDay = state.where(
        (s) => s.dayOfWeek == day && (excludeId == null || s.id != excludeId));

    for (final schedule in schedulesOnDay) {
      // Convertir a minutos para comparar
      final existingStart =
          schedule.startTime.hour * 60 + schedule.startTime.minute;
      final existingEnd = schedule.endTime.hour * 60 + schedule.endTime.minute;
      final newStart = start.hour * 60 + start.minute;
      final newEnd = end.hour * 60 + end.minute;

      // Verificar solapamiento
      if ((newStart >= existingStart && newStart < existingEnd) ||
          (newEnd > existingStart && newEnd <= existingEnd) ||
          (newStart <= existingStart && newEnd >= existingEnd)) {
        return true;
      }
    }

    return false;
  }

  List<ClassSchedule> getSchedulesByCourse(String courseId) {
    return state.where((s) => s.courseId == courseId).toList();
  }

  ClassSchedule? getCurrentClass() {
    final now = DateTime.now();
    final currentDay = _getDayOfWeek(now.weekday);
    final currentTime = TimeOfDayModel(hour: now.hour, minute: now.minute);
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;

    final todaySchedules = state.where((s) => s.dayOfWeek == currentDay);

    for (final schedule in todaySchedules) {
      final startMinutes =
          schedule.startTime.hour * 60 + schedule.startTime.minute;
      final endMinutes = schedule.endTime.hour * 60 + schedule.endTime.minute;

      if (currentMinutes >= startMinutes && currentMinutes < endMinutes) {
        return schedule;
      }
    }

    return null;
  }

  ClassSchedule? getNextClass() {
    final now = DateTime.now();
    final currentDay = _getDayOfWeek(now.weekday);
    final currentTime = TimeOfDayModel(hour: now.hour, minute: now.minute);
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;

    // Buscar en el día actual
    final todaySchedules = state
        .where((s) => s.dayOfWeek == currentDay)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    for (final schedule in todaySchedules) {
      final startMinutes =
          schedule.startTime.hour * 60 + schedule.startTime.minute;
      if (startMinutes > currentMinutes) {
        return schedule;
      }
    }

    // Buscar en los próximos días
    for (int i = 1; i < 7; i++) {
      final nextDay = _getDayOfWeek((now.weekday + i) % 7);
      final nextDaySchedules = state
          .where((s) => s.dayOfWeek == nextDay)
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));

      if (nextDaySchedules.isNotEmpty) {
        return nextDaySchedules.first;
      }
    }

    return null;
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
