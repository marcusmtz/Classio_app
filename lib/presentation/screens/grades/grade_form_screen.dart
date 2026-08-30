import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/utils/error_utils.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/models/grade_model.dart';
import '../../providers/grades_provider.dart';
import '../../providers/courses_provider.dart';
import '../../providers/app_settings_provider.dart';

class GradeFormScreen extends ConsumerStatefulWidget {
  final String courseId;
  final Grade? grade;

  const GradeFormScreen({
    super.key,
    required this.courseId,
    this.grade,
  });

  @override
  ConsumerState<GradeFormScreen> createState() => _GradeFormScreenState();
}

class _GradeFormScreenState extends ConsumerState<GradeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _scoreController;
  late TextEditingController _maxScoreController;
  late TextEditingController _weightController;
  late TextEditingController _notesController;
  late GradeType _selectedType;
  late DateTime _selectedDate;
  late bool _hasScore;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.grade?.title ?? '');
    _scoreController =
        TextEditingController(text: widget.grade?.score?.toString() ?? '');
    _maxScoreController =
        TextEditingController(text: widget.grade?.maxScore?.toString() ?? '');
    _weightController =
        TextEditingController(text: widget.grade?.weight.toString() ?? '');
    _notesController = TextEditingController(text: widget.grade?.notes ?? '');
    _selectedType = widget.grade?.type ?? GradeType.exam;
    _selectedDate = widget.grade?.date ?? DateTime.now();
    _hasScore = widget.grade?.score != null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _scoreController.dispose();
    _maxScoreController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final course =
        ref.watch(coursesProvider.notifier).getCourseById(widget.courseId);
    if (course == null) {
      return const Scaffold(
        body: Center(child: Text('Curso no encontrado')),
      );
    }

    final settings = ref.watch(appSettingsProvider);
    final isEditing = widget.grade != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Nota' : 'Nueva Nota'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          children: [
            // Course Info
            Container(
              padding: const EdgeInsets.all(AppSizes.spacing16),
              decoration: BoxDecoration(
                color: Color(course.colorValue).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(
                  color: Color(course.colorValue).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(course.colorValue),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          course.code,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
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

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ej: Examen Parcial 1',
                prefixIcon: Icon(Iconsax.edit),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa un título';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spacing16),

            // Type Selector
            DropdownButtonFormField<GradeType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                prefixIcon: Icon(Iconsax.category),
              ),
              items: GradeType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getTypeName(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: AppSizes.spacing16),

            // Has Score toggle
            SwitchListTile(
              title: const Text('Ya tengo la nota'),
              subtitle: Text(_hasScore ? 'Ingresa nota obtenida y máxima' : 'Solo planificar evaluación (pendiente)'),
              value: _hasScore,
              onChanged: (v) => setState(() {
                _hasScore = v;
                if (!v) {
                  _scoreController.clear();
                  _maxScoreController.clear();
                }
              }),
              secondary: Icon(_hasScore ? Iconsax.tick_circle : Iconsax.clock, color: _hasScore ? AppColors.success : AppColors.warning),
            ),
            const SizedBox(height: AppSizes.spacing8),

            // Score and Max Score (only if hasScore)
            if (_hasScore)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _scoreController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Nota Obtenida',
                        hintText: settings.gradeMaxValue.toStringAsFixed(1),
                        prefixIcon: const Icon(Iconsax.star),
                        helperText:
                            '${settings.gradeMinValue.toStringAsFixed(1)} - ${settings.gradeMaxValue.toStringAsFixed(1)}',
                      ),
                      validator: (value) {
                        if (!_hasScore) return null;
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        final score = double.tryParse(value);
                        if (score == null) {
                          return 'Número inválido';
                        }
                        if (score < settings.gradeMinValue ||
                            score > settings.gradeMaxValue) {
                          return 'Fuera de rango';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing12),
                  Expanded(
                    child: TextFormField(
                      controller: _maxScoreController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Nota Máxima',
                        hintText: settings.gradeMaxValue.toStringAsFixed(1),
                        prefixIcon: const Icon(Iconsax.star_1),
                      ),
                      validator: (value) {
                        if (!_hasScore) return null;
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        final maxScore = double.tryParse(value);
                        if (maxScore == null || maxScore <= 0) {
                          return 'Inválido';
                        }
                        if (maxScore < settings.gradeMinValue ||
                            maxScore > settings.gradeMaxValue) {
                          return 'Fuera de rango';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            if (_hasScore) const SizedBox(height: AppSizes.spacing16),

            // Weight
            TextFormField(
              controller: _weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Ponderación (%)',
                hintText: '30',
                prefixIcon: Icon(Iconsax.percentage_circle),
                suffixText: '%',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa la ponderación';
                }
                final weight = double.tryParse(value);
                if (weight == null || weight <= 0 || weight > 100) {
                  return 'Debe estar entre 0 y 100';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spacing16),

            // Date
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  prefixIcon: Icon(Iconsax.calendar),
                ),
                child: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacing16),

            // Notes
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notas (Opcional)',
                hintText: 'Comentarios adicionales...',
                prefixIcon: Icon(Iconsax.note_text),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSizes.spacing24),

            // Preview
            _buildPreview(context),
            const SizedBox(height: AppSizes.spacing24),

            // Save Button
            FilledButton.icon(
              onPressed: _saveGrade,
              icon: const Icon(Iconsax.tick_circle),
              label: Text(isEditing ? 'Guardar Cambios' : 'Agregar Nota'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(AppSizes.spacing16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    if (!_hasScore) {
      final weight = double.tryParse(_weightController.text) ?? 0.0;
      return Container(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Iconsax.clock, color: AppColors.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Evaluación pendiente: ${weight.toStringAsFixed(1)}% del promedio. Agrega la nota cuando la tengas.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.warning),
              ),
            ),
          ],
        ),
      );
    }
    final score = double.tryParse(_scoreController.text) ?? 0.0;
    final maxScore = double.tryParse(_maxScoreController.text) ?? 7.0;
    final percentage = maxScore > 0 ? (score / maxScore) * 100.0 : 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vista Previa',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSizes.spacing12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Porcentaje:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(percentage),
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor:
                  isDark ? AppColors.darkSurface : AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getScoreColor(percentage),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 90) return AppColors.priorityLow;
    if (percentage >= 70) return AppColors.secondary;
    if (percentage >= 60) return AppColors.priorityMedium;
    return AppColors.priorityCritical;
  }

  String _getTypeName(GradeType type) {
    switch (type) {
      case GradeType.exam:
        return 'Examen';
      case GradeType.quiz:
        return 'Prueba';
      case GradeType.homework:
        return 'Tarea';
      case GradeType.project:
        return 'Proyecto';
      case GradeType.participation:
        return 'Participación';
      case GradeType.other:
        return 'Otro';
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveGrade() async {
    if (!_formKey.currentState!.validate()) return;

    final weight = double.parse(_weightController.text);
    double? score;
    double? maxScore;
    if (_hasScore) {
      score = double.parse(_scoreController.text);
      maxScore = double.parse(_maxScoreController.text);
    }

    try {
      if (widget.grade != null) {
        // Update
        Grade updatedGrade;
        if (_hasScore) {
          updatedGrade = widget.grade!.copyWith(
            title: _titleController.text,
            score: score,
            maxScore: maxScore,
            weight: weight,
            type: _selectedType,
            date: _selectedDate,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
          );
        } else {
          // Pending: clear scores
          updatedGrade = widget.grade!
              .copyWith(
                title: _titleController.text,
                weight: weight,
                type: _selectedType,
                date: _selectedDate,
                notes: _notesController.text.isEmpty ? null : _notesController.text,
              )
              .copyWithNullableScore(score: null, maxScore: null);
        }
        await ref.read(gradesProvider.notifier).updateGrade(updatedGrade);
      } else {
        // Add
        await ref.read(gradesProvider.notifier).addGrade(
              courseId: widget.courseId,
              title: _titleController.text,
              score: score,
              maxScore: maxScore,
              weight: weight,
              type: _selectedType,
              date: _selectedDate,
              notes:
                  _notesController.text.isEmpty ? null : _notesController.text,
            );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.grade != null ? 'Nota actualizada' : 'Nota agregada',
            ),
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
    }
  }
}
