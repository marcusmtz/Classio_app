import 'package:hive/hive.dart';
import '../models/class_schedule_model.dart';
import '../local/hive_service.dart';

class ClassScheduleRepository {
  final Box<ClassSchedule> _box = HiveService.classesBoxInstance;

  List<ClassSchedule> getAll() {
    return _box.values.toList();
  }

  List<ClassSchedule> getByCourse(String courseId) {
    return _box.values.where((cls) => cls.courseId == courseId).toList();
  }

  List<ClassSchedule> getByDay(DayOfWeek day) {
    return _box.values.where((cls) => cls.dayOfWeek == day).toList();
  }

  ClassSchedule? getById(String id) {
    return _box.get(id);
  }

  Future<void> add(ClassSchedule classSchedule) async {
    await _box.put(classSchedule.id, classSchedule);
  }

  Future<void> update(ClassSchedule classSchedule) async {
    await _box.put(classSchedule.id, classSchedule);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<int> deleteByCourse(String courseId) async {
    final schedules = getByCourse(courseId);

    for (final schedule in schedules) {
      await _box.delete(schedule.id);
    }

    return schedules.length;
  }

  Stream<BoxEvent> watch() {
    return _box.watch();
  }
}
