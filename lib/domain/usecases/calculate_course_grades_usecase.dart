import '../../data/models/grade_model.dart';

class CalculateCourseGradesUseCase {
  double calculateAverage(Iterable<Grade> grades) {
    final gradeList = grades.toList();
    if (gradeList.isEmpty) return 0.0;

    double weightedSum = 0.0;
    double totalWeight = 0.0;

    for (final grade in gradeList) {
      final normalizedScore = (grade.score / grade.maxScore) * 7.0;
      weightedSum += normalizedScore * (grade.weight / 100);
      totalWeight += grade.weight;
    }

    if (totalWeight == 0) return 0.0;
    return weightedSum / (totalWeight / 100);
  }

  double? calculateMinimumNeeded({
    required Iterable<Grade> grades,
    required double targetAverage,
    required double remainingWeight,
  }) {
    if (remainingWeight <= 0) return null;

    double currentWeightedSum = 0.0;
    for (final grade in grades) {
      final normalizedScore = (grade.score / grade.maxScore) * 7.0;
      currentWeightedSum += normalizedScore * (grade.weight / 100);
    }

    final neededWeightedSum = targetAverage - currentWeightedSum;
    return neededWeightedSum / (remainingWeight / 100);
  }

  double totalWeight(Iterable<Grade> grades) {
    return grades.fold<double>(0, (sum, grade) => sum + grade.weight);
  }
}
