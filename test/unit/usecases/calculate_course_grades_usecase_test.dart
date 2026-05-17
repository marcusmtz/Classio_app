import 'package:flutter_test/flutter_test.dart';

import 'package:classio_app/data/models/grade_model.dart';
import 'package:classio_app/domain/usecases/calculate_course_grades_usecase.dart';

Grade _grade({
  required String id,
  required double score,
  required double maxScore,
  required double weight,
}) {
  return Grade(
    id: id,
    courseId: 'course-1',
    title: id,
    type: GradeType.exam,
    score: score,
    maxScore: maxScore,
    weight: weight,
    date: DateTime(2026, 5, 1),
    createdAt: DateTime(2026, 5, 1),
  );
}

void main() {
  final useCase = CalculateCourseGradesUseCase();

  test('calculates weighted average in 1-7 scale', () {
    final grades = [
      _grade(id: 'g1', score: 5.0, maxScore: 7.0, weight: 50),
      _grade(id: 'g2', score: 6.0, maxScore: 7.0, weight: 50),
    ];

    final average = useCase.calculateAverage(grades);
    expect(average, closeTo(5.5, 0.0001));
  });

  test('returns minimum needed for target average', () {
    final grades = [
      _grade(id: 'g1', score: 4.0, maxScore: 7.0, weight: 40),
    ];

    final needed = useCase.calculateMinimumNeeded(
      grades: grades,
      targetAverage: 5.0,
      remainingWeight: 60,
    );

    expect(needed, isNotNull);
    expect(needed!, greaterThan(5.0));
  });
}
