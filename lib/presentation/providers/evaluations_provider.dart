import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/usecases/calculate_evaluation_priority_usecase.dart';
import '../../data/models/evaluation_model.dart';
import '../../data/repositories/evaluation_repository.dart';
import '../../core/services/notification_service.dart';
import 'app_settings_provider.dart';
import 'courses_provider.dart';

final evaluationRepositoryProvider = Provider((ref) => EvaluationRepository());

final notificationServiceProvider = Provider((ref) => NotificationService());

final calculateEvaluationPriorityUseCaseProvider =
    Provider((ref) => CalculateEvaluationPriorityUseCase());

final evaluationsProvider =
    StateNotifierProvider<EvaluationsNotifier, List<Evaluation>>((ref) {
  return EvaluationsNotifier(
    ref.read(evaluationRepositoryProvider),
    ref.read(notificationServiceProvider),
    ref.read(calculateEvaluationPriorityUseCaseProvider),
    ref,
  );
});

final pendingEvaluationsProvider = Provider<List<Evaluation>>((ref) {
  final evals = ref.watch(evaluationsProvider);
  return evals.where((e) => !e.isCompleted).toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
});

final completedEvaluationsProvider = Provider<List<Evaluation>>((ref) {
  final evals = ref.watch(evaluationsProvider);
  return evals.where((e) => e.isCompleted).toList()
    ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
});

class EvaluationsNotifier extends StateNotifier<List<Evaluation>> {
  final EvaluationRepository _repository;
  final NotificationService _notificationService;
  final CalculateEvaluationPriorityUseCase _calculatePriorityUseCase;
  final Ref _ref;
  final _uuid = const Uuid();
  StreamSubscription? _evaluationsSubscription;

  EvaluationsNotifier(
    this._repository,
    this._notificationService,
    this._calculatePriorityUseCase,
    this._ref,
  ) : super([]) {
    _loadEvaluations();
    _evaluationsSubscription = _repository.watch().listen((_) {
      _loadEvaluations();
    });
  }

  void _loadEvaluations() {
    state = _repository.getAll();
  }

  Future<void> addEvaluation({
    required String courseId,
    required String title,
    String? description,
    required EvaluationType type,
    required DateTime dueDate,
    Priority? priority,
    List<Subtask>? subtasks,
  }) async {
    final calculatedPriority = priority ??
        _calculatePriorityUseCase.execute(type: type, dueDate: dueDate);

    final evaluation = Evaluation(
      id: _uuid.v4(),
      courseId: courseId,
      title: title,
      description: description,
      type: type,
      dueDate: dueDate,
      priority: calculatedPriority,
      subtasks: subtasks,
      createdAt: DateTime.now(),
      isPriorityManual: priority != null,
    );

    await _repository.add(evaluation);
    state = [...state, evaluation];

    await _handleNotificationsForEvaluation(evaluation);
  }

  Future<void> updateEvaluation(Evaluation evaluation) async {
    await _repository.update(evaluation);
    state = [
      for (final e in state)
        if (e.id == evaluation.id) evaluation else e,
    ];

    await _handleNotificationsForEvaluation(evaluation);
  }

  Future<void> deleteEvaluation(String id) async {
    await _repository.delete(id);
    state = state.where((e) => e.id != id).toList();

    // Cancelar notificaciones
    await _notificationService.cancelEvaluationNotifications(id);
  }

  Future<void> toggleCompleted(String id) async {
    final evaluation = getEvaluationById(id);
    if (evaluation == null) return;

    if (evaluation.isCompleted) {
      await _repository.markAsPending(id);
      await _handleNotificationsForEvaluation(evaluation);
    } else {
      await _repository.markAsCompleted(id);
      // Cancelar notificaciones al completar
      await _notificationService.cancelEvaluationNotifications(id);
    }
    _loadEvaluations();
  }

  Future<void> updateSubtask(
      String evaluationId, Subtask updatedSubtask) async {
    final evaluation = getEvaluationById(evaluationId);
    if (evaluation == null) return;

    final updatedSubtasks = evaluation.subtasks?.map((s) {
      return s.id == updatedSubtask.id ? updatedSubtask : s;
    }).toList();

    final updatedEvaluation = evaluation.copyWith(subtasks: updatedSubtasks);
    await updateEvaluation(updatedEvaluation);
  }

  List<Evaluation> getEvaluationsByDate(DateTime date) {
    return state.where((e) {
      return e.dueDate.year == date.year &&
          e.dueDate.month == date.month &&
          e.dueDate.day == date.day;
    }).toList();
  }

  List<Evaluation> getEvaluationsByCourse(String courseId) {
    return state.where((e) => e.courseId == courseId).toList();
  }

  Evaluation? getEvaluationById(String id) {
    try {
      return state.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> _handleNotificationsForEvaluation(Evaluation evaluation) async {
    try {
      final settings = _ref.read(appSettingsProvider);
      if (!settings.notificationsEnabled) {
        await _notificationService.cancelEvaluationNotifications(evaluation.id);
        return;
      }

      final course = _ref.read(coursesProvider.notifier).getCourseById(
            evaluation.courseId,
          );

      if (course == null) {
        await _notificationService.cancelEvaluationNotifications(evaluation.id);
        return;
      }

      await _notificationService.scheduleEvaluationNotification(
        evaluation: evaluation,
        courseCode: course.code,
        courseName: course.name,
      );
    } catch (_) {
      // No bloquear flujos principales por errores de notificaciones.
    }
  }

  @override
  void dispose() {
    _evaluationsSubscription?.cancel();
    super.dispose();
  }
}
