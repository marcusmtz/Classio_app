# Roadmap tecnico - Classio

Documento de trabajo para ejecutar mejoras del proyecto por fases. Cada fase y tarea se puede marcar conforme avance la implementacion.

## Objetivos

- Mejorar confiabilidad funcional (evitar crashes y estados inconsistentes).
- Asegurar integridad de datos locales (Hive) ante operaciones CRUD.
- Fortalecer arquitectura y testabilidad sin frenar entregas.
- Reducir deuda tecnica y preparar base para nuevas funcionalidades.

## Fase 1 - Estabilizacion critica (alta prioridad)

Meta: eliminar riesgos de fallo y de corrupcion logica de datos en flujos actuales.

Estado de fase: [ ] Pendiente  [ ] En progreso  [x] Completada

### Checklist

- [x] Implementar borrado en cascada al eliminar curso (horarios, evaluaciones, notas, notificaciones).
- [x] Evitar datos huerfanos en UI y providers despues de eliminaciones.
- [x] Reemplazar `firstWhere` sin fallback en rutas criticas.
- [x] Definir degradacion segura cuando falte el curso relacionado.
- [x] Corregir logica de `getNextClass` para domingo y transicion semanal.
- [x] Validar casos edge de calendario y horario.
- [x] Evitar programaciones invalidas de notificaciones con datos incompletos.
- [x] Mantener idempotencia al reprogramar notificaciones por actualizacion.

### Archivos foco

- `lib/presentation/providers/courses_provider.dart`
- `lib/presentation/providers/evaluations_provider.dart`
- `lib/presentation/providers/schedule_provider.dart`
- `lib/presentation/providers/grades_provider.dart`
- `lib/presentation/screens/evaluations/widgets/evaluation_card.dart`
- `lib/presentation/screens/evaluations/evaluation_detail_screen.dart`
- `lib/core/services/notification_service.dart`
- `lib/data/repositories/*.dart`

### Criterios de salida

- [x] Sin crashes en flujos principales (cursos, evaluaciones, horario, notas).
- [x] Eliminar curso no deja datos huerfanos.
- [x] Proxima clase se calcula correctamente para toda la semana.

## Fase 2 - Endurecimiento funcional y coherencia de producto (prioridad media)

Meta: alinear funcionalidades visibles con configuraciones y cerrar features incompletas de mayor impacto.

Estado de fase: [ ] Pendiente  [ ] En progreso  [x] Completada

### Checklist

- [x] Conectar `notificationsEnabled` para habilitar/deshabilitar programacion real.
- [x] Definir comportamiento funcional de `widgetEnabled` (feature deshabilitada hoy).
- [x] Definir alcance de `language` (activar localizacion real o dejar backlog explicito).
- [x] Implementar detalle de curso (actualmente TODO).
- [x] Implementar estrategia de exportacion de datos (JSON local o compartir archivo).
- [x] Implementar limpieza de datos real con confirmaciones seguras.
- [x] Normalizar manejo de errores en formularios y acciones async.
- [x] Evitar mostrar excepciones crudas al usuario final.

### Archivos foco

- `lib/presentation/providers/app_settings_provider.dart`
- `lib/data/repositories/app_settings_repository.dart`
- `lib/core/services/notification_service.dart`
- `lib/presentation/screens/settings/settings_screen.dart`
- `lib/presentation/screens/courses/courses_screen.dart`
- `lib/data/local/hive_service.dart`
- `lib/presentation/screens/**`
- `lib/presentation/providers/**`

### Criterios de salida

- [x] Configuraciones de usuario con efecto real y verificable.
- [x] Sin placeholders criticos en ajustes clave.
- [x] Mensajeria de errores consistente en toda la app.

## Fase 3 - Arquitectura y testabilidad (prioridad media/alta)

Meta: mejorar mantenibilidad a largo plazo con bajo riesgo de regresion.

Estado de fase: [ ] Pendiente  [ ] En progreso  [x] Completada

### Checklist

- [x] Crear `lib/domain/usecases/` y mover logica de negocio clave a casos de uso.
- [x] Extraer calculo de prioridad a caso de uso.
- [x] Extraer deteccion de semana critica a caso de uso.
- [x] Extraer calculo de promedios y nota minima a caso de uso.
- [x] Extraer validaciones de horario a caso de uso.
- [x] Crear interfaces de repositorio en `lib/domain/repositories/`.
- [x] Adaptar `lib/data/repositories/` como implementaciones concretas.
- [x] Remover `print()` de runtime y usar estrategia de logging controlada.
- [x] Endurecer reglas en `analysis_options.yaml`.
- [x] Limpiar dependencias no usadas en `pubspec.yaml`.

### Archivos foco

- `lib/domain/usecases/`
- `lib/domain/repositories/`
- `lib/data/repositories/`
- `analysis_options.yaml`
- `pubspec.yaml`
- `lib/**`

### Criterios de salida

- [x] Reglas de negocio concentradas y testeables.
- [x] Capa de presentacion mas delgada.
- [x] Menor acoplamiento con almacenamiento concreto.

## Fase 4 - Calidad continua y release readiness (prioridad sostenida)

Meta: establecer base de calidad para releases estables y escalables.

Estado de fase: [ ] Pendiente  [x] En progreso  [ ] Completada

### Checklist

- [x] Crear tests unitarios para use cases y repositorios.
- [x] Crear tests de providers (Riverpod) para estados clave.
- [x] Crear widget tests de pantallas criticas.
- [x] Definir y ejecutar pipeline local minimo de verificacion.
- [x] Ejecutar `flutter analyze` sin errores bloqueantes.
- [x] Ejecutar `flutter test` con resultados estables.
- [ ] Ejecutar build objetivo (`flutter build apk --debug` o plataforma destino).
- [x] Revalidar migraciones Hive/typeId antes de release.
- [x] Verificar permisos de notificaciones por plataforma.
- [ ] Probar escenarios sin datos, con datos parciales y con alta carga.

### Rutas sugeridas

- `test/unit/`
- `test/providers/`
- `test/widgets/`

### Criterios de salida

- [ ] Cobertura base en componentes criticos.
- [ ] Releases repetibles con checklist y verificacion minima.

Nota: el build debug de APK queda pendiente por decision explicita de validarlo directamente en dispositivo fisico.

## Orden recomendado de ejecucion

1. Fase 1 (obligatoria antes de nuevas features grandes).
2. Fase 2 (cierre funcional y coherencia de producto).
3. Fase 3 (arquitectura y mantenibilidad).
4. Fase 4 (calidad continua y preparacion de release).

## Notas de implementacion

- Priorizar cambios pequenos por PR para reducir riesgo.
- Mantener compatibilidad con datos actuales en Hive.
- Evitar refactors masivos en una sola iteracion.
- Medir impacto de cada fase con criterios de salida concretos.
