import 'dart:async';

class PendingDeletion<T> {
  final T data;
  final Timer timer;
  PendingDeletion({required this.data, required this.timer});
}

class UndoManager<T> {
  final Duration duration;
  final Future<void> Function(T data) onCommit;
  final Map<String, PendingDeletion<T>> _pending = {};

  UndoManager({required this.duration, required this.onCommit});

  bool get hasPending => _pending.isNotEmpty;

  void stage(String id, T data) {
    // Cancel previous if exists
    _pending[id]?.timer.cancel();
    final timer = Timer(duration, () async {
      final pending = _pending.remove(id);
      if (pending != null) {
        await onCommit(pending.data);
      }
    });
    _pending[id] = PendingDeletion(data: data, timer: timer);
  }

  T? undo(String id) {
    final pending = _pending.remove(id);
    if (pending != null) {
      pending.timer.cancel();
      return pending.data;
    }
    return null;
  }

  Future<void> commitAll() async {
    final ids = _pending.keys.toList();
    for (final id in ids) {
      final pending = _pending.remove(id);
      if (pending != null) {
        pending.timer.cancel();
        await onCommit(pending.data);
      }
    }
  }

  void dispose() {
    for (final p in _pending.values) {
      p.timer.cancel();
    }
    _pending.clear();
  }
}

// Bundle for course deletion with cascade
class CourseDeletionBundle {
  final dynamic course; // Course
  final List<dynamic> schedules; // ClassSchedule
  final List<dynamic> evaluations; // Evaluation
  final List<dynamic> grades; // Grade
  final List<String> evaluationIds;

  CourseDeletionBundle({
    required this.course,
    required this.schedules,
    required this.evaluations,
    required this.grades,
    required this.evaluationIds,
  });
}
