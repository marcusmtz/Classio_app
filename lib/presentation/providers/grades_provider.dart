import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/undo_manager.dart';
import '../../domain/usecases/calculate_course_grades_usecase.dart';
import '../../data/models/grade_model.dart';
import '../../data/repositories/grade_repository.dart';
import '../../core/services/notification_service.dart';
import 'app_settings_provider.dart';
import 'courses_provider.dart';

final gradeRepositoryProvider = Provider((ref) => GradeRepository());
final calculateCourseGradesUseCaseProvider =
    Provider((ref) => CalculateCourseGradesUseCase());
final gradesNotificationServiceProvider =
    Provider((ref) => NotificationService());

final gradesProvider =
    StateNotifierProvider<GradesNotifier, List<Grade>>((ref) {
  return GradesNotifier(
    ref.read(gradeRepositoryProvider),
    ref.read(calculateCourseGradesUseCaseProvider),
    ref.read(gradesNotificationServiceProvider),
    ref,
  );
});

final gradesByCourseProvider =
    Provider.family<List<Grade>, String>((ref, courseId) {
  final allGrades = ref.watch(gradesProvider);
  return allGrades.where((g) => g.courseId == courseId).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
});

final courseAverageProvider = Provider.family<double?, String>((ref, courseId) {
  final grades = ref.watch(gradesByCourseProvider(courseId));
  if (grades.isEmpty) return null;
  final completed = grades.where((g) => g.score != null && g.maxScore != null).toList();
  if (completed.isEmpty) return null;
  final useCase = ref.read(calculateCourseGradesUseCaseProvider);
  return useCase.calculateAverage(grades);
});

class GradesNotifier extends StateNotifier<List<Grade>> {
  final GradeRepository _repository;
  final CalculateCourseGradesUseCase _gradesUseCase;
  final NotificationService _notificationService;
  final Ref _ref;
  final _uuid = const Uuid();
  StreamSubscription? _gradesSubscription;
  late final UndoManager<Grade> _undoManager;

  GradesNotifier(
    this._repository,
    this._gradesUseCase,
    this._notificationService,
    this._ref,
  ) : super([]) {
    _undoManager = UndoManager<Grade>(
      duration: const Duration(seconds: 5),
      onCommit: (grade) async {
        await _repository.delete(grade.id);
      },
    );
    _loadGrades();
    _gradesSubscription = _repository.watch().listen((_) {
      _loadGrades();
    });
  }

  void _loadGrades() {
    if (_undoManager.hasPending) return;
    state = _repository.getAll();
  }

  bool undoDelete(String id) {
    final grade = _undoManager.undo(id);
    if (grade != null) {
      state = [...state, grade]..sort((a, b) => a.date.compareTo(b.date));
      return true;
    }
    return false;
  }

  Future<void> commitPendingDeletes() async {
    await _undoManager.commitAll();
  }

  Future<void> addGrade({
    required String courseId,
    required String title,
    double? score,
    double? maxScore,
    required double weight,
    required GradeType type,
    DateTime? date,
    String? notes,
  }) async {
    final existingGrades = state.where((g) => g.courseId == courseId).toList();
    final totalWeight = _gradesUseCase.totalWeight(existingGrades);

    if (totalWeight + weight > 100.01) {
      throw Exception(
        'El peso total no puede exceder 100%. Actualmente: ${totalWeight.toStringAsFixed(1)}% + ${weight.toStringAsFixed(1)}% = ${(totalWeight + weight).toStringAsFixed(1)}%',
      );
    }

    // Si score es nulo, maxScore puede ser nulo también (pendiente)
    if (score != null && maxScore == null) {
      throw Exception('Si ingresas nota, debes ingresar nota máxima');
    }
    if (score == null && maxScore != null) {
      throw Exception('Si ingresas nota máxima, debes ingresar nota');
    }

    final grade = Grade(
      id: _uuid.v4(),
      courseId: courseId,
      title: title,
      score: score,
      maxScore: maxScore,
      weight: weight,
      type: type,
      date: date ?? DateTime.now(),
      notes: notes,
      createdAt: DateTime.now(),
    );

    await _repository.add(grade);
    // El stream watch() dispara _loadGrades() automáticamente
    if (score != null) await _handleNotificationsForGrade(grade);
  }

  Future<void> updateGradeScore({
    required String gradeId,
    required double score,
    required double maxScore,
  }) async {
    final grade = _repository.getById(gradeId) ?? state.firstWhere((g) => g.id == gradeId);
    final updated = grade.copyWithNullableScore(score: score, maxScore: maxScore);
    await updateGrade(updated);
    await _handleNotificationsForGrade(updated);
  }

  Future<void> clearGradeScore(String gradeId) async {
    final grade = _repository.getById(gradeId) ?? state.firstWhere((g) => g.id == gradeId);
    final updated = grade.copyWithNullableScore(score: null, maxScore: null);
    await _repository.update(updated);
  }

  Future<void> updateGrade(Grade grade) async {
    final existingGrades = state
        .where((g) => g.courseId == grade.courseId && g.id != grade.id)
        .toList();
    final totalWeight = _gradesUseCase.totalWeight(existingGrades);

    if (totalWeight + grade.weight > 100.01) {
      throw Exception(
        'El peso total no puede exceder 100%. Actualmente: ${totalWeight.toStringAsFixed(1)}%',
      );
    }

    await _repository.update(grade);
    // El stream watch() dispara _loadGrades() automáticamente
  }

  Future<void> deleteGrade(String id) async {
    Grade? grade = _repository.getById(id);
    if (grade == null) {
      try {
        grade = state.firstWhere((g) => g.id == id);
      } catch (_) {
        return;
      }
    }
    state = state.where((g) => g.id != id).toList();
    _undoManager.stage(id, grade);
  }

  Future<void> deleteGradeImmediate(String id) async {
    await _repository.delete(id);
    _loadGrades();
  }

  double? getCourseAverage(String courseId) {
    final grades = state.where((grade) => grade.courseId == courseId).toList();
    return _gradesUseCase.calculateAverage(grades);
  }

  double? getMinimumNeeded({
    required String courseId,
    required double targetAverage,
    required double remainingWeight,
  }) {
    final grades = state.where((grade) => grade.courseId == courseId).toList();
    return _gradesUseCase.calculateMinimumNeeded(
      grades: grades,
      targetAverage: targetAverage,
      remainingWeight: remainingWeight,
    );
  }

  double getTotalWeight(String courseId) {
    final grades = state.where((grade) => grade.courseId == courseId).toList();
    return _gradesUseCase.totalWeight(grades);
  }

  Future<void> _handleNotificationsForGrade(Grade grade) async {
    try {
      if (grade.score == null || grade.maxScore == null) return;
      final settings = _ref.read(appSettingsProvider);
      if (!settings.notificationsEnabled || !settings.lowGradeAlertEnabled) {
        return;
      }

      final course = _ref.read(coursesProvider.notifier).getCourseById(
            grade.courseId,
          );

      if (course == null) return;

      // Calcular el porcentaje de la nota
      final percentage = (grade.score! / grade.maxScore!) * 7.0;

      // Calcular el promedio actual del curso
      final average = getCourseAverage(grade.courseId) ?? percentage;

      // Notificar si la nota es baja (< 4.0)
      if (percentage < 4.0) {
        await _notificationService.scheduleGradeAlert(
          courseCode: course.code,
          courseName: course.name,
          grade: percentage,
          average: average,
        );
      }
    } catch (_) {
      // No bloquear flujos principales por errores de notificaciones.
    }
  }

  double getCompletedWeight(String courseId) {
    final grades = state.where((grade) => grade.courseId == courseId).toList();
    return _gradesUseCase.calculateCompletedWeight(grades);
  }

  @override
  void dispose() {
    _gradesSubscription?.cancel();
    _undoManager.dispose();
    super.dispose();
  }
}
