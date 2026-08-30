import 'package:flutter/material.dart';
import '../../data/local/hive_service.dart';
import '../../data/models/evaluation_model.dart';
import '../../presentation/screens/evaluations/evaluation_detail_screen.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> handleNotificationPayload(String? payload) async {
    if (payload == null || payload.isEmpty) return;
    // Solo soportamos evaluación: payload es evaluationId directo o con prefijo eval:
    String evalId = payload;
    if (payload.startsWith('eval:')) {
      evalId = payload.substring(5);
    } else if (payload.startsWith('class_') || payload.startsWith('critical_week') || payload == 'daily_summary') {
      // No deep-link para estos tipos según decisión
      return;
    }
    // Intentar obtener evaluación desde Hive directamente (sincrónico)
    Evaluation? evaluation;
    try {
      evaluation = HiveService.evaluationsBoxInstance.get(evalId);
    } catch (_) {
      evaluation = null;
    }
    if (evaluation == null) return;
    final context = navigatorKey.currentContext;
    if (context == null) return;
    // Evitar empujar si ya está montado duplicado: simplemente push
    await navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => EvaluationDetailScreen(evaluation: evaluation!),
      ),
    );
  }
}
