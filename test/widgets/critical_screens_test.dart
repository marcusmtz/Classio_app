import 'package:classio_app/data/models/course_model.dart';
import 'package:classio_app/presentation/providers/critical_week_provider.dart';
import 'package:classio_app/presentation/providers/courses_provider.dart';
import 'package:classio_app/presentation/providers/evaluations_provider.dart';
import 'package:classio_app/presentation/screens/courses/courses_screen.dart';
import 'package:classio_app/presentation/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_ES', null);
  });

  group('Critical screens widgets', () {
    testWidgets('CoursesScreen shows empty state without active courses', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeCoursesProvider.overrideWith((ref) => []),
            filteredActiveCoursesProvider.overrideWith((ref) => []),
          ],
          child: const MaterialApp(home: CoursesScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No tienes cursos registrados'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('CoursesScreen filters course list by search query', (
      tester,
    ) async {
      final courses = [
        Course(
          id: 'c1',
          name: 'Matematicas',
          code: 'MAT101',
          colorValue: Colors.blue.toARGB32(),
          createdAt: DateTime(2026, 1, 10),
        ),
        Course(
          id: 'c2',
          name: 'Historia',
          code: 'HIS201',
          colorValue: Colors.green.toARGB32(),
          createdAt: DateTime(2026, 1, 10),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeCoursesProvider.overrideWith((ref) => courses),
            filteredActiveCoursesProvider.overrideWith((ref) => courses),
          ],
          child: const MaterialApp(home: CoursesScreen()),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Matematicas'), findsOneWidget);
      expect(find.text('Historia'), findsOneWidget);

      await tester.tap(find.byIcon(Iconsax.search_normal));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'mate');
      await tester.pumpAndSettle();

      expect(find.text('Matematicas'), findsOneWidget);
      expect(find.text('Historia'), findsNothing);
    });

    testWidgets('HomeScreen shows critical week banner when provider flags it', (
      tester,
    ) async {
      const criticalInfo = CriticalWeekInfo(
        isCritical: true,
        totalEvaluations: 4,
        examsCount: 2,
        projectsCount: 1,
        tasksCount: 1,
        message: 'Tienes varias entregas en los próximos días.',
        evaluations: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pendingEvaluationsProvider.overrideWith((ref) => []),
            activeCoursesProvider.overrideWith((ref) => []),
            criticalWeekProvider.overrideWith((ref) => criticalInfo),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('¡Semana Crítica!'), findsOneWidget);
      expect(
        find.text('Tienes varias entregas en los próximos días.'),
        findsOneWidget,
      );
      expect(find.text('Resumen de Hoy'), findsOneWidget);
    });
  });
}
