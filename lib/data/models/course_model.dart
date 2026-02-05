import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'course_model.g.dart';

@HiveType(typeId: 0)
class Course extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String code;

  @HiveField(3)
  final int colorValue;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime? updatedAt;

  @HiveField(6)
  final bool isActive;

  const Course({
    required this.id,
    required this.name,
    required this.code,
    required this.colorValue,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  Course copyWith({
    String? id,
    String? name,
    String? code,
    int? colorValue,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, code, colorValue, createdAt, updatedAt, isActive];
}
