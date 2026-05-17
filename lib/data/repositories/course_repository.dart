import 'package:hive/hive.dart';
import '../models/course_model.dart';
import '../local/hive_service.dart';
import '../../domain/repositories/course_repository_contract.dart';

class CourseRepository implements CourseRepositoryContract {
  final Box<Course> _box = HiveService.coursesBoxInstance;

  @override
  List<Course> getAll() {
    return _box.values.toList();
  }

  @override
  List<Course> getActive() {
    return _box.values.where((course) => course.isActive).toList();
  }

  @override
  Course? getById(String id) {
    return _box.get(id);
  }

  @override
  Future<void> add(Course course) async {
    await _box.put(course.id, course);
  }

  @override
  Future<void> update(Course course) async {
    await _box.put(course.id, course.copyWith(updatedAt: DateTime.now()));
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> archive(String id) async {
    final course = _box.get(id);
    if (course != null) {
      await _box.put(
        id,
        course.copyWith(isActive: false, updatedAt: DateTime.now()),
      );
    }
  }

  @override
  Future<void> restore(String id) async {
    final course = _box.get(id);
    if (course != null) {
      await _box.put(
        id,
        course.copyWith(isActive: true, updatedAt: DateTime.now()),
      );
    }
  }

  Stream<BoxEvent> watch() {
    return _box.watch();
  }
}
