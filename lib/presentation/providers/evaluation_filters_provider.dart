import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/evaluation_model.dart';
import 'evaluations_provider.dart';

// Estado de filtros
class EvaluationFilters {
  final String? courseId;
  final EvaluationType? type;
  final bool? isCompleted;
  final Priority? priority;

  const EvaluationFilters({
    this.courseId,
    this.type,
    this.isCompleted,
    this.priority,
  });

  EvaluationFilters copyWith({
    String? Function()? courseId,
    EvaluationType? Function()? type,
    bool? Function()? isCompleted,
    Priority? Function()? priority,
  }) {
    return EvaluationFilters(
      courseId: courseId != null ? courseId() : this.courseId,
      type: type != null ? type() : this.type,
      isCompleted: isCompleted != null ? isCompleted() : this.isCompleted,
      priority: priority != null ? priority() : this.priority,
    );
  }

  bool get hasActiveFilters =>
      courseId != null || type != null || isCompleted != null || priority != null;

  int get activeFilterCount {
    int count = 0;
    if (courseId != null) count++;
    if (type != null) count++;
    if (isCompleted != null) count++;
    if (priority != null) count++;
    return count;
  }
}

// Provider de filtros
final evaluationFiltersProvider =
    StateNotifierProvider<EvaluationFiltersNotifier, EvaluationFilters>((ref) {
  return EvaluationFiltersNotifier();
});

class EvaluationFiltersNotifier extends StateNotifier<EvaluationFilters> {
  EvaluationFiltersNotifier() : super(const EvaluationFilters());

  void setCourseFilter(String? courseId) {
    state = state.copyWith(courseId: () => courseId);
  }

  void setTypeFilter(EvaluationType? type) {
    state = state.copyWith(type: () => type);
  }

  void setStatusFilter(bool? isCompleted) {
    state = state.copyWith(isCompleted: () => isCompleted);
  }

  void setPriorityFilter(Priority? priority) {
    state = state.copyWith(priority: () => priority);
  }

  void clearFilters() {
    state = const EvaluationFilters();
  }
}

// Provider de evaluaciones filtradas
final filteredEvaluationsProvider = Provider<List<Evaluation>>((ref) {
  final evaluations = ref.watch(evaluationsProvider);
  final filters = ref.watch(evaluationFiltersProvider);

  var filtered = evaluations;

  // Filtrar por curso
  if (filters.courseId != null) {
    filtered = filtered.where((e) => e.courseId == filters.courseId).toList();
  }

  // Filtrar por tipo
  if (filters.type != null) {
    filtered = filtered.where((e) => e.type == filters.type).toList();
  }

  // Filtrar por estado
  if (filters.isCompleted != null) {
    filtered = filtered.where((e) => e.isCompleted == filters.isCompleted).toList();
  }

  // Filtrar por prioridad
  if (filters.priority != null) {
    filtered = filtered.where((e) => e.priority == filters.priority).toList();
  }

  // Ordenar por fecha
  filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));

  return filtered;
});
