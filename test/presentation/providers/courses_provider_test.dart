import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:classio_app/core/services/notification_service.dart';
import 'package:classio_app/data/local/hive_service.dart';
import 'package:classio_app/data/models/app_settings_model.dart';
import 'package:classio_app/data/models/class_schedule_model.dart';
import 'package:classio_app/data/models/course_model.dart';
import 'package:classio_app/data/models/evaluation_model.dart' as eval_model;
import 'package:classio_app/data/models/grade_model.dart';
import 'package:classio_app/data/models/user_settings_model.dart';
import 'package:classio_app/data/repositories/class_schedule_repository.dart';
import 'package:classio_app/data/repositories/course_repository.dart';
import 'package:classio_app/data/repositories/evaluation_repository.dart';
import 'package:classio_app/data/repositories/grade_repository.dart';
import 'package:classio_app/presentation/providers/courses_provider.dart';

Future<Directory> _initHiveForCourseTests() async {
  final tempDir = await Directory.systemTemp.createTemp('classio_course_test_');
  Hive.init(tempDir.path);

  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(CourseAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(DayOfWeekAdapter());
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(TimeOfDayModelAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(ClassScheduleAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(eval_model.EvaluationTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(eval_model.PriorityAdapter());
  }
  if (!Hive.isAdapterRegistered(6)) {
    Hive.registerAdapter(eval_model.SubtaskAdapter());
  }
  if (!Hive.isAdapterRegistered(7)) {
    Hive.registerAdapter(eval_model.EvaluationAdapter());
  }
  if (!Hive.isAdapterRegistered(8)) Hive.registerAdapter(GradeTypeAdapter());
  if (!Hive.isAdapterRegistered(9)) Hive.registerAdapter(GradeAdapter());
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(UserSettingsAdapter());
  }
  if (!Hive.isAdapterRegistered(11)) Hive.registerAdapter(ThemeModeAdapter());
  if (!Hive.isAdapterRegistered(12)) {
    Hive.registerAdapter(AppSettingsAdapter());
  }

  if (!Hive.isBoxOpen(HiveService.coursesBox)) {
    await Hive.openBox<Course>(HiveService.coursesBox);
  }
  if (!Hive.isBoxOpen(HiveService.classesBox)) {
    await Hive.openBox<ClassSchedule>(HiveService.classesBox);
  }
  if (!Hive.isBoxOpen(HiveService.evaluationsBox)) {
    await Hive.openBox<eval_model.Evaluation>(HiveService.evaluationsBox);
  }
  if (!Hive.isBoxOpen(HiveService.gradesBox)) {
    await Hive.openBox<Grade>(HiveService.gradesBox);
  }

  return tempDir;
}

Future<void> _disposeHive(Directory tempDir) async {
  await Hive.close();
  if (await tempDir.exists()) {
    await tempDir.delete(recursive: true);
  }
}

void main() {
  test('deleteCourse removes linked schedules, evaluations and grades',
      () async {
    final tempDir = await _initHiveForCourseTests();

    try {
      final courseRepository = CourseRepository();
      final scheduleRepository = ClassScheduleRepository();
      final evaluationRepository = EvaluationRepository();
      final gradeRepository = GradeRepository();

      const courseId = 'course-1';
      await courseRepository.add(
        Course(
          id: courseId,
          name: 'Calculo',
          code: 'MAT101',
          colorValue: 0xFF3B82F6,
          createdAt: DateTime(2026, 1, 1),
        ),
      );

      await scheduleRepository.add(
        ClassSchedule(
          id: 'sch-1',
          courseId: courseId,
          dayOfWeek: DayOfWeek.monday,
          startTime: const TimeOfDayModel(hour: 8, minute: 0),
          endTime: const TimeOfDayModel(hour: 10, minute: 0),
          createdAt: DateTime(2026, 1, 1),
        ),
      );

      await evaluationRepository.add(
        eval_model.Evaluation(
          id: 'ev-1',
          courseId: courseId,
          title: 'Parcial 1',
          type: eval_model.EvaluationType.exam,
          dueDate: DateTime(2026, 5, 5, 10, 0),
          priority: eval_model.Priority.high,
          createdAt: DateTime(2026, 1, 1),
        ),
      );

      await gradeRepository.add(
        Grade(
          id: 'gr-1',
          courseId: courseId,
          title: 'Control',
          type: GradeType.quiz,
          score: 5.5,
          maxScore: 7.0,
          weight: 20,
          date: DateTime(2026, 3, 1),
          createdAt: DateTime(2026, 3, 1),
        ),
      );

      final cancelledNotifications = <String>[];
      final notifier = CoursesNotifier(
        courseRepository,
        scheduleRepository,
        evaluationRepository,
        gradeRepository,
        NotificationService(),
        cancelEvaluationNotifications: (evaluationId) async {
          cancelledNotifications.add(evaluationId);
        },
      );

      await notifier.deleteCourse(courseId);

      expect(courseRepository.getById(courseId), isNull);
      expect(scheduleRepository.getByCourse(courseId), isEmpty);
      expect(evaluationRepository.getByCourse(courseId), isEmpty);
      expect(gradeRepository.getByCourse(courseId), isEmpty);
      expect(cancelledNotifications, ['ev-1']);
    } finally {
      await _disposeHive(tempDir);
    }
  });
}
