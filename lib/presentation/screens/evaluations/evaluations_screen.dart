import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/evaluations_provider.dart';
import '../../../data/models/evaluation_model.dart';
import 'evaluation_form_screen.dart';
import 'widgets/evaluation_card.dart';

class EvaluationsScreen extends ConsumerStatefulWidget {
  const EvaluationsScreen({super.key});

  @override
  ConsumerState<EvaluationsScreen> createState() => _EvaluationsScreenState();
}

class _EvaluationsScreenState extends ConsumerState<EvaluationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingEvaluations = ref.watch(pendingEvaluationsProvider);
    final allEvaluations = ref.watch(evaluationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.evaluations),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Iconsax.calendar), text: 'Calendario'),
            Tab(icon: Icon(Iconsax.task_square), text: 'Lista'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalendarView(allEvaluations),
          _buildListView(pendingEvaluations),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context),
        icon: const Icon(Iconsax.add),
        label: const Text('Nueva'),
      ),
    );
  }

  Widget _buildCalendarView(List<Evaluation> evaluations) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              return evaluations.where((e) {
                return e.dueDate.year == day.year &&
                    e.dueDate.month == day.month &&
                    e.dueDate.day == day.day;
              }).toList();
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),
        const SizedBox(height: 16),
        Expanded(
          child: _buildDayEvaluations(evaluations),
        ),
      ],
    );
  }

  Widget _buildDayEvaluations(List<Evaluation> allEvaluations) {
    final dayEvaluations = allEvaluations.where((e) {
      return e.dueDate.year == _selectedDay.year &&
          e.dueDate.month == _selectedDay.month &&
          e.dueDate.day == _selectedDay.day;
    }).toList();

    if (dayEvaluations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.calendar_tick,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay evaluaciones este día',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ).animate().fadeIn(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: dayEvaluations.length,
      itemBuilder: (context, index) {
        return EvaluationCard(
          evaluation: dayEvaluations[index],
          onTap: () => _navigateToForm(context, dayEvaluations[index]),
        ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: -0.1, end: 0);
      },
    );
  }

  Widget _buildListView(List<Evaluation> evaluations) {
    if (evaluations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.task_square,
              size: 80,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.noEvaluationsPending,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega tu primera evaluación',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ).animate().fadeIn(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: evaluations.length,
      itemBuilder: (context, index) {
        return EvaluationCard(
          evaluation: evaluations[index],
          onTap: () => _navigateToForm(context, evaluations[index]),
        ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: -0.1, end: 0);
      },
    );
  }

  void _navigateToForm(BuildContext context, [Evaluation? evaluation]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EvaluationFormScreen(evaluation: evaluation),
      ),
    );
  }
}
