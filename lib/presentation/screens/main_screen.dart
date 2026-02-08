import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import 'home/home_screen.dart';
import 'schedule/schedule_screen.dart';
import 'evaluations/evaluations_screen.dart';
import 'courses/courses_screen.dart';
import 'grades/grades_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ScheduleScreen(),
    EvaluationsScreen(),
    GradesScreen(),
    CoursesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Iconsax.home),
              activeIcon: Icon(Iconsax.home_15),
              label: AppStrings.navHome,
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.calendar),
              activeIcon: Icon(Iconsax.calendar_15),
              label: AppStrings.navSchedule,
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.task_square),
              activeIcon: Icon(Iconsax.task_square5),
              label: AppStrings.navEvaluations,
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.chart),
              activeIcon: Icon(Iconsax.chart5),
              label: 'Notas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.book),
              activeIcon: Icon(Iconsax.book_1),
              label: AppStrings.navCourses,
            ),
          ],
        ),
      ),
    );
  }
}
