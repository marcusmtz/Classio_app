import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'class_schedule_model.g.dart';

@HiveType(typeId: 1)
enum DayOfWeek {
  @HiveField(0)
  monday,
  @HiveField(1)
  tuesday,
  @HiveField(2)
  wednesday,
  @HiveField(3)
  thursday,
  @HiveField(4)
  friday,
  @HiveField(5)
  saturday,
  @HiveField(6)
  sunday,
}

@HiveType(typeId: 2)
class TimeOfDayModel extends Equatable implements Comparable<TimeOfDayModel> {
  @HiveField(0)
  final int hour;

  @HiveField(1)
  final int minute;

  const TimeOfDayModel({
    required this.hour,
    required this.minute,
  });

  String toFormattedString() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String format() {
    return toFormattedString();
  }

  @override
  int compareTo(TimeOfDayModel other) {
    final thisMinutes = hour * 60 + minute;
    final otherMinutes = other.hour * 60 + other.minute;
    return thisMinutes.compareTo(otherMinutes);
  }

  @override
  List<Object?> get props => [hour, minute];
}

@HiveType(typeId: 3)
class ClassSchedule extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String courseId;

  @HiveField(2)
  final DayOfWeek dayOfWeek;

  @HiveField(3)
  final TimeOfDayModel startTime;

  @HiveField(4)
  final TimeOfDayModel endTime;

  @HiveField(5)
  final String? location;

  @HiveField(6)
  final String? professor;

  @HiveField(7)
  final bool isRecurrent;

  @HiveField(8)
  final DateTime createdAt;

  const ClassSchedule({
    required this.id,
    required this.courseId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.location,
    this.professor,
    this.isRecurrent = true,
    required this.createdAt,
  });

  ClassSchedule copyWith({
    String? id,
    String? courseId,
    DayOfWeek? dayOfWeek,
    TimeOfDayModel? startTime,
    TimeOfDayModel? endTime,
    String? location,
    String? professor,
    bool? isRecurrent,
    DateTime? createdAt,
  }) {
    return ClassSchedule(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      professor: professor ?? this.professor,
      isRecurrent: isRecurrent ?? this.isRecurrent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        courseId,
        dayOfWeek,
        startTime,
        endTime,
        location,
        professor,
        isRecurrent,
        createdAt,
      ];
}
