# Ignorar Digital Turbine Ignite
-dontwarn com.digitalturbine.**
-keep class !com.digitalturbine.** { *; }

# Mantener clases de la app
-keep class com.example.classio_app.** { *; }
-keep class io.flutter.** { *; }
-keep class androidx.** { *; }
