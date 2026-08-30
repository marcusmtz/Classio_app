import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/navigation/app_navigator.dart';
import 'data/local/hive_service.dart';
import 'core/services/notification_service.dart';
import 'presentation/providers/app_settings_provider.dart';
import 'presentation/providers/smart_notifications_provider.dart';
import 'data/models/app_settings_model.dart' as models;
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/onboarding/welcome_screen.dart';
import 'presentation/screens/onboarding/intro_slides_screen.dart';

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

class ClassioApp extends ConsumerStatefulWidget {
  const ClassioApp({super.key});

  @override
  ConsumerState<ClassioApp> createState() => _ClassioAppState();
}

class _ClassioAppState extends ConsumerState<ClassioApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Agregar observer para detectar cambios en el ciclo de vida de la app
    WidgetsBinding.instance.addObserver(this);

    // Inicializar notificaciones inteligentes y deep-link después de que el widget esté montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSmartNotifications();
      _setupNotificationDeepLink();
    });
  }

  @override
  void dispose() {
    // Remover observer al destruir el widget
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Detectar cuando la app pasa a segundo plano o se pausa
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Ocultar contenido sensible cuando la app se minimiza o el dispositivo se bloquea
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    } else if (state == AppLifecycleState.resumed) {
      // Restaurar UI cuando la app vuelve al frente
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    }
  }

  Future<void> _initializeSmartNotifications() async {
    try {
      final smartNotifications = ref.read(smartNotificationsServiceProvider);
      await smartNotifications.updateAllSmartNotifications();
    } catch (_) {
      // No bloquear la app si falla la inicialización de notificaciones
    }
  }

  void _setupNotificationDeepLink() {
    final notificationService = NotificationService();
    // Clicks en foreground/background
    notificationService.onNotificationClick.listen((payload) {
      if (!mounted) return;
      AppNavigator.handleNotificationPayload(payload);
    });
    // Click que abrió la app desde terminated
    Future.delayed(const Duration(milliseconds: 800), () async {
      final initialPayload = await notificationService.getInitialPayload();
      if (initialPayload != null && mounted) {
        await AppNavigator.handleNotificationPayload(initialPayload);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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

    // Determinar la pantalla inicial
    Widget homeScreen;
    if (settings.userName == null || settings.userName!.trim().isEmpty) {
      // Usuario nuevo - mostrar pantalla de bienvenida
      homeScreen = const WelcomeScreen();
    } else if (!settings.hasSeenTour) {
      // Usuario con nombre pero sin tour - mostrar intro slides
      homeScreen = const IntroSlidesScreen();
    } else {
      // Usuario completo - ir directo a la app
      homeScreen = const MainScreen();
    }

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      navigatorKey: AppNavigator.navigatorKey,
      home: homeScreen,
    );
  }
}
