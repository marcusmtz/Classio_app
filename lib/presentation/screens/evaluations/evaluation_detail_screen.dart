import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/evaluation_model.dart';
import '../../../data/models/course_model.dart';
import '../../providers/evaluations_provider.dart';
import '../../providers/courses_provider.dart';

class EvaluationDetailScreen extends ConsumerStatefulWidget {
  final Evaluation evaluation;

  const EvaluationDetailScreen({super.key, required this.evaluation});

  @override
  ConsumerState<EvaluationDetailScreen> createState() =>
      _EvaluationDetailScreenState();
}

class _EvaluationDetailScreenState
    extends ConsumerState<EvaluationDetailScreen> {
  final _subtaskController = TextEditingController();
  final _uuid = const Uuid();

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final evaluation = ref.watch(evaluationsProvider).firstWhere(
          (e) => e.id == widget.evaluation.id,
          orElse: () => widget.evaluation,
        );
    final courses = ref.watch(coursesProvider);
    Course? course;
    for (final item in courses) {
      if (item.id == evaluation.courseId) {
        course = item;
        break;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detalles'),
        actions: [
          IconButton(
            onPressed: () => _toggleCompleted(evaluation),
            icon: Icon(
              evaluation.isCompleted
                  ? Iconsax.tick_circle5
                  : Iconsax.tick_circle,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(evaluation, course),
          const SizedBox(height: 24),
          _buildInfoSection(evaluation),
          if (evaluation.description != null &&
              evaluation.description!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildDescriptionSection(evaluation),
          ],
          if (evaluation.type == EvaluationType.project) ...[
            const SizedBox(height: 24),
            _buildSubtasksSection(evaluation),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(Evaluation evaluation, Course? course) {
    final courseColor =
        course != null ? Color(course.colorValue) : AppColors.info;
    final courseName = course?.name ?? 'Curso eliminado';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            courseColor,
            courseColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTypeIcon(evaluation.type),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  evaluation.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            courseName,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeIcon(EvaluationType type) {
    IconData icon;
    switch (type) {
      case EvaluationType.exam:
        icon = Iconsax.document_text;
        break;
      case EvaluationType.task:
        icon = Iconsax.task;
        break;
      case EvaluationType.project:
        icon = Iconsax.folder;
        break;
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }

  Widget _buildInfoSection(Evaluation evaluation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Iconsax.calendar,
            label: 'Fecha de entrega',
            value: DateFormat('dd MMMM yyyy, HH:mm', 'es')
                .format(evaluation.dueDate),
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Iconsax.flag,
            label: 'Prioridad',
            value: _getPriorityLabel(evaluation.priority),
            valueColor: _getPriorityColor(evaluation.priority),
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Iconsax.status,
            label: 'Estado',
            value: evaluation.isCompleted ? 'Completada' : 'Pendiente',
            valueColor:
                evaluation.isCompleted ? AppColors.success : AppColors.warning,
          ),
          if (evaluation.isCompleted && evaluation.completedAt != null) ...[
            const Divider(height: 24),
            _buildInfoRow(
              icon: Iconsax.tick_circle,
              label: 'Completada el',
              value: DateFormat('dd MMMM yyyy, HH:mm', 'es')
                  .format(evaluation.completedAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(Evaluation evaluation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.note, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              const Text(
                'Descripción',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            evaluation.description!,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtasksSection(Evaluation evaluation) {
    final subtasks = evaluation.subtasks ?? [];
    final progress = evaluation.progress;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.task_square,
                  size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              const Text(
                'Subtareas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation(AppColors.success),
            ),
          ),
          const SizedBox(height: 16),
          ...subtasks.map((subtask) => _buildSubtaskItem(evaluation, subtask)),
          const SizedBox(height: 12),
          _buildAddSubtaskField(evaluation),
        ],
      ),
    );
  }

  Widget _buildSubtaskItem(Evaluation evaluation, Subtask subtask) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Checkbox(
            value: subtask.isCompleted,
            onChanged: (value) {
              final updatedSubtask = subtask.copyWith(isCompleted: value);
              ref
                  .read(evaluationsProvider.notifier)
                  .updateSubtask(evaluation.id, updatedSubtask);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Text(
              subtask.title,
              style: TextStyle(
                fontSize: 14,
                color: subtask.isCompleted
                    ? AppColors.textTertiary
                    : AppColors.textPrimary,
                decoration: subtask.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _deleteSubtask(evaluation, subtask),
            icon: const Icon(Iconsax.trash, size: 18),
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildAddSubtaskField(Evaluation evaluation) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _subtaskController,
            decoration: InputDecoration(
              hintText: 'Nueva subtarea...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onSubmitted: (_) => _addSubtask(evaluation),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _addSubtask(evaluation),
          icon: const Icon(Iconsax.add_circle),
          color: AppColors.primary,
          iconSize: 32,
        ),
      ],
    );
  }

  void _addSubtask(Evaluation evaluation) {
    if (_subtaskController.text.trim().isEmpty) return;

    final subtasks = evaluation.subtasks ?? [];
    final newSubtask = Subtask(
      id: _uuid.v4(),
      title: _subtaskController.text.trim(),
      order: subtasks.length,
    );

    final updatedEvaluation = evaluation.copyWith(
      subtasks: [...subtasks, newSubtask],
    );

    ref.read(evaluationsProvider.notifier).updateEvaluation(updatedEvaluation);
    _subtaskController.clear();
  }

  void _deleteSubtask(Evaluation evaluation, Subtask subtask) {
    final subtasks = evaluation.subtasks ?? [];
    final updatedSubtasks = subtasks.where((s) => s.id != subtask.id).toList();

    final updatedEvaluation = evaluation.copyWith(subtasks: updatedSubtasks);
    ref.read(evaluationsProvider.notifier).updateEvaluation(updatedEvaluation);
  }

  void _toggleCompleted(Evaluation evaluation) {
    ref.read(evaluationsProvider.notifier).toggleCompleted(evaluation.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          evaluation.isCompleted
              ? 'Marcada como pendiente'
              : 'Marcada como completada',
        ),
      ),
    );
  }

  String _getPriorityLabel(Priority priority) {
    switch (priority) {
      case Priority.critical:
        return 'Crítica';
      case Priority.high:
        return 'Alta';
      case Priority.medium:
        return 'Media';
      case Priority.low:
        return 'Baja';
    }
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.critical:
        return AppColors.priorityCritical;
      case Priority.high:
        return AppColors.priorityHigh;
      case Priority.medium:
        return AppColors.priorityMedium;
      case Priority.low:
        return AppColors.priorityLow;
    }
  }
}
