import 'package:hive/hive.dart';
import '../models/evaluation_model.dart';
import '../local/hive_service.dart';

class EvaluationRepository {
  final Box<Evaluation> _box = HiveService.evaluationsBoxInstance;

  List<Evaluation> getAll() {
    return _box.values.toList();
  }

  List<Evaluation> getPending() {
    return _box.values.where((eval) => !eval.isCompleted).toList();
  }

  List<Evaluation> getCompleted() {
    return _box.values.where((eval) => eval.isCompleted).toList();
  }

  List<Evaluation> getByCourse(String courseId) {
    return _box.values.where((eval) => eval.courseId == courseId).toList();
  }

  List<Evaluation> getByDateRange(DateTime start, DateTime end) {
    return _box.values
        .where(
            (eval) => eval.dueDate.isAfter(start) && eval.dueDate.isBefore(end))
        .toList();
  }

  Evaluation? getById(String id) {
    return _box.get(id);
  }

  Future<void> add(Evaluation evaluation) async {
    await _box.put(evaluation.id, evaluation);
  }

  Future<void> update(Evaluation evaluation) async {
    await _box.put(evaluation.id, evaluation);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

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
