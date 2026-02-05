# Modelos de Datos

## 📚 Curso (Course)

```dart
class Course {
  String id;
  String name;
  Color color;
  DateTime createdAt;
  DateTime? updatedAt;
  bool isActive;
}
```

**Campos:**
- `id`: UUID único
- `name`: Nombre del curso (ej: "Cálculo II")
- `color`: Color identificador (hex)
- `createdAt`: Fecha de creación
- `updatedAt`: Última modificación
- `isActive`: Si está activo o archivado

---

## 📅 Clase (ClassSchedule)

```dart
class ClassSchedule {
  String id;
  String courseId;
  DayOfWeek dayOfWeek;
  TimeOfDay startTime;
  TimeOfDay endTime;
  String? location;
  String? professor;
  bool isRecurrent;
}
```

**Campos:**
- `id`: UUID único
- `courseId`: Referencia al curso
- `dayOfWeek`: Día de la semana (enum: Monday-Sunday)
- `startTime`: Hora de inicio
- `endTime`: Hora de fin
- `location`: Aula/salón (opcional)
- `professor`: Nombre del profesor (opcional)
- `isRecurrent`: Si se repite semanalmente

---

## 📝 Evaluación (Evaluation)

```dart
enum EvaluationType {
  exam,      // Examen
  task,      // Tarea
  project    // Proyecto
}

enum Priority {
  low,
  medium,
  high,
  critical
}

class Evaluation {
  String id;
  String courseId;
  String title;
  String? description;
  EvaluationType type;
  DateTime dueDate;
  Priority priority;
  bool isCompleted;
  DateTime? completedAt;
  List<Subtask>? subtasks; // Solo para proyectos
  DateTime createdAt;
}
```

**Campos:**
- `id`: UUID único
- `courseId`: Referencia al curso
- `title`: Título de la evaluación
- `description`: Detalles adicionales
- `type`: Tipo de evaluación
- `dueDate`: Fecha de entrega/examen
- `priority`: Prioridad (auto-calculada o manual)
- `isCompleted`: Estado de completitud
- `completedAt`: Cuándo se marcó como completa
- `subtasks`: Lista de subtareas (solo proyectos)

---

## ✅ Subtarea (Subtask)

```dart
class Subtask {
  String id;
  String title;
  bool isCompleted;
  int order;
}
```

**Campos:**
- `id`: UUID único
- `title`: Descripción de la subtarea
- `isCompleted`: Si está completada
- `order`: Orden de visualización

---

## 📊 Nota de Evaluación (Grade)

```dart
enum GradeType {
  partial,   // Parcial
  final,     // Final
  practice,  // Práctica
  other      // Otro
}

class Grade {
  String id;
  String courseId;
  String name;
  GradeType type;
  double score;        // Nota obtenida
  double weight;       // Peso en % (0-100)
  DateTime date;
  DateTime createdAt;
}
```

**Campos:**
- `id`: UUID único
- `courseId`: Referencia al curso
- `name`: Nombre de la evaluación (ej: "Parcial 1")
- `type`: Tipo de evaluación
- `score`: Nota obtenida (0-20 o escala configurada)
- `weight`: Peso porcentual en la nota final
- `date`: Fecha de la evaluación

---

## 📈 Resumen Académico (CourseGradeSummary)

**Calculado dinámicamente, no almacenado:**

```dart
class CourseGradeSummary {
  String courseId;
  double currentAverage;
  double totalWeightUsed;
  double remainingWeight;
  double? minimumNeededToPass;
  String status; // "passing", "at_risk", "failing"
}
```

---

## 🚨 Semana Crítica (CriticalWeek)

**Calculado dinámicamente:**

```dart
class CriticalWeek {
  DateTime weekStart;
  int examCount;
  int taskCount;
  int projectCount;
  bool isCritical;
  String message;
}
```

**Criterios:**
- ≥ 3 exámenes en la semana
- ≥ 5 entregas totales
- ≥ 2 proyectos

---

## 🔔 Recordatorio (Reminder)

```dart
enum ReminderType {
  oneDayBefore,
  sameDay,
  custom
}

class Reminder {
  String id;
  String evaluationId;
  ReminderType type;
  DateTime scheduledTime;
  bool isTriggered;
}
```

---

## ⚙️ Configuración de Usuario (UserSettings)

```dart
class UserSettings {
  int criticalWeekThreshold;  // Número de evaluaciones para semana crítica
  bool enableNotifications;
  TimeOfDay defaultReminderTime;
  double passingGrade;        // Nota mínima para aprobar (ej: 10.5)
  String gradeScale;          // "0-20" o "0-100"
}
```
