import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/undo_manager.dart';
import '../../data/models/class_schedule_model.dart';
import '../../data/models/course_model.dart';
import '../../data/models/evaluation_model.dart';
import '../../data/models/grade_model.dart';
import '../../data/repositories/class_schedule_repository.dart';
import '../../data/repositories/course_repository.dart';
import '../../data/repositories/evaluation_repository.dart';
import '../../data/repositories/grade_repository.dart';
import '../../core/services/notification_service.dart';
import 'app_settings_provider.dart';

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

final filteredActiveCoursesProvider = Provider<List<Course>>((ref) {
  final all = ref.watch(activeCoursesProvider);
  final activeSemesterId = ref.watch(appSettingsProvider).activeSemesterId;
  if (activeSemesterId == null) return all;
  // Mostrar solo cursos del semestre activo + sin semestre? Decisión: solo del semestre activo
  return all.where((c) => c.semesterId == activeSemesterId).toList();
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
  late final UndoManager<CourseDeletionBundle> _undoManager;

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

    _undoManager = UndoManager<CourseDeletionBundle>(
      duration: const Duration(seconds: 5),
      onCommit: (bundle) async {
        final courseId = (bundle.course as Course).id;
        for (final evalId in bundle.evaluationIds) {
          await _cancelEvaluationNotifications(evalId);
        }
        // Ya se recolectaron ids, borrar hijos
        for (final s in bundle.schedules.cast<ClassSchedule>()) {
          await _classScheduleRepository.delete(s.id);
        }
        for (final e in bundle.evaluations.cast<Evaluation>()) {
          await _evaluationRepository.delete(e.id);
        }
        for (final g in bundle.grades.cast<Grade>()) {
          await _gradeRepository.delete(g.id);
        }
        await _repository.delete(courseId);
      },
    );

    _loadCourses();
    _coursesSubscription = _repository.watch().listen((_) {
      _loadCourses();
    });
  }

  void _loadCourses() {
    if (_undoManager.hasPending) return;
    state = _repository.getAll();
  }

  bool undoDelete(String id) {
    final bundle = _undoManager.undo(id);
    if (bundle != null) {
      final course = bundle.course as Course;
      state = [...state, course]..sort((a, b) => a.name.compareTo(b.name));
      // Restaurar hijos en repos (sin notifs, se reprogramarán vía watch elsewhere)
      for (final s in bundle.schedules.cast<ClassSchedule>()) {
        _classScheduleRepository.add(s);
      }
      for (final e in bundle.evaluations.cast<Evaluation>()) {
        _evaluationRepository.add(e);
      }
      for (final g in bundle.grades.cast<Grade>()) {
        _gradeRepository.add(g);
      }
      return true;
    }
    return false;
  }

  Future<void> commitPendingDeletes() async {
    await _undoManager.commitAll();
  }

  Future<void> addCourse({
    required String name,
    required String code,
    required int colorValue,
    String? semesterId,
  }) async {
    final course = Course(
      id: _uuid.v4(),
      name: name,
      code: code,
      colorValue: colorValue,
      createdAt: DateTime.now(),
      semesterId: semesterId,
    );

    await _repository.add(course);
    // El stream watch() dispara _loadCourses() automáticamente
  }

  Future<void> moveCourseToSemester(String courseId, String? semesterId) async {
    final course = getCourseById(courseId);
    if (course == null) return;
    final updated = course.copyWithNullableSemester(semesterId);
    await _repository.update(updated);
  }

  Future<void> updateCourse(Course course) async {
    await _repository.update(course);
    // El stream watch() dispara _loadCourses() automáticamente
  }

  Future<void> deleteCourse(String id) async {
    final course = getCourseById(id);
    if (course == null) return;
    // Recolectar hijos antes de borrar optimista
    final schedules = _classScheduleRepository.getByCourse(id);
    final evaluations = _evaluationRepository.getByCourse(id);
    final grades = _gradeRepository.getByCourse(id);
    final evaluationIds = evaluations.map((e) => e.id).toList();

    // Optimistic remove de UI
    state = state.where((c) => c.id != id).toList();

    final bundle = CourseDeletionBundle(
      course: course,
      schedules: schedules,
      evaluations: evaluations,
      grades: grades,
      evaluationIds: evaluationIds,
    );
    _undoManager.stage(id, bundle);
  }

  Future<void> deleteCourseImmediate(String id) async {
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
    _undoManager.dispose();
    super.dispose();
  }
}
