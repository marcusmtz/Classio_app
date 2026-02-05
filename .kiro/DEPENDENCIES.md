# Dependencias del Proyecto

## 📦 pubspec.yaml Completo

```yaml
name: classio_app
description: Planificador académico universitario offline-first
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Estado y Arquitectura
  flutter_riverpod: ^2.5.1

  # Almacenamiento Local
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # UI Moderna y Animaciones
  animate_do: ^3.3.4
  flutter_animate: ^4.5.0
  shimmer: ^3.0.0
  flutter_staggered_animations: ^1.1.1
  
  # Componentes UI Premium
  google_fonts: ^6.2.1
  flutter_slidable: ^3.1.0
  flutter_speed_dial: ^7.0.0
  badges: ^3.1.2
  
  # Calendario y Gráficos
  table_calendar: ^3.1.2
  fl_chart: ^0.68.0
  syncfusion_flutter_charts: ^26.2.14
  
  # Notificaciones
  flutter_local_notifications: ^17.2.3
  timezone: ^0.9.4

  # Utilidades
  uuid: ^4.5.1
  equatable: ^2.0.5
  intl: ^0.19.0
  
  # Iconos Premium
  cupertino_icons: ^1.0.8
  iconsax: ^0.0.8
  phosphor_flutter: ^2.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.12

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
```

---

## 📚 Descripción de Dependencias

### Estado y Arquitectura
- **flutter_riverpod**: Manejo de estado reactivo
- **riverpod_annotation**: Code generation para providers

### Almacenamiento
- **hive**: Base de datos NoSQL local, rápida y ligera
- **hive_flutter**: Extensiones de Hive para Flutter

### UI y Visualización
- **table_calendar**: Calendario personalizable
- **fl_chart**: Gráficos (barras, líneas, torta)
- **intl**: Internacionalización y formato de fechas

### Notificaciones
- **flutter_local_notifications**: Notificaciones locales
- **timezone**: Manejo de zonas horarias

### Utilidades
- **uuid**: Generación de IDs únicos
- **equatable**: Comparación de objetos

---

## 🔧 Comandos de Instalación

```bash
# Instalar dependencias
flutter pub get

# Generar código (Hive adapters, Riverpod providers)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode para desarrollo
flutter pub run build_runner watch
```

---

## 📱 Configuración de Plataformas

### Android (android/app/build.gradle.kts)
```kotlin
android {
    compileSdk = 34
    
    defaultConfig {
        minSdk = 21
        targetSdk = 34
    }
}
```

### iOS (ios/Podfile)
```ruby
platform :ios, '12.0'
```

---

## 🔔 Permisos Necesarios

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

### iOS (ios/Runner/Info.plist)
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```
