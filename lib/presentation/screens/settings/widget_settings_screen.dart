import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../providers/app_settings_provider.dart';

class WidgetSettingsScreen extends ConsumerWidget {
  const WidgetSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget de Pantalla'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        children: [
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.mobile, color: AppColors.primary),
            ),
            title: const Text('Solicitar widget en pantalla de inicio'),
            subtitle: const Text(
              'Quedará guardado para activación futura',
            ),
            value: settings.widgetEnabled,
            onChanged: (value) async {
              await ref
                  .read(appSettingsProvider.notifier)
                  .updateWidgetEnabled(value);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Preferencia guardada. El widget está en desarrollo.'
                          : 'Widget desactivado',
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: AppSizes.spacing12),
          Container(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Iconsax.info_circle,
                  color: AppColors.info,
                ),
                const SizedBox(width: AppSizes.spacing12),
                Expanded(
                  child: Text(
                    'La funcionalidad de widget está temporalmente deshabilitada. Tu preferencia se guardará para una actualización futura.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
