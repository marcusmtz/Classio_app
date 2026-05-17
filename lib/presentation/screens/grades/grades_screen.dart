import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/models/grade_model.dart';
import '../../../data/models/course_model.dart';
import '../../providers/grades_provider.dart';
import '../../providers/courses_provider.dart';
import 'grade_form_screen.dart';
import 'widgets/grade_card.dart';
import 'widgets/course_grade_summary.dart';

class GradesScreen extends ConsumerStatefulWidget {
  const GradesScreen({super.key});

  @override
  ConsumerState<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends ConsumerState<GradesScreen> {
  String? _selectedCourseId;

  @override
  Widget build(BuildContext context) {
    final courses = ref.watch(activeCoursesProvider);

    // Si no hay curso seleccionado, seleccionar el primero
    if (_selectedCourseId == null && courses.isNotEmpty) {
      _selectedCourseId = courses.first.id;
    }

    final selectedCourse = courses.isNotEmpty
        ? courses.firstWhere(
            (c) => c.id == _selectedCourseId,
            orElse: () => courses.first,
          )
        : null;

    final courseGrades = _selectedCourseId != null
        ? ref.watch(gradesByCourseProvider(_selectedCourseId!))
        : <Grade>[];

    final average = _selectedCourseId != null
        ? ref.watch(courseAverageProvider(_selectedCourseId!))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas'),
        actions: [
          if (selectedCourse != null)
            IconButton(
              icon: const Icon(Iconsax.calculator),
              onPressed: () => _showCalculator(context, selectedCourse.id),
              tooltip: 'Calculadora',
            ),
        ],
      ),
      body: courses.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                // Course Selector
                _buildCourseSelector(context, courses),

                // Summary
                if (selectedCourse != null)
                  CourseGradeSummary(
                    course: selectedCourse,
                    grades: courseGrades,
                    average: average,
                  ),

                // Grades List
                Expanded(
                  child: courseGrades.isEmpty
                      ? _buildEmptyGrades(context)
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppSizes.spacing16),
                          itemCount: courseGrades.length,
                          itemBuilder: (context, index) {
                            return GradeCard(
                              grade: courseGrades[index],
                              course: selectedCourse!,
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: selectedCourse != null
          ? FloatingActionButton.extended(
              heroTag: 'grades_fab',
              onPressed: () => _showAddGradeDialog(context, selectedCourse.id),
              icon: const Icon(Iconsax.add),
              label: const Text('Agregar Nota'),
            )
          : null,
    );
  }

  Widget _buildCourseSelector(BuildContext context, List<Course> courses) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          final isSelected = course.id == _selectedCourseId;

          return Padding(
            padding: const EdgeInsets.only(right: AppSizes.spacing8),
            child: FilterChip(
              selected: isSelected,
              label: Text(course.code),
              avatar: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Color(course.colorValue),
                  shape: BoxShape.circle,
                ),
              ),
              onSelected: (selected) {
                setState(() {
                  _selectedCourseId = course.id;
                });
              },
            ),
          );
        },
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
            Icon(
              Iconsax.book,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSizes.spacing16),
            Text(
              'No hay cursos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSizes.spacing8),
            Text(
              'Primero debes crear cursos para agregar notas',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyGrades(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.clipboard_text,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSizes.spacing16),
            Text(
              'No hay notas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSizes.spacing8),
            Text(
              'Agrega tu primera nota para este curso',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGradeDialog(BuildContext context, String courseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GradeFormScreen(courseId: courseId),
      ),
    );
  }

  void _showCalculator(BuildContext context, String courseId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _GradeCalculatorSheet(courseId: courseId),
    );
  }
}

class _GradeCalculatorSheet extends ConsumerStatefulWidget {
  final String courseId;

  const _GradeCalculatorSheet({required this.courseId});

  @override
  ConsumerState<_GradeCalculatorSheet> createState() =>
      _GradeCalculatorSheetState();
}

class _GradeCalculatorSheetState extends ConsumerState<_GradeCalculatorSheet> {
  final _targetController = TextEditingController(text: '4.0');
  double? _minimumNeeded;

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  void _calculate() {
    final target = double.tryParse(_targetController.text);
    if (target == null || target < 1.0 || target > 7.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa una nota válida (1.0 - 7.0)')),
      );
      return;
    }

    final totalWeight =
        ref.read(gradesProvider.notifier).getTotalWeight(widget.courseId);
    final remainingWeight = 100 - totalWeight;

    if (remainingWeight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya tienes el 100% de las notas ingresadas'),
        ),
      );
      return;
    }

    final minimum = ref.read(gradesProvider.notifier).getMinimumNeeded(
          courseId: widget.courseId,
          targetAverage: target,
          remainingWeight: remainingWeight,
        );

    setState(() {
      _minimumNeeded = minimum;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalWeight =
        ref.watch(gradesProvider.notifier).getTotalWeight(widget.courseId);
    final remainingWeight = 100 - totalWeight;
    final average = ref.watch(courseAverageProvider(widget.courseId));

    return Container(
      padding: EdgeInsets.only(
        top: AppSizes.spacing24,
        left: AppSizes.spacing24,
        right: AppSizes.spacing24,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.spacing24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.spacing12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: const Icon(
                  Iconsax.calculator,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calculadora de Notas',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'Calcula la nota mínima necesaria',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing24),

          // Current Info
          Container(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Promedio Actual:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      average != null ? average.toStringAsFixed(2) : 'N/A',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacing8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Peso Restante:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${remainingWeight.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: remainingWeight > 0
                                ? AppColors.secondary
                                : AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spacing24),

          // Target Input
          TextField(
            controller: _targetController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Nota Objetivo',
              hintText: '4.0',
              suffixText: '(1.0 - 7.0)',
            ),
          ),
          const SizedBox(height: AppSizes.spacing16),

          // Calculate Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: remainingWeight > 0 ? _calculate : null,
              icon: const Icon(Iconsax.calculator),
              label: const Text('Calcular'),
            ),
          ),

          // Result
          if (_minimumNeeded != null) ...[
            const SizedBox(height: AppSizes.spacing24),
            Container(
              padding: const EdgeInsets.all(AppSizes.spacing20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.secondary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Nota Mínima Necesaria',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSizes.spacing8),
                  Text(
                    _minimumNeeded!.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getGradeColor(_minimumNeeded!),
                        ),
                  ),
                  const SizedBox(height: AppSizes.spacing8),
                  Text(
                    _getGradeMessage(_minimumNeeded!),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getGradeColor(double grade) {
    if (grade >= 6.0) return AppColors.priorityCritical;
    if (grade >= 5.0) return AppColors.priorityHigh;
    if (grade >= 4.0) return AppColors.secondary;
    return AppColors.priorityLow;
  }

  String _getGradeMessage(double grade) {
    if (grade > 7.0) {
      return 'No es posible alcanzar esta nota 😔';
    } else if (grade >= 6.0) {
      return '¡Necesitas una nota muy alta! 💪';
    } else if (grade >= 5.0) {
      return 'Necesitas una buena nota 📚';
    } else if (grade >= 4.0) {
      return '¡Totalmente alcanzable! 🎯';
    } else {
      return '¡Muy fácil de lograr! 🌟';
    }
  }
}
