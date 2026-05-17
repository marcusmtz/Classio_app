import '../../data/models/evaluation_model.dart';

abstract class EvaluationRepositoryContract {
  List<Evaluation> getAll();
  List<Evaluation> getPending();
  List<Evaluation> getCompleted();
  List<Evaluation> getByCourse(String courseId);
  Evaluation? getById(String id);
  Future<void> add(Evaluation evaluation);
  Future<void> update(Evaluation evaluation);
  Future<void> delete(String id);
  Future<List<String>> deleteByCourse(String courseId);
  Future<void> markAsCompleted(String id);
  Future<void> markAsPending(String id);
}
