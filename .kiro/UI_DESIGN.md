# Guía de Diseño UI/UX

## 🎨 Paleta de Colores

### Colores Principales
```dart
// Primary
const primaryColor = Color(0xFF6366F1); // Indigo
const primaryLight = Color(0xFF818CF8);
const primaryDark = Color(0xFF4F46E5);

// Secondary
const secondaryColor = Color(0xFF10B981); // Green
const secondaryLight = Color(0xFF34D399);
const secondaryDark = Color(0xFF059669);

// Neutral
const backgroundColor = Color(0xFFF9FAFB);
const surfaceColor = Color(0xFFFFFFFF);
const textPrimary = Color(0xFF111827);
const textSecondary = Color(0xFF6B7280);
```

### Colores de Estado
```dart
// Prioridades
const priorityCritical = Color(0xFFEF4444); // Rojo
const priorityHigh = Color(0xFFF59E0B);     // Naranja
const priorityMedium = Color(0xFFFBBF24);   // Amarillo
const priorityLow = Color(0xFF10B981);      // Verde

// Tipos de Evaluación
const examColor = Color(0xFFEF4444);     // Rojo
const taskColor = Color(0xFF3B82F6);     // Azul
const projectColor = Color(0xFF10B981);  // Verde
```

### Colores para Cursos (Palette)
```dart
const courseColors = [
  Color(0xFFEF4444), // Rojo
  Color(0xFFF59E0B), // Naranja
  Color(0xFFFBBF24), // Amarillo
  Color(0xFF10B981), // Verde
  Color(0xFF3B82F6), // Azul
  Color(0xFF6366F1), // Indigo
  Color(0xFF8B5CF6), // Púrpura
  Color(0xFFEC4899), // Rosa
];
```

---

## 📐 Espaciado y Tamaños

```dart
// Espaciado
const spacing4 = 4.0;
const spacing8 = 8.0;
const spacing12 = 12.0;
const spacing16 = 16.0;
const spacing24 = 24.0;
const spacing32 = 32.0;

// Border Radius
const radiusSmall = 8.0;
const radiusMedium = 12.0;
const radiusLarge = 16.0;

// Tamaños de Iconos
const iconSmall = 16.0;
const iconMedium = 24.0;
const iconLarge = 32.0;
```

---

## 🔤 Tipografía

```dart
// Headings
final headingLarge = TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.bold,
  color: textPrimary,
);

final headingMedium = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: textPrimary,
);

final headingSmall = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: textPrimary,
);

// Body
final bodyLarge = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.normal,
  color: textPrimary,
);

final bodyMedium = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.normal,
  color: textPrimary,
);

// Caption
final caption = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.normal,
  color: textSecondary,
);
```

---

## 🎴 Componentes UI

### Card Estándar
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(radiusMedium),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: // contenido
)
```

### Badge
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: priorityHigh.withOpacity(0.1),
    borderRadius: BorderRadius.circular(radiusSmall),
  ),
  child: Text(
    'Alta',
    style: caption.copyWith(
      color: priorityHigh,
      fontWeight: FontWeight.w600,
    ),
  ),
)
```

### Botón Primario
```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
  ),
  child: Text('Guardar'),
)
```

---

## 📱 Layouts de Pantallas

### Home Screen
```
┌─────────────────────────────┐
│ Header                      │
│ "Jueves, 5 de Febrero"     │
│ [Semana Crítica Badge]     │
├─────────────────────────────┤
│                             │
│ ┌─────────────────────────┐ │
│ │ Clase Actual            │ │
│ │ Cálculo II              │ │
│ │ 10:00 - 12:00           │ │
│ │ Aula 301                │ │
│ └─────────────────────────┘ │
│                             │
│ ┌─────────────────────────┐ │
│ │ Próxima Evaluación      │ │
│ │ 📝 Tarea de Física      │ │
│ │ Mañana a las 23:59      │ │
│ └─────────────────────────┘ │
│                             │
│ Resumen del Día             │
│ • 2 clases restantes        │
│ • 1 evaluación pendiente    │
│                             │
└─────────────────────────────┘
```

### Calendario de Clases
```
┌─────────────────────────────┐
│ Semana del 3 - 9 Feb        │
├──┬──┬──┬──┬──┬──┬──────────┤
│Lu│Ma│Mi│Ju│Vi│Sa│Do        │
├──┴──┴──┴──┴──┴──┴──────────┤
│ 08:00                       │
│ ┌────┐                      │
│ │Cál │                      │
│ └────┘                      │
│ 10:00                       │
│        ┌────┐               │
│        │Fís │               │
│        └────┘               │
│ 12:00                       │
│                             │
└─────────────────────────────┘
```

---

## 🎭 Animaciones

### Transiciones
- Navegación: Slide (300ms)
- Modal: Fade + Scale (250ms)
- Cards: Fade in (200ms)

### Micro-interacciones
- Botones: Scale down al presionar
- Checkboxes: Bounce al marcar
- Swipe actions: Slide reveal

---

## 📊 Iconografía

### Tipos de Evaluación
- 📝 Tarea
- 📚 Examen
- 🎯 Proyecto

### Estados
- ✅ Completado
- ⏰ Pendiente
- 🚨 Crítico
- 💪 Motivacional

### Acciones
- ➕ Agregar
- ✏️ Editar
- 🗑️ Eliminar
- 🔔 Notificación
- 📊 Estadísticas

---

## 🌙 Modo Oscuro

```dart
// Dark Theme Colors
const darkBackground = Color(0xFF111827);
const darkSurface = Color(0xFF1F2937);
const darkTextPrimary = Color(0xFFF9FAFB);
const darkTextSecondary = Color(0xFF9CA3AF);
```

---

## ♿ Accesibilidad

### Contraste
- Texto sobre fondo: mínimo 4.5:1
- Elementos interactivos: mínimo 3:1

### Tamaños Táctiles
- Mínimo: 44x44 dp
- Recomendado: 48x48 dp

### Semántica
- Labels en todos los campos
- Hints descriptivos
- Mensajes de error claros
