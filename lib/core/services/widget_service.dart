import 'package:home_widget/home_widget.dart';
import '../../data/models/evaluation_model.dart';
import '../../data/models/class_schedule_model.dart';
import 'package:intl/intl.dart';

class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  static const String _widgetName = 'ClassioWidgetProvider';
  static const String _iosWidgetName = 'ClassioWidget';

  /// Actualizar widget con información de clase actual y próxima evaluación
  Future<void> updateWidget({
    ClassSchedule? currentClass,
    ClassSchedule? nextClass,
    Evaluation? nextEvaluation,
    String? currentCourseCode,
    String? nextCourseCode,
    String? evaluationCourseCode,
  }) async {
    try {
      final now = DateTime.now();
      final timeFormat = DateFormat('HH:mm');
      final dateFormat = DateFormat('dd/MM');

      // Datos de clase actual
      if (currentClass != null && currentCourseCode != null) {
        await HomeWidget.saveWidgetData<String>(
          'current_class_course',
          currentCourseCode,
        );
        await HomeWidget.saveWidgetData<String>(
          'current_class_time',
          '${currentClass.startTime.toFormattedString()} - ${currentClass.endTime.toFormattedString()}',
        );
        await HomeWidget.saveWidgetData<String>(
          'current_class_location',
          currentClass.location ?? 'Sin ubicación',
        );
        await HomeWidget.saveWidgetData<bool>('has_current_class', true);
      } else {
        await HomeWidget.saveWidgetData<bool>('has_current_class', false);
      }

      // Datos de próxima clase
      if (nextClass != null && nextCourseCode != null) {
        await HomeWidget.saveWidgetData<String>(
          'next_class_course',
          nextCourseCode,
        );
        await HomeWidget.saveWidgetData<String>(
          'next_class_time',
          nextClass.startTime.toFormattedString(),
        );
        await HomeWidget.saveWidgetData<String>(
          'next_class_day',
          _getDayName(nextClass.dayOfWeek),
        );
        await HomeWidget.saveWidgetData<bool>('has_next_class', true);
      } else {
        await HomeWidget.saveWidgetData<bool>('has_next_class', false);
      }

      // Datos de próxima evaluación
      if (nextEvaluation != null && evaluationCourseCode != null) {
        final daysUntil = nextEvaluation.dueDate.difference(now).inDays;
        String daysText;

        if (daysUntil == 0) {
          daysText = 'HOY';
        } else if (daysUntil == 1) {
          daysText = 'Mañana';
        } else {
          daysText = 'En $daysUntil días';
        }

        await HomeWidget.saveWidgetData<String>(
          'evaluation_course',
          evaluationCourseCode,
        );
        await HomeWidget.saveWidgetData<String>(
          'evaluation_title',
          nextEvaluation.title,
        );
        await HomeWidget.saveWidgetData<String>(
          'evaluation_date',
          dateFormat.format(nextEvaluation.dueDate),
        );
        await HomeWidget.saveWidgetData<String>(
          'evaluation_days',
          daysText,
        );
        await HomeWidget.saveWidgetData<String>(
          'evaluation_type',
          _getEvaluationType(nextEvaluation.type),
        );
        await HomeWidget.saveWidgetData<String>(
          'evaluation_priority',
          _getPriorityLevel(nextEvaluation.priority),
        );
        await HomeWidget.saveWidgetData<bool>('has_evaluation', true);
      } else {
        await HomeWidget.saveWidgetData<bool>('has_evaluation', false);
      }

      // Timestamp de última actualización
      await HomeWidget.saveWidgetData<String>(
        'last_update',
        timeFormat.format(now),
      );

      // Actualizar widget
      await HomeWidget.updateWidget(
        androidName: _widgetName,
        iOSName: _iosWidgetName,
      );
    } catch (e) {
      print('Error updating widget: $e');
    }
  }

  /// Limpiar datos del widget
  Future<void> clearWidget() async {
    try {
      await HomeWidget.saveWidgetData<bool>('has_current_class', false);
      await HomeWidget.saveWidgetData<bool>('has_next_class', false);
      await HomeWidget.saveWidgetData<bool>('has_evaluation', false);

      await HomeWidget.updateWidget(
        androidName: _widgetName,
        iOSName: _iosWidgetName,
      );
    } catch (e) {
      print('Error clearing widget: $e');
    }
  }

  /// Configurar callback para tap en widget
  Future<void> setupInteractivity() async {
    try {
      HomeWidget.setAppGroupId('group.com.classio.app');

      // Registrar callback para cuando se toca el widget
      HomeWidget.widgetClicked.listen((uri) {
        if (uri != null) {
          _handleWidgetClick(uri);
        }
      });
    } catch (e) {
      print('Error setting up widget interactivity: $e');
    }
  }

  /// Manejar click en widget
  void _handleWidgetClick(Uri uri) {
    // TODO: Navegar a la pantalla correspondiente
    print('Widget clicked: ${uri.toString()}');

    // Ejemplos de URIs:
    // classio://schedule - Abrir horario
    // classio://evaluations - Abrir evaluaciones
    // classio://home - Abrir home
  }

  /// Obtener nombre del día
  String _getDayName(DayOfWeek dayOfWeek) {
    switch (dayOfWeek) {
      case DayOfWeek.monday:
        return 'Lunes';
      case DayOfWeek.tuesday:
        return 'Martes';
      case DayOfWeek.wednesday:
        return 'Miércoles';
      case DayOfWeek.thursday:
        return 'Jueves';
      case DayOfWeek.friday:
        return 'Viernes';
      case DayOfWeek.saturday:
        return 'Sábado';
      case DayOfWeek.sunday:
        return 'Domingo';
    }
  }

  /// Obtener tipo de evaluación
  String _getEvaluationType(EvaluationType type) {
    switch (type) {
      case EvaluationType.exam:
        return 'Examen';
      case EvaluationType.task:
        return 'Tarea';
      case EvaluationType.project:
        return 'Proyecto';
    }
  }

  /// Obtener nivel de prioridad
  String _getPriorityLevel(Priority priority) {
    switch (priority) {
      case Priority.critical:
        return 'CRÍTICA';
      case Priority.high:
        return 'ALTA';
      case Priority.medium:
        return 'MEDIA';
      case Priority.low:
        return 'BAJA';
    }
  }
}
