import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/app_settings_model.dart' as models;
import '../../providers/app_settings_provider.dart';
import 'notifications_settings_screen.dart';
import 'widget_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        children: [
          // Apariencia
          _buildSectionHeader(context, 'Apariencia'),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.brush, color: AppColors.primary),
            ),
            title: const Text('Tema'),
            subtitle: Text(_getThemeModeText(settings.themeMode)),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: () => _showThemeDialog(context, ref, settings.themeMode),
          ),

          const Divider(height: 1),

          // Horario
          _buildSectionHeader(context, 'Horario'),
          Consumer(
            builder: (context, ref, child) {
              final settings = ref.watch(appSettingsProvider);
              return Column(
                children: [
                  SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          const Icon(Iconsax.calendar, color: AppColors.info),
                    ),
                    title: const Text('Mostrar Sábado'),
                    subtitle: const Text('Incluir sábado en el horario'),
                    value: settings.showSaturday,
                    onChanged: (value) {
                      ref
                          .read(appSettingsProvider.notifier)
                          .updateShowSaturday(value);
                    },
                  ),
                  SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          const Icon(Iconsax.calendar, color: AppColors.info),
                    ),
                    title: const Text('Mostrar Domingo'),
                    subtitle: const Text('Incluir domingo en el horario'),
                    value: settings.showSunday,
                    onChanged: (value) {
                      ref
                          .read(appSettingsProvider.notifier)
                          .updateShowSunday(value);
                    },
                  ),
                ],
              );
            },
          ),

          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Iconsax.notification, color: AppColors.secondary),
            ),
            title: const Text('Notificaciones'),
            subtitle: const Text('Configurar recordatorios'),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsSettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.mobile, color: AppColors.info),
            ),
            title: const Text('Widget de Pantalla'),
            subtitle: const Text('Configurar widget'),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WidgetSettingsScreen(),
                ),
              );
            },
          ),

          const Divider(height: 1),

          // Notificaciones y Widget
          _buildSectionHeader(context, 'Funcionalidades'),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.export, color: AppColors.warning),
            ),
            title: const Text('Exportar Datos'),
            subtitle: const Text('Guardar copia de seguridad'),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: () => _showComingSoonDialog(context, 'Exportar Datos'),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.trash, color: AppColors.error),
            ),
            title: const Text('Limpiar Datos'),
            subtitle: const Text('Eliminar toda la información'),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: () => _showClearDataDialog(context),
          ),

          const Divider(height: 1),

          // Información
          _buildSectionHeader(context, 'Información'),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.info_circle, color: AppColors.primary),
            ),
            title: const Text('Acerca de la App'),
            subtitle: const Text('Versión 1.0.0'),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: () => _showAboutDialog(context),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.user, color: AppColors.secondary),
            ),
            title: const Text('Desarrollador'),
            subtitle: const Text('Marcos-Mart18'),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: () => _showDeveloperDialog(context),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.document_text, color: AppColors.info),
            ),
            title: const Text('Términos y Privacidad'),
            subtitle: const Text('Políticas de uso'),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: () => _showPrivacyDialog(context),
          ),

          const SizedBox(height: AppSizes.spacing24),

          // Footer
          Center(
            child: Column(
              children: [
                Text(
                  AppStrings.appName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Versión 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hecho con ❤️ por Marcos-Mart18',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spacing32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
      ),
    );
  }

  String _getThemeModeText(models.ThemeMode mode) {
    switch (mode) {
      case models.ThemeMode.light:
        return 'Claro';
      case models.ThemeMode.dark:
        return 'Oscuro';
      case models.ThemeMode.system:
        return 'Sistema';
    }
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    models.ThemeMode currentMode,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<models.ThemeMode>(
              title: const Text('Claro'),
              subtitle: const Text('Tema claro siempre'),
              value: models.ThemeMode.light,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appSettingsProvider.notifier).updateThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<models.ThemeMode>(
              title: const Text('Oscuro'),
              subtitle: const Text('Tema oscuro siempre'),
              value: models.ThemeMode.dark,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appSettingsProvider.notifier).updateThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<models.ThemeMode>(
              title: const Text('Sistema'),
              subtitle: const Text('Seguir configuración del sistema'),
              value: models.ThemeMode.system,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appSettingsProvider.notifier).updateThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Iconsax.book, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Acerca de Classio'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Classio es tu planificador académico universitario offline-first.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(context, 'Versión', '1.0.0'),
              _buildInfoRow(context, 'Plataforma', 'Flutter'),
              _buildInfoRow(context, 'Licencia', 'MIT'),
              const SizedBox(height: 16),
              Text(
                'Características:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _buildFeature('✅ Gestión de horarios'),
              _buildFeature('✅ Seguimiento de evaluaciones'),
              _buildFeature('✅ Calculadora de notas'),
              _buildFeature('✅ Notificaciones inteligentes'),
              _buildFeature('✅ Widget de pantalla'),
              _buildFeature('✅ 100% offline'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showDeveloperDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.code,
                  color: AppColors.secondary, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Desarrollador'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.user,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Marcos-Mart18',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Flutter Developer',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Contacto:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildContactButton(
              context,
              icon: Iconsax.global,
              label: 'GitHub',
              value: '@Marcos-Mart18',
              onTap: () => _launchURL('https://github.com/Marcos-Mart18'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacidad y Términos'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Privacidad',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Todos tus datos se almacenan localmente en tu dispositivo\n'
                '• No recopilamos información personal\n'
                '• No compartimos datos con terceros\n'
                '• No requiere conexión a internet',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Términos de Uso',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Uso personal y educativo\n'
                '• Software proporcionado "tal cual"\n'
                '• Sin garantías de ningún tipo\n'
                '• Código abierto bajo licencia MIT',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Limpiar Datos'),
        content: const Text(
          'Esta acción eliminará TODOS tus datos:\n\n'
          '• Cursos\n'
          '• Horarios\n'
          '• Evaluaciones\n'
          '• Notas\n'
          '• Configuraciones\n\n'
          'Esta acción NO se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoonDialog(context, 'Limpiar Datos');
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Eliminar Todo'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Próximamente'),
        content: Text('La función "$feature" estará disponible pronto.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text),
    );
  }

  Widget _buildContactButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
