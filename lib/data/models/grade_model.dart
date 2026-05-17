import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'grade_model.g.dart';

@HiveType(typeId: 8)
enum GradeType {
  @HiveField(0)
  exam,
  @HiveField(1)
  quiz,
  @HiveField(2)
  homework,
  @HiveField(3)
  project,
  @HiveField(4)
  participation,
  @HiveField(5)
  other,
}

@HiveType(typeId: 9)
class Grade extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String courseId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final GradeType type;

  @HiveField(4)
  final double score;

  @HiveField(5)
  final double maxScore;

  @HiveField(6)
  final double weight;

  @HiveField(7)
  final DateTime date;

  @HiveField(8)
  final String? notes;

  @HiveField(9)
  final DateTime createdAt;

  const Grade({
    required this.id,
    required this.courseId,
    required this.title,
    required this.type,
    required this.score,
    required this.maxScore,
    required this.weight,
    required this.date,
    this.notes,
    required this.createdAt,
  });

  Grade copyWith({
    String? id,
    String? courseId,
    String? title,
    GradeType? type,
    double? score,
    double? maxScore,
    double? weight,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
  }) {
    return Grade(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      type: type ?? this.type,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      weight: weight ?? this.weight,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        courseId,
        title,
        type,
        score,
        maxScore,
        weight,
        date,
        notes,
        createdAt
      ];
}
