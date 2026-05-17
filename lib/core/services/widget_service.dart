import '../../data/models/evaluation_model.dart';
import '../../data/models/class_schedule_model.dart';

/// Servicio para gestionar widgets de pantalla de inicio
///
/// NOTA: Funcionalidad de widget deshabilitada.
class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  /// Actualizar widget (deshabilitado)
  Future<void> updateWidget({
    ClassSchedule? currentClass,
    ClassSchedule? nextClass,
    Evaluation? nextEvaluation,
    String? currentCourseCode,
    String? nextCourseCode,
    String? evaluationCourseCode,
  }) async {
    // Widget functionality disabled
    return;
  }

  /// Limpiar datos del widget (deshabilitado)
  Future<void> clearWidget() async {
    // Widget functionality disabled
    return;
  }

  /// Configurar callback para tap en widget (deshabilitado)
  Future<void> setupInteractivity() async {
    // Widget functionality disabled
    return;
  }
}
