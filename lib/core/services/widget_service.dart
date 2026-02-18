import '../../data/models/evaluation_model.dart';
import '../../data/models/class_schedule_model.dart';

/// Servicio para gestionar widgets de pantalla de inicio
///
/// NOTA: Este servicio está deshabilitado temporalmente.
/// Para habilitar widgets, agrega 'home_widget: ^0.6.0' en pubspec.yaml
/// y descomenta la implementación completa.
class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  /// Actualizar widget con información de clase actual y próxima evaluación
  Future<void> updateWidget({
    ClassSchedule? currentClass,
    ClassSchedule? nextClass,
    Evaluation? nextEvaluation,
    String? currentCourseCode,
    String? nextCourseCode,
    String? evaluationCourseCode,
  }) async {
    // Widget functionality disabled - add home_widget package to enable
    return;
  }

  /// Limpiar datos del widget
  Future<void> clearWidget() async {
    // Widget functionality disabled - add home_widget package to enable
    return;
  }

  /// Configurar callback para tap en widget
  Future<void> setupInteractivity() async {
    // Widget functionality disabled - add home_widget package to enable
    return;
  }
}
