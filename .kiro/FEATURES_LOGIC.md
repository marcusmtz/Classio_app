# Lógica de Features Inteligentes

## 🚨 Modo Semana Crítica

### Objetivo
Alertar al estudiante cuando tiene una semana con alta carga académica.

### Criterios de Detección

Una semana es "crítica" si cumple **al menos uno**:
- ≥ 3 exámenes
- ≥ 5 entregas totales (exámenes + tareas + proyectos)
- ≥ 2 proyectos con fecha de entrega

### Cálculo

```dart
bool isCriticalWeek(DateTime weekStart) {
  final weekEnd = weekStart.add(Duration(days: 7));
  final evaluations = getEvaluationsInRange(weekStart, weekEnd);
  
  final exams = evaluations.where((e) => e.type == EvaluationType.exam).length;
  final projects = evaluations.where((e) => e.type == EvaluationType.project).length;
  final total = evaluations.length;
  
  return exams >= 3 || total >= 5 || projects >= 2;
}
```

### Visualización

#### En Home
- Badge rojo en el header: "Semana Crítica 😵‍💫"
- Mensaje: "Tienes X entregas esta semana"
- Botón: "Ver detalles"

#### En Calendario
- Días de la semana crítica con fondo destacado
- Indicador visual en la vista mensual

### Mensajes Dinámicos
- "Esta semana es pesada 😵‍💫"
- "Tienes 3 exámenes esta semana 📚"
- "5 entregas pendientes - organízate 💪"

---

## 🧠 Prioridad Inteligente

### Objetivo
Sugerir automáticamente la prioridad de una evaluación basándose en criterios objetivos.

### Factores de Cálculo

#### 1. Tipo de Evaluación (Peso: 40%)
- Examen: +3 puntos
- Proyecto: +2 puntos
- Tarea: +1 punto

#### 2. Días Restantes (Peso: 40%)
- 0-1 días: +3 puntos (CRÍTICO)
- 2-3 días: +2 puntos (ALTO)
- 4-7 días: +1 punto (MEDIO)
- >7 días: +0 puntos (BAJO)

#### 3. Carga de la Semana (Peso: 20%)
- Semana crítica: +1 punto
- Semana normal: +0 puntos

### Algoritmo

```dart
Priority calculatePriority(Evaluation evaluation) {
  int score = 0;
  
  // Factor 1: Tipo
  switch (evaluation.type) {
    case EvaluationType.exam:
      score += 3;
      break;
    case EvaluationType.project:
      score += 2;
      break;
    case EvaluationType.task:
      score += 1;
      break;
  }
  
  // Factor 2: Días restantes
  final daysLeft = evaluation.dueDate.difference(DateTime.now()).inDays;
  if (daysLeft <= 1) {
    score += 3;
  } else if (daysLeft <= 3) {
    score += 2;
  } else if (daysLeft <= 7) {
    score += 1;
  }
  
  // Factor 3: Semana crítica
  if (isCriticalWeek(evaluation.dueDate)) {
    score += 1;
  }
  
  // Mapeo a prioridad
  if (score >= 6) return Priority.critical;
  if (score >= 4) return Priority.high;
  if (score >= 2) return Priority.medium;
  return Priority.low;
}
```

### UX

#### Al Crear Evaluación
- Mostrar sugerencia: "Prioridad sugerida: Alta 🔴"
- Permitir override manual
- Explicación breve: "Basado en tipo y fecha"

#### Actualización Automática
- Recalcular prioridad diariamente
- Si cambia, notificar al usuario (opcional)

#### Visualización
- Critical: 🔴 Rojo
- High: 🟠 Naranja
- Medium: 🟡 Amarillo
- Low: 🟢 Verde

---

## 🧩 Checklist en Proyectos

### Objetivo
Permitir desglosar proyectos grandes en subtareas manejables.

### Funcionalidad

#### Crear Subtareas
- Solo disponible para tipo "Proyecto"
- Agregar múltiples subtareas
- Cada subtarea tiene:
  - Título
  - Estado (completada/pendiente)
  - Orden

#### Progreso Visual
- Barra de progreso: "3/5 completadas"
- Porcentaje: "60%"
- Icono de check cuando todas están completas

#### Lógica de Completitud

```dart
bool isProjectComplete(Evaluation project) {
  if (project.subtasks == null || project.subtasks.isEmpty) {
    return project.isCompleted;
  }
  
  return project.subtasks.every((subtask) => subtask.isCompleted);
}

double getProjectProgress(Evaluation project) {
  if (project.subtasks == null || project.subtasks.isEmpty) {
    return project.isCompleted ? 1.0 : 0.0;
  }
  
  final completed = project.subtasks.where((s) => s.isCompleted).length;
  return completed / project.subtasks.length;
}
```

#### Auto-completar Proyecto
- Cuando todas las subtareas están completas
- Sugerir marcar el proyecto como completo
- Confirmación del usuario

---

## 📊 Calculadora de Notas por Curso

### Objetivo
Calcular promedio actual y nota mínima necesaria para aprobar.

### Cálculos

#### 1. Promedio Actual

```dart
double calculateCurrentAverage(List<Grade> grades) {
  if (grades.isEmpty) return 0.0;
  
  double weightedSum = 0.0;
  double totalWeight = 0.0;
  
  for (var grade in grades) {
    weightedSum += grade.score * (grade.weight / 100);
    totalWeight += grade.weight;
  }
  
  if (totalWeight == 0) return 0.0;
  
  return (weightedSum / totalWeight) * 100;
}
```

#### 2. Nota Mínima Necesaria

```dart
double? calculateMinimumNeeded(
  List<Grade> grades,
  double passingGrade,
) {
  final totalWeight = grades.fold(0.0, (sum, g) => sum + g.weight);
  final remainingWeight = 100 - totalWeight;
  
  if (remainingWeight <= 0) return null; // Ya no hay más evaluaciones
  
  final currentWeightedSum = grades.fold(
    0.0,
    (sum, g) => sum + (g.score * g.weight / 100),
  );
  
  final neededWeightedSum = passingGrade - currentWeightedSum;
  final minimumNeeded = (neededWeightedSum / remainingWeight) * 100;
  
  return minimumNeeded;
}
```

#### 3. Estado del Curso

```dart
String getCourseStatus(
  double currentAverage,
  double? minimumNeeded,
  double passingGrade,
) {
  if (currentAverage >= passingGrade) {
    return "passing"; // "¡Vas bien! 💪"
  }
  
  if (minimumNeeded == null) {
    return "failing"; // "No alcanzaste la nota mínima"
  }
  
  if (minimumNeeded > 20) {
    return "failing"; // "Ya no es posible aprobar"
  }
  
  if (minimumNeeded > 15) {
    return "at_risk"; // "Necesitas un gran esfuerzo"
  }
  
  return "recoverable"; // "Aún puedes aprobar"
}
```

### Mensajes Dinámicos

```dart
String getMotivationalMessage(CourseGradeSummary summary) {
  switch (summary.status) {
    case "passing":
      return "¡Vas excelente! 💪 Sigue así";
    case "recoverable":
      return "Aún puedes aprobar. Necesitas ≥ ${summary.minimumNeededToPass?.toStringAsFixed(1)} en el final";
    case "at_risk":
      return "Situación complicada. Necesitas ≥ ${summary.minimumNeededToPass?.toStringAsFixed(1)} 📚";
    case "failing":
      return "No es posible aprobar con las evaluaciones restantes";
    default:
      return "Registra tus notas para ver tu progreso";
  }
}
```

---

## 📈 Estadísticas y Gráficos

### Métricas Calculadas

#### 1. Tasa de Completitud
```dart
double getCompletionRate() {
  final total = evaluations.length;
  final completed = evaluations.where((e) => e.isCompleted).length;
  return total > 0 ? completed / total : 0.0;
}
```

#### 2. Carga por Curso
```dart
Map<String, int> getLoadByCourse() {
  final Map<String, int> load = {};
  for (var eval in evaluations.where((e) => !e.isCompleted)) {
    load[eval.courseId] = (load[eval.courseId] ?? 0) + 1;
  }
  return load;
}
```

#### 3. Distribución por Tipo
```dart
Map<EvaluationType, int> getDistributionByType() {
  final Map<EvaluationType, int> distribution = {};
  for (var eval in evaluations) {
    distribution[eval.type] = (distribution[eval.type] ?? 0) + 1;
  }
  return distribution;
}
```

#### 4. Semanas Críticas del Mes
```dart
List<DateTime> getCriticalWeeksInMonth(DateTime month) {
  final List<DateTime> criticalWeeks = [];
  DateTime weekStart = month.startOfMonth.startOfWeek;
  
  while (weekStart.isBefore(month.endOfMonth)) {
    if (isCriticalWeek(weekStart)) {
      criticalWeeks.add(weekStart);
    }
    weekStart = weekStart.add(Duration(days: 7));
  }
  
  return criticalWeeks;
}
```

---

## ⏰ Sistema de Recordatorios

### Tipos de Recordatorios

#### 1. Un Día Antes
- Hora: 20:00 del día anterior
- Mensaje: "Mañana tienes: [Título] - [Curso]"

#### 2. Mismo Día
- Hora: 08:00 del mismo día
- Mensaje: "Hoy tienes: [Título] - [Curso] a las [Hora]"

#### 3. Personalizado
- Usuario elige fecha y hora
- Mensaje personalizable

### Programación

```dart
void scheduleReminder(Evaluation evaluation, ReminderType type) {
  DateTime scheduledTime;
  
  switch (type) {
    case ReminderType.oneDayBefore:
      scheduledTime = evaluation.dueDate
          .subtract(Duration(days: 1))
          .copyWith(hour: 20, minute: 0);
      break;
    case ReminderType.sameDay:
      scheduledTime = evaluation.dueDate
          .copyWith(hour: 8, minute: 0);
      break;
    case ReminderType.custom:
      // Usuario define
      break;
  }
  
  // Usar flutter_local_notifications
  notificationService.schedule(
    id: evaluation.id.hashCode,
    title: getNotificationTitle(evaluation),
    body: getNotificationBody(evaluation),
    scheduledTime: scheduledTime,
  );
}
```

### Cancelación Automática
- Al marcar evaluación como completada
- Al eliminar evaluación
- Al editar fecha (reprogramar)
