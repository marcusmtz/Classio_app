import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/widget_service.dart';
import 'schedule_provider.dart';
import 'evaluations_provider.dart';
import 'courses_provider.dart';

final widgetServiceProvider = Provider((ref) => WidgetService());

/// Provider que actualiza el widget automáticamente
final widgetUpdaterProvider = Provider((ref) {
  final widgetService = ref.watch(widgetServiceProvider);
  final scheduleNotifier = ref.watch(scheduleProvider.notifier);
  final evaluations = ref.watch(pendingEvaluationsProvider);
  final courses = ref.watch(activeCoursesProvider);

  // Obtener clase actual y próxima
  final currentClass = scheduleNotifier.getCurrentClass();
  final nextClass = scheduleNotifier.getNextClass();

  // Obtener próxima evaluación
  final nextEvaluation = evaluations.isNotEmpty ? evaluations.first : null;

  // Obtener códigos de cursos
  String? currentCourseCode;
  String? nextCourseCode;
  String? evaluationCourseCode;

  if (currentClass != null) {
    final course = courses.firstWhere(
      (c) => c.id == currentClass.courseId,
      orElse: () => courses.first,
    );
    currentCourseCode = course.code;
  }

  if (nextClass != null) {
    final course = courses.firstWhere(
      (c) => c.id == nextClass.courseId,
      orElse: () => courses.first,
    );
    nextCourseCode = course.code;
  }

  if (nextEvaluation != null) {
    final course = courses.firstWhere(
      (c) => c.id == nextEvaluation.courseId,
      orElse: () => courses.first,
    );
    evaluationCourseCode = course.code;
  }

  // Actualizar widget
  widgetService.updateWidget(
    currentClass: currentClass,
    nextClass: nextClass,
    nextEvaluation: nextEvaluation,
    currentCourseCode: currentCourseCode,
    nextCourseCode: nextCourseCode,
    evaluationCourseCode: evaluationCourseCode,
  );

  return widgetService;
});

/// Notifier para actualizar widget manualmente
class WidgetNotifier extends StateNotifier<bool> {
  final WidgetService _widgetService;
  final Ref _ref;

  WidgetNotifier(this._widgetService, this._ref) : super(false);

  /// Actualizar widget manualmente
  Future<void> updateWidget() async {
    state = true;

    try {
      final scheduleNotifier = _ref.read(scheduleProvider.notifier);
      final evaluations = _ref.read(pendingEvaluationsProvider);
      final courses = _ref.read(activeCoursesProvider);

      final currentClass = scheduleNotifier.getCurrentClass();
      final nextClass = scheduleNotifier.getNextClass();
      final nextEvaluation = evaluations.isNotEmpty ? evaluations.first : null;

      String? currentCourseCode;
      String? nextCourseCode;
      String? evaluationCourseCode;

      if (currentClass != null) {
        final course = courses.firstWhere(
          (c) => c.id == currentClass.courseId,
          orElse: () => courses.first,
        );
        currentCourseCode = course.code;
      }

      if (nextClass != null) {
        final course = courses.firstWhere(
          (c) => c.id == nextClass.courseId,
          orElse: () => courses.first,
        );
        nextCourseCode = course.code;
      }

      if (nextEvaluation != null) {
        final course = courses.firstWhere(
          (c) => c.id == nextEvaluation.courseId,
          orElse: () => courses.first,
        );
        evaluationCourseCode = course.code;
      }

      await _widgetService.updateWidget(
        currentClass: currentClass,
        nextClass: nextClass,
        nextEvaluation: nextEvaluation,
        currentCourseCode: currentCourseCode,
        nextCourseCode: nextCourseCode,
        evaluationCourseCode: evaluationCourseCode,
      );
    } finally {
      state = false;
    }
  }

  /// Limpiar widget
  Future<void> clearWidget() async {
    await _widgetService.clearWidget();
  }
}

final widgetNotifierProvider =
    StateNotifierProvider<WidgetNotifier, bool>((ref) {
  return WidgetNotifier(
    ref.read(widgetServiceProvider),
    ref,
  );
});
