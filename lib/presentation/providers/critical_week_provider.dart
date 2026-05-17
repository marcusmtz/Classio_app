import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/detect_critical_week_usecase.dart';
import '../../data/models/evaluation_model.dart';
import 'evaluations_provider.dart';

/// Modelo para información de semana crítica
class CriticalWeekInfo {
  final bool isCritical;
  final int totalEvaluations;
  final int examsCount;
  final int projectsCount;
  final int tasksCount;
  final String message;
  final List<Evaluation> evaluations;

  const CriticalWeekInfo({
    required this.isCritical,
    required this.totalEvaluations,
    required this.examsCount,
    required this.projectsCount,
    required this.tasksCount,
    required this.message,
    required this.evaluations,
  });

  factory CriticalWeekInfo.empty() {
    return const CriticalWeekInfo(
      isCritical: false,
      totalEvaluations: 0,
      examsCount: 0,
      projectsCount: 0,
      tasksCount: 0,
      message: '',
      evaluations: [],
    );
  }
}

/// Provider que detecta si la semana actual es crítica
final detectCriticalWeekUseCaseProvider =
    Provider((ref) => DetectCriticalWeekUseCase());

final criticalWeekProvider = Provider<CriticalWeekInfo>((ref) {
  final pendingEvaluations = ref.watch(pendingEvaluationsProvider);
  final useCase = ref.watch(detectCriticalWeekUseCaseProvider);
  final now = DateTime.now();

  final thisWeekEvaluations = useCase.upcomingWindow(
    pendingEvaluations,
    referenceDate: now,
    days: 7,
  );
  final analysis = useCase.analyze(thisWeekEvaluations);

  return CriticalWeekInfo(
    isCritical: analysis.isCritical,
    totalEvaluations: analysis.totalEvaluations,
    examsCount: analysis.examsCount,
    projectsCount: analysis.projectsCount,
    tasksCount: analysis.tasksCount,
    message: analysis.message,
    evaluations: thisWeekEvaluations,
  );
});

/// Provider para detectar semanas críticas en un rango de fechas
final criticalWeeksInMonthProvider =
    Provider.family<List<DateTime>, DateTime>((ref, month) {
  final pendingEvaluations = ref.watch(pendingEvaluationsProvider);
  final useCase = ref.watch(detectCriticalWeekUseCaseProvider);
  final criticalWeeks = <DateTime>[];

  // Obtener primer día del mes
  final firstDay = DateTime(month.year, month.month, 1);
  // Obtener último día del mes
  final lastDay = DateTime(month.year, month.month + 1, 0);

  // Iterar por semanas
  DateTime weekStart = firstDay;
  while (weekStart.isBefore(lastDay) || weekStart.isAtSameMomentAs(lastDay)) {
    final weekEnd = weekStart.add(const Duration(days: 7));

    // Obtener evaluaciones de esta semana
    final weekEvaluations = pendingEvaluations.where((e) {
      return e.dueDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          e.dueDate.isBefore(weekEnd);
    }).toList();

    final analysis = useCase.analyze(weekEvaluations);
    if (analysis.isCritical) {
      criticalWeeks.add(weekStart);
    }

    weekStart = weekEnd;
  }

  return criticalWeeks;
});
