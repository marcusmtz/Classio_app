import 'package:hive/hive.dart';
import '../../domain/usecases/calculate_course_grades_usecase.dart';
import '../models/grade_model.dart';
import '../local/hive_service.dart';

class GradeRepository {
  final Box<Grade> _box = HiveService.gradesBoxInstance;
  final CalculateCourseGradesUseCase _gradesUseCase =
      CalculateCourseGradesUseCase();

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

  Future<int> deleteByCourse(String courseId) async {
    final grades = getByCourse(courseId);

    for (final grade in grades) {
      await _box.delete(grade.id);
    }

    return grades.length;
  }

  double calculateAverage(String courseId) {
    return _gradesUseCase.calculateAverage(getByCourse(courseId));
  }

  double? calculateMinimumNeeded({
    required String courseId,
    required double targetAverage,
    required double remainingWeight,
  }) {
    return _gradesUseCase.calculateMinimumNeeded(
      grades: getByCourse(courseId),
      targetAverage: targetAverage,
      remainingWeight: remainingWeight,
    );
  }

  Stream<BoxEvent> watch() {
    return _box.watch();
  }
}
