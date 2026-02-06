import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../../data/models/evaluation_model.dart' as models;

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
      print('Notification tapped with payload: $payload');
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
}
