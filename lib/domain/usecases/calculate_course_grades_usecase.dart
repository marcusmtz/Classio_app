import '../../data/models/grade_model.dart';

class CalculateCourseGradesUseCase {
  // Promedio solo sobre evaluaciones calificadas (score != null)
  double calculateAverage(Iterable<Grade> grades) {
    final completed = grades.where((g) => g.score != null && g.maxScore != null && g.maxScore! > 0).toList();
    if (completed.isEmpty) return 0.0;

    double weightedSum = 0.0;
    double totalWeight = 0.0;

    for (final grade in completed) {
      final normalizedScore = (grade.score! / grade.maxScore!) * 7.0;
      weightedSum += normalizedScore * (grade.weight / 100);
      totalWeight += grade.weight;
    }

    if (totalWeight == 0) return 0.0;
    return weightedSum / (totalWeight / 100);
  }

  double calculateCompletedWeight(Iterable<Grade> grades) {
    return grades
        .where((g) => g.score != null && g.maxScore != null)
        .fold<double>(0, (sum, grade) => sum + grade.weight);
  }

  double? calculateMinimumNeeded({
    required Iterable<Grade> grades,
    required double targetAverage,
    required double remainingWeight,
  }) {
    if (remainingWeight <= 0) return null;

    double currentWeightedSum = 0.0;
    for (final grade in grades.where((g) => g.score != null && g.maxScore != null)) {
      final normalizedScore = (grade.score! / grade.maxScore!) * 7.0;
      currentWeightedSum += normalizedScore * (grade.weight / 100);
    }

    final neededWeightedSum = targetAverage - currentWeightedSum;
    return neededWeightedSum / (remainingWeight / 100);
  }

  double totalWeight(Iterable<Grade> grades) {
    return grades.fold<double>(0, (sum, grade) => sum + grade.weight);
  }
}
