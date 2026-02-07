import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../providers/schedule_provider.dart';
import 'schedule_form_screen.dart';
import 'widgets/schedule_grid_view.dart';
import 'widgets/schedule_list_view.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    final schedules = ref.watch(scheduleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Horario'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Semanal', icon: Icon(Iconsax.calendar_1)),
            Tab(text: 'Lista', icon: Icon(Iconsax.menu)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ScheduleGridView(schedules: schedules),
          ScheduleListView(schedules: schedules),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'schedule_fab',
        onPressed: () => _showAddScheduleDialog(context),
        icon: const Icon(Iconsax.add),
        label: const Text('Agregar Clase'),
      ),
    );
  }

  void _showAddScheduleDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScheduleFormScreen(),
      ),
    );
  }
}
