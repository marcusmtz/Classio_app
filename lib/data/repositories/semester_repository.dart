import 'package:hive/hive.dart';
import '../models/semester_model.dart';
import '../local/hive_service.dart';

class SemesterRepository {
  Box<Semester> get _box {
    try {
      return HiveService.semestersBoxInstance;
    } catch (_) {
      // Box not open in tests - return empty handling
      throw HiveError('Box not open');
    }
  }

  List<Semester> getAll() {
    try {
      final list = _box.values.toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  Semester? getById(String id) {
    try {
      return _box.get(id);
    } catch (_) {
      return null;
    }
  }

  Future<void> add(Semester semester) async {
    await _box.put(semester.id, semester);
  }

  Future<void> update(Semester semester) async {
    await _box.put(semester.id, semester.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> archive(String id) async {
    final s = getById(id);
    if (s != null) {
      await _box.put(id, s.copyWith(isArchived: true, updatedAt: DateTime.now()));
    }
  }

  Future<void> restore(String id) async {
    final s = getById(id);
    if (s != null) {
      await _box.put(id, s.copyWith(isArchived: false, updatedAt: DateTime.now()));
    }
  }

  Stream<BoxEvent> watch() {
    try {
      return _box.watch();
    } catch (_) {
      return const Stream.empty();
    }
  }
}
