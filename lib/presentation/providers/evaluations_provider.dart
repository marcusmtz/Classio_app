import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/evaluation_model.dart';
import '../../data/repositories/evaluation_repository.dart';

final evaluationRepositoryProvider = Provider((ref) => EvaluationRepository());

final evaluationsProvider =
    StateNotifierProvider<EvaluationsNotifier, List<Evaluation>>((ref) {
  return EvaluationsNotifier(ref.read(evaluationRepositoryProvider));
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
  final _uuid = const Uuid();

  EvaluationsNotifier(this._repository) : super([]) {
    _loadEvaluations();
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
    final calculatedPriority =
        priority ?? _calculateSmartPriority(type, dueDate);

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
  }

  Future<void> updateEvaluation(Evaluation evaluation) async {
    await _repository.update(evaluation);
    state = [
      for (final e in state)
        if (e.id == evaluation.id) evaluation else e,
    ];
  }

  Future<void> deleteEvaluation(String id) async {
    await _repository.delete(id);
    state = state.where((e) => e.id != id).toList();
  }

  Future<void> toggleCompleted(String id) async {
    final evaluation = state.firstWhere((e) => e.id == id);
    if (evaluation.isCompleted) {
      await _repository.markAsPending(id);
    } else {
      await _repository.markAsCompleted(id);
    }
    _loadEvaluations();
  }

  Future<void> updateSubtask(
      String evaluationId, Subtask updatedSubtask) async {
    final evaluation = state.firstWhere((e) => e.id == evaluationId);
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

  // Prioridad Inteligente
  Priority _calculateSmartPriority(EvaluationType type, DateTime dueDate) {
    final now = DateTime.now();
    final daysUntilDue = dueDate.difference(now).inDays;

    // Peso por tipo
    int typeWeight = 0;
    switch (type) {
      case EvaluationType.exam:
        typeWeight = 3;
        break;
      case EvaluationType.project:
        typeWeight = 2;
        break;
      case EvaluationType.task:
        typeWeight = 1;
        break;
    }

    // Peso por cercanía
    int dateWeight = 0;
    if (daysUntilDue <= 1) {
      dateWeight = 4;
    } else if (daysUntilDue <= 3) {
      dateWeight = 3;
    } else if (daysUntilDue <= 7) {
      dateWeight = 2;
    } else if (daysUntilDue <= 14) {
      dateWeight = 1;
    }

    final totalWeight = typeWeight + dateWeight;

    if (totalWeight >= 6) return Priority.critical;
    if (totalWeight >= 4) return Priority.high;
    if (totalWeight >= 2) return Priority.medium;
    return Priority.low;
  }

  Evaluation? getEvaluationById(String id) {
    try {
      return state.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }
}
