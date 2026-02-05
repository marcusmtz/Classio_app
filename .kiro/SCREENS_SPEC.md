# Especificación de Pantallas

## 1️⃣ Home - "Hoy"

### Objetivo
Vista rápida del día actual con información relevante.

### Componentes

#### Header
- Fecha actual: "Jueves, 5 de Febrero"
- Indicador de Semana Crítica (si aplica)
  - Badge rojo: "Semana Crítica 😵‍💫"
  - Contador: "5 entregas esta semana"

#### Clase Actual/Próxima
- Card destacado con:
  - Nombre del curso
  - Hora: "10:00 - 12:00"
  - Ubicación (si existe)
  - Estado: "En curso" / "Próxima en 30 min"
  - Color del curso como acento

#### Próxima Evaluación
- Card con:
  - Título de la evaluación
  - Tipo (icono): 📝 Tarea / 📚 Examen / 🎯 Proyecto
  - Curso
  - Fecha y tiempo restante: "Mañana" / "En 3 días"
  - Prioridad (color de borde)

#### Resumen del Día
- Número de clases restantes
- Evaluaciones pendientes hoy
- Botón: "Ver calendario completo"

### Acciones
- Tap en clase → Ver horario semanal
- Tap en evaluación → Ver detalle
- Tap en semana crítica → Ver lista de evaluaciones

---

## 2️⃣ Calendario de Clases

### Objetivo
Visualizar y gestionar el horario semanal de clases.

### Vista Principal: Horario Semanal

#### Layout
- Grid de 7 columnas (Lun-Dom)
- Filas por hora (ej: 7:00 - 22:00)
- Bloques de clases con:
  - Color del curso
  - Nombre del curso
  - Hora
  - Ubicación (si existe)

#### Indicadores
- Clase actual: borde pulsante o highlight
- Día actual: columna destacada

### Vista: Lista de Clases
- Agrupadas por día
- Ordenadas por hora
- Swipe para editar/eliminar

### Formulario: Crear/Editar Clase

**Campos:**
- Curso (selector)
- Día de la semana
- Hora de inicio
- Hora de fin
- Ubicación (opcional)
- Profesor (opcional)
- Recurrente (toggle)

**Validaciones:**
- Hora fin > Hora inicio
- No solapamiento con otras clases

### Acciones
- FAB: Agregar clase
- Tap en clase: Ver/Editar
- Long press: Menú rápido (Editar/Eliminar)
- Filtro por curso

---

## 3️⃣ Calendario de Evaluaciones

### Objetivo
Planificar y hacer seguimiento de exámenes, tareas y proyectos.

### Vista: Calendario Mensual

#### Componentes
- Calendario con `table_calendar`
- Días con evaluaciones: badges de colores
  - Rojo: Examen
  - Azul: Tarea
  - Verde: Proyecto
- Múltiples evaluaciones: número en badge

#### Interacción
- Tap en día: Ver evaluaciones de ese día
- Días críticos: fondo destacado

### Vista: Lista Cronológica

#### Agrupación
- Por fecha: "Hoy", "Mañana", "Esta semana", "Próximas"
- Separadores visuales

#### Card de Evaluación
- Título
- Curso (con color)
- Tipo (icono)
- Fecha y hora
- Prioridad (indicador visual)
- Estado: Pendiente / Completada
- Progreso (si es proyecto con subtareas)

### Formulario: Crear/Editar Evaluación

**Campos básicos:**
- Título
- Curso (selector)
- Tipo (Examen/Tarea/Proyecto)
- Fecha y hora
- Descripción (opcional)

**Prioridad:**
- Auto-calculada (mostrar sugerencia)
- Opción de override manual

**Si es Proyecto:**
- Sección de subtareas
- Agregar/eliminar subtareas
- Reordenar

**Recordatorios:**
- Toggle: Recordar
- Opciones: 1 día antes / Mismo día / Personalizado

### Filtros
- Por curso
- Por tipo
- Por estado (Pendiente/Completada)
- Por prioridad

### Acciones
- FAB: Nueva evaluación
- Checkbox: Marcar como completada
- Swipe: Editar/Eliminar
- Tap: Ver detalle

---

## 4️⃣ Gestión de Cursos

### Objetivo
CRUD de cursos - base de toda la app.

### Vista: Lista de Cursos

#### Card de Curso
- Nombre
- Color (círculo o barra lateral)
- Estadísticas rápidas:
  - Clases por semana
  - Evaluaciones pendientes
  - Promedio actual (si hay notas)

#### Estados
- Activos (por defecto)
- Archivados (toggle para ver)

### Formulario: Crear/Editar Curso

**Campos:**
- Nombre del curso
- Selector de color (palette predefinida)

**Validaciones:**
- Nombre no vacío
- Nombre único

### Sección: Notas del Curso

#### Vista de Notas
- Lista de evaluaciones registradas
- Cada item muestra:
  - Nombre
  - Tipo
  - Nota obtenida
  - Peso (%)
  - Fecha

#### Resumen Académico (Card destacado)
- Promedio actual: **15.5**
- Peso usado: 60%
- Peso restante: 40%
- Nota mínima necesaria: **12.0**
- Mensaje motivacional:
  - "¡Vas bien! 💪"
  - "Necesitas mejorar en el final"
  - "Aún puedes aprobar"

#### Formulario: Agregar Nota
- Nombre de la evaluación
- Tipo (Parcial/Final/Práctica/Otro)
- Nota obtenida (0-20 o escala configurada)
- Peso (%) - validar que no exceda 100%
- Fecha

### Acciones
- FAB: Nuevo curso
- Tap en curso: Ver detalle y notas
- Editar curso
- Archivar curso
- Eliminar curso (con confirmación)

---

## 📊 Pantalla Extra: Estadísticas

### Objetivo
Visualización de datos académicos.

### Secciones

#### 1. Resumen General
- Total de cursos activos
- Evaluaciones completadas vs pendientes
- Semanas críticas en el mes

#### 2. Gráfico: Carga por Curso
- Gráfico de barras
- Eje X: Cursos
- Eje Y: Número de evaluaciones pendientes

#### 3. Gráfico: Entregas del Mes
- Gráfico de línea o barras
- Completadas vs Pendientes por semana

#### 4. Distribución por Tipo
- Gráfico de torta
- Exámenes / Tareas / Proyectos

#### 5. Calendario de Calor
- Vista mensual
- Intensidad de color según carga diaria

---

## 📱 Widget de Pantalla de Inicio

### Objetivo
Acceso rápido sin abrir la app.

### Información Mostrada
- Fecha y hora actual
- Clase actual o próxima
  - Nombre del curso
  - Hora
- Próxima evaluación
  - Título
  - Tiempo restante

### Interacción
- Tap en widget: Abrir app en Home
- Tap en clase: Abrir calendario de clases
- Tap en evaluación: Abrir detalle

### Actualización
- Cada 15 minutos
- Al cambiar de clase
- Al completar evaluación
