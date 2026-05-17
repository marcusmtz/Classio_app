import '../../data/models/class_schedule_model.dart';

class ValidateScheduleUseCase {
  bool isValidTimeWindow(TimeOfDayModel start, TimeOfDayModel end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    final startsAfterOrAt7 = start.hour >= 7;
    final endsBeforeOrAt23 =
        end.hour < 23 || (end.hour == 23 && end.minute == 0);

    return startsAfterOrAt7 && endsBeforeOrAt23 && endMinutes > startMinutes;
  }

  bool hasOverlap({
    required Iterable<ClassSchedule> schedules,
    required DayOfWeek day,
    required TimeOfDayModel start,
    required TimeOfDayModel end,
    String? excludeId,
  }) {
    final schedulesOnDay = schedules.where(
      (item) =>
          item.dayOfWeek == day && (excludeId == null || item.id != excludeId),
    );

    final newStart = start.hour * 60 + start.minute;
    final newEnd = end.hour * 60 + end.minute;

    for (final schedule in schedulesOnDay) {
      final existingStart =
          schedule.startTime.hour * 60 + schedule.startTime.minute;
      final existingEnd = schedule.endTime.hour * 60 + schedule.endTime.minute;

      if ((newStart >= existingStart && newStart < existingEnd) ||
          (newEnd > existingStart && newEnd <= existingEnd) ||
          (newStart <= existingStart && newEnd >= existingEnd)) {
        return true;
      }
    }

    return false;
  }
}
