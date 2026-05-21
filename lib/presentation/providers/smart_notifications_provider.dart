import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/notification_service.dart';
import 'app_settings_provider.dart';
import 'evaluations_provider.dart';
import 'courses_provider.dart';

final smartNotificationsServiceProvider =
    Provider((ref) => SmartNotificationsService(ref));

class SmartNotificationsService {
  final Ref _ref;
  final NotificationService _notificationService = NotificationService();

  SmartNotificationsService(this._ref);

  /// Programar resumen diario
  Future<void> scheduleDailySummary() async {
    try {
      final settings = _ref.read(appSettingsProvider);
      if (!settings.notificationsEnabled || !settings.dailySummaryEnabled) {
        await _notificationService.cancelDailySummary();
        return;
      }

      final evaluations = _ref.read(evaluationsProvider);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Contar evaluaciones pendientes
      final pending = evaluations.where((e) => !e.isCompleted).length;

      // Contar evaluaciones de hoy
      final todayEvals = evaluations.where((e) {
        final evalDate =
            DateTime(e.dueDate.year, e.dueDate.month, e.dueDate.day);
        return !e.isCompleted && evalDate.isAtSameMomentAs(today);
      }).length;

      // Contar evaluaciones vencidas
      final overdue = evaluations.where((e) {
        final evalDate =
            DateTime(e.dueDate.year, e.dueDate.month, e.dueDate.day);
        return !e.isCompleted && evalDate.isBefore(today);
      }).length;

      await _notificationService.scheduleDailySummary(
        pendingCount: pending,
        todayCount: todayEvals,
        overdueCount: overdue,
      );
    } catch (_) {
      // No bloquear flujos principales
    }
  }

  /// Detectar y notificar semanas críticas
  Future<void> checkAndScheduleCriticalWeeks() async {
    try {
      final settings = _ref.read(appSettingsProvider);
      if (!settings.notificationsEnabled || !settings.criticalWeekEnabled) {
        return;
      }

      final evaluations = _ref.read(evaluationsProvider);
      final courses = _ref.read(coursesProvider);
      final now = DateTime.now();

      // Analizar las próximas 4 semanas
      for (int weekOffset = 0; weekOffset < 4; weekOffset++) {
        final weekStart =
            _getStartOfWeek(now.add(Duration(days: weekOffset * 7)));
        final weekEnd = weekStart.add(const Duration(days: 7));

        // Contar evaluaciones en esta semana
        final weekEvaluations = evaluations.where((e) {
          return !e.isCompleted &&
              e.dueDate.isAfter(weekStart) &&
              e.dueDate.isBefore(weekEnd);
        }).toList();

        // Si hay 3 o más evaluaciones, es una semana crítica
        if (weekEvaluations.length >= 3) {
          // Obtener nombres de cursos únicos
          final courseIds = weekEvaluations.map((e) => e.courseId).toSet();
          final courseNames = courseIds
              .map((id) => courses.firstWhere((c) => c.id == id).code)
              .toList();

          await _notificationService.scheduleCriticalWeekNotification(
            weekStart: weekStart,
            evaluationCount: weekEvaluations.length,
            courseNames: courseNames,
          );
        }
      }
    } catch (_) {
      // No bloquear flujos principales
    }
  }

  /// Obtener el inicio de la semana (lunes)
  DateTime _getStartOfWeek(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: weekday - 1));
  }

  /// Actualizar todas las notificaciones inteligentes
  Future<void> updateAllSmartNotifications() async {
    await scheduleDailySummary();
    await checkAndScheduleCriticalWeeks();
  }
}
