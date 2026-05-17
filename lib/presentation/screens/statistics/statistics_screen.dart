import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../providers/statistics_provider.dart';
import 'widgets/summary_cards.dart';
import 'widgets/course_load_chart.dart';
import 'widgets/type_distribution_chart.dart';
import 'widgets/monthly_deliveries_chart.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(statisticsSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Estadísticas'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen general
            SummaryCards(summary: summary)
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: AppSizes.spacing24),

            // Título de gráficos
            Text(
              'Análisis Visual',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: AppSizes.spacing16),

            // Gráfico: Carga por curso
            const CourseLoadChart()
                .animate(delay: 200.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: AppSizes.spacing24),

            // Gráfico: Distribución por tipo
            const TypeDistributionChart()
                .animate(delay: 300.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: AppSizes.spacing24),

            // Gráfico: Entregas del mes
            const MonthlyDeliveriesChart()
                .animate(delay: 400.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: AppSizes.spacing24),
          ],
        ),
      ),
    );
  }
}
