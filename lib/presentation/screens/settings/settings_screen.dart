import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/error_utils.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/data_import_service.dart';
import '../../../data/models/app_settings_model.dart' as models;
import '../../../data/local/hive_service.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/courses_provider.dart';
import '../../providers/evaluations_provider.dart';
import '../../providers/grades_provider.dart';
import '../../providers/schedule_provider.dart';
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
          _buildSectionHeader(context, 'Perfil'),
          Consumer(
            builder: (context, ref, child) {
              final settings = ref.watch(appSettingsProvider);
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Iconsax.user, color: AppColors.secondary),
                ),
                title: const Text('Tu nombre'),
                subtitle: Text(
                  (settings.userName != null &&
                          settings.userName!.trim().isNotEmpty)
                      ? settings.userName!
                      : 'Sin configurar',
                ),
                trailing: const Icon(Iconsax.arrow_right_3),
                onTap: () =>
                    _showEditNameDialog(context, ref, settings.userName ?? ''),
              );
            },
          ),

          const Divider(height: 1),

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
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.global, color: AppColors.info),
            ),
            title: const Text('Idioma'),
            subtitle: Text(
              settings.language == 'es'
                  ? 'Español (predeterminado)'
                  : settings.language,
            ),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: () => _showComingSoonDialog(context, 'Selección de idioma'),
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
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.mobile, color: AppColors.primary),
            ),
            title: const Text('Widget de Pantalla'),
            subtitle: Text(
              settings.widgetEnabled
                  ? 'Solicitado (temporalmente deshabilitado)'
                  : 'Desactivado',
            ),
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

          // Datos
          _buildSectionHeader(context, 'Datos'),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.export_1, color: AppColors.warning),
            ),
            title: const Text('Exportar Datos'),
            subtitle: const Text('Guardar copia de seguridad'),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: () => _showExportDataDialog(context, ref),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.import, color: AppColors.info),
            ),
            title: const Text('Importar Datos'),
            subtitle: const Text('Restaurar desde copia de seguridad'),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: () => _showImportDataDialog(context, ref),
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
            onTap: () => _showClearDataDialog(context, ref),
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
            subtitle: const Text('marcusmtz'),
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
                  'Hecho con ❤️ por marcusmtz',
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

  void _showEditNameDialog(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) {
    final controller = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tu nombre'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              hintText: 'Ej: Carlos, María...',
              prefixIcon: Icon(Iconsax.user),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor ingresa tu nombre';
              }
              if (value.trim().length < 2) {
                return 'El nombre debe tener al menos 2 caracteres';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await ref
                  .read(appSettingsProvider.notifier)
                  .updateUserName(controller.text.trim());
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
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
                    'marcusmtz',
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
              value: '@marcusmtz',
              onTap: () => _launchURL('https://github.com/marcusmtz'),
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

  Future<void> _showExportDataDialog(
      BuildContext context, WidgetRef ref) async {
    final exportMap = {
      'generatedAt': DateTime.now().toIso8601String(),
      'app': AppStrings.appName,
      'version': '1.0.0',
      'courses': ref.read(coursesProvider).map((course) {
        return {
          'id': course.id,
          'name': course.name,
          'code': course.code,
          'colorValue': course.colorValue,
          'createdAt': course.createdAt.toIso8601String(),
          'updatedAt': course.updatedAt?.toIso8601String(),
          'isActive': course.isActive,
        };
      }).toList(),
      'schedule': ref.read(scheduleProvider).map((schedule) {
        return {
          'id': schedule.id,
          'courseId': schedule.courseId,
          'dayOfWeek': schedule.dayOfWeek.name,
          'startTime': {
            'hour': schedule.startTime.hour,
            'minute': schedule.startTime.minute,
          },
          'endTime': {
            'hour': schedule.endTime.hour,
            'minute': schedule.endTime.minute,
          },
          'location': schedule.location,
          'professor': schedule.professor,
          'isRecurrent': schedule.isRecurrent,
          'createdAt': schedule.createdAt.toIso8601String(),
        };
      }).toList(),
      'evaluations': ref.read(evaluationsProvider).map((evaluation) {
        return {
          'id': evaluation.id,
          'courseId': evaluation.courseId,
          'title': evaluation.title,
          'description': evaluation.description,
          'type': evaluation.type.name,
          'dueDate': evaluation.dueDate.toIso8601String(),
          'priority': evaluation.priority.name,
          'isCompleted': evaluation.isCompleted,
          'completedAt': evaluation.completedAt?.toIso8601String(),
          'isPriorityManual': evaluation.isPriorityManual,
          'createdAt': evaluation.createdAt.toIso8601String(),
          'subtasks': evaluation.subtasks?.map((subtask) {
            return {
              'id': subtask.id,
              'title': subtask.title,
              'isCompleted': subtask.isCompleted,
              'order': subtask.order,
            };
          }).toList(),
        };
      }).toList(),
      'grades': ref.read(gradesProvider).map((grade) {
        return {
          'id': grade.id,
          'courseId': grade.courseId,
          'title': grade.title,
          'type': grade.type.name,
          'score': grade.score,
          'maxScore': grade.maxScore,
          'weight': grade.weight,
          'date': grade.date.toIso8601String(),
          'notes': grade.notes,
          'createdAt': grade.createdAt.toIso8601String(),
        };
      }).toList(),
      'appSettings': {
        'themeMode': ref.read(appSettingsProvider).themeMode.name,
        'notificationsEnabled':
            ref.read(appSettingsProvider).notificationsEnabled,
        'widgetEnabled': ref.read(appSettingsProvider).widgetEnabled,
        'language': ref.read(appSettingsProvider).language,
        'showSaturday': ref.read(appSettingsProvider).showSaturday,
        'showSunday': ref.read(appSettingsProvider).showSunday,
        'lastUpdated':
            ref.read(appSettingsProvider).lastUpdated?.toIso8601String(),
      },
    };

    final exportJson = const JsonEncoder.withIndent('  ').convert(exportMap);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportación JSON'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              exportJson,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: exportJson));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('JSON copiado al portapapeles'),
                  ),
                );
              }
            },
            child: const Text('Copiar JSON'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
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
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(notificationServiceProvider)
                    .cancelAllNotifications();
                await HiveService.clearAll();
                ref.read(appSettingsProvider.notifier).loadSettings();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Todos los datos fueron eliminados'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ErrorUtils.toUserMessage(
                        e,
                        fallback: 'No se pudo limpiar los datos.',
                      )),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
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
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurfaceVariant
              : AppColors.surfaceVariant,
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

  // ============================================
  // IMPORTAR DATOS
  // ============================================

  void _showImportDataDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Iconsax.import, color: AppColors.info),
              ),
              const SizedBox(width: 12),
              const Text('Importar Datos'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Iconsax.warning_2,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Esta acción reemplazará todos tus datos actuales',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.warning,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pega el JSON exportado:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    maxLines: 10,
                    decoration: InputDecoration(
                      hintText:
                          '{\n  "app": "Classio",\n  "version": "1.0.0",\n  ...\n}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Iconsax.info_circle,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Usa el JSON generado desde "Exportar Datos"',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (controller.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor pega el JSON'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      setState(() => isLoading = true);

                      try {
                        // Validar y parsear JSON
                        final result =
                            await DataImportService.validateAndParseJson(
                          controller.text.trim(),
                        );

                        if (!result.success) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text(result.error ?? 'Error desconocido'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                          setState(() => isLoading = false);
                          return;
                        }

                        // Mostrar confirmación con resumen
                        if (context.mounted) {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar Importación'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Se importarán los siguientes datos:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildImportSummaryItem(
                                    context,
                                    Iconsax.book,
                                    'Cursos',
                                    result.courses.length,
                                  ),
                                  _buildImportSummaryItem(
                                    context,
                                    Iconsax.calendar,
                                    'Horarios',
                                    result.schedules.length,
                                  ),
                                  _buildImportSummaryItem(
                                    context,
                                    Iconsax.task_square,
                                    'Evaluaciones',
                                    result.evaluations.length,
                                  ),
                                  _buildImportSummaryItem(
                                    context,
                                    Iconsax.clipboard_text,
                                    'Notas',
                                    result.grades.length,
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.error
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Iconsax.danger,
                                          color: AppColors.error,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Tus datos actuales serán reemplazados',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppColors.error,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.info,
                                  ),
                                  child: const Text('Importar'),
                                ),
                              ],
                            ),
                          );

                          if (confirm != true) {
                            setState(() => isLoading = false);
                            return;
                          }
                        }

                        // Realizar importación
                        await _performImport(context, ref, result);

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '✅ ${result.totalItems} elementos importados correctamente',
                              ),
                              backgroundColor: AppColors.success,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      } finally {
                        if (context.mounted) {
                          setState(() => isLoading = false);
                        }
                      }
                    },
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Iconsax.import),
              label: Text(isLoading ? 'Importando...' : 'Importar'),
            ),
          ],
        ),
      ),
    ).then((_) => controller.dispose());
  }

  Widget _buildImportSummaryItem(
    BuildContext context,
    IconData icon,
    String label,
    int count,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performImport(
    BuildContext context,
    WidgetRef ref,
    ImportResult result,
  ) async {
    // 1. Limpiar datos actuales
    await HiveService.clearAll();

    // 2. Importar cursos
    for (final course in result.courses) {
      await ref.read(coursesProvider.notifier).addCourse(
            name: course.name,
            code: course.code,
            colorValue: course.colorValue,
          );
    }

    // 3. Importar horarios
    for (final schedule in result.schedules) {
      await ref.read(scheduleProvider.notifier).addSchedule(
            courseId: schedule.courseId,
            dayOfWeek: schedule.dayOfWeek,
            startTime: schedule.startTime,
            endTime: schedule.endTime,
            location: schedule.location,
          );
    }

    // 4. Importar evaluaciones
    for (final evaluation in result.evaluations) {
      await ref.read(evaluationsProvider.notifier).addEvaluation(
            courseId: evaluation.courseId,
            title: evaluation.title,
            description: evaluation.description,
            type: evaluation.type,
            dueDate: evaluation.dueDate,
            priority: evaluation.isPriorityManual ? evaluation.priority : null,
          );
    }

    // 5. Importar notas
    for (final grade in result.grades) {
      await ref.read(gradesProvider.notifier).addGrade(
            courseId: grade.courseId,
            title: grade.title,
            type: grade.type,
            score: grade.score,
            maxScore: grade.maxScore,
            weight: grade.weight,
            date: grade.date,
            notes: grade.notes,
          );
    }

    // 6. Importar configuración (si existe)
    if (result.settings != null) {
      final settings = result.settings!;
      await ref
          .read(appSettingsProvider.notifier)
          .updateThemeMode(settings.themeMode);
      await ref
          .read(appSettingsProvider.notifier)
          .updateNotificationsEnabled(settings.notificationsEnabled);
      await ref
          .read(appSettingsProvider.notifier)
          .updateShowSaturday(settings.showSaturday);
      await ref
          .read(appSettingsProvider.notifier)
          .updateShowSunday(settings.showSunday);
      if (settings.userName != null) {
        await ref
            .read(appSettingsProvider.notifier)
            .updateUserName(settings.userName!);
      }
    }

    // Los providers se actualizan automáticamente al agregar datos
  }
}

