import 'package:hive/hive.dart';
import '../models/evaluation_model.dart';
import '../local/hive_service.dart';
import '../../domain/repositories/evaluation_repository_contract.dart';

class EvaluationRepository implements EvaluationRepositoryContract {
  final Box<Evaluation> _box = HiveService.evaluationsBoxInstance;

  @override
  List<Evaluation> getAll() {
    return _box.values.toList();
  }

  @override
  List<Evaluation> getPending() {
    return _box.values.where((eval) => !eval.isCompleted).toList();
  }

  @override
  List<Evaluation> getCompleted() {
    return _box.values.where((eval) => eval.isCompleted).toList();
  }

  @override
  List<Evaluation> getByCourse(String courseId) {
    return _box.values.where((eval) => eval.courseId == courseId).toList();
  }

  List<Evaluation> getByDateRange(DateTime start, DateTime end) {
    return _box.values
        .where(
            (eval) => eval.dueDate.isAfter(start) && eval.dueDate.isBefore(end))
        .toList();
  }

  @override
  Evaluation? getById(String id) {
    return _box.get(id);
  }

  @override
  Future<void> add(Evaluation evaluation) async {
    await _box.put(evaluation.id, evaluation);
  }

  @override
  Future<void> update(Evaluation evaluation) async {
    await _box.put(evaluation.id, evaluation);
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  @override
  Future<List<String>> deleteByCourse(String courseId) async {
    final evaluations = getByCourse(courseId);
    final deletedIds = <String>[];

    for (final evaluation in evaluations) {
      await _box.delete(evaluation.id);
      deletedIds.add(evaluation.id);
    }

    return deletedIds;
  }

  @override
  Future<void> markAsCompleted(String id) async {
    final evaluation = _box.get(id);
    if (evaluation != null) {
      await _box.put(
        id,
        evaluation.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<void> markAsPending(String id) async {
    final evaluation = _box.get(id);
    if (evaluation != null) {
      await _box.put(
        id,
        evaluation.copyWith(
          isCompleted: false,
          completedAt: null,
        ),
      );
    }
  }

  Stream<BoxEvent> watch() {
    return _box.watch();
  }
}
