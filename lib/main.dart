import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'data/local/hive_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/widget_service.dart';
import 'presentation/providers/app_settings_provider.dart';
import 'data/models/app_settings_model.dart' as models;
import 'presentation/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive
  await HiveService.init();

  // Inicializar locale español para intl
  await initializeDateFormatting('es', null);

  // Inicializar servicio de notificaciones
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  // Inicializar widget service
  final widgetService = WidgetService();
  await widgetService.setupInteractivity();

  // Configurar orientación
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurar barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: ClassioApp()));
}

class ClassioApp extends ConsumerWidget {
  const ClassioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    material.ThemeMode themeMode;
    switch (settings.themeMode) {
      case models.ThemeMode.light:
        themeMode = material.ThemeMode.light;
        break;
      case models.ThemeMode.dark:
        themeMode = material.ThemeMode.dark;
        break;
      case models.ThemeMode.system:
        themeMode = material.ThemeMode.system;
        break;
    }

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const MainScreen(),
    );
  }
}
