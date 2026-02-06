# Plan de Implementación - Tareas Detalladas

## 🏗️ Fase 1: Setup y Fundamentos (Semana 1-2) ✅ COMPLETADA

### 1.1 Configuración Inicial
- [x] Crear proyecto Flutter
- [x] Configurar pubspec.yaml con dependencias
- [x] Setup de carpetas (arquitectura limpia)
- [x] Configurar análisis estático (analysis_options.yaml)

### 1.2 Dependencias Principales
```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  table_calendar: ^3.1.2
  fl_chart: ^0.68.0
  flutter_local_notifications: ^17.2.3
  uuid: ^4.5.1
  intl: ^0.19.0
  + animate_do, flutter_animate, shimmer, google_fonts, iconsax, etc.
```

### 1.3 Modelos de Datos
- [x] Crear modelo Course
- [x] Crear modelo ClassSchedule
- [x] Crear modelo Evaluation
- [x] Crear modelo Subtask
- [x] Crear modelo Grade
- [x] Crear modelo UserSettings
- [x] Agregar TypeAdapters para Hive

### 1.4 Almacenamiento Local
- [x] Inicializar Hive
- [x] Crear boxes para cada modelo
- [x] Implementar Repository pattern
- [x] CRUD básico para cada entidad

### 1.5 Navegación
- [x] Setup de rutas
- [x] Bottom navigation bar
- [x] Navegación entre pantallas principales

---

## 🎨 Fase 2: Pantallas Core (Semana 3-4) ✅ COMPLETADA

### 2.1 Gestión de Cursos
- [x] Pantalla lista de cursos
- [x] Formulario crear curso
- [x] Formulario editar curso
- [x] Eliminar curso (con confirmación)
- [x] Selector de color (palette)
- [x] Validaciones de formulario

### 2.2 Calendario de Clases
- [x] Vista horario semanal (grid)
- [x] Renderizar bloques de clases
- [x] Detectar clase actual
- [x] Formulario crear clase
- [x] Formulario editar clase
- [x] Validación de solapamiento
- [x] Vista lista de clases
- [x] Filtro por curso

### 2.3 Home - "Hoy"
- [x] Layout básico
- [x] Card clase actual/próxima
- [x] Card próxima evaluación
- [x] Resumen del día
- [x] Navegación a otras pantallas

---

## 📝 Fase 3: Evaluaciones (Semana 5-6) ✅ COMPLETADA

### 3.1 Calendario de Evaluaciones
- [x] Integrar table_calendar
- [x] Mostrar badges en días con evaluaciones
- [x] Vista lista cronológica
- [x] Card de evaluación
- [x] Agrupar por fecha

### 3.2 CRUD de Evaluaciones
- [x] Formulario crear evaluación
- [x] Selector de tipo
- [x] Date/time picker
- [x] Formulario editar evaluación
- [x] Eliminar evaluación
- [x] Marcar como completada

### 3.3 Filtros y Búsqueda ✅
- [x] Filtro por curso
- [x] Filtro por tipo
- [x] Filtro por estado
- [x] Filtro por prioridad

---

## 🧠 Fase 4: Features Inteligentes (Semana 7-8) ⚠️ EN PROGRESO

### 4.1 Prioridad Inteligente ✅
- [x] Algoritmo de cálculo de prioridad
- [x] Auto-asignar al crear evaluación
- [x] Mostrar sugerencia en UI
- [x] Permitir override manual
- [ ] Actualización diaria automática

### 4.2 Semana Crítica ✅
- [x] Algoritmo de detección
- [x] Indicador en Home
- [x] Badge en calendario
- [x] Mensajes dinámicos
- [x] Vista de detalles

### 4.3 Checklist en Proyectos ✅
- [x] UI para agregar subtareas
- [x] Marcar subtareas como completadas
- [x] Barra de progreso
- [x] Auto-completar proyecto
- [ ] Reordenar subtareas

### 4.4 Calculadora de Notas ✅
- [x] Pantalla de notas por curso
- [x] Formulario agregar nota
- [x] Cálculo de promedio actual
- [x] Cálculo de nota mínima necesaria
- [x] Resumen académico con mensajes
- [x] Validación de pesos (no exceder 100%)

---

## 📊 Fase 5: Visualización (Semana 9-10) ✅ COMPLETADA

### 5.1 Pantalla de Estadísticas ✅
- [x] Layout de estadísticas
- [x] Resumen general (cards)
- [x] Integrar fl_chart

### 5.2 Gráficos ✅
- [x] Gráfico: Carga por curso (barras)
- [x] Gráfico: Entregas del mes (línea)
- [x] Gráfico: Distribución por tipo (torta)
- [ ] Calendario de calor (opcional)

### 5.3 Dashboard Mejorado ✅
- [x] Mejorar UI de Home
- [x] Animaciones sutiles
- [x] Indicadores visuales mejorados

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
