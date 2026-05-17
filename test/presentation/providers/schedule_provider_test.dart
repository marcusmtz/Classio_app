import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:classio_app/data/local/hive_service.dart';
import 'package:classio_app/data/models/class_schedule_model.dart';
import 'package:classio_app/data/repositories/class_schedule_repository.dart';
import 'package:classio_app/domain/usecases/validate_schedule_usecase.dart';
import 'package:classio_app/presentation/providers/schedule_provider.dart';

Future<Directory> _initHiveForScheduleTests() async {
  final tempDir =
      await Directory.systemTemp.createTemp('classio_schedule_test_');
  Hive.init(tempDir.path);

  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(DayOfWeekAdapter());
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(TimeOfDayModelAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(ClassScheduleAdapter());
  }

  if (!Hive.isBoxOpen(HiveService.classesBox)) {
    await Hive.openBox<ClassSchedule>(HiveService.classesBox);
  }

  return tempDir;
}

Future<void> _disposeHive(Directory tempDir) async {
  await Hive.close();
  if (await tempDir.exists()) {
    await tempDir.delete(recursive: true);
  }
}

ClassSchedule _schedule({
  required String id,
  required DayOfWeek day,
  required int startHour,
  required int startMinute,
  required int endHour,
  required int endMinute,
}) {
  return ClassSchedule(
    id: id,
    courseId: 'course-1',
    dayOfWeek: day,
    startTime: TimeOfDayModel(hour: startHour, minute: startMinute),
    endTime: TimeOfDayModel(hour: endHour, minute: endMinute),
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('ScheduleNotifier.getNextClass', () {
    late Directory tempDir;
    late ClassScheduleRepository repository;

    setUp(() async {
      tempDir = await _initHiveForScheduleTests();
      repository = ClassScheduleRepository();
    });

    tearDown(() async {
      await _disposeHive(tempDir);
    });

    test('returns next class from next week when now is sunday night',
        () async {
      await repository.add(
        _schedule(
          id: 'sun-morning',
          day: DayOfWeek.sunday,
          startHour: 10,
          startMinute: 0,
          endHour: 12,
          endMinute: 0,
        ),
      );
      await repository.add(
        _schedule(
          id: 'mon-morning',
          day: DayOfWeek.monday,
          startHour: 8,
          startMinute: 0,
          endHour: 10,
          endMinute: 0,
        ),
      );

      final notifier = ScheduleNotifier(
        repository,
        ValidateScheduleUseCase(),
        nowProvider: () => DateTime(2026, 4, 26, 23, 0),
      );

      final nextClass = notifier.getNextClass();

      expect(nextClass, isNotNull);
      expect(nextClass!.id, 'mon-morning');
    });

    test('returns sunday class when now is saturday and sunday has classes',
        () async {
      await repository.add(
        _schedule(
          id: 'sun-early',
          day: DayOfWeek.sunday,
          startHour: 9,
          startMinute: 0,
          endHour: 11,
          endMinute: 0,
        ),
      );

      final notifier = ScheduleNotifier(
        repository,
        ValidateScheduleUseCase(),
        nowProvider: () => DateTime(2026, 4, 25, 20, 0),
      );

      final nextClass = notifier.getNextClass();

      expect(nextClass, isNotNull);
      expect(nextClass!.id, 'sun-early');
    });

    test('returns same-day upcoming class before checking other days',
        () async {
      await repository.add(
        _schedule(
          id: 'mon-late',
          day: DayOfWeek.monday,
          startHour: 15,
          startMinute: 0,
          endHour: 17,
          endMinute: 0,
        ),
      );
      await repository.add(
        _schedule(
          id: 'tue-morning',
          day: DayOfWeek.tuesday,
          startHour: 8,
          startMinute: 0,
          endHour: 10,
          endMinute: 0,
        ),
      );

      final notifier = ScheduleNotifier(
        repository,
        ValidateScheduleUseCase(),
        nowProvider: () => DateTime(2026, 4, 20, 10, 0),
      );

      final nextClass = notifier.getNextClass();

      expect(nextClass, isNotNull);
      expect(nextClass!.id, 'mon-late');
    });
  });
}
