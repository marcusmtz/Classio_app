import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/models/course_model.dart';
import '../../providers/courses_provider.dart';
import 'widgets/color_picker_grid.dart';

class CourseFormScreen extends ConsumerStatefulWidget {
  final Course? course;

  const CourseFormScreen({super.key, this.course});

  @override
  ConsumerState<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends ConsumerState<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  int _selectedColorValue = AppColors.courseColors[0].value;

  bool get isEditing => widget.course != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.course!.name;
      _codeController.text = widget.course!.code;
      _selectedColorValue = widget.course!.colorValue;
    }

    // Agregar listeners para actualizar la vista previa en tiempo real
    _nameController.addListener(() {
      setState(() {});
    });
    _codeController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.editCourse : AppStrings.addCourse),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.spacing20),
          children: [
            // Course name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Curso',
                hintText: 'Ej: Cálculo II',
                prefixIcon: Icon(Iconsax.book),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa el nombre del curso';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spacing16),

            // Course code field
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Código del Curso',
                hintText: 'Ej: MAT201',
                prefixIcon: Icon(Iconsax.code),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa el código del curso';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spacing32),

            // Color picker section
            Text(
              AppStrings.courseColor,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSizes.spacing16),
            ColorPickerGrid(
              selectedColorValue: _selectedColorValue,
              onColorSelected: (colorValue) {
                setState(() {
                  _selectedColorValue = colorValue;
                });
              },
            ),
            const SizedBox(height: AppSizes.spacing32),

            // Preview card
            Container(
              padding: const EdgeInsets.all(AppSizes.spacing16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vista Previa',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: AppSizes.spacing12),
                  Container(
                    padding: const EdgeInsets.all(AppSizes.spacing16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkSurface
                          : AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMedium),
                      border: Border.all(
                        color: Color(_selectedColorValue),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(_selectedColorValue)
                                .withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMedium),
                          ),
                          child: Center(
                            child: Icon(
                              Iconsax.book_1,
                              color: Color(_selectedColorValue),
                              size: AppSizes.iconMedium,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.spacing12),
                        Expanded(
                          child: Text(
                            _nameController.text.isEmpty
                                ? 'Nombre del curso'
                                : _nameController.text,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          child: ElevatedButton(
            onPressed: _saveCourse,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
            ),
            child: Text(isEditing ? 'Actualizar Curso' : 'Crear Curso'),
          ),
        ),
      ),
    );
  }

  void _saveCourse() {
    if (!_formKey.currentState!.validate()) return;

    final coursesNotifier = ref.read(coursesProvider.notifier);

    if (isEditing) {
      coursesNotifier.updateCourse(
        widget.course!.copyWith(
          name: _nameController.text.trim(),
          code: _codeController.text.trim().toUpperCase(),
          colorValue: _selectedColorValue,
        ),
      );
    } else {
      coursesNotifier.addCourse(
        name: _nameController.text.trim(),
        code: _codeController.text.trim().toUpperCase(),
        colorValue: _selectedColorValue,
      );
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing
              ? 'Curso actualizado exitosamente'
              : 'Curso creado exitosamente',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
