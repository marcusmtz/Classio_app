import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/models/evaluation_model.dart';
import '../../providers/evaluations_provider.dart';
import '../../providers/courses_provider.dart';
import '../../providers/critical_week_provider.dart';
import '../evaluations/evaluation_detail_screen.dart';
import '../statistics/statistics_screen.dart';
import '../settings/settings_screen.dart';
import 'widgets/critical_week_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingEvaluations = ref.watch(pendingEvaluationsProvider);
    final courses = ref.watch(activeCoursesProvider);
    final criticalWeekInfo = ref.watch(criticalWeekProvider);

    final now = DateTime.now();
    final todayEvaluations = pendingEvaluations.where((e) {
      return e.dueDate.year == now.year &&
          e.dueDate.month == now.month &&
          e.dueDate.day == now.day;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(child: _buildHeader(context)),

            // Critical Week Banner
            if (criticalWeekInfo.isCritical)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing16,
                  ),
                  child: _buildCriticalWeekBanner(
                    context,
                    criticalWeekInfo,
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.2, end: 0),
                ),
              ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(AppSizes.spacing16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildTodaySummary(
                          context, todayEvaluations.length, courses.length)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: AppSizes.spacing16),
                  if (pendingEvaluations.isNotEmpty)
                    _buildNextEvaluationCard(
                      context,
                      ref,
                      pendingEvaluations.first,
                    )
                        .animate(delay: 100.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: AppSizes.spacing24),
                  _buildQuickStats(
                    context,
                    pendingEvaluations.length,
                    criticalWeekInfo.totalEvaluations,
                  ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                  if (todayEvaluations.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.spacing24),
                    _buildTodayEvaluations(context, ref, todayEvaluations)
                        .animate(delay: 300.ms)
                        .fadeIn(duration: 400.ms),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '¡Buenos días!';
    if (hour < 19) return '¡Buenas tardes!';
    return '¡Buenas noches!';
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, d \'de\' MMMM', 'es_ES');
    final formattedDate = dateFormat.format(now);
    final capitalizedDate =
        formattedDate[0].toUpperCase() + formattedDate.substring(1);

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSizes.spacing8),
                    Text(
                      capitalizedDate,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StatisticsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Iconsax.chart),
                    tooltip: 'Estadísticas',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Iconsax.setting_2),
                    tooltip: 'Configuración',
                    style: IconButton.styleFrom(
                      backgroundColor:
                          AppColors.secondary.withValues(alpha: 0.1),
                      foregroundColor: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalWeekBanner(BuildContext context, CriticalWeekInfo info) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CriticalWeekDetailScreen(info: info),
          ),
        );
      },
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        margin: const EdgeInsets.only(bottom: AppSizes.spacing16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.spacing8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: const Icon(
                Iconsax.warning_2,
                color: Colors.white,
                size: AppSizes.iconMedium,
              ),
            ),
            const SizedBox(width: AppSizes.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Semana Crítica!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSizes.spacing4),
                  Text(
                    info.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                  ),
                ],
              ),
            ),
            const Icon(
              Iconsax.arrow_right_3,
              color: Colors.white,
              size: AppSizes.iconSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySummary(
      BuildContext context, int todayCount, int coursesCount) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.spacing8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: const Icon(
                  Iconsax.calendar_1,
                  color: Colors.white,
                  size: AppSizes.iconMedium,
                ),
              ),
              const SizedBox(width: AppSizes.spacing12),
              Text(
                'Resumen de Hoy',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$todayCount',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    Text(
                      todayCount == 1 ? 'Evaluación hoy' : 'Evaluaciones hoy',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              const SizedBox(width: AppSizes.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$coursesCount',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    Text(
                      coursesCount == 1 ? 'Curso activo' : 'Cursos activos',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextEvaluationCard(
    BuildContext context,
    WidgetRef ref,
    Evaluation evaluation,
  ) {
    final course =
        ref.read(coursesProvider.notifier).getCourseById(evaluation.courseId);
    if (course == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final daysUntil = evaluation.dueDate.difference(now).inDays;
    final timeFormat = DateFormat('HH:mm');

    String timeText;
    if (daysUntil == 0) {
      timeText = 'Hoy a las ${timeFormat.format(evaluation.dueDate)}';
    } else if (daysUntil == 1) {
      timeText = 'Mañana a las ${timeFormat.format(evaluation.dueDate)}';
    } else {
      final dateFormat = DateFormat('d MMM', 'es_ES');
      timeText =
          '${dateFormat.format(evaluation.dueDate)} a las ${timeFormat.format(evaluation.dueDate)}';
    }

    Color priorityColor;
    switch (evaluation.priority) {
      case Priority.critical:
        priorityColor = AppColors.priorityCritical;
        break;
      case Priority.high:
        priorityColor = AppColors.priorityHigh;
        break;
      case Priority.medium:
        priorityColor = AppColors.priorityMedium;
        break;
      case Priority.low:
        priorityColor = AppColors.priorityLow;
        break;
    }

    IconData typeIcon;
    Color typeColor;
    switch (evaluation.type) {
      case EvaluationType.exam:
        typeIcon = Iconsax.clipboard_text;
        typeColor = AppColors.examColor;
        break;
      case EvaluationType.project:
        typeIcon = Iconsax.folder_2;
        typeColor = AppColors.projectColor;
        break;
      case EvaluationType.task:
        typeIcon = Iconsax.task_square;
        typeColor = AppColors.taskColor;
        break;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EvaluationDetailScreen(evaluation: evaluation),
          ),
        );
      },
      borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.spacing20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          border: Border.all(color: AppColors.surfaceVariant, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.spacing8),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                  child: Icon(
                    typeIcon,
                    color: typeColor,
                    size: AppSizes.iconMedium,
                  ),
                ),
                const SizedBox(width: AppSizes.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Próxima Evaluación',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: AppSizes.spacing4),
                      Text(
                        '${evaluation.title} - ${course.name}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacing16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing12,
                    vertical: AppSizes.spacing8,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: priorityColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacing8),
                      Text(
                        timeText,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: priorityColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(
      BuildContext context, int pendingCount, int weekCount) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas Rápidas',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSizes.spacing16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Iconsax.task_square,
                  label: 'Pendientes',
                  value: '$pendingCount',
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: AppSizes.spacing12),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Iconsax.calendar_2,
                  label: 'Esta Semana',
                  value: '$weekCount',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: AppSizes.iconLarge),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: AppSizes.spacing4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }

  Widget _buildTodayEvaluations(
      BuildContext context, WidgetRef ref, List<Evaluation> evaluations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.spacing12),
          child: Text(
            'Evaluaciones de Hoy',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        ...evaluations.map((evaluation) {
          final course = ref
              .read(coursesProvider.notifier)
              .getCourseById(evaluation.courseId);
          if (course == null) return const SizedBox.shrink();

          return Container(
            margin: const EdgeInsets.only(bottom: AppSizes.spacing12),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EvaluationDetailScreen(evaluation: evaluation),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.spacing16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  border: Border.all(
                    color: Color(course.colorValue).withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(course.colorValue),
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            evaluation.title,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: AppSizes.spacing4),
                          Text(
                            course.name,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Iconsax.arrow_right_3,
                      color: AppColors.textSecondary,
                      size: AppSizes.iconSmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
