import 'package:flutter_riverpod/flutter_riverpod.dart';
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
final criticalWeekProvider = Provider<CriticalWeekInfo>((ref) {
  final pendingEvaluations = ref.watch(pendingEvaluationsProvider);
  final now = DateTime.now();

  // Obtener evaluaciones de esta semana (próximos 7 días)
  final thisWeekEvaluations = pendingEvaluations.where((e) {
    final diff = e.dueDate.difference(now).inDays;
    return diff >= 0 && diff <= 7;
  }).toList();

  // Contar por tipo
  final examsCount =
      thisWeekEvaluations.where((e) => e.type == EvaluationType.exam).length;
  final projectsCount =
      thisWeekEvaluations.where((e) => e.type == EvaluationType.project).length;
  final tasksCount =
      thisWeekEvaluations.where((e) => e.type == EvaluationType.task).length;
  final totalCount = thisWeekEvaluations.length;

  // Criterios de detección:
  // - ≥ 3 exámenes
  // - ≥ 5 entregas totales
  // - ≥ 2 proyectos
  final isCritical = examsCount >= 3 || totalCount >= 5 || projectsCount >= 2;

  // Generar mensaje dinámico
  String message = '';
  if (isCritical) {
    if (examsCount >= 3) {
      message = 'Tienes $examsCount exámenes esta semana 📚';
    } else if (projectsCount >= 2) {
      message = '$projectsCount proyectos por entregar - organízate 💪';
    } else {
      message = '$totalCount entregas pendientes - esta semana es pesada 😵‍💫';
    }
  }

  return CriticalWeekInfo(
    isCritical: isCritical,
    totalEvaluations: totalCount,
    examsCount: examsCount,
    projectsCount: projectsCount,
    tasksCount: tasksCount,
    message: message,
    evaluations: thisWeekEvaluations,
  );
});

/// Provider para detectar semanas críticas en un rango de fechas
final criticalWeeksInMonthProvider =
    Provider.family<List<DateTime>, DateTime>((ref, month) {
  final pendingEvaluations = ref.watch(pendingEvaluationsProvider);
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

    // Verificar si es crítica
    final examsCount =
        weekEvaluations.where((e) => e.type == EvaluationType.exam).length;
    final projectsCount =
        weekEvaluations.where((e) => e.type == EvaluationType.project).length;
    final totalCount = weekEvaluations.length;

    if (examsCount >= 3 || totalCount >= 5 || projectsCount >= 2) {
      criticalWeeks.add(weekStart);
    }

    weekStart = weekEnd;
  }

  return criticalWeeks;
});
