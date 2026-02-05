# Arquitectura del Proyecto

## 🏛️ Patrón Arquitectónico

**Clean Architecture + Feature-First**

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_sizes.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── color_schemes.dart
│   ├── utils/
│   │   ├── date_utils.dart
│   │   ├── validators.dart
│   │   └── extensions.dart
│   └── router/
│       └── app_router.dart
│
├── data/
│   ├── models/
│   │   ├── course_model.dart
│   │   ├── class_schedule_model.dart
│   │   ├── evaluation_model.dart
│   │   ├── grade_model.dart
│   │   └── user_settings_model.dart
│   ├── repositories/
│   │   ├── course_repository.dart
│   │   ├── class_repository.dart
│   │   ├── evaluation_repository.dart
│   │   └── grade_repository.dart
│   └── local/
│       ├── hive_service.dart
│       └── boxes.dart
│
├── domain/
│   ├── entities/
│   │   └── (si necesitas separar de models)
│   └── usecases/
│       ├── calculate_priority.dart
│       ├── detect_critical_week.dart
│       └── calculate_grades.dart
│
├── presentation/
│   ├── screens/
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── current_class_card.dart
│   │   │   │   ├── next_evaluation_card.dart
│   │   │   │   └── critical_week_banner.dart
│   │   │   └── providers/
│   │   │       └── home_provider.dart
│   │   │
│   │   ├── courses/
│   │   │   ├── courses_screen.dart
│   │   │   ├── course_detail_screen.dart
│   │   │   ├── course_form_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── course_card.dart
│   │   │   │   └── color_picker.dart
│   │   │   └── providers/
│   │   │       └── courses_provider.dart
│   │   │
│   │   ├── schedule/
│   │   │   ├── schedule_screen.dart
│   │   │   ├── class_form_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── weekly_schedule_grid.dart
│   │   │   │   └── class_block.dart
│   │   │   └── providers/
│   │   │       └── schedule_provider.dart
│   │   │
│   │   ├── evaluations/
│   │   │   ├── evaluations_screen.dart
│   │   │   ├── evaluation_detail_screen.dart
│   │   │   ├── evaluation_form_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── evaluation_card.dart
│   │   │   │   ├── subtask_list.dart
│   │   │   │   └── priority_indicator.dart
│   │   │   └── providers/
│   │   │       └── evaluations_provider.dart
│   │   │
│   │   ├── grades/
│   │   │   ├── course_grades_screen.dart
│   │   │   ├── grade_form_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── grade_summary_card.dart
│   │   │   │   └── grade_list_item.dart
│   │   │   └── providers/
│   │   │       └── grades_provider.dart
│   │   │
│   │   └── statistics/
│   │       ├── statistics_screen.dart
│   │       ├── widgets/
│   │       │   ├── load_by_course_chart.dart
│   │       │   ├── completion_chart.dart
│   │       │   └── type_distribution_chart.dart
│   │       └── providers/
│   │           └── statistics_provider.dart
│   │
│   ├── widgets/
│   │   ├── common/
│   │   │   ├── custom_button.dart
│   │   │   ├── custom_text_field.dart
│   │   │   ├── loading_indicator.dart
│   │   │   └── empty_state.dart
│   │   └── navigation/
│   │       └── bottom_nav_bar.dart
│   │
│   └── providers/
│       └── app_providers.dart
│
└── services/
    ├── notifications/
    │   └── notification_service.dart
    ├── storage/
    │   └── storage_service.dart
    └── widget/
        └── widget_service.dart
```

---

## 🔄 Flujo de Datos

### Riverpod Providers

```dart
// Provider de repositorio
final courseRepositoryProvider = Provider((ref) {
  return CourseRepository(ref.read(hiveServiceProvider));
});

// Provider de estado
final coursesProvider = StateNotifierProvider<CoursesNotifier, List<Course>>((ref) {
  return CoursesNotifier(ref.read(courseRepositoryProvider));
});

// Provider computado
final activeCourses Provider = Provider((ref) {
  return ref.watch(coursesProvider).where((c) => c.isActive).toList();
});
```

---

## 🗄️ Capa de Datos

### Repository Pattern

```dart
class CourseRepository {
  final HiveService _hiveService;
  
  CourseRepository(this._hiveService);
  
  Future<List<Course>> getAll() async {
    return _hiveService.getBox<Course>('courses').values.toList();
  }
  
  Future<void> add(Course course) async {
    await _hiveService.getBox<Course>('courses').put(course.id, course);
  }
  
  Future<void> update(Course course) async {
    await _hiveService.getBox<Course>('courses').put(course.id, course);
  }
  
  Future<void> delete(String id) async {
    await _hiveService.getBox<Course>('courses').delete(id);
  }
}
```

---

## 🎯 Capa de Dominio

### Use Cases

```dart
class CalculatePriorityUseCase {
  Priority execute(Evaluation evaluation) {
    // Lógica de cálculo de prioridad
    int score = 0;
    
    // Factor 1: Tipo
    score += _getTypeScore(evaluation.type);
    
    // Factor 2: Días restantes
    score += _getDaysScore(evaluation.dueDate);
    
    // Factor 3: Semana crítica
    if (_isCriticalWeek(evaluation.dueDate)) {
      score += 1;
    }
    
    return _mapScoreToPriority(score);
  }
}
```

---

## 🎨 Capa de Presentación

### Screen Structure

```dart
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentClass = ref.watch(currentClassProvider);
    final nextEvaluation = ref.watch(nextEvaluationProvider);
    final isCriticalWeek = ref.watch(criticalWeekProvider);
    
    return Scaffold(
      body: Column(
        children: [
          if (isCriticalWeek) CriticalWeekBanner(),
          CurrentClassCard(classSchedule: currentClass),
          NextEvaluationCard(evaluation: nextEvaluation),
        ],
      ),
    );
  }
}
```

---

## 🔌 Servicios

### Notification Service

```dart
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  
  Future<void> initialize() async {
    // Configuración de notificaciones
  }
  
  Future<void> scheduleReminder(Evaluation evaluation) async {
    // Programar notificación
  }
  
  Future<void> cancelReminder(String evaluationId) async {
    // Cancelar notificación
  }
}
```

---

## 📊 Principios de Diseño

### 1. Separación de Responsabilidades
- **Data**: Manejo de persistencia
- **Domain**: Lógica de negocio
- **Presentation**: UI y estado

### 2. Dependency Injection
- Usar Riverpod para inyección de dependencias
- Providers en lugar de singletons

### 3. Inmutabilidad
- Modelos inmutables con `copyWith`
- Estado inmutable en Riverpod

### 4. Testabilidad
- Repositorios mockeables
- Use cases aislados
- Widgets testables

---

## 🔄 Estado Global vs Local

### Estado Global (Riverpod)
- Lista de cursos
- Lista de evaluaciones
- Configuración de usuario

### Estado Local (StatefulWidget)
- Estado de formularios
- Animaciones
- UI temporal
