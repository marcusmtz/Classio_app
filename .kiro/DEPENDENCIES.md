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

  # Estado
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

  # Almacenamiento local
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # UI Components
  table_calendar: ^3.0.9
  fl_chart: ^0.65.0
  intl: ^0.18.1

  # Notificaciones
  flutter_local_notifications: ^16.3.0
  timezone: ^0.9.2

  # Utilidades
  uuid: ^4.2.2
  equatable: ^2.0.5

  # Iconos
  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

  # Code generation
  build_runner: ^2.4.7
  hive_generator: ^2.0.1
  riverpod_generator: ^2.3.0

flutter:
  uses-material-design: true
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
