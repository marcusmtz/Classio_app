import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      renderDoneBtn: const SizedBox.shrink(), // Ocultar botón "Comenzar"

      // Configuración de estilo
      isShowDoneBtn: false, // No mostrar botón en último slide
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
    return SizedBox(
      width: size.width,
      height: size.height,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.08,
            vertical: size.height * 0.02,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Decorative circles
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: size.width * 0.35,
                    height: size.width * 0.35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  Container(
                    width: size.width * 0.26,
                    height: size.width * 0.26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  Container(
                    width: size.width * 0.18,
                    height: size.width * 0.18,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                      Iconsax.book_1,
                      size: size.width * 0.09,
                      color: const Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 2),
              Text(
                'Bienvenido a Classio',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.075,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.015),
              Text(
                'Tu planificador académico universitario que funciona completamente offline',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: size.width * 0.038,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: size.height * 0.025),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.012,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Organiza tu vida académica de forma simple',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.03,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizationSlide(BuildContext context, Size size) {
    final cardSize = size.width * 0.22;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.08,
            vertical: size.height * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              // Grid of feature cards
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFeatureCard(
                      Iconsax.calendar, 'Horarios', Colors.white, cardSize),
                  SizedBox(width: size.width * 0.04),
                  _buildFeatureCard(
                      Iconsax.task_square, 'Tareas', Colors.white, cardSize),
                ],
              ),
              SizedBox(height: size.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFeatureCard(Iconsax.clipboard_text, 'Exámenes',
                      Colors.white, cardSize),
                  SizedBox(width: size.width * 0.04),
                  _buildFeatureCard(
                      Iconsax.chart, 'Notas', Colors.white, cardSize),
                ],
              ),
              const Spacer(flex: 1),
              Text(
                'Organiza tu Vida Académica',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.07,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.02),
              Text(
                'Gestiona tus horarios de clase, evaluaciones, tareas y proyectos. Calcula tus notas y mantén todo bajo control en un solo lugar',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: size.width * 0.037,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsSlide(BuildContext context, Size size) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.08,
            vertical: size.height * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              // Notification bell with rings
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: size.width * 0.36,
                    height: size.width * 0.36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                  ),
                  Container(
                    width: size.width * 0.28,
                    height: size.width * 0.28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                  ),
                  Container(
                    width: size.width * 0.2,
                    height: size.width * 0.2,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                      Iconsax.notification,
                      size: size.width * 0.1,
                      color: const Color(0xFFEC4899),
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 1),
              Text(
                'Notificaciones Inteligentes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.07,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.02),
              Text(
                'Recibe recordatorios automáticos de tus evaluaciones, alertas de semanas críticas y avisos antes de cada clase',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: size.width * 0.037,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.03),
              _buildNotificationExample(
                  'Examen de Cálculo mañana a las 10:00', size),
              SizedBox(height: size.height * 0.015),
              _buildNotificationExample(
                  'Semana crítica: 5 evaluaciones próximas', size),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSlide(BuildContext context, Size size) {
    final cardSize = size.width * 0.22;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.08,
            vertical: size.height * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              // Stats visualization
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatCard('4.5', 'Promedio', cardSize, size),
                  SizedBox(width: size.width * 0.04),
                  _buildStatCard('12', 'Cursos', cardSize, size),
                ],
              ),
              SizedBox(height: size.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatCard('8', 'Pendientes', cardSize, size),
                  SizedBox(width: size.width * 0.04),
                  _buildStatCard('95%', 'Asistencia', cardSize, size),
                ],
              ),
              const Spacer(flex: 1),
              Text(
                'Estadísticas y Análisis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.07,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.02),
              Text(
                'Visualiza tu rendimiento académico con gráficos detallados. Calcula promedios automáticamente y sigue tu progreso en tiempo real',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: size.width * 0.037,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineSlide(BuildContext context, Size size) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.08,
            vertical: size.height * 0.03,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Shield with checkmark - ANIMADO Y CLICKEABLE
              GestureDetector(
                onTap: _onDonePress,
                child: _AnimatedShield(size: size),
              ),
              const Spacer(flex: 2),
              Text(
                'Privacidad Total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.065,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.015),
              Text(
                'Todos tus datos se guardan localmente en tu dispositivo. No necesitas internet para usar Classio',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: size.width * 0.035,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: size.height * 0.025),
              _buildFeatureRow(
                  Iconsax.lock, 'Sin registro ni inicio de sesión', size),
              SizedBox(height: size.height * 0.015),
              _buildFeatureRow(Iconsax.mobile, 'Funciona sin conexión', size),
              SizedBox(height: size.height * 0.015),
              _buildFeatureRow(
                  Iconsax.shield_security, 'Tus datos son solo tuyos', size),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      IconData icon, String label, Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(size * 0.2),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: size * 0.36),
          SizedBox(height: size * 0.08),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: size * 0.12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationExample(String text, Size screenSize) {
    return Container(
      padding: EdgeInsets.all(screenSize.width * 0.04),
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
          Icon(Iconsax.notification_bing,
              color: Colors.white, size: screenSize.width * 0.05),
          SizedBox(width: screenSize.width * 0.03),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: screenSize.width * 0.035,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String value, String label, double size, Size screenSize) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(size * 0.2),
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
            style: TextStyle(
              color: Colors.white,
              fontSize: screenSize.width * 0.065,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: size * 0.04),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: screenSize.width * 0.03,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, Size screenSize) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(screenSize.width * 0.02),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: screenSize.width * 0.05),
        ),
        SizedBox(width: screenSize.width * 0.03),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenSize.width * 0.037,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderSkipButton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenWidth * 0.02,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "Saltar",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: screenWidth * 0.038,
            ),
          ),
        );
      },
    );
  }

  Widget _renderNextButton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        return Container(
          padding: EdgeInsets.all(screenWidth * 0.03),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Iconsax.arrow_right_3,
            color: Colors.white,
            size: screenWidth * 0.06,
          ),
        );
      },
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

// Widget separado para la animación del escudo
class _AnimatedShield extends StatefulWidget {
  final Size size;

  const _AnimatedShield({required this.size});

  @override
  State<_AnimatedShield> createState() => _AnimatedShieldState();
}

class _AnimatedShieldState extends State<_AnimatedShield>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Círculo exterior con animación de opacidad
              Container(
                width: widget.size.width * 0.32,
                height: widget.size.width * 0.32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      Colors.white.withValues(alpha: 0.15 * _controller.value),
                ),
              ),
              // Círculo interior clickeable
              Container(
                width: widget.size.width * 0.24,
                height: widget.size.width * 0.24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Iconsax.shield_tick,
                  size: widget.size.width * 0.12,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
