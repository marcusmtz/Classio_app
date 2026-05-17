import 'package:flutter_test/flutter_test.dart';

import 'package:classio_app/data/models/evaluation_model.dart';
import 'package:classio_app/domain/usecases/calculate_evaluation_priority_usecase.dart';

void main() {
  final useCase = CalculateEvaluationPriorityUseCase();

  test('returns critical for exam due tomorrow', () {
    final priority = useCase.execute(
      type: EvaluationType.exam,
      dueDate: DateTime(2026, 5, 2),
      now: DateTime(2026, 5, 1),
    );

    expect(priority, Priority.critical);
  });

  test('returns low for task due in more than 2 weeks', () {
    final priority = useCase.execute(
      type: EvaluationType.task,
      dueDate: DateTime(2026, 5, 30),
      now: DateTime(2026, 5, 1),
    );

    expect(priority, Priority.low);
  });
}
