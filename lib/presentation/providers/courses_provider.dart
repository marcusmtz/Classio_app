import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/course_model.dart';
import '../../data/repositories/course_repository.dart';

final courseRepositoryProvider = Provider((ref) => CourseRepository());

final coursesProvider =
    StateNotifierProvider<CoursesNotifier, List<Course>>((ref) {
  return CoursesNotifier(ref.read(courseRepositoryProvider));
});

final activeCoursesProvider = Provider<List<Course>>((ref) {
  return ref.watch(coursesProvider).where((c) => c.isActive).toList();
});

class CoursesNotifier extends StateNotifier<List<Course>> {
  final CourseRepository _repository;
  final _uuid = const Uuid();

  CoursesNotifier(this._repository) : super([]) {
    _loadCourses();
  }

  void _loadCourses() {
    state = _repository.getAll();
  }

  Future<void> addCourse({
    required String name,
    required String code,
    required int colorValue,
  }) async {
    final course = Course(
      id: _uuid.v4(),
      name: name,
      code: code,
      colorValue: colorValue,
      createdAt: DateTime.now(),
    );

    await _repository.add(course);
    state = [...state, course];
  }

  Future<void> updateCourse(Course course) async {
    await _repository.update(course);
    state = [
      for (final c in state)
        if (c.id == course.id) course else c,
    ];
  }

  Future<void> deleteCourse(String id) async {
    await _repository.delete(id);
    state = state.where((c) => c.id != id).toList();
  }

  Future<void> archiveCourse(String id) async {
    await _repository.archive(id);
    _loadCourses();
  }

  Future<void> restoreCourse(String id) async {
    await _repository.restore(id);
    _loadCourses();
  }

  Course? getCourseById(String id) {
    try {
      return state.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
