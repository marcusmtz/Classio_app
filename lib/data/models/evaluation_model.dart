import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'evaluation_model.g.dart';

@HiveType(typeId: 4)
enum EvaluationType {
  @HiveField(0)
  exam,
  @HiveField(1)
  task,
  @HiveField(2)
  project,
}

@HiveType(typeId: 5)
enum Priority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
  @HiveField(3)
  critical,
}

@HiveType(typeId: 6)
class Subtask extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final bool isCompleted;

  @HiveField(3)
  final int order;

  const Subtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.order,
  });

  Subtask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    int? order,
  }) {
    return Subtask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [id, title, isCompleted, order];
}

@HiveType(typeId: 7)
class Evaluation extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String courseId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final EvaluationType type;

  @HiveField(5)
  final DateTime dueDate;

  @HiveField(6)
  final Priority priority;

  @HiveField(7)
  final bool isCompleted;

  @HiveField(8)
  final DateTime? completedAt;

  @HiveField(9)
  final List<Subtask>? subtasks;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final bool isPriorityManual;

  const Evaluation({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.type,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
    this.completedAt,
    this.subtasks,
    required this.createdAt,
    this.isPriorityManual = false,
  });

  Evaluation copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    EvaluationType? type,
    DateTime? dueDate,
    Priority? priority,
    bool? isCompleted,
    DateTime? completedAt,
    List<Subtask>? subtasks,
    DateTime? createdAt,
    bool? isPriorityManual,
  }) {
    return Evaluation(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      subtasks: subtasks ?? this.subtasks,
      createdAt: createdAt ?? this.createdAt,
      isPriorityManual: isPriorityManual ?? this.isPriorityManual,
    );
  }

  double get progress {
    if (subtasks == null || subtasks!.isEmpty) {
      return isCompleted ? 1.0 : 0.0;
    }
    final completed = subtasks!.where((s) => s.isCompleted).length;
    return completed / subtasks!.length;
  }

  @override
  List<Object?> get props => [
        id,
        courseId,
        title,
        description,
        type,
        dueDate,
        priority,
        isCompleted,
        completedAt,
        subtasks,
        createdAt,
        isPriorityManual,
      ];
}
