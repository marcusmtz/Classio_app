import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/grade_model.dart';
import '../../data/repositories/grade_repository.dart';

final gradeRepositoryProvider = Provider((ref) => GradeRepository());

final gradesProvider =
    StateNotifierProvider<GradesNotifier, List<Grade>>((ref) {
  return GradesNotifier(ref.read(gradeRepositoryProvider));
});

final gradesByCourseProvider =
    Provider.family<List<Grade>, String>((ref, courseId) {
  final allGrades = ref.watch(gradesProvider);
  return allGrades.where((g) => g.courseId == courseId).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
});

final courseAverageProvider = Provider.family<double?, String>((ref, courseId) {
  final grades = ref.watch(gradesByCourseProvider(courseId));
  if (grades.isEmpty) return null;

  final repository = ref.read(gradeRepositoryProvider);
  return repository.calculateAverage(courseId);
});

class GradesNotifier extends StateNotifier<List<Grade>> {
  final GradeRepository _repository;
  final _uuid = const Uuid();

  GradesNotifier(this._repository) : super([]) {
    _loadGrades();
  }

  void _loadGrades() {
    state = _repository.getAll();
  }

  Future<void> addGrade({
    required String courseId,
    required String title,
    required double score,
    required double maxScore,
    required double weight,
    required GradeType type,
    DateTime? date,
    String? notes,
  }) async {
    // Validar que el peso total no exceda 100%
    final existingGrades = state.where((g) => g.courseId == courseId).toList();
    final totalWeight = existingGrades.fold<double>(
      0,
      (sum, grade) => sum + grade.weight,
    );

    if (totalWeight + weight > 100) {
      throw Exception(
        'El peso total no puede exceder 100%. Actualmente: ${totalWeight.toStringAsFixed(1)}%',
      );
    }

    final grade = Grade(
      id: _uuid.v4(),
      courseId: courseId,
      title: title,
      score: score,
      maxScore: maxScore,
      weight: weight,
      type: type,
      date: date ?? DateTime.now(),
      notes: notes,
      createdAt: DateTime.now(),
    );

    await _repository.add(grade);
    state = [...state, grade];
  }

  Future<void> updateGrade(Grade grade) async {
    // Validar que el peso total no exceda 100% (excluyendo la nota actual)
    final existingGrades = state
        .where((g) => g.courseId == grade.courseId && g.id != grade.id)
        .toList();
    final totalWeight = existingGrades.fold<double>(
      0,
      (sum, g) => sum + g.weight,
    );

    if (totalWeight + grade.weight > 100) {
      throw Exception(
        'El peso total no puede exceder 100%. Actualmente: ${totalWeight.toStringAsFixed(1)}%',
      );
    }

    await _repository.update(grade);
    state = [
      for (final g in state)
        if (g.id == grade.id) grade else g,
    ];
  }

  Future<void> deleteGrade(String id) async {
    await _repository.delete(id);
    state = state.where((g) => g.id != id).toList();
  }

  double? getCourseAverage(String courseId) {
    return _repository.calculateAverage(courseId);
  }

  double? getMinimumNeeded({
    required String courseId,
    required double targetAverage,
    required double remainingWeight,
  }) {
    return _repository.calculateMinimumNeeded(
      courseId: courseId,
      targetAverage: targetAverage,
      remainingWeight: remainingWeight,
    );
  }

  double getTotalWeight(String courseId) {
    final grades = state.where((g) => g.courseId == courseId).toList();
    return grades.fold<double>(0, (sum, grade) => sum + grade.weight);
  }
}
