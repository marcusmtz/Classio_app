import 'package:hive/hive.dart';
import '../models/grade_model.dart';
import '../local/hive_service.dart';

class GradeRepository {
  final Box<Grade> _box = HiveService.gradesBoxInstance;

  List<Grade> getAll() {
    return _box.values.toList();
  }

  List<Grade> getByCourse(String courseId) {
    return _box.values.where((grade) => grade.courseId == courseId).toList();
  }

  Grade? getById(String id) {
    return _box.get(id);
  }

  Future<void> add(Grade grade) async {
    await _box.put(grade.id, grade);
  }

  Future<void> update(Grade grade) async {
    await _box.put(grade.id, grade);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  double calculateAverage(String courseId) {
    final grades = getByCourse(courseId);
    if (grades.isEmpty) return 0.0;

    double weightedSum = 0.0;
    double totalWeight = 0.0;

    for (var grade in grades) {
      // Convertir score a escala 1-7 si es necesario
      final normalizedScore = (grade.score / grade.maxScore) * 7.0;
      weightedSum += normalizedScore * (grade.weight / 100);
      totalWeight += grade.weight;
    }

    if (totalWeight == 0) return 0.0;
    return weightedSum / (totalWeight / 100);
  }

  double? calculateMinimumNeeded({
    required String courseId,
    required double targetAverage,
    required double remainingWeight,
  }) {
    if (remainingWeight <= 0) return null;

    final grades = getByCourse(courseId);

    double currentWeightedSum = 0.0;
    for (var grade in grades) {
      final normalizedScore = (grade.score / grade.maxScore) * 7.0;
      currentWeightedSum += normalizedScore * (grade.weight / 100);
    }

    // targetAverage = (currentWeightedSum + minimumNeeded * remainingWeight/100) / 1.0
    // targetAverage = currentWeightedSum + minimumNeeded * remainingWeight/100
    // minimumNeeded * remainingWeight/100 = targetAverage - currentWeightedSum
    // minimumNeeded = (targetAverage - currentWeightedSum) / (remainingWeight/100)

    final neededWeightedSum = targetAverage - currentWeightedSum;
    return neededWeightedSum / (remainingWeight / 100);
  }

  Stream<BoxEvent> watch() {
    return _box.watch();
  }
}
