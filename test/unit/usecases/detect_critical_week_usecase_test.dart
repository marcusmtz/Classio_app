import 'package:flutter_test/flutter_test.dart';

import 'package:classio_app/data/models/evaluation_model.dart' as eval_model;
import 'package:classio_app/domain/usecases/detect_critical_week_usecase.dart';

eval_model.Evaluation _evaluation({
  required String id,
  required eval_model.EvaluationType type,
  required DateTime dueDate,
}) {
  return eval_model.Evaluation(
    id: id,
    courseId: 'course-1',
    title: id,
    type: type,
    dueDate: dueDate,
    priority: eval_model.Priority.medium,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  final useCase = DetectCriticalWeekUseCase();

  test('detects critical week with 3 exams', () {
    final evaluations = [
      _evaluation(
          id: 'e1',
          type: eval_model.EvaluationType.exam,
          dueDate: DateTime(2026, 5, 2)),
      _evaluation(
          id: 'e2',
          type: eval_model.EvaluationType.exam,
          dueDate: DateTime(2026, 5, 3)),
      _evaluation(
          id: 'e3',
          type: eval_model.EvaluationType.exam,
          dueDate: DateTime(2026, 5, 4)),
    ];

    final analysis = useCase.analyze(evaluations);

    expect(analysis.isCritical, isTrue);
    expect(analysis.examsCount, 3);
  });

  test('filters upcoming window from reference date', () {
    final evaluations = [
      _evaluation(
          id: 'near',
          type: eval_model.EvaluationType.task,
          dueDate: DateTime(2026, 5, 5)),
      _evaluation(
          id: 'far',
          type: eval_model.EvaluationType.project,
          dueDate: DateTime(2026, 6, 1)),
    ];

    final filtered = useCase.upcomingWindow(
      evaluations,
      referenceDate: DateTime(2026, 5, 1),
      days: 7,
    );

    expect(filtered.length, 1);
    expect(filtered.first.id, 'near');
  });
}
