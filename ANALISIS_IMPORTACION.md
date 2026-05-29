# Análisis del Problema de Importación en Classio

## 🔴 Problema Identificado

Al importar datos desde un archivo JSON de respaldo, se presentaban los siguientes problemas:

### 1. **Evaluaciones y Horarios No Visibles**
- ✅ Los cursos sí se importaban y eran visibles
- ❌ Las evaluaciones NO aparecían en la app
- ❌ Los horarios NO aparecían en el calendario
- ❌ Los nombres de cursos perdían la capitalización correcta (ej: "Redes Informáticas II" → "Redes Informáticas ii")

### 2. **Causa Raíz: IDs No Coincidentes**

El problema principal era que el código de importación **generaba nuevos IDs** para los cursos en lugar de preservar los IDs originales del JSON:

```dart
// ❌ CÓDIGO ANTERIOR (INCORRECTO)
for (final course in result.courses) {
  await ref.read(coursesProvider.notifier).addCourse(
    name: course.name,      // ✅ Nombre correcto
    code: course.code,      // ✅ Código correcto
    colorValue: course.colorValue,
    // ❌ PROBLEMA: addCourse() genera un nuevo ID con uuid.v4()
    // El ID original del JSON se pierde
  );
}
```

**Consecuencia:**
1. Curso original en JSON: `id: "4cdb507d-e9c8-46bc-a36d-8af4bb137100"`
2. Curso importado en la app: `id: "nuevo-uuid-generado-123456"`
3. Horarios y evaluaciones siguen referenciando: `courseId: "4cdb507d-e9c8-46bc-a36d-8af4bb137100"`
4. **Resultado:** Horarios y evaluaciones quedan "huérfanos" sin curso asociado → No se muestran

### 3. **Problemas Secundarios**

- **Subtareas perdidas:** Las evaluaciones con subtareas no las importaban
- **Profesor perdido:** El campo `professor` de los horarios no se importaba
- **Timestamps perdidos:** Las fechas originales (createdAt, completedAt) se reemplazaban con fechas nuevas
- **Estado de completado perdido:** Las evaluaciones completadas volvían a estado pendiente

## ✅ Solución Implementada

### Cambio Principal: Usar Repositorios Directamente

En lugar de usar los métodos de los providers (que generan nuevos IDs), ahora se usan directamente los repositorios que **preservan los IDs originales**:

```dart
// ✅ CÓDIGO NUEVO (CORRECTO)
// 2. Importar cursos directamente al repositorio (preservando IDs originales)
final courseRepo = ref.read(courseRepositoryProvider);
for (final course in result.courses) {
  await courseRepo.add(course);  // ✅ Preserva el ID original del objeto Course
}

// 3. Importar horarios directamente al repositorio (preservando IDs originales)
final scheduleRepo = ref.read(scheduleRepositoryProvider);
for (final schedule in result.schedules) {
  await scheduleRepo.add(schedule);  // ✅ Preserva todos los campos originales
}

// 4. Importar evaluaciones directamente al repositorio (preservando IDs originales)
final evaluationRepo = ref.read(evaluationRepositoryProvider);
for (final evaluation in result.evaluations) {
  await evaluationRepo.add(evaluation);  // ✅ Preserva subtareas, estado, etc.
}

// 5. Importar notas directamente al repositorio (preservando IDs originales)
final gradeRepo = ref.read(gradeRepositoryProvider);
for (final grade in result.grades) {
  await gradeRepo.add(grade);  // ✅ Preserva todos los campos
}
```

### Ventajas de Esta Solución

1. ✅ **IDs Preservados:** Los cursos mantienen sus IDs originales
2. ✅ **Relaciones Intactas:** Horarios y evaluaciones siguen referenciando correctamente a sus cursos
3. ✅ **Datos Completos:** Se preservan todos los campos (subtareas, profesor, timestamps, estado)
4. ✅ **Capitalización Correcta:** Los nombres de cursos mantienen su formato original
5. ✅ **Notificaciones Automáticas:** Los providers se actualizan automáticamente vía streams

## 📊 Ejemplo de Flujo Correcto

### JSON de Entrada:
```json
{
  "courses": [
    {
      "id": "b24b1e0b-2aee-4491-abcb-caaea6940f28",
      "name": "Redes Informáticas II",
      "code": "RI_II"
    }
  ],
  "schedule": [
    {
      "id": "123f8ec6-43c6-4d44-9c58-18d296e97cd4",
      "courseId": "b24b1e0b-2aee-4491-abcb-caaea6940f28",  // ← Referencia al curso
      "dayOfWeek": "sunday",
      "startTime": {"hour": 13, "minute": 10}
    }
  ],
  "evaluations": [
    {
      "id": "93807947-2d4e-4df2-8ea8-6a3a43b5bd55",
      "courseId": "b24b1e0b-2aee-4491-abcb-caaea6940f28",  // ← Referencia al curso
      "title": "Prueba conocimiento",
      "isCompleted": true,
      "subtasks": [...]
    }
  ]
}
```

### Resultado Después de Importar:

✅ **Curso:**
- ID: `b24b1e0b-2aee-4491-abcb-caaea6940f28` (preservado)
- Nombre: "Redes Informáticas II" (capitalización correcta)

✅ **Horario:**
- Aparece en el calendario del domingo
- Correctamente asociado al curso "Redes Informáticas II"

✅ **Evaluación:**
- Aparece en la lista de evaluaciones completadas
- Correctamente asociada al curso "Redes Informáticas II"
- Mantiene sus subtareas y estado de completado

## 🔧 Archivos Modificados

- `lib/presentation/screens/settings/settings_screen.dart`
  - Función `_performImport()` modificada para usar repositorios directamente

## 🧪 Cómo Probar

1. Exporta tus datos actuales desde la app
2. Borra todos los datos (o usa una instalación limpia)
3. Importa el JSON exportado
4. Verifica que:
   - ✅ Los cursos aparecen con nombres correctos
   - ✅ Los horarios aparecen en el calendario
   - ✅ Las evaluaciones aparecen en sus listas correspondientes
   - ✅ Las evaluaciones completadas mantienen su estado
   - ✅ Las subtareas se preservan

## 📝 Notas Técnicas

### ¿Por Qué Funcionan los Repositorios?

Los repositorios de Hive usan el patrón:
```dart
await _box.put(course.id, course);
```

Esto significa que la **clave** en Hive es el `id` del objeto, por lo que se preserva el ID original.

En cambio, los providers usan:
```dart
final course = Course(
  id: _uuid.v4(),  // ← Genera un nuevo ID
  name: name,
  // ...
);
```

### Actualización Automática de la UI

Aunque usamos repositorios directamente, los providers se actualizan automáticamente porque:

1. Los repositorios tienen un método `watch()` que retorna un `Stream<BoxEvent>`
2. Los providers se suscriben a este stream en su constructor
3. Cuando se agrega un dato al repositorio, el stream emite un evento
4. El provider recarga los datos automáticamente
5. La UI se actualiza vía Riverpod

```dart
// En el provider
_coursesSubscription = _repository.watch().listen((_) {
  _loadCourses();  // ← Se ejecuta automáticamente al agregar datos
});
```

## ✨ Resultado Final

Ahora la importación funciona correctamente y **todos los datos se preservan exactamente como estaban** en el momento de la exportación, incluyendo:

- ✅ IDs originales
- ✅ Nombres con capitalización correcta
- ✅ Relaciones entre cursos, horarios y evaluaciones
- ✅ Subtareas de evaluaciones
- ✅ Estado de completado
- ✅ Fechas originales
- ✅ Todos los campos opcionales (profesor, descripción, notas, etc.)
