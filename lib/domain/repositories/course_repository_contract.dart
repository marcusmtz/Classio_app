import '../../data/models/course_model.dart';

abstract class CourseRepositoryContract {
  List<Course> getAll();
  List<Course> getActive();
  Course? getById(String id);
  Future<void> add(Course course);
  Future<void> update(Course course);
  Future<void> delete(String id);
  Future<void> archive(String id);
  Future<void> restore(String id);
}
