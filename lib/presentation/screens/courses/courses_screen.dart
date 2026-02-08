import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../providers/courses_provider.dart';
import '../../../data/models/course_model.dart';
import 'course_form_screen.dart';
import 'widgets/course_card.dart';
import 'widgets/empty_courses_state.dart';

class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key});

  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Course> _filteredCourses = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredCourses = [];
      }
    });
  }

  void _filterCourses(String query, List<Course> allCourses) {
    if (query.isEmpty) {
      setState(() {
        _filteredCourses = [];
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredCourses = allCourses.where((course) {
        return course.name.toLowerCase().contains(lowercaseQuery) ||
            course.code.toLowerCase().contains(lowercaseQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final allCourses = ref.watch(activeCoursesProvider);
    final coursesToShow =
        _searchController.text.isEmpty ? allCourses : _filteredCourses;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar cursos...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.textTertiary),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                    ),
                onChanged: (query) => _filterCourses(query, allCourses),
              )
            : const Text(AppStrings.courses),
        actions: [
          if (allCourses.isNotEmpty)
            IconButton(
              icon: Icon(
                  _isSearching ? Iconsax.close_square : Iconsax.search_normal),
              onPressed: _toggleSearch,
            ),
        ],
      ),
      body: allCourses.isEmpty
          ? const EmptyCoursesState()
          : coursesToShow.isEmpty && _searchController.text.isNotEmpty
              ? _buildNoResultsState()
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.spacing16),
                  itemCount: coursesToShow.length,
                  itemBuilder: (context, index) {
                    final course = coursesToShow[index];
                    return CourseCard(
                      course: course,
                      onTap: () {
                        // TODO: Navegar a detalle del curso
                      },
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CourseFormScreen(course: course),
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

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.search_status,
            size: 80,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSizes.spacing16),
          Text(
            'No se encontraron cursos',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            'Intenta con otro término de búsqueda',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
        ],
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
