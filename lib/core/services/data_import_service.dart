import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide ThemeMode;
import '../../data/models/course_model.dart';
import '../../data/models/class_schedule_model.dart';
import '../../data/models/evaluation_model.dart';
import '../../data/models/grade_model.dart';
import '../../data/models/semester_model.dart';
import '../../data/models/app_settings_model.dart';

class DataImportService {
  /// Validar y parsear JSON de importación
  static Future<ImportResult> validateAndParseJson(String jsonString) async {
    try {
      final Map<String, dynamic> data = json.decode(jsonString);

      // Validar estructura básica
      if (!data.containsKey('app') || data['app'] != 'Classio') {
        return ImportResult.error(
            'El archivo no es un backup válido de Classio');
      }

      // Validar versión (opcional, para futuras migraciones)
      final version = data['version'] as String?;
      if (version == null) {
        return ImportResult.error(
            'El archivo no contiene información de versión');
      }

      // Parsear datos
      final courses = await _parseCourses(data['courses'] as List?);
      final semesters = await _parseSemesters(data['semesters'] as List?);
      final schedules = await _parseSchedules(data['schedule'] as List?);
      final evaluations = await _parseEvaluations(data['evaluations'] as List?);
      final grades = await _parseGrades(data['grades'] as List?);
      final settings =
          await _parseSettings(data['appSettings'] as Map<String, dynamic>?);

      return ImportResult.success(
        courses: courses,
        semesters: semesters,
        schedules: schedules,
        evaluations: evaluations,
        grades: grades,
        settings: settings,
        generatedAt: data['generatedAt'] as String?,
      );
    } catch (e) {
      debugPrint('Error parsing import data: $e');
      return ImportResult.error(
          'Error al procesar el archivo: ${e.toString()}');
    }
  }

  /// Parsear cursos
  static Future<List<Course>> _parseCourses(List? coursesData) async {
    if (coursesData == null) return [];

    final courses = <Course>[];
    for (final item in coursesData) {
      try {
        final courseMap = item as Map<String, dynamic>;
        courses.add(Course(
          id: courseMap['id'] as String,
          name: courseMap['name'] as String,
          code: courseMap['code'] as String,
          colorValue: courseMap['colorValue'] as int,
          createdAt: DateTime.parse(courseMap['createdAt'] as String),
          updatedAt: courseMap['updatedAt'] != null
              ? DateTime.parse(courseMap['updatedAt'] as String)
              : null,
          isActive: courseMap['isActive'] as bool? ?? true,
          semesterId: courseMap['semesterId'] as String?,
        ));
      } catch (e) {
        debugPrint('Error parsing course: $e');
      }
    }
    return courses;
  }

  static Future<List<Semester>> _parseSemesters(List? semestersData) async {
    if (semestersData == null) return [];
    final semesters = <Semester>[];
    for (final item in semestersData) {
      try {
        final map = item as Map<String, dynamic>;
        semesters.add(Semester(
          id: map['id'] as String,
          name: map['name'] as String,
          createdAt: DateTime.parse(map['createdAt'] as String),
          startDate: map['startDate'] != null ? DateTime.parse(map['startDate'] as String) : null,
          endDate: map['endDate'] != null ? DateTime.parse(map['endDate'] as String) : null,
          isArchived: map['isArchived'] as bool? ?? false,
          updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : null,
        ));
      } catch (e) {
        debugPrint('Error parsing semester: $e');
      }
    }
    return semesters;
  }

  /// Parsear horarios
  static Future<List<ClassSchedule>> _parseSchedules(
      List? schedulesData) async {
    if (schedulesData == null) return [];

    final schedules = <ClassSchedule>[];
    for (final item in schedulesData) {
      try {
        final scheduleMap = item as Map<String, dynamic>;
        final startTimeMap = scheduleMap['startTime'] as Map<String, dynamic>;
        final endTimeMap = scheduleMap['endTime'] as Map<String, dynamic>;

        schedules.add(ClassSchedule(
          id: scheduleMap['id'] as String,
          courseId: scheduleMap['courseId'] as String,
          dayOfWeek: DayOfWeek.values.firstWhere(
            (e) => e.name == scheduleMap['dayOfWeek'],
          ),
          startTime: TimeOfDayModel(
            hour: startTimeMap['hour'] as int,
            minute: startTimeMap['minute'] as int,
          ),
          endTime: TimeOfDayModel(
            hour: endTimeMap['hour'] as int,
            minute: endTimeMap['minute'] as int,
          ),
          location: scheduleMap['location'] as String?,
          professor: scheduleMap['professor'] as String?,
          isRecurrent: scheduleMap['isRecurrent'] as bool? ?? true,
          createdAt: DateTime.parse(scheduleMap['createdAt'] as String),
        ));
      } catch (e) {
        debugPrint('Error parsing schedule: $e');
      }
    }
    return schedules;
  }

  /// Parsear evaluaciones
  static Future<List<Evaluation>> _parseEvaluations(
      List? evaluationsData) async {
    if (evaluationsData == null) return [];

    final evaluations = <Evaluation>[];
    for (final item in evaluationsData) {
      try {
        final evalMap = item as Map<String, dynamic>;

        // Parsear subtareas
        List<Subtask>? subtasks;
        if (evalMap['subtasks'] != null) {
          subtasks = (evalMap['subtasks'] as List).map((st) {
            final stMap = st as Map<String, dynamic>;
            return Subtask(
              id: stMap['id'] as String,
              title: stMap['title'] as String,
              isCompleted: stMap['isCompleted'] as bool,
              order: stMap['order'] as int,
            );
          }).toList();
        }

        evaluations.add(Evaluation(
          id: evalMap['id'] as String,
          courseId: evalMap['courseId'] as String,
          title: evalMap['title'] as String,
          description: evalMap['description'] as String?,
          type: EvaluationType.values.firstWhere(
            (e) => e.name == evalMap['type'],
          ),
          dueDate: DateTime.parse(evalMap['dueDate'] as String),
          priority: Priority.values.firstWhere(
            (e) => e.name == evalMap['priority'],
          ),
          isCompleted: evalMap['isCompleted'] as bool,
          completedAt: evalMap['completedAt'] != null
              ? DateTime.parse(evalMap['completedAt'] as String)
              : null,
          isPriorityManual: evalMap['isPriorityManual'] as bool? ?? false,
          createdAt: DateTime.parse(evalMap['createdAt'] as String),
          subtasks: subtasks,
        ));
      } catch (e) {
        debugPrint('Error parsing evaluation: $e');
      }
    }
    return evaluations;
  }

  /// Parsear notas
  static Future<List<Grade>> _parseGrades(List? gradesData) async {
    if (gradesData == null) return [];

    final grades = <Grade>[];
    for (final item in gradesData) {
      try {
        final gradeMap = item as Map<String, dynamic>;
        grades.add(Grade(
          id: gradeMap['id'] as String,
          courseId: gradeMap['courseId'] as String,
          title: gradeMap['title'] as String,
          type: GradeType.values.firstWhere(
            (e) => e.name == gradeMap['type'],
          ),
          score: gradeMap['score'] != null ? (gradeMap['score'] as num).toDouble() : null,
          maxScore: gradeMap['maxScore'] != null ? (gradeMap['maxScore'] as num).toDouble() : null,
          weight: (gradeMap['weight'] as num).toDouble(),
          date: DateTime.parse(gradeMap['date'] as String),
          notes: gradeMap['notes'] as String?,
          createdAt: DateTime.parse(gradeMap['createdAt'] as String),
        ));
      } catch (e) {
        debugPrint('Error parsing grade: $e');
      }
    }
    return grades;
  }

  /// Parsear configuración
  static Future<AppSettings?> _parseSettings(
      Map<String, dynamic>? settingsData) async {
    if (settingsData == null) return null;

    try {
      return AppSettings(
        themeMode: ThemeMode.values.firstWhere(
          (e) => e.name == settingsData['themeMode'],
          orElse: () => ThemeMode.system,
        ),
        notificationsEnabled:
            settingsData['notificationsEnabled'] as bool? ?? true,
        widgetEnabled: settingsData['widgetEnabled'] as bool? ?? false,
        language: settingsData['language'] as String? ?? 'es',
        showSaturday: settingsData['showSaturday'] as bool? ?? false,
        showSunday: settingsData['showSunday'] as bool? ?? false,
        userName: settingsData['userName'] as String?,
        activeSemesterId: settingsData['activeSemesterId'] as String?,
        lastUpdated: settingsData['lastUpdated'] != null
            ? DateTime.parse(settingsData['lastUpdated'] as String)
            : null,
      );
    } catch (e) {
      debugPrint('Error parsing settings: $e');
      return null;
    }
  }
}

/// Resultado de la importación
class ImportResult {
  final bool success;
  final String? error;
  final List<Course> courses;
  final List<Semester> semesters;
  final List<ClassSchedule> schedules;
  final List<Evaluation> evaluations;
  final List<Grade> grades;
  final AppSettings? settings;
  final String? generatedAt;

  ImportResult._({
    required this.success,
    this.error,
    this.courses = const [],
    this.semesters = const [],
    this.schedules = const [],
    this.evaluations = const [],
    this.grades = const [],
    this.settings,
    this.generatedAt,
  });

  factory ImportResult.success({
    required List<Course> courses,
    List<Semester> semesters = const [],
    required List<ClassSchedule> schedules,
    required List<Evaluation> evaluations,
    required List<Grade> grades,
    AppSettings? settings,
    String? generatedAt,
  }) {
    return ImportResult._(
      success: true,
      courses: courses,
      semesters: semesters,
      schedules: schedules,
      evaluations: evaluations,
      grades: grades,
      settings: settings,
      generatedAt: generatedAt,
    );
  }

  factory ImportResult.error(String message) {
    return ImportResult._(
      success: false,
      error: message,
    );
  }

  int get totalItems =>
      courses.length + semesters.length + schedules.length + evaluations.length + grades.length;
}
