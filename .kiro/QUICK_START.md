# Guía de Inicio Rápido

## 🚀 Comenzar el Desarrollo

### 1. Setup Inicial
```bash
# Instalar dependencias
flutter pub get

# Generar código
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Orden de Implementación Recomendado

#### Semana 1-2: Fundamentos
1. Crear modelos de datos en `lib/data/models/`
2. Agregar TypeAdapters de Hive
3. Implementar repositorios en `lib/data/repositories/`
4. Setup de navegación básica

#### Semana 3-4: Primera Pantalla Funcional
1. Pantalla de Gestión de Cursos
2. CRUD completo de cursos
3. Almacenamiento local funcionando

#### Semana 5-6: Calendario de Clases
1. Vista horario semanal
2. Crear/editar clases
3. Detección de clase actual

#### Semana 7-8: Evaluaciones
1. Calendario de evaluaciones
2. CRUD de evaluaciones
3. Prioridad inteligente

#### Semana 9-10: Features Avanzadas
1. Semana crítica
2. Calculadora de notas
3. Checklist de proyectos

#### Semana 11-12: Pulido
1. Estadísticas y gráficos
2. Notificaciones
3. Widget (opcional)

---

## 📁 Archivos Clave para Empezar

### 1. main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Registrar adapters
  Hive.registerAdapter(CourseAdapter());
  Hive.registerAdapter(ClassScheduleAdapter());
  
  runApp(ProviderScope(child: MyApp()));
}
```

### 2. Primer Modelo: Course
```dart
@HiveType(typeId: 0)
class Course extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final int colorValue;
  
  Course({required this.id, required this.name, required this.colorValue});
}
```

### 3. Primer Repository
```dart
class CourseRepository {
  Box<Course> get _box => Hive.box<Course>('courses');
  
  List<Course> getAll() => _box.values.toList();
  
  Future<void> add(Course course) => _box.put(course.id, course);
}
```

---

## 🎯 Hitos del MVP

- [ ] **Hito 1**: CRUD de cursos funcionando
- [ ] **Hito 2**: Horario semanal visible
- [ ] **Hito 3**: Crear y listar evaluaciones
- [ ] **Hito 4**: Prioridad inteligente activa
- [ ] **Hito 5**: Calculadora de notas funcionando
- [ ] **Hito 6**: Home con datos reales

---

## 💡 Tips de Desarrollo

1. **Usa hot reload**: Aprovecha el hot reload de Flutter
2. **Genera código frecuentemente**: `build_runner watch`
3. **Testea en dispositivo real**: Especialmente notificaciones
4. **Commits pequeños**: Commit después de cada feature
5. **UI primero, lógica después**: Mockea datos al inicio
