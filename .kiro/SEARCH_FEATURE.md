# Funcionalidad de Búsqueda en Cursos

## Implementación Completada

Se ha implementado la funcionalidad de búsqueda en la pantalla de Cursos con las siguientes características:

### Características

1. **Botón de búsqueda en AppBar**
   - Ícono de lupa que activa el modo de búsqueda
   - Cambia a ícono de cerrar (X) cuando está en modo búsqueda

2. **Campo de búsqueda**
   - Aparece en el AppBar al activar la búsqueda
   - Autofocus para comenzar a escribir inmediatamente
   - Placeholder: "Buscar cursos..."

3. **Búsqueda en tiempo real**
   - Filtra mientras escribes
   - Busca en:
     - Nombre del curso
     - Código del curso
   - No distingue entre mayúsculas y minúsculas

4. **Estado sin resultados**
   - Muestra un mensaje amigable cuando no hay coincidencias
   - Ícono de búsqueda con estado vacío
   - Texto: "No se encontraron cursos"
   - Sugerencia: "Intenta con otro término de búsqueda"

5. **Limpieza de búsqueda**
   - Al cerrar la búsqueda, se limpia el campo
   - Vuelve a mostrar todos los cursos

### Uso

1. Presiona el ícono de lupa en la esquina superior derecha
2. Escribe el nombre o código del curso que buscas
3. Los resultados se filtran automáticamente
4. Presiona la X para salir del modo búsqueda

### Código

La implementación convirtió `CoursesScreen` de `ConsumerWidget` a `ConsumerStatefulWidget` para manejar:
- Estado de búsqueda activa/inactiva
- TextEditingController para el campo de búsqueda
- Lista filtrada de cursos
- Lógica de filtrado en tiempo real
