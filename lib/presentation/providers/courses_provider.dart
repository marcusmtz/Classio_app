import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/course_model.dart';
import '../../data/repositories/class_schedule_repository.dart';
import '../../data/repositories/course_repository.dart';
import '../../data/repositories/evaluation_repository.dart';
import '../../data/repositories/grade_repository.dart';
import '../../core/services/notification_service.dart';

final courseRepositoryProvider = Provider((ref) => CourseRepository());
final classScheduleRepositoryProvider =
    Provider((ref) => ClassScheduleRepository());
final courseEvaluationRepositoryProvider =
    Provider((ref) => EvaluationRepository());
final courseGradeRepositoryProvider = Provider((ref) => GradeRepository());
final courseNotificationServiceProvider =
    Provider((ref) => NotificationService());

final coursesProvider =
    StateNotifierProvider<CoursesNotifier, List<Course>>((ref) {
  return CoursesNotifier(
    ref.read(courseRepositoryProvider),
    ref.read(classScheduleRepositoryProvider),
    ref.read(courseEvaluationRepositoryProvider),
    ref.read(courseGradeRepositoryProvider),
    ref.read(courseNotificationServiceProvider),
  );
});

final activeCoursesProvider = Provider<List<Course>>((ref) {
  return ref.watch(coursesProvider).where((c) => c.isActive).toList();
});

class CoursesNotifier extends StateNotifier<List<Course>> {
  final CourseRepository _repository;
  final ClassScheduleRepository _classScheduleRepository;
  final EvaluationRepository _evaluationRepository;
  final GradeRepository _gradeRepository;
  late final Future<void> Function(String evaluationId)
      _cancelEvaluationNotifications;
  final _uuid = const Uuid();
  StreamSubscription? _coursesSubscription;

  CoursesNotifier(
    this._repository,
    this._classScheduleRepository,
    this._evaluationRepository,
    this._gradeRepository,
    NotificationService notificationService, {
    Future<void> Function(String evaluationId)? cancelEvaluationNotifications,
  }) : super([]) {
    _cancelEvaluationNotifications = cancelEvaluationNotifications ??
        ((evaluationId) =>
            notificationService.cancelEvaluationNotifications(evaluationId));

    _loadCourses();
    _coursesSubscription = _repository.watch().listen((_) {
      _loadCourses();
    });
  }

  void _loadCourses() {
    state = _repository.getAll();
  }

  Future<void> addCourse({
    required String name,
    required String code,
    required int colorValue,
  }) async {
    final course = Course(
      id: _uuid.v4(),
      name: name,
      code: code,
      colorValue: colorValue,
      createdAt: DateTime.now(),
    );

    await _repository.add(course);
    state = [...state, course];
  }

  Future<void> updateCourse(Course course) async {
    await _repository.update(course);
    state = [
      for (final c in state)
        if (c.id == course.id) course else c,
    ];
  }

  Future<void> deleteCourse(String id) async {
    final deletedEvaluationIds = await _evaluationRepository.deleteByCourse(id);

    for (final evaluationId in deletedEvaluationIds) {
      await _cancelEvaluationNotifications(evaluationId);
    }

    await _classScheduleRepository.deleteByCourse(id);
    await _gradeRepository.deleteByCourse(id);
    await _repository.delete(id);
    _loadCourses();
  }

  Future<void> archiveCourse(String id) async {
    await _repository.archive(id);
    _loadCourses();
  }

  Future<void> restoreCourse(String id) async {
    await _repository.restore(id);
    _loadCourses();
  }

  Course? getCourseById(String id) {
    try {
      return state.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _coursesSubscription?.cancel();
    super.dispose();
  }
}
