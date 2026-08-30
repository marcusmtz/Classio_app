import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/semester_model.dart';
import '../../data/repositories/semester_repository.dart';

final semesterRepositoryProvider = Provider((ref) => SemesterRepository());

final semestersProvider =
    StateNotifierProvider<SemesterNotifier, List<Semester>>((ref) {
  return SemesterNotifier(ref.read(semesterRepositoryProvider));
});

final activeSemestersProvider = Provider<List<Semester>>((ref) {
  return ref.watch(semestersProvider).where((s) => !s.isArchived).toList();
});

final archivedSemestersProvider = Provider<List<Semester>>((ref) {
  return ref.watch(semestersProvider).where((s) => s.isArchived).toList();
});

class SemesterNotifier extends StateNotifier<List<Semester>> {
  final SemesterRepository _repository;
  final _uuid = const Uuid();
  StreamSubscription? _sub;

  SemesterNotifier(this._repository) : super([]) {
    _load();
    _sub = _repository.watch().listen((_) => _load());
  }

  void _load() {
    state = _repository.getAll();
  }

  Future<Semester> addSemester({
    required String name,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (name.trim().isEmpty) throw Exception('Nombre requerido');
    final semester = Semester(
      id: _uuid.v4(),
      name: name.trim(),
      createdAt: DateTime.now(),
      startDate: startDate,
      endDate: endDate,
    );
    await _repository.add(semester);
    return semester;
  }

  Future<void> updateSemester(Semester semester) async {
    await _repository.update(semester);
  }

  Future<void> deleteSemester(String id) async {
    await _repository.delete(id);
  }

  Future<void> archiveSemester(String id) async {
    await _repository.archive(id);
  }

  Future<void> restoreSemester(String id) async {
    await _repository.restore(id);
  }

  Semester? getById(String id) {
    try {
      return state.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
