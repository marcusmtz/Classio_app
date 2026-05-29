# Mejora del Selector de Cursos en Vista de Notas

## 🎯 Problema Identificado

En la vista de notas, los chips de cursos estaban en una fila horizontal (`ListView.builder` con `scrollDirection: Axis.horizontal`), lo que causaba:

- ❌ Scroll lateral excesivo cuando hay muchos cursos
- ❌ Mala experiencia de usuario al buscar un curso específico
- ❌ No escalable para usuarios con 8+ cursos

## ✅ Solución Implementada

### Sistema Adaptativo Inteligente

La solución implementa **dos modos automáticos** según la cantidad de cursos:

#### 1. **Modo Chips (≤ 6 cursos)** 🎨
Cuando hay **6 cursos o menos**, se muestran chips con `Wrap`:

```dart
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: [chips...]
)
```

**Ventajas:**
- ✅ Los chips se ajustan automáticamente en múltiples filas
- ✅ No requiere scroll horizontal
- ✅ Visual y fácil de usar
- ✅ Muestra todos los cursos a la vez

**Ejemplo visual:**
```
[RI_II] [IG_II] [VST] [GP]
[IA] [AM]
```

#### 2. **Modo Dropdown (> 6 cursos)** 📋
Cuando hay **más de 6 cursos**, se muestra un dropdown:

```dart
DropdownButtonFormField<String>(
  decoration: InputDecoration(
    labelText: 'Curso',
    prefixIcon: [círculo de color]
  ),
  items: [lista de cursos]
)
```

**Ventajas:**
- ✅ Ocupa solo una línea, sin importar cuántos cursos haya
- ✅ Muestra código Y nombre completo del curso
- ✅ Búsqueda nativa en algunos dispositivos
- ✅ Indicador visual del color del curso seleccionado

**Ejemplo visual:**
```
┌─────────────────────────────────────┐
│ ● Curso                        ▼   │
│   RI_II - Redes Informáticas II    │
└─────────────────────────────────────┘
```

Al hacer clic, se despliega:
```
┌─────────────────────────────────────┐
│ ● RI_II - Redes Informáticas II    │
│ ● IG_II - Ingeniería De Software   │
│ ● VST - Virtualización De Servic...│
│ ● GP - Gestión De Procesos         │
│ ● IA - Ingeniería Administrativa   │
│ ● AM - Análisis Multivariado       │
│ ● FORMA_II - Formación Cristiana   │
│ ● PDS - Pruebas Y Despliegue       │
└─────────────────────────────────────┘
```

## 📊 Comparación: Antes vs Después

### Antes (ListView Horizontal)
```
┌─────────────────────────────────────────────────────────────────────┐
│ [RI_II] [IG_II] [VST] [GP] [IA] [AM] [FORMA_II] [PDS] ➡️ scroll... │
└─────────────────────────────────────────────────────────────────────┘
```
- ❌ Requiere scroll horizontal
- ❌ Solo se ven 3-4 cursos a la vez
- ❌ Difícil encontrar un curso específico

### Después (Adaptativo)

**Con 6 cursos o menos:**
```
┌─────────────────────────────────┐
│ [RI_II] [IG_II] [VST]          │
│ [GP] [IA] [AM]                 │
└─────────────────────────────────┘
```
- ✅ Todos visibles sin scroll
- ✅ Fácil de seleccionar

**Con más de 6 cursos:**
```
┌─────────────────────────────────┐
│ ● Curso                    ▼   │
│   RI_II - Redes Informát...    │
└─────────────────────────────────┘
```
- ✅ Compacto (1 línea)
- ✅ Muestra nombre completo
- ✅ Escalable a 100+ cursos

## 🎨 Características Visuales

### Chips (Modo ≤ 6 cursos)
- **Círculo de color** del curso como avatar
- **Código del curso** como etiqueta
- **Estado seleccionado** con fondo destacado
- **Espaciado automático** entre chips

### Dropdown (Modo > 6 cursos)
- **Círculo de color** en el prefixIcon
- **Código + Nombre completo** en cada opción
- **Overflow con ellipsis** para nombres largos
- **Border redondeado** consistente con el diseño

## 🔧 Implementación Técnica

### Lógica de Decisión
```dart
Widget _buildCourseSelector(BuildContext context, List<Course> courses) {
  if (courses.length > 6) {
    return _buildDropdownSelector(context, courses);
  }
  return _buildChipsSelector(context, courses);  // Wrap
}
```

### Ventajas Técnicas
1. **Sin breaking changes:** La API pública no cambia
2. **Automático:** El usuario no necesita configurar nada
3. **Performante:** Wrap es más eficiente que ListView para pocos elementos
4. **Responsive:** Se adapta al ancho de pantalla disponible

## 📱 Experiencia de Usuario

### Escenario 1: Estudiante con 4 cursos
- Ve todos los cursos como chips
- Selección con un solo tap
- Visual y colorido

### Escenario 2: Estudiante con 8 cursos
- Ve un dropdown compacto
- Puede ver código y nombre completo
- Búsqueda fácil en la lista desplegable

### Escenario 3: Estudiante con 15+ cursos
- Dropdown sigue siendo compacto
- Scroll vertical en el menú desplegable (nativo)
- Algunos dispositivos permiten búsqueda por texto

## 🚀 Mejoras Futuras (Opcionales)

Si en el futuro quieres agregar más funcionalidades:

### 1. Búsqueda en Dropdown
```dart
// Agregar un TextField de búsqueda en el dropdown
showDialog(
  context: context,
  builder: (context) => SearchableCourseDialog(
    courses: courses,
    onSelected: (courseId) => setState(() => _selectedCourseId = courseId),
  ),
);
```

### 2. Favoritos
```dart
// Marcar cursos favoritos para mostrarlos primero
courses.sort((a, b) {
  if (a.isFavorite && !b.isFavorite) return -1;
  if (!a.isFavorite && b.isFavorite) return 1;
  return a.name.compareTo(b.name);
});
```

### 3. Umbral Configurable
```dart
// Permitir al usuario elegir cuándo cambiar a dropdown
final threshold = settings.courseSelectorThreshold ?? 6;
if (courses.length > threshold) {
  return _buildDropdownSelector(context, courses);
}
```

## 📝 Archivos Modificados

- `lib/presentation/screens/grades/grades_screen.dart`
  - Método `_buildCourseSelector()` - Ahora con lógica adaptativa
  - Nuevo método `_buildDropdownSelector()` - Para modo dropdown

## ✨ Resultado Final

La vista de notas ahora es:
- ✅ **Escalable** - Funciona con 2 o 20 cursos
- ✅ **Intuitiva** - Chips para pocos, dropdown para muchos
- ✅ **Sin scroll horizontal** - Mejor UX
- ✅ **Automática** - Se adapta sin configuración
- ✅ **Consistente** - Mantiene el diseño de la app

¡La experiencia de usuario mejora significativamente! 🎉
