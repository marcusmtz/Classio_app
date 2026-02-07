import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../providers/courses_provider.dart';
import 'course_form_screen.dart';
import 'widgets/course_card.dart';
import 'widgets/empty_courses_state.dart';

class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(activeCoursesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.courses),
        actions: [
          if (courses.isNotEmpty)
            IconButton(
              icon: const Icon(Iconsax.search_normal),
              onPressed: () {
                // TODO: Implementar búsqueda
              },
            ),
        ],
      ),
      body: courses.isEmpty
          ? const EmptyCoursesState()
          : ListView.builder(
              padding: const EdgeInsets.all(AppSizes.spacing16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return CourseCard(
                  course: course,
                  onTap: () {
                    // TODO: Navegar a detalle del curso
                  },
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseFormScreen(course: course),
                      ),
                    );
                  },
                  onDelete: () {
                    _showDeleteDialog(context, ref, course.id, course.name);
                  },
                )
                    .animate(delay: (100 * index).ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.2, end: 0);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'courses_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CourseFormScreen(),
            ),
          );
        },
        icon: const Icon(Iconsax.add),
        label: const Text(AppStrings.addCourse),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String courseId,
    String courseName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteCourseConfirm),
        content: Text('¿Estás seguro de eliminar "$courseName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(coursesProvider.notifier).deleteCourse(courseId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppStrings.deleteSuccess),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}
