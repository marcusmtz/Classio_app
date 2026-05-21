import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/app_settings_provider.dart';
import '../main_screen.dart';

class IntroSlidesScreen extends ConsumerStatefulWidget {
  const IntroSlidesScreen({super.key});

  @override
  ConsumerState<IntroSlidesScreen> createState() => _IntroSlidesScreenState();
}

class _IntroSlidesScreenState extends ConsumerState<IntroSlidesScreen> {
  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      key: UniqueKey(),
      listContentConfig: _getSlides(context),
      onDonePress: _onDonePress,
      onSkipPress: _onSkipPress,
      renderSkipBtn: _renderSkipButton(),
      renderNextBtn: _renderNextButton(),
      renderDoneBtn: _renderDoneButton(),

      // Configuración de estilo
      isShowDoneBtn: true,
      isShowSkipBtn: true,
      isShowPrevBtn: false,

      // Configuración del indicador (dots)
      indicatorConfig: const IndicatorConfig(
        colorIndicator: Colors.white38,
        colorActiveIndicator: Colors.white,
        sizeIndicator: 10.0,
        typeIndicatorAnimation: TypeIndicatorAnimation.sliding,
      ),

      // Animaciones
      curveScroll: Curves.easeInOutCubic,
    );
  }

  List<ContentConfig> _getSlides(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return [
      // Slide 1: Bienvenida con diseño moderno
      ContentConfig(
        title: "",
        description: "",
        pathImage: "",
        backgroundColor: const Color(0xFF6366F1),
        widgetTitle: _buildWelcomeSlide(context, size),
      ),

      // Slide 2: Organización
      ContentConfig(
        title: "",
        description: "",
        pathImage: "",
        backgroundColor: const Color(0xFF8B5CF6),
        widgetTitle: _buildOrganizationSlide(context, size),
      ),

      // Slide 3: Notificaciones
      ContentConfig(
        title: "",
        description: "",
        pathImage: "",
        backgroundColor: const Color(0xFFEC4899),
        widgetTitle: _buildNotificationsSlide(context, size),
      ),

      // Slide 4: Estadísticas
      ContentConfig(
        title: "",
        description: "",
        pathImage: "",
        backgroundColor: const Color(0xFF10B981),
        widgetTitle: _buildStatisticsSlide(context, size),
      ),

      // Slide 5: Offline
      ContentConfig(
        title: "",
        description: "",
        pathImage: "",
        backgroundColor: const Color(0xFF3B82F6),
        widgetTitle: _buildOfflineSlide(context, size),
      ),
    ];
  }

  Widget _buildWelcomeSlide(BuildContext context, Size size) {
    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Decorative circles
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Iconsax.book_1,
                  size: 50,
                  color: Color(0xFF6366F1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          const Text(
            'Bienvenido a Classio',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Tu planificador académico universitario que funciona completamente offline',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 18,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Text(
              'Organiza tu vida académica de forma simple',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationSlide(BuildContext context, Size size) {
    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Grid of feature cards
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFeatureCard(Iconsax.calendar, 'Horarios', Colors.white),
              const SizedBox(width: 16),
              _buildFeatureCard(Iconsax.task_square, 'Tareas', Colors.white),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFeatureCard(
                  Iconsax.clipboard_text, 'Exámenes', Colors.white),
              const SizedBox(width: 16),
              _buildFeatureCard(Iconsax.chart, 'Notas', Colors.white),
            ],
          ),
          const SizedBox(height: 60),
          const Text(
            'Organiza tu Vida Académica',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Gestiona tus horarios de clase, evaluaciones, tareas y proyectos. Calcula tus notas y mantén todo bajo control en un solo lugar',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSlide(BuildContext context, Size size) {
    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Notification bell with rings
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Iconsax.notification,
                  size: 50,
                  color: Color(0xFFEC4899),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          const Text(
            'Notificaciones Inteligentes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Recibe recordatorios automáticos de tus evaluaciones, alertas de semanas críticas y avisos antes de cada clase',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildNotificationExample('Examen de Cálculo mañana a las 10:00'),
          const SizedBox(height: 12),
          _buildNotificationExample('Semana crítica: 5 evaluaciones próximas'),
        ],
      ),
    );
  }

  Widget _buildStatisticsSlide(BuildContext context, Size size) {
    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Stats visualization
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatCard('4.5', 'Promedio'),
              const SizedBox(width: 16),
              _buildStatCard('12', 'Cursos'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatCard('8', 'Pendientes'),
              const SizedBox(width: 16),
              _buildStatCard('95%', 'Asistencia'),
            ],
          ),
          const SizedBox(height: 60),
          const Text(
            'Estadísticas y Análisis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Visualiza tu rendimiento académico con gráficos detallados. Calcula promedios automáticamente y sigue tu progreso en tiempo real',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineSlide(BuildContext context, Size size) {
    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Shield with checkmark
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Iconsax.shield_tick,
                  size: 60,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          const Text(
            'Privacidad Total',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Todos tus datos se guardan localmente en tu dispositivo. No necesitas internet para usar Classio',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildFeatureRow(Iconsax.lock, 'Sin registro ni inicio de sesión'),
          const SizedBox(height: 16),
          _buildFeatureRow(Iconsax.mobile, 'Funciona sin conexión'),
          const SizedBox(height: 16),
          _buildFeatureRow(Iconsax.shield_security, 'Tus datos son solo tuyos'),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String label, Color color) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationExample(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.notification_bing, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderSkipButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        "Saltar",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _renderNextButton() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Iconsax.arrow_right_3,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _renderDoneButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Text(
        "Comenzar",
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  void _onDonePress() {
    // Marcar el tour como visto
    ref.read(appSettingsProvider.notifier).updateHasSeenTour(true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainScreen(showTutorial: true),
      ),
    );
  }

  void _onSkipPress() {
    // Marcar el tour como visto incluso si se salta
    ref.read(appSettingsProvider.notifier).updateHasSeenTour(true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainScreen(showTutorial: true),
      ),
    );
  }
}
