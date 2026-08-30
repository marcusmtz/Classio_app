import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'semester_model.g.dart';

@HiveType(typeId: 13)
class Semester extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final DateTime? startDate;

  @HiveField(4)
  final DateTime? endDate;

  @HiveField(5)
  final bool isArchived;

  @HiveField(6)
  final DateTime? updatedAt;

  const Semester({
    required this.id,
    required this.name,
    required this.createdAt,
    this.startDate,
    this.endDate,
    this.isArchived = false,
    this.updatedAt,
  });

  Semester copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? startDate,
    DateTime? endDate,
    bool? isArchived,
    DateTime? updatedAt,
  }) {
    return Semester(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isArchived: isArchived ?? this.isArchived,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, createdAt, startDate, endDate, isArchived, updatedAt];
}
