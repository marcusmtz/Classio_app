# 🎨 Guía Rápida: Generar Ícono de Classio

## Paso 1: Preparar tus Imágenes

Necesitas crear 2 imágenes PNG:

### 1. app_icon.png
- Tamaño: **1024x1024 px**
- Contenido: Logo completo de Classio
- Puede tener fondo de color o transparente

### 2. app_icon_foreground.png
- Tamaño: **1024x1024 px**
- Contenido: Solo el logo (sin fondo)
- **Debe tener fondo transparente**
- Para Android adaptive icons

## Paso 2: Colocar las Imágenes

Guarda ambas imágenes en:
```
assets/icon/
├── app_icon.png
└── app_icon_foreground.png
```

## Paso 3: Instalar Dependencias

```bash
flutter pub get
```

## Paso 4: Generar los Íconos

```bash
flutter pub run flutter_launcher_icons
```

Este comando generará automáticamente todos los tamaños necesarios para Android e iOS.

## Paso 5: Probar

```bash
# Desinstala la app anterior (para ver el nuevo ícono)
flutter clean

# Instala con el nuevo ícono
flutter run
```

---

## 🎨 Herramientas Recomendadas para Crear el Ícono

### Opción 1: Canva (Más Fácil)
1. Ve a https://www.canva.com
2. Crea diseño personalizado: 1024x1024 px
3. Diseña tu logo
4. Descarga como PNG

### Opción 2: Figma (Profesional)
1. Crea frame de 1024x1024 px
2. Diseña
3. Exporta como PNG

### Opción 3: Generadores Online
- https://appicon.co/ - Genera todos los tamaños
- https://icon.kitchen/ - Herramienta de Google
- https://makeappicon.com/ - Muy simple

### Opción 4: IA
- DALL-E: "Create a minimalist app icon for an academic planner app called Classio"
- Midjourney: "/imagine app icon, academic planner, book, calendar, modern, flat design"

---

## 💡 Ideas de Diseño para Classio

### Concepto 1: Libro + Calendario
```
┌─────────────┐
│   📚 📅    │
│   Classio   │
└─────────────┘
```

### Concepto 2: Letra C Estilizada
```
┌─────────────┐
│             │
│      C      │  <- Con elementos académicos
│             │
└─────────────┘
```

### Concepto 3: Cuaderno Moderno
```
┌─────────────┐
│   ┌─────┐   │
│   │ ✓   │   │  <- Cuaderno con check
│   └─────┘   │
└─────────────┘
```

---

## 🎨 Paleta de Colores de Classio

Usa estos colores para mantener consistencia:

- **Primario**: `#6366F1` (Azul/Índigo)
- **Secundario**: `#8B5CF6` (Morado)
- **Acento**: `#10B981` (Verde)
- **Fondo**: `#FFFFFF` (Blanco)

---

## ⚠️ Errores Comunes

### Error: "Image not found"
- Verifica que las imágenes estén en `assets/icon/`
- Verifica que los nombres sean exactos (con minúsculas)

### Error: "Invalid image format"
- Asegúrate de que sean PNG
- Verifica que el tamaño sea 1024x1024 px

### El ícono no cambia en el dispositivo
- Desinstala completamente la app
- Ejecuta `flutter clean`
- Vuelve a instalar con `flutter run`

---

## 📱 Verificar el Resultado

Después de generar, verifica:

✅ Android:
- `android/app/src/main/res/mipmap-*/ic_launcher.png`

✅ iOS:
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

---

## 🚀 Comando Todo-en-Uno

```bash
# Ejecuta todo de una vez
flutter pub get && flutter pub run flutter_launcher_icons && flutter clean && flutter run
```

---

## 📞 ¿Necesitas Ayuda?

Si no tienes experiencia en diseño:
1. Usa Canva con plantillas gratuitas
2. Contrata en Fiverr (desde $5)
3. Usa generadores de IA (DALL-E, Midjourney)
4. Busca íconos base en Flaticon o Icons8

**Recuerda**: Un buen ícono es simple, reconocible y se ve bien en tamaños pequeños.
