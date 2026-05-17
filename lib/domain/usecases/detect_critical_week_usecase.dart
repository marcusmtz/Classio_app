import '../../data/models/evaluation_model.dart';

class CriticalWeekAnalysis {
  final int totalEvaluations;
  final int examsCount;
  final int projectsCount;
  final int tasksCount;
  final bool isCritical;
  final String message;

  const CriticalWeekAnalysis({
    required this.totalEvaluations,
    required this.examsCount,
    required this.projectsCount,
    required this.tasksCount,
    required this.isCritical,
    required this.message,
  });
}

class DetectCriticalWeekUseCase {
  List<Evaluation> upcomingWindow(
    Iterable<Evaluation> evaluations, {
    DateTime? referenceDate,
    int days = 7,
  }) {
    final now = referenceDate ?? DateTime.now();
    return evaluations.where((evaluation) {
      final diff = evaluation.dueDate.difference(now).inDays;
      return diff >= 0 && diff <= days;
    }).toList();
  }

  CriticalWeekAnalysis analyze(Iterable<Evaluation> evaluations) {
    final list = evaluations.toList();
    final examsCount =
        list.where((item) => item.type == EvaluationType.exam).length;
    final projectsCount =
        list.where((item) => item.type == EvaluationType.project).length;
    final tasksCount =
        list.where((item) => item.type == EvaluationType.task).length;
    final totalCount = list.length;

    final isCritical = examsCount >= 3 || totalCount >= 5 || projectsCount >= 2;

    String message = '';
    if (isCritical) {
      if (examsCount >= 3) {
        message = 'Tienes $examsCount exámenes esta semana 📚';
      } else if (projectsCount >= 2) {
        message = '$projectsCount proyectos por entregar - organízate 💪';
      } else {
        message =
            '$totalCount entregas pendientes - esta semana es pesada 😵‍💫';
      }
    }

    return CriticalWeekAnalysis(
      totalEvaluations: totalCount,
      examsCount: examsCount,
      projectsCount: projectsCount,
      tasksCount: tasksCount,
      isCritical: isCritical,
      message: message,
    );
  }
}
