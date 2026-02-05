# Estrategia de Testing

## 🧪 Tipos de Tests

### 1. Unit Tests
Probar lógica de negocio aislada.

**Qué testear:**
- Algoritmo de prioridad inteligente
- Detección de semana crítica
- Cálculo de notas y promedios
- Validaciones de formularios
- Utilidades y extensiones

**Ejemplo:**
```dart
test('Calcula prioridad crítica para examen en 1 día', () {
  final evaluation = Evaluation(
    type: EvaluationType.exam,
    dueDate: DateTime.now().add(Duration(days: 1)),
  );
  
  final priority = CalculatePriorityUseCase().execute(evaluation);
  
  expect(priority, Priority.critical);
});
```

### 2. Widget Tests
Probar componentes UI individuales.

**Qué testear:**
- Renderizado de cards
- Interacciones de usuario
- Estados de loading/error
- Formularios

**Ejemplo:**
```dart
testWidgets('Muestra clase actual correctamente', (tester) async {
  final classSchedule = ClassSchedule(
    courseName: 'Cálculo II',
    startTime: TimeOfDay(hour: 10, minute: 0),
  );
  
  await tester.pumpWidget(
    MaterialApp(
      home: CurrentClassCard(classSchedule: classSchedule),
    ),
  );
  
  expect(find.text('Cálculo II'), findsOneWidget);
  expect(find.text('10:00'), findsOneWidget);
});
```

### 3. Integration Tests
Probar flujos completos.

**Qué testear:**
- Crear curso → Agregar clase → Ver en horario
- Crear evaluación → Marcar completada
- Agregar notas → Ver promedio calculado

---

## 📋 Checklist de Testing

### Prioridad Alta
- [ ] Cálculo de prioridad inteligente
- [ ] Detección de semana crítica
- [ ] Cálculo de promedio de notas
- [ ] Cálculo de nota mínima necesaria
- [ ] Validación de solapamiento de clases

### Prioridad Media
- [ ] CRUD de cursos
- [ ] CRUD de evaluaciones
- [ ] Progreso de proyectos
- [ ] Filtros de evaluaciones

### Prioridad Baja
- [ ] Widgets de UI
- [ ] Animaciones
- [ ] Navegación
