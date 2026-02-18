# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Play Core (para evitar errores de clases faltantes)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Home Widget
-keep class es.antonborri.home_widget.** { *; }
-dontwarn es.antonborri.home_widget.**

# AndroidX
-keep class androidx.** { *; }
-keep interface androidx.** { *; }
-dontwarn androidx.**

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# Hive
-keep class * extends com.hivedb.** { *; }
-keep class * implements com.hivedb.** { *; }

# Riverpod
-keep class * extends com.riverpod.** { *; }

# Notificaciones
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**
