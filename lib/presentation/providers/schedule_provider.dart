import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/usecases/validate_schedule_usecase.dart';
import '../../data/models/class_schedule_model.dart';
import '../../data/repositories/class_schedule_repository.dart';

final scheduleRepositoryProvider = Provider((ref) => ClassScheduleRepository());
final validateScheduleUseCaseProvider =
    Provider((ref) => ValidateScheduleUseCase());

final scheduleProvider =
    StateNotifierProvider<ScheduleNotifier, List<ClassSchedule>>((ref) {
  return ScheduleNotifier(
    ref.read(scheduleRepositoryProvider),
    ref.read(validateScheduleUseCaseProvider),
  );
});

final scheduleByDayProvider =
    Provider.family<List<ClassSchedule>, DayOfWeek>((ref, day) {
  final allSchedules = ref.watch(scheduleProvider);
  return allSchedules.where((s) => s.dayOfWeek == day).toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
});

class ScheduleNotifier extends StateNotifier<List<ClassSchedule>> {
  final ClassScheduleRepository _repository;
  final ValidateScheduleUseCase _validateScheduleUseCase;
  final DateTime Function() _nowProvider;
  final _uuid = const Uuid();
  StreamSubscription? _scheduleSubscription;

  ScheduleNotifier(
    this._repository,
    this._validateScheduleUseCase, {
    DateTime Function()? nowProvider,
  })  : _nowProvider = nowProvider ?? DateTime.now,
        super([]) {
    _loadSchedules();
    _scheduleSubscription = _repository.watch().listen((_) {
      _loadSchedules();
    });
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
    if (!_validateScheduleUseCase.isValidTimeWindow(startTime, endTime)) {
      throw Exception('Horario inválido. Revisa hora de inicio y término.');
    }

    if (_validateScheduleUseCase.hasOverlap(
      schedules: state,
      day: dayOfWeek,
      start: startTime,
      end: endTime,
    )) {
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
    if (!_validateScheduleUseCase.isValidTimeWindow(
      schedule.startTime,
      schedule.endTime,
    )) {
      throw Exception('Horario inválido. Revisa hora de inicio y término.');
    }

    if (_validateScheduleUseCase.hasOverlap(
      schedules: state,
      day: schedule.dayOfWeek,
      start: schedule.startTime,
      end: schedule.endTime,
      excludeId: schedule.id,
    )) {
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

  List<ClassSchedule> getSchedulesByCourse(String courseId) {
    return state.where((s) => s.courseId == courseId).toList();
  }

  ClassSchedule? getCurrentClass() {
    final now = _nowProvider();
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
    final now = _nowProvider();
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
      final nextWeekday = ((now.weekday - 1 + i) % 7) + 1;
      final nextDay = _getDayOfWeek(nextWeekday);
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

  @override
  void dispose() {
    _scheduleSubscription?.cancel();
    super.dispose();
  }
}
