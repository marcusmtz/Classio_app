import 'package:flutter_test/flutter_test.dart';

import 'package:classio_app/data/models/class_schedule_model.dart';
import 'package:classio_app/domain/usecases/validate_schedule_usecase.dart';

ClassSchedule _schedule({
  required String id,
  required DayOfWeek day,
  required int startHour,
  required int endHour,
}) {
  return ClassSchedule(
    id: id,
    courseId: 'course-1',
    dayOfWeek: day,
    startTime: TimeOfDayModel(hour: startHour, minute: 0),
    endTime: TimeOfDayModel(hour: endHour, minute: 0),
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  final useCase = ValidateScheduleUseCase();

  test('rejects invalid time window', () {
    final isValid = useCase.isValidTimeWindow(
      const TimeOfDayModel(hour: 6, minute: 30),
      const TimeOfDayModel(hour: 8, minute: 0),
    );

    expect(isValid, isFalse);
  });

  test('detects overlap in same day', () {
    final schedules = [
      _schedule(id: 's1', day: DayOfWeek.monday, startHour: 8, endHour: 10),
    ];

    final hasOverlap = useCase.hasOverlap(
      schedules: schedules,
      day: DayOfWeek.monday,
      start: const TimeOfDayModel(hour: 9, minute: 0),
      end: const TimeOfDayModel(hour: 11, minute: 0),
    );

    expect(hasOverlap, isTrue);
  });
}
