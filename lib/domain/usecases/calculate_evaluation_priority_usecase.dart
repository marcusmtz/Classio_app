import '../../data/models/evaluation_model.dart';

class CalculateEvaluationPriorityUseCase {
  Priority execute({
    required EvaluationType type,
    required DateTime dueDate,
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final daysUntilDue = dueDate.difference(reference).inDays;

    final typeWeight = switch (type) {
      EvaluationType.exam => 3,
      EvaluationType.project => 2,
      EvaluationType.task => 1,
    };

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
}
