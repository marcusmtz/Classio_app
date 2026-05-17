import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/utils/error_utils.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/services/notification_service.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/evaluations_provider.dart';

class NotificationsSettingsScreen extends ConsumerStatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  ConsumerState<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends ConsumerState<NotificationsSettingsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final notificationService = ref.read(notificationServiceProvider);
    final settings = ref.watch(appSettingsProvider);
    final notificationsEnabled = settings.notificationsEnabled;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        children: [
          // Info Card
          Container(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Iconsax.notification,
                  color: AppColors.primary,
                  size: 32,
                ),
                const SizedBox(width: AppSizes.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recordatorios Automáticos',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Recibe notificaciones antes de tus evaluaciones',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spacing24),

          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Iconsax.notification, color: AppColors.secondary),
            ),
            title: const Text('Notificaciones activas'),
            subtitle: Text(
              notificationsEnabled
                  ? 'Los recordatorios se programan automáticamente'
                  : 'No se programarán recordatorios',
            ),
            value: notificationsEnabled,
            onChanged: _isLoading
                ? null
                : (value) => _toggleNotifications(value, notificationService),
          ),

          const SizedBox(height: AppSizes.spacing8),

          // Configuración de notificaciones
          Text(
            'Recordatorios Predeterminados',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSizes.spacing12),

          _buildNotificationTile(
            icon: Iconsax.calendar_1,
            title: '1 día antes',
            subtitle: 'A las 8:00 AM',
            enabled: notificationsEnabled,
          ),
          _buildNotificationTile(
            icon: Iconsax.clock,
            title: 'El mismo día',
            subtitle: 'A las 8:00 AM',
            enabled: notificationsEnabled,
          ),
          _buildNotificationTile(
            icon: Iconsax.timer,
            title: '2 horas antes',
            subtitle: 'Si la evaluación tiene hora específica',
            enabled: notificationsEnabled,
          ),

          const SizedBox(height: AppSizes.spacing24),

          // Acciones
          Text(
            'Acciones',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSizes.spacing12),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.notification_status,
                  color: AppColors.info),
            ),
            title: const Text('Probar Notificación'),
            subtitle: const Text('Enviar una notificación de prueba'),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: notificationsEnabled
                ? () => _testNotification(notificationService)
                : null,
          ),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.refresh, color: AppColors.secondary),
            ),
            title: const Text('Reprogramar Todas'),
            subtitle: const Text('Actualizar notificaciones de evaluaciones'),
            trailing: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Iconsax.arrow_right_3),
            onTap: _isLoading || !notificationsEnabled ? null : _rescheduleAll,
          ),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Iconsax.document_text, color: AppColors.warning),
            ),
            title: const Text('Ver Pendientes'),
            subtitle: const Text('Notificaciones programadas'),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: notificationsEnabled
                ? () => _showPendingNotifications(notificationService)
                : null,
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
            title: const Text('Cancelar Todas'),
            subtitle: const Text('Eliminar todas las notificaciones'),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: notificationsEnabled
                ? () => _cancelAll(notificationService)
                : null,
          ),

          const SizedBox(height: AppSizes.spacing24),

          // Info adicional
          Container(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Iconsax.info_circle,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Información',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Las notificaciones se programan automáticamente al crear evaluaciones\n'
                  '• Se cancelan al completar o eliminar evaluaciones\n'
                  '• Asegúrate de tener los permisos activados en tu dispositivo',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.textTertiary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.primary : AppColors.textTertiary,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(
        enabled ? Iconsax.tick_circle5 : Iconsax.close_circle,
        color: enabled ? AppColors.success : AppColors.textTertiary,
      ),
    );
  }

  Future<void> _testNotification(NotificationService service) async {
    await service.showImmediateNotification(
      title: '🎓 Classio Test',
      body: '¡Las notificaciones están funcionando correctamente!',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notificación de prueba enviada'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _toggleNotifications(
    bool enabled,
    NotificationService service,
  ) async {
    setState(() => _isLoading = true);

    try {
      await ref
          .read(appSettingsProvider.notifier)
          .updateNotificationsEnabled(enabled);

      if (!enabled) {
        await service.cancelAllNotifications();
      } else {
        await _rescheduleAll(showFeedback: false);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              enabled
                  ? 'Notificaciones activadas y reprogramadas'
                  : 'Notificaciones desactivadas',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorUtils.toUserMessage(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _rescheduleAll({bool showFeedback = true}) async {
    final notificationsEnabled =
        ref.read(appSettingsProvider).notificationsEnabled;
    if (!notificationsEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activa las notificaciones para reprogramarlas'),
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final evaluations = ref.read(evaluationsProvider);
      final notificationService = ref.read(notificationServiceProvider);

      // Cancelar todas primero
      await notificationService.cancelAllNotifications();

      // Reprogramar evaluaciones pendientes
      for (final eval in evaluations) {
        if (!eval.isCompleted) {
          // Trigger re-schedule through provider
          await ref.read(evaluationsProvider.notifier).updateEvaluation(eval);
        }
      }

      if (mounted && showFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${evaluations.where((e) => !e.isCompleted).length} notificaciones reprogramadas'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted && showFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorUtils.toUserMessage(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showPendingNotifications(NotificationService service) async {
    final pending = await service.getPendingNotifications();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notificaciones Pendientes'),
        content: pending.isEmpty
            ? const Text('No hay notificaciones programadas')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: pending.length,
                  itemBuilder: (context, index) {
                    final notification = pending[index];
                    return ListTile(
                      leading: const Icon(Iconsax.notification),
                      title: Text(notification.title ?? 'Sin título'),
                      subtitle: Text(notification.body ?? 'Sin descripción'),
                      dense: true,
                    );
                  },
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

  Future<void> _cancelAll(NotificationService service) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Todas'),
        content: const Text(
          '¿Estás seguro de que quieres cancelar todas las notificaciones programadas?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await service.cancelAllNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todas las notificaciones canceladas'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}
