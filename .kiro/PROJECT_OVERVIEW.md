# Classio App - Planificador Académico Universitario

## 🎯 Objetivo
App móvil offline-first para estudiantes universitarios que permite:
- Organizar horarios de clases
- Gestionar exámenes, tareas y proyectos
- Evaluar situación académica por curso
- Visibilidad rápida desde widget

**Sin login ni backend - 100% local**

## 🧱 Stack Técnico
- **Framework**: Flutter
- **Almacenamiento**: Hive o SQLite
- **Estado**: Riverpod / Provider
- **Notificaciones**: flutter_local_notifications
- **Calendario**: table_calendar
- **Gráficos**: fl_chart
- **Plataformas**: Android, iOS, Web

## 📊 Alcance del MVP

### Pantallas Principales (4)
1. Home - "Hoy"
2. Calendario de Clases
3. Calendario de Evaluaciones
4. Gestión de Cursos

### Features Inteligentes
- 🚨 Modo Semana Crítica
- 🧠 Prioridad Inteligente
- 🧩 Checklist en Proyectos
- 📊 Calculadora de Notas por Curso
- 📈 Estadísticas y Gráficos
- 📱 Widget de pantalla de inicio
- ⏰ Recordatorios locales

## 🗂️ Estructura de Carpetas Propuesta

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   ├── theme/
│   └── utils/
├── data/
│   ├── models/
│   ├── repositories/
│   └── local/
├── domain/
│   ├── entities/
│   └── usecases/
├── presentation/
│   ├── screens/
│   ├── widgets/
│   └── providers/
└── services/
    ├── notifications/
    ├── storage/
    └── analytics/
```

## 📅 Fases de Desarrollo

### Fase 1: Fundamentos (Semana 1-2)
- Setup del proyecto
- Modelos de datos
- Almacenamiento local
- Navegación básica

### Fase 2: Pantallas Core (Semana 3-4)
- Gestión de Cursos
- Calendario de Clases
- Home básico

### Fase 3: Evaluaciones (Semana 5-6)
- Calendario de Evaluaciones
- CRUD completo
- Filtros y búsqueda

### Fase 4: Features Inteligentes (Semana 7-8)
- Semana Crítica
- Prioridad Inteligente
- Calculadora de Notas

### Fase 5: Visualización (Semana 9-10)
- Estadísticas
- Gráficos
- Dashboard mejorado

### Fase 6: Extras (Semana 11-12)
- Widget
- Notificaciones
- Pulido UI/UX
