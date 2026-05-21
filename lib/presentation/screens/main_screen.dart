import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import 'home/home_screen.dart';
import 'schedule/schedule_screen.dart';
import 'evaluations/evaluations_screen.dart';
import 'courses/courses_screen.dart';
import 'grades/grades_screen.dart';

class MainScreen extends StatefulWidget {
  final bool showTutorial;

  const MainScreen({super.key, this.showTutorial = false});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  TutorialCoachMark? tutorialCoachMark;

  // GlobalKeys para el tutorial de navegación
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _scheduleKey = GlobalKey();
  final GlobalKey _evaluationsKey = GlobalKey();
  final GlobalKey _gradesKey = GlobalKey();
  final GlobalKey _coursesKey = GlobalKey();

  final List<Widget> _screens = const [
    HomeScreen(),
    ScheduleScreen(),
    EvaluationsScreen(),
    GradesScreen(),
    CoursesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.showTutorial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _showTutorial();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Iconsax.home, key: _homeKey),
              activeIcon: Icon(Iconsax.home_15, key: _homeKey),
              label: AppStrings.navHome,
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.calendar, key: _scheduleKey),
              activeIcon: Icon(Iconsax.calendar_15, key: _scheduleKey),
              label: AppStrings.navSchedule,
            ),
            BottomNavigationBarItem(
                icon: Icon(Iconsax.task_square, key: _evaluationsKey),
                activeIcon: Icon(Iconsax.task_square5, key: _evaluationsKey),
                label: AppStrings.navEvaluations),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.chart, key: _gradesKey),
              activeIcon: Icon(Iconsax.chart5, key: _gradesKey),
              label: 'Notas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.book, key: _coursesKey),
              activeIcon: Icon(Iconsax.book_1, key: _coursesKey),
              label: AppStrings.navCourses,
            ),
          ],
        ),
      ),
    );
  }

  void _showTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: AppColors.primary,
      paddingFocus: 10,
      opacityShadow: 0.8,
      alignSkip: Alignment.topRight,
      onFinish: () {},
      onSkip: () => true,
    );
    tutorialCoachMark!.show(context: context);
  }

  List<TargetFocus> _createTargets() {
    return [
      // PASO 1: Bienvenida
      TargetFocus(
        identify: "welcome",
        keyTarget: _homeKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialContent(
                context,
                controller,
                title: "Bienvenido a Classio",
                description:
                    "Te voy a mostrar cómo funciona la aplicación. Este tour te llevará por todas las funcionalidades principales.",
              );
            },
          ),
        ],
      ),

      // PASO 2: Inicio
      TargetFocus(
        identify: "home-tab",
        keyTarget: _homeKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialContent(
                context,
                controller,
                title: "Pantalla de Inicio",
                description:
                    "Esta es tu pantalla principal. Aquí verás un resumen de tu día: evaluaciones pendientes, próximas clases y estadísticas.",
                onNext: () {
                  setState(() => _currentIndex = 1);
                  Future.delayed(const Duration(milliseconds: 300), () {
                    controller.next();
                  });
                },
              );
            },
          ),
        ],
      ),

      // PASO 3: Horario
      TargetFocus(
        identify: "schedule-tab",
        keyTarget: _scheduleKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialContent(
                context,
                controller,
                title: "Horario de Clases",
                description:
                    "Aquí gestionas tu horario semanal. Agrega tus clases con día, hora, aula y profesor. Vista de cuadrícula o lista.",
                onNext: () {
                  setState(() => _currentIndex = 2);
                  Future.delayed(const Duration(milliseconds: 300), () {
                    controller.next();
                  });
                },
              );
            },
          ),
        ],
      ),

      // PASO 4: Evaluaciones (UN SOLO PASO)
      TargetFocus(
        identify: "evaluations-tab",
        keyTarget: _evaluationsKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialContent(
                context,
                controller,
                title: "Evaluaciones",
                description:
                    "Sección más importante. Gestiona exámenes, tareas y proyectos. Organízalas por fecha, prioridad y tipo. El calendario muestra semanas críticas en rojo. Usa los filtros para buscar evaluaciones específicas.",
                onNext: () {
                  setState(() => _currentIndex = 3);
                  Future.delayed(const Duration(milliseconds: 300), () {
                    controller.next();
                  });
                },
              );
            },
          ),
        ],
      ),

      // PASO 5: Notas (UN SOLO PASO)
      TargetFocus(
        identify: "grades-tab",
        keyTarget: _gradesKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialContent(
                context,
                controller,
                title: "Gestión de Notas",
                description:
                    "Registra y calcula tus notas. La app calcula automáticamente tu promedio ponderado. Usa los chips para cambiar entre cursos. Incluye calculadora para saber qué nota necesitas.",
                onNext: () {
                  setState(() => _currentIndex = 4);
                  Future.delayed(const Duration(milliseconds: 300), () {
                    controller.next();
                  });
                },
              );
            },
          ),
        ],
      ),

      // PASO 6: Cursos (UN SOLO PASO)
      TargetFocus(
        identify: "courses-tab",
        keyTarget: _coursesKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialContent(
                context,
                controller,
                title: "Gestión de Cursos",
                description:
                    "Los cursos son la base. Crea y gestiona tus cursos del semestre. Cada tarjeta muestra código, nombre, color y créditos. Usa la búsqueda para encontrar cursos rápidamente.",
                onNext: () {
                  setState(() => _currentIndex = 0);
                  Future.delayed(const Duration(milliseconds: 300), () {
                    controller.next();
                  });
                },
              );
            },
          ),
        ],
      ),

      // PASO 7: Navegación
      TargetFocus(
        identify: "back-home",
        keyTarget: _homeKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialContent(
                context,
                controller,
                title: "Navegación",
                description:
                    "Usa esta barra para moverte entre secciones. Acceso rápido a cualquier parte de la app.",
              );
            },
          ),
        ],
      ),

      // PASO 8: Final
      TargetFocus(
        identify: "finish",
        keyTarget: _homeKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialContent(
                context,
                controller,
                title: "¡Listo para Comenzar!",
                description:
                    "Ya conoces las funcionalidades principales. Comienza agregando tus cursos, luego tu horario y finalmente tus evaluaciones.",
                isLast: true,
              );
            },
          ),
        ],
      ),
    ];
  }

  Widget _buildTutorialContent(
    BuildContext context,
    TutorialCoachMarkController controller, {
    required String title,
    required String description,
    VoidCallback? onNext,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                if (onNext != null) {
                  onNext();
                } else {
                  controller.next();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(isLast ? "¡Entendido!" : "Siguiente"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    tutorialCoachMark?.finish();
    super.dispose();
  }
}
