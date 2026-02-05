# Plan de Implementación - Tareas Detalladas

## 🏗️ Fase 1: Setup y Fundamentos (Semana 1-2)

### 1.1 Configuración Inicial
- [ ] Crear proyecto Flutter
- [ ] Configurar pubspec.yaml con dependencias
- [ ] Setup de carpetas (arquitectura limpia)
- [ ] Configurar análisis estático (analysis_options.yaml)

### 1.2 Dependencias Principales
```yaml
dependencies:
  flutter_riverpod: ^2.4.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  table_calendar: ^3.0.9
  fl_chart: ^0.65.0
  flutter_local_notifications: ^16.3.0
  uuid: ^4.2.2
  intl: ^0.18.1
```

### 1.3 Modelos de Datos
- [ ] Crear modelo Course
- [ ] Crear modelo ClassSchedule
- [ ] Crear modelo Evaluation
- [ ] Crear modelo Subtask
- [ ] Crear modelo Grade
- [ ] Crear modelo UserSettings
- [ ] Agregar TypeAdapters para Hive

### 1.4 Almacenamiento Local
- [ ] Inicializar Hive
- [ ] Crear boxes para cada modelo
- [ ] Implementar Repository pattern
- [ ] CRUD básico para cada entidad

### 1.5 Navegación
- [ ] Setup de rutas
- [ ] Bottom navigation bar
- [ ] Navegación entre pantallas principales

---

## 🎨 Fase 2: Pantallas Core (Semana 3-4)

### 2.1 Gestión de Cursos
- [ ] Pantalla lista de cursos
- [ ] Formulario crear curso
- [ ] Formulario editar curso
- [ ] Eliminar curso (con confirmación)
- [ ] Selector de color (palette)
- [ ] Validaciones de formulario

### 2.2 Calendario de Clases
- [ ] Vista horario semanal (grid)
- [ ] Renderizar bloques de clases
- [ ] Detectar clase actual
- [ ] Formulario crear clase
- [ ] Formulario editar clase
- [ ] Validación de solapamiento
- [ ] Vista lista de clases
- [ ] Filtro por curso

### 2.3 Home - "Hoy"
- [ ] Layout básico
- [ ] Card clase actual/próxima
- [ ] Card próxima evaluación
- [ ] Resumen del día
- [ ] Navegación a otras pantallas

---

## 📝 Fase 3: Evaluaciones (Semana 5-6)

### 3.1 Calendario de Evaluaciones
- [ ] Integrar table_calendar
- [ ] Mostrar badges en días con evaluaciones
- [ ] Vista lista cronológica
- [ ] Card de evaluación
- [ ] Agrupar por fecha

### 3.2 CRUD de Evaluaciones
- [ ] Formulario crear evaluación
- [ ] Selector de tipo
- [ ] Date/time picker
- [ ] Formulario editar evaluación
- [ ] Eliminar evaluación
- [ ] Marcar como completada

### 3.3 Filtros y Búsqueda
- [ ] Filtro por curso
- [ ] Filtro por tipo
- [ ] Filtro por estado
- [ ] Filtro por prioridad

---

## 🧠 Fase 4: Features Inteligentes (Semana 7-8)

### 4.1 Prioridad Inteligente
- [ ] Algoritmo de cálculo de prioridad
- [ ] Auto-asignar al crear evaluación
- [ ] Mostrar sugerencia en UI
- [ ] Permitir override manual
- [ ] Actualización diaria automática

### 4.2 Semana Crítica
- [ ] Algoritmo de detección
- [ ] Indicador en Home
- [ ] Badge en calendario
- [ ] Mensajes dinámicos
- [ ] Vista de detalles

### 4.3 Checklist en Proyectos
- [ ] UI para agregar subtareas
- [ ] Marcar subtareas como completadas
- [ ] Barra de progreso
- [ ] Auto-completar proyecto
- [ ] Reordenar subtareas

### 4.4 Calculadora de Notas
- [ ] Pantalla de notas por curso
- [ ] Formulario agregar nota
- [ ] Cálculo de promedio actual
- [ ] Cálculo de nota mínima necesaria
- [ ] Resumen académico con mensajes
- [ ] Validación de pesos (no exceder 100%)

---

## 📊 Fase 5: Visualización (Semana 9-10)

### 5.1 Pantalla de Estadísticas
- [ ] Layout de estadísticas
- [ ] Resumen general (cards)
- [ ] Integrar fl_chart

### 5.2 Gráficos
- [ ] Gráfico: Carga por curso (barras)
- [ ] Gráfico: Entregas del mes (línea)
- [ ] Gráfico: Distribución por tipo (torta)
- [ ] Calendario de calor (opcional)

### 5.3 Dashboard Mejorado
- [ ] Mejorar UI de Home
- [ ] Animaciones sutiles
- [ ] Indicadores visuales mejorados

---

## 🔔 Fase 6: Extras (Semana 11-12)

### 6.1 Notificaciones Locales
- [ ] Setup flutter_local_notifications
- [ ] Programar recordatorios
- [ ] Notificación 1 día antes
- [ ] Notificación mismo día
- [ ] Recordatorio personalizado
- [ ] Cancelar al completar/eliminar

### 6.2 Widget de Pantalla
- [ ] Crear widget Android
- [ ] Crear widget iOS
- [ ] Mostrar clase actual
- [ ] Mostrar próxima evaluación
- [ ] Actualización periódica
- [ ] Tap actions

### 6.3 Pulido UI/UX
- [ ] Tema personalizado
- [ ] Modo oscuro
- [ ] Animaciones
- [ ] Feedback visual
- [ ] Mensajes de error amigables
- [ ] Loading states
- [ ] Empty states

### 6.4 Testing
- [ ] Unit tests para lógica de negocio
- [ ] Widget tests para componentes
- [ ] Tests de integración básicos

---

## 🚀 Fase 7: Lanzamiento

### 7.1 Preparación
- [ ] Iconos de app
- [ ] Splash screen
- [ ] Permisos (notificaciones)
- [ ] Configuración de build

### 7.2 Documentación
- [ ] README con instrucciones
- [ ] Capturas de pantalla
- [ ] Video demo

### 7.3 Deploy
- [ ] Build Android (APK/AAB)
- [ ] Build iOS (IPA)
- [ ] Publicar en stores (opcional)
