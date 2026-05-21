import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../../data/models/evaluation_model.dart' as models;
import '../../data/models/class_schedule_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    if (_initialized) return;

    // Inicializar timezone
    tz.initializeTimeZones();

    // Configuración Android
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Manejar tap en notificación
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Navegar a la evaluación específica
    final payload = response.payload;
    if (payload != null) {
      debugPrint('Notification tapped with payload: $payload');
    }
  }

  /// Solicitar permisos (especialmente para iOS)
  Future<bool> requestPermissions() async {
    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final iosImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    // Android 13+ requiere permiso explícito
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    // iOS siempre requiere permiso
    if (iosImplementation != null) {
      return await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return true;
  }

  /// Programar notificación para evaluación
  Future<void> scheduleEvaluationNotification({
    required models.Evaluation evaluation,
    required String courseCode,
    required String courseName,
  }) async {
    if (!_initialized) await initialize();

    // Cancelar notificaciones previas de esta evaluación
    await cancelEvaluationNotifications(evaluation.id);

    final now = DateTime.now();
    final dueDate = evaluation.dueDate;

    // Notificación 1 día antes (8:00 AM)
    final oneDayBefore = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day - 1,
      8,
      0,
    );

    if (oneDayBefore.isAfter(now)) {
      await _scheduleNotification(
        id: _getNotificationId(evaluation.id, 'day_before'),
        title: '📚 Evaluación mañana',
        body: '$courseCode: ${evaluation.title}',
        scheduledDate: oneDayBefore,
        payload: evaluation.id,
      );
    }

    // Notificación el mismo día (8:00 AM)
    final sameDay = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      8,
      0,
    );

    if (sameDay.isAfter(now)) {
      await _scheduleNotification(
        id: _getNotificationId(evaluation.id, 'same_day'),
        title: '⚠️ Evaluación HOY',
        body: '$courseCode: ${evaluation.title}',
        scheduledDate: sameDay,
        payload: evaluation.id,
      );
    }

    // Notificación 2 horas antes (si la evaluación tiene hora específica)
    if (dueDate.hour > 0) {
      final twoHoursBefore = dueDate.subtract(const Duration(hours: 2));
      if (twoHoursBefore.isAfter(now)) {
        await _scheduleNotification(
          id: _getNotificationId(evaluation.id, 'two_hours'),
          title: '🔔 Evaluación en 2 horas',
          body: '$courseCode: ${evaluation.title}',
          scheduledDate: twoHoursBefore,
          payload: evaluation.id,
        );
      }
    }
  }

  /// Programar notificación personalizada
  Future<void> scheduleCustomNotification({
    required String evaluationId,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_initialized) await initialize();

    await _scheduleNotification(
      id: _getNotificationId(evaluationId, 'custom'),
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: evaluationId,
    );
  }

  /// Método interno para programar notificación
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'evaluations_channel',
      'Evaluaciones',
      channelDescription: 'Recordatorios de evaluaciones y tareas',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Cancelar todas las notificaciones de una evaluación
  Future<void> cancelEvaluationNotifications(String evaluationId) async {
    await _notifications.cancel(_getNotificationId(evaluationId, 'day_before'));
    await _notifications.cancel(_getNotificationId(evaluationId, 'same_day'));
    await _notifications.cancel(_getNotificationId(evaluationId, 'two_hours'));
    await _notifications.cancel(_getNotificationId(evaluationId, 'custom'));
  }

  /// Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Obtener notificaciones pendientes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Generar ID único para notificación
  int _getNotificationId(String evaluationId, String type) {
    // Combinar evaluationId y type para crear un ID único
    final combined = '$evaluationId-$type';
    return combined.hashCode.abs() % 2147483647; // Max int32
  }

  /// Mostrar notificación inmediata (para testing)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test',
      channelDescription: 'Notificaciones de prueba',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
    );
  }

  // ============================================
  // NOTIFICACIONES INTELIGENTES
  // ============================================

  /// Programar notificación de resumen diario (8:00 AM)
  Future<void> scheduleDailySummary({
    required int pendingCount,
    required int todayCount,
    required int overdueCount,
  }) async {
    if (!_initialized) await initialize();

    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 8, 0);

    String body = '';
    if (overdueCount > 0) {
      body = '⚠️ $overdueCount vencidas, $pendingCount pendientes';
    } else if (todayCount > 0) {
      body = '📚 $todayCount evaluaciones hoy, $pendingCount pendientes';
    } else if (pendingCount > 0) {
      body = '✅ $pendingCount evaluaciones pendientes';
    } else {
      body = '🎉 ¡No tienes evaluaciones pendientes!';
    }

    await _scheduleNotification(
      id: 999999, // ID fijo para resumen diario
      title: '🌅 Buenos días - Resumen del día',
      body: body,
      scheduledDate: tomorrow,
      payload: 'daily_summary',
    );
  }

  /// Programar notificación de semana crítica
  Future<void> scheduleCriticalWeekNotification({
    required DateTime weekStart,
    required int evaluationCount,
    required List<String> courseNames,
  }) async {
    if (!_initialized) await initialize();

    final now = DateTime.now();
    // Notificar el domingo anterior a las 6:00 PM
    final notificationDate = weekStart.subtract(const Duration(days: 1));
    final scheduledDate = DateTime(
      notificationDate.year,
      notificationDate.month,
      notificationDate.day,
      18,
      0,
    );

    if (scheduledDate.isAfter(now)) {
      final coursesText = courseNames.take(3).join(', ');
      final moreText = courseNames.length > 3 ? ' y más' : '';

      await _scheduleNotification(
        id: _getNotificationId('critical_week', weekStart.toIso8601String()),
        title: '🔥 Semana Crítica Próxima',
        body:
            '$evaluationCount evaluaciones: $coursesText$moreText. ¡Prepárate!',
        scheduledDate: scheduledDate,
        payload: 'critical_week_${weekStart.toIso8601String()}',
      );
    }
  }

  /// Programar notificación de clase próxima (10 minutos antes)
  Future<void> scheduleClassReminder({
    required ClassSchedule schedule,
    required String courseName,
    required String courseCode,
  }) async {
    if (!_initialized) await initialize();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Calcular el próximo día de la semana
    final targetDayOfWeek = _dayOfWeekToInt(schedule.dayOfWeek);
    final currentDayOfWeek = now.weekday;

    int daysUntilClass = targetDayOfWeek - currentDayOfWeek;
    if (daysUntilClass <= 0) {
      daysUntilClass += 7; // Próxima semana
    }

    final classDate = today.add(Duration(days: daysUntilClass));
    final classDateTime = DateTime(
      classDate.year,
      classDate.month,
      classDate.day,
      schedule.startTime.hour,
      schedule.startTime.minute,
    );

    final reminderTime = classDateTime.subtract(const Duration(minutes: 10));

    if (reminderTime.isAfter(now)) {
      final location =
          schedule.location != null ? ' en ${schedule.location}' : '';

      await _scheduleNotification(
        id: _getNotificationId(schedule.id, 'class_reminder'),
        title: '🎓 Clase en 10 minutos',
        body: '$courseCode: $courseName$location',
        scheduledDate: reminderTime,
        payload: 'class_${schedule.id}',
      );
    }
  }

  /// Programar notificación de nota baja
  Future<void> scheduleGradeAlert({
    required String courseCode,
    required String courseName,
    required double grade,
    required double average,
  }) async {
    if (!_initialized) await initialize();

    // Notificación inmediata para notas bajas
    if (grade < 4.0) {
      await showImmediateNotification(
        title: '📉 Nota Baja Registrada',
        body:
            '$courseCode: ${grade.toStringAsFixed(1)} - Promedio: ${average.toStringAsFixed(2)}',
      );
    }
  }

  /// Programar recordatorio de evaluación próxima (personalizado)
  Future<void> scheduleCustomEvaluationReminder({
    required models.Evaluation evaluation,
    required String courseCode,
    required int hoursBefore,
  }) async {
    if (!_initialized) await initialize();

    final now = DateTime.now();
    final reminderTime =
        evaluation.dueDate.subtract(Duration(hours: hoursBefore));

    if (reminderTime.isAfter(now)) {
      String emoji = '📝';
      switch (evaluation.type) {
        case models.EvaluationType.exam:
          emoji = '📝';
          break;
        case models.EvaluationType.task:
          emoji = '📋';
          break;
        case models.EvaluationType.project:
          emoji = '📁';
          break;
      }

      await _scheduleNotification(
        id: _getNotificationId(evaluation.id, 'custom_$hoursBefore'),
        title: '$emoji Recordatorio: ${evaluation.title}',
        body: '$courseCode - En $hoursBefore horas',
        scheduledDate: reminderTime,
        payload: evaluation.id,
      );
    }
  }

  /// Cancelar notificación de clase
  Future<void> cancelClassReminder(String scheduleId) async {
    await _notifications
        .cancel(_getNotificationId(scheduleId, 'class_reminder'));
  }

  /// Cancelar notificación de semana crítica
  Future<void> cancelCriticalWeekNotification(DateTime weekStart) async {
    await _notifications.cancel(
      _getNotificationId('critical_week', weekStart.toIso8601String()),
    );
  }

  /// Cancelar resumen diario
  Future<void> cancelDailySummary() async {
    await _notifications.cancel(999999);
  }

  /// Convertir DayOfWeek a int (1 = Lunes, 7 = Domingo)
  int _dayOfWeekToInt(DayOfWeek day) {
    switch (day) {
      case DayOfWeek.monday:
        return 1;
      case DayOfWeek.tuesday:
        return 2;
      case DayOfWeek.wednesday:
        return 3;
      case DayOfWeek.thursday:
        return 4;
      case DayOfWeek.friday:
        return 5;
      case DayOfWeek.saturday:
        return 6;
      case DayOfWeek.sunday:
        return 7;
    }
  }
}
