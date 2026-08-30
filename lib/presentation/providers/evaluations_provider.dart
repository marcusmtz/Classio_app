import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/undo_manager.dart';
import '../../domain/usecases/calculate_evaluation_priority_usecase.dart';
import '../../data/models/evaluation_model.dart';
import '../../data/repositories/evaluation_repository.dart';
import '../../core/services/notification_service.dart';
import 'app_settings_provider.dart';
import 'courses_provider.dart';
import 'smart_notifications_provider.dart';

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

final overdueEvaluationsProvider = Provider<List<Evaluation>>((ref) {
  final evals = ref.watch(evaluationsProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return evals
      .where((e) => !e.isCompleted && e.dueDate.isBefore(today))
      .toList()
    ..sort((a, b) => b.dueDate.compareTo(a.dueDate));
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
  late final UndoManager<Evaluation> _undoManager;

  EvaluationsNotifier(
    this._repository,
    this._notificationService,
    this._calculatePriorityUseCase,
    this._ref,
  ) : super([]) {
    _undoManager = UndoManager<Evaluation>(
      duration: const Duration(seconds: 5),
      onCommit: (evaluation) async {
        await _repository.delete(evaluation.id);
        await _notificationService.cancelEvaluationNotifications(evaluation.id);
        _updateSmartNotifications();
      },
    );
    _loadEvaluations();
    _evaluationsSubscription = _repository.watch().listen((_) {
      _loadEvaluations();
    });
  }

  void _loadEvaluations() {
    // No recargar si hay pending deletes (para mantener undo en memoria)
    if (_undoManager.hasPending) return;
    state = _repository.getAll();
  }

  bool undoDelete(String id) {
    final evaluation = _undoManager.undo(id);
    if (evaluation != null) {
      state = [...state, evaluation]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      _handleNotificationsForEvaluation(evaluation);
      _updateSmartNotifications();
      return true;
    }
    return false;
  }

  Future<void> commitPendingDeletes() async {
    await _undoManager.commitAll();
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
    // El stream watch() dispara _loadEvaluations() automáticamente

    await _handleNotificationsForEvaluation(evaluation);

    // Actualizar notificaciones inteligentes
    _updateSmartNotifications();
  }

  Future<void> updateEvaluation(Evaluation evaluation) async {
    await _repository.update(evaluation);
    // El stream watch() dispara _loadEvaluations() automáticamente

    await _handleNotificationsForEvaluation(evaluation);

    // Actualizar notificaciones inteligentes
    _updateSmartNotifications();
  }

  Future<void> deleteEvaluation(String id) async {
    final evaluation = getEvaluationById(id);
    if (evaluation == null) return;
    // Optimistic remove
    state = state.where((e) => e.id != id).toList();
    _undoManager.stage(id, evaluation);
    // Notificaciones se cancelan al commit, no ahora
    _updateSmartNotifications();
  }

  // Borrado inmediato sin undo (para casos internos)
  Future<void> deleteEvaluationImmediate(String id) async {
    await _repository.delete(id);
    state = state.where((e) => e.id != id).toList();
    await _notificationService.cancelEvaluationNotifications(id);
    _updateSmartNotifications();
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

    // Actualizar notificaciones inteligentes
    _updateSmartNotifications();
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

  void _updateSmartNotifications() {
    try {
      // Programar actualización de notificaciones inteligentes de forma asíncrona
      Future.microtask(() async {
        final smartNotifications = _ref.read(smartNotificationsServiceProvider);
        await smartNotifications.updateAllSmartNotifications();
      });
    } catch (_) {
      // No bloquear flujos principales
    }
  }

  @override
  void dispose() {
    _evaluationsSubscription?.cancel();
    _undoManager.dispose();
    super.dispose();
  }
}
