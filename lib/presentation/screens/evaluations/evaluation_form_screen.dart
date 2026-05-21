import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/evaluation_model.dart';
import '../../providers/evaluations_provider.dart';
import '../../providers/courses_provider.dart';

class EvaluationFormScreen extends ConsumerStatefulWidget {
  final Evaluation? evaluation;

  const EvaluationFormScreen({super.key, this.evaluation});

  @override
  ConsumerState<EvaluationFormScreen> createState() =>
      _EvaluationFormScreenState();
}

class _EvaluationFormScreenState extends ConsumerState<EvaluationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  String? _selectedCourseId;
  EvaluationType _selectedType = EvaluationType.task;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  Priority? _selectedPriority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.evaluation?.title);
    _descriptionController =
        TextEditingController(text: widget.evaluation?.description);

    if (widget.evaluation != null) {
      _selectedCourseId = widget.evaluation!.courseId;
      _selectedType = widget.evaluation!.type;
      _selectedDate = widget.evaluation!.dueDate;
      _selectedTime = TimeOfDay.fromDateTime(widget.evaluation!.dueDate);
      if (widget.evaluation!.isPriorityManual) {
        _selectedPriority = widget.evaluation!.priority;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courses = ref.watch(activeCoursesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.evaluation == null
              ? AppStrings.addEvaluation
              : AppStrings.editEvaluation,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection(
              title: 'Información Básica',
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: AppStrings.evaluationTitle,
                    hintText: 'Ej: Examen Parcial 1',
                    prefixIcon: const Icon(Iconsax.edit),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa un título';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCourseId,
                  decoration: InputDecoration(
                    labelText: 'Curso',
                    prefixIcon: const Icon(Iconsax.book),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: courses.map((course) {
                    return DropdownMenuItem(
                      value: course.id,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Color(course.colorValue),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(course.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCourseId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Selecciona un curso';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: AppStrings.description,
                    hintText: 'Detalles adicionales (opcional)',
                    prefixIcon: const Icon(Iconsax.note),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Tipo y Fecha',
              children: [
                _buildTypeSelector(context),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateSelector(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimeSelector(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Prioridad',
              children: [
                _buildPrioritySelector(context),
                if (_selectedPriority == null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.info_circle,
                          size: 20,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'La prioridad se calculará automáticamente',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _savEvaluation,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                AppStrings.save,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildTypeSelector(BuildContext context) {
    return Row(
      children: [
        _buildTypeChip(
          context,
          label: 'Examen',
          icon: Iconsax.document_text,
          type: EvaluationType.exam,
          color: AppColors.examColor,
        ),
        const SizedBox(width: 8),
        _buildTypeChip(
          context,
          label: 'Tarea',
          icon: Iconsax.task,
          type: EvaluationType.task,
          color: AppColors.taskColor,
        ),
        const SizedBox(width: 8),
        _buildTypeChip(
          context,
          label: 'Proyecto',
          icon: Iconsax.folder,
          type: EvaluationType.project,
          color: AppColors.projectColor,
        ),
      ],
    );
  }

  Widget _buildTypeChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required EvaluationType type,
    required Color color,
  }) {
    final isSelected = _selectedType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedBg = isDark ? AppColors.darkSurface : Colors.white;
    final textColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : unselectedBg,
            border: Border.all(
              color: isSelected
                  ? color
                  : (isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.surfaceVariant),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : textColor,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? color : textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() {
            _selectedDate = date;
          });
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurface
              : Colors.white,
          border: Border.all(
            color: isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.surfaceVariant,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Iconsax.calendar,
                  size: 16,
                  color: textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Fecha',
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('dd MMM yyyy', 'es').format(_selectedDate),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
        );
        if (time != null) {
          setState(() {
            _selectedTime = time;
          });
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurface
              : Colors.white,
          border: Border.all(
            color: isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.surfaceVariant,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Iconsax.clock,
                  size: 16,
                  color: textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Hora',
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _selectedTime.format(context),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySelector(BuildContext context) {
    return Row(
      children: [
        _buildPriorityChip(
            context, 'Baja', Priority.low, AppColors.priorityLow),
        const SizedBox(width: 8),
        _buildPriorityChip(
            context, 'Media', Priority.medium, AppColors.priorityMedium),
        const SizedBox(width: 8),
        _buildPriorityChip(
            context, 'Alta', Priority.high, AppColors.priorityHigh),
        const SizedBox(width: 8),
        _buildPriorityChip(
            context, 'Crítica', Priority.critical, AppColors.priorityCritical),
      ],
    );
  }

  Widget _buildPriorityChip(
      BuildContext context, String label, Priority priority, Color color) {
    final isSelected = _selectedPriority == priority;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedBg = isDark ? AppColors.darkSurface : Colors.white;
    final textColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() {
          _selectedPriority = isSelected ? null : priority;
        }),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : unselectedBg,
            border: Border.all(
              color: isSelected
                  ? color
                  : (isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.surfaceVariant),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? color : textColor,
            ),
          ),
        ),
      ),
    );
  }

  void _savEvaluation() {
    if (!_formKey.currentState!.validate()) return;

    final dueDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (widget.evaluation == null) {
      ref.read(evaluationsProvider.notifier).addEvaluation(
            courseId: _selectedCourseId!,
            title: _titleController.text,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            type: _selectedType,
            dueDate: dueDate,
            priority: _selectedPriority,
          );
    } else {
      ref.read(evaluationsProvider.notifier).updateEvaluation(
            widget.evaluation!.copyWith(
              courseId: _selectedCourseId,
              title: _titleController.text,
              description: _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
              type: _selectedType,
              dueDate: dueDate,
              priority: _selectedPriority ?? widget.evaluation!.priority,
              isPriorityManual: _selectedPriority != null,
            ),
          );
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.evaluation == null
              ? 'Evaluación creada'
              : 'Evaluación actualizada',
        ),
      ),
    );
  }
}
