import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/models/semester_model.dart';
import '../../providers/semester_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/courses_provider.dart';

class SemestersScreen extends ConsumerWidget {
  const SemestersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semesters = ref.watch(semestersProvider);
    final activeId = ref.watch(appSettingsProvider).activeSemesterId;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Periodos Académicos'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear_filter') {
                ref.read(appSettingsProvider.notifier).updateActiveSemesterId(null);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Filtro: Todos los periodos')),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'clear_filter', child: Text('Ver todos')),
            ],
          ),
        ],
      ),
      body: semesters.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(AppSizes.spacing16),
              itemCount: semesters.length,
              itemBuilder: (context, index) {
                final semester = semesters[index];
                final isActive = semester.id == activeId;
                final courseCount = ref
                    .watch(coursesProvider)
                    .where((c) => c.semesterId == semester.id)
                    .length;
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSizes.spacing12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    border: Border.all(
                      color: isActive ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: semester.isArchived
                            ? AppColors.textSecondary.withValues(alpha: 0.1)
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        semester.isArchived ? Iconsax.archive : Iconsax.calendar_1,
                        color: semester.isArchived ? AppColors.textSecondary : AppColors.primary,
                      ),
                    ),
                    title: Text(
                      semester.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      courseCount == 0
                          ? 'Sin cursos'
                          : '$courseCount ${courseCount == 1 ? 'curso' : 'cursos'}'
                              '${semester.isArchived ? ' • Archivado' : ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) => _handleMenu(context, ref, semester, value, isActive),
                      itemBuilder: (context) => [
                        if (!isActive) const PopupMenuItem(value: 'activate', child: Text('Filtrar por este')),
                        if (semester.isArchived)
                          const PopupMenuItem(value: 'restore', child: Text('Restaurar'))
                        else
                          const PopupMenuItem(value: 'archive', child: Text('Archivar')),
                        const PopupMenuItem(value: 'edit', child: Text('Editar')),
                        const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                      ],
                    ),
                    onTap: () {
                      if (semester.isArchived) return;
                      if (isActive) {
                        ref.read(appSettingsProvider.notifier).updateActiveSemesterId(null);
                      } else {
                        ref.read(appSettingsProvider.notifier).updateActiveSemesterId(semester.id);
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        icon: const Icon(Iconsax.add),
        label: const Text('Nuevo Periodo'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.calendar, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: AppSizes.spacing16),
            Text('Sin periodos', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSizes.spacing8),
            Text(
              'Crea periodos para organizar tus cursos por semestre (ej: 2025-1)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenu(BuildContext context, WidgetRef ref, Semester semester, String value, bool isActive) {
    switch (value) {
      case 'activate':
        ref.read(appSettingsProvider.notifier).updateActiveSemesterId(semester.id);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Filtrando: ${semester.name}')));
        break;
      case 'archive':
        ref.read(semesterRepositoryProvider).archive(semester.id);
        break;
      case 'restore':
        ref.read(semesterRepositoryProvider).restore(semester.id);
        break;
      case 'edit':
        _showEditDialog(context, ref, semester);
        break;
      case 'delete':
        _showDeleteDialog(context, ref, semester);
        break;
    }
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Periodo'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            hintText: 'Ej: 2025 - Semestre 1',
            prefixIcon: Icon(Iconsax.calendar),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await ref.read(semestersProvider.notifier).addSemester(name: controller.text.trim());
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Periodo creado')));
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Semester semester) {
    final controller = TextEditingController(text: semester.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Periodo'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nombre', prefixIcon: Icon(Iconsax.edit)),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await ref.read(semestersProvider.notifier).updateSemester(semester.copyWith(name: controller.text.trim()));
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Semester semester) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar periodo'),
        content: Text('¿Eliminar "${semester.name}"? Los cursos quedarán sin periodo.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              // Mover cursos sin periodo
              final courses = ref.read(coursesProvider);
              for (final c in courses.where((c) => c.semesterId == semester.id)) {
                await ref.read(coursesProvider.notifier).moveCourseToSemester(c.id, null);
              }
              await ref.read(semestersProvider.notifier).deleteSemester(semester.id);
              // Si era activo limpiar filtro
              final activeId = ref.read(appSettingsProvider).activeSemesterId;
              if (activeId == semester.id) {
                await ref.read(appSettingsProvider.notifier).updateActiveSemesterId(null);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
