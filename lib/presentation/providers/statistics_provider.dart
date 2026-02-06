import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/evaluation_model.dart';
import 'evaluations_provider.dart';
import 'courses_provider.dart';

/// Modelo para estadísticas generales
class StatisticsSummary {
  final int totalEvaluations;
  final int completedEvaluations;
  final int pendingEvaluations;
  final double completionRate;
  final int totalCourses;
  final int criticalPriorityCount;
  final int thisWeekCount;
  final int thisMonthCount;

  const StatisticsSummary({
    required this.totalEvaluations,
    required this.completedEvaluations,
    required this.pendingEvaluations,
    required this.completionRate,
    required this.totalCourses,
    required this.criticalPriorityCount,
    required this.thisWeekCount,
    required this.thisMonthCount,
  });
}

/// Modelo para carga por curso
class CourseLoad {
  final String courseId;
  final String courseName;
  final int colorValue;
  final int evaluationCount;

  const CourseLoad({
    required this.courseId,
    required this.courseName,
    required this.colorValue,
    required this.evaluationCount,
  });
}

/// Modelo para distribución por tipo
class TypeDistribution {
  final EvaluationType type;
  final int count;
  final double percentage;

  const TypeDistribution({
    required this.type,
    required this.count,
    required this.percentage,
  });
}

/// Provider para resumen de estadísticas
final statisticsSummaryProvider = Provider<StatisticsSummary>((ref) {
  final allEvaluations = ref.watch(evaluationsProvider);
  final pendingEvaluations = ref.watch(pendingEvaluationsProvider);
  final completedEvaluations = ref.watch(completedEvaluationsProvider);
  final courses = ref.watch(activeCoursesProvider);

  final now = DateTime.now();

  // Evaluaciones de esta semana
  final thisWeekCount = pendingEvaluations.where((e) {
    final diff = e.dueDate.difference(now).inDays;
    return diff >= 0 && diff <= 7;
  }).length;

  // Evaluaciones de este mes
  final thisMonthCount = pendingEvaluations.where((e) {
    return e.dueDate.year == now.year && e.dueDate.month == now.month;
  }).length;

  // Evaluaciones con prioridad crítica
  final criticalCount =
      pendingEvaluations.where((e) => e.priority == Priority.critical).length;

  // Tasa de completitud
  final completionRate = allEvaluations.isNotEmpty
      ? completedEvaluations.length / allEvaluations.length
      : 0.0;

  return StatisticsSummary(
    totalEvaluations: allEvaluations.length,
    completedEvaluations: completedEvaluations.length,
    pendingEvaluations: pendingEvaluations.length,
    completionRate: completionRate,
    totalCourses: courses.length,
    criticalPriorityCount: criticalCount,
    thisWeekCount: thisWeekCount,
    thisMonthCount: thisMonthCount,
  );
});

/// Provider para carga por curso
final courseLoadProvider = Provider<List<CourseLoad>>((ref) {
  final pendingEvaluations = ref.watch(pendingEvaluationsProvider);
  final coursesNotifier = ref.watch(coursesProvider.notifier);

  final Map<String, int> loadMap = {};

  // Contar evaluaciones por curso
  for (var eval in pendingEvaluations) {
    loadMap[eval.courseId] = (loadMap[eval.courseId] ?? 0) + 1;
  }

  // Convertir a lista de CourseLoad
  final courseLoads = <CourseLoad>[];
  for (var entry in loadMap.entries) {
    final course = coursesNotifier.getCourseById(entry.key);
    if (course != null) {
      courseLoads.add(CourseLoad(
        courseId: course.id,
        courseName: course.name,
        colorValue: course.colorValue,
        evaluationCount: entry.value,
      ));
    }
  }

  // Ordenar por cantidad (descendente)
  courseLoads.sort((a, b) => b.evaluationCount.compareTo(a.evaluationCount));

  return courseLoads;
});

/// Provider para distribución por tipo
final typeDistributionProvider = Provider<List<TypeDistribution>>((ref) {
  final allEvaluations = ref.watch(evaluationsProvider);

  if (allEvaluations.isEmpty) {
    return [];
  }

  final Map<EvaluationType, int> distributionMap = {};

  // Contar por tipo
  for (var eval in allEvaluations) {
    distributionMap[eval.type] = (distributionMap[eval.type] ?? 0) + 1;
  }

  // Convertir a lista con porcentajes
  final total = allEvaluations.length;
  final distributions = <TypeDistribution>[];

  for (var entry in distributionMap.entries) {
    distributions.add(TypeDistribution(
      type: entry.key,
      count: entry.value,
      percentage: (entry.value / total) * 100,
    ));
  }

  // Ordenar por cantidad (descendente)
  distributions.sort((a, b) => b.count.compareTo(a.count));

  return distributions;
});

/// Provider para entregas del mes (para gráfico de línea)
final monthlyDeliveriesProvider =
    Provider.family<Map<int, int>, DateTime>((ref, month) {
  final allEvaluations = ref.watch(evaluationsProvider);

  final Map<int, int> deliveriesPerDay = {};

  // Inicializar todos los días del mes en 0
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  for (int i = 1; i <= daysInMonth; i++) {
    deliveriesPerDay[i] = 0;
  }

  // Contar evaluaciones por día
  for (var eval in allEvaluations) {
    if (eval.dueDate.year == month.year && eval.dueDate.month == month.month) {
      final day = eval.dueDate.day;
      deliveriesPerDay[day] = (deliveriesPerDay[day] ?? 0) + 1;
    }
  }

  return deliveriesPerDay;
});

/// Provider para tasa de completitud por mes (últimos 6 meses)
final completionRateHistoryProvider = Provider<List<double>>((ref) {
  final allEvaluations = ref.watch(evaluationsProvider);
  final now = DateTime.now();
  final rates = <double>[];

  for (int i = 5; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i, 1);
    final monthEvaluations = allEvaluations.where((e) {
      return e.dueDate.year == month.year && e.dueDate.month == month.month;
    }).toList();

    if (monthEvaluations.isEmpty) {
      rates.add(0.0);
    } else {
      final completed = monthEvaluations.where((e) => e.isCompleted).length;
      rates.add(completed / monthEvaluations.length);
    }
  }

  return rates;
});
