# Classio - Planificador Académico Universitario

Aplicación móvil offline-first para gestionar tu vida académica universitaria. Sin login, sin backend, 100% privado y almacenado localmente.

## Características

### Funcionalidades Principales
- Gestión de cursos con colores personalizados
- Horario de clases semanal con vista de cuadrícula y lista
- Sistema de evaluaciones (exámenes, tareas, proyectos)
- Calculadora de notas y promedios por curso
- Dashboard con vista del día actual
- Detección de semanas críticas con alta carga académica

### Características Técnicas
- Almacenamiento local con Hive (NoSQL)
- Arquitectura limpia con separación de capas
- Gestión de estado con Riverpod
- Material Design 3
- Soporte para modo claro y oscuro
- Animaciones fluidas
- Notificaciones locales
- Fuente Inter de Google Fonts
- Iconos premium (Iconsax, Phosphor)

## Requisitos

- Flutter 3.0 o superior
- Dart 3.0 o superior

## Instalación

```bash
# Clonar el repositorio
git clone https://github.com/tu-usuario/classio_app.git

# Navegar al directorio
cd classio_app

# Instalar dependencias
flutter pub get

# Ejecutar la aplicación
flutter run
```

## Stack Tecnológico

### Framework y Lenguaje
- Flutter 3.0+
- Dart 3.0+

### Gestión de Estado
- flutter_riverpod 2.5.1

### Almacenamiento Local
- hive 2.2.3
- hive_flutter 1.1.0

### UI y Animaciones
- google_fonts 6.2.1
- animate_do 3.3.4
- flutter_animate 4.5.0
- shimmer 3.0.0
- flutter_staggered_animations 1.1.1
- flutter_slidable 3.1.0
- flutter_speed_dial 7.0.0
- badges 3.1.2

### Visualización de Datos
- table_calendar 3.1.2
- fl_chart 0.68.0
- syncfusion_flutter_charts 26.2.14

### Notificaciones
- flutter_local_notifications 17.2.3
- timezone 0.9.4

### Iconos
- iconsax 0.0.8
- phosphor_flutter 2.1.0

### Utilidades
- uuid 4.5.1
- equatable 2.0.5
- intl 0.19.0

## Estructura del Proyecto

```
lib/
├── core/
│   ├── constants/      # Constantes de la aplicación
│   └── theme/          # Temas, colores y estilos
├── data/
│   ├── local/          # Servicio de Hive
│   ├── models/         # Modelos de datos con Hive
│   └── repositories/   # Repositorios para acceso a datos
├── presentation/
│   ├── providers/      # Providers de Riverpod
│   └── screens/        # Pantallas de la aplicación
│       ├── courses/    # Gestión de cursos
│       ├── evaluations/# Gestión de evaluaciones
│       ├── grades/     # Gestión de notas
│       ├── home/       # Dashboard principal
│       └── schedule/   # Horario de clases
└── main.dart           # Punto de entrada
```

## Arquitectura

El proyecto sigue una arquitectura limpia con tres capas principales:

1. Presentación: UI y lógica de presentación con Riverpod
2. Datos: Modelos, repositorios y almacenamiento local
3. Core: Constantes, temas y utilidades compartidas

## Modelos de Datos

- CourseModel: Información de cursos (nombre, código, color, créditos)
- ClassScheduleModel: Horario de clases (día, hora, ubicación)
- EvaluationModel: Evaluaciones (tipo, fecha, peso, estado)
- GradeModel: Notas obtenidas en evaluaciones
- UserSettingsModel: Configuración del usuario


## Autor

Desarrollado para estudiantes universitarios que buscan organizar su vida académica de forma simple y privada.
