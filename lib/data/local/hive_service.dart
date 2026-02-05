import 'package:hive_flutter/hive_flutter.dart';
import '../models/course_model.dart';
import '../models/class_schedule_model.dart';
import '../models/evaluation_model.dart';
import '../models/grade_model.dart';
import '../models/user_settings_model.dart';

class HiveService {
  static const String coursesBox = 'courses';
  static const String classesBox = 'classes';
  static const String evaluationsBox = 'evaluations';
  static const String gradesBox = 'grades';
  static const String settingsBox = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Registrar adapters
    Hive.registerAdapter(CourseAdapter());
    Hive.registerAdapter(DayOfWeekAdapter());
    Hive.registerAdapter(TimeOfDayModelAdapter());
    Hive.registerAdapter(ClassScheduleAdapter());
    Hive.registerAdapter(EvaluationTypeAdapter());
    Hive.registerAdapter(PriorityAdapter());
    Hive.registerAdapter(SubtaskAdapter());
    Hive.registerAdapter(EvaluationAdapter());
    Hive.registerAdapter(GradeTypeAdapter());
    Hive.registerAdapter(GradeAdapter());
    Hive.registerAdapter(UserSettingsAdapter());

    // Abrir boxes
    await Hive.openBox<Course>(coursesBox);
    await Hive.openBox<ClassSchedule>(classesBox);
    await Hive.openBox<Evaluation>(evaluationsBox);
    await Hive.openBox<Grade>(gradesBox);
    await Hive.openBox<UserSettings>(settingsBox);
  }

  static Box<Course> get coursesBoxInstance => Hive.box<Course>(coursesBox);
  static Box<ClassSchedule> get classesBoxInstance =>
      Hive.box<ClassSchedule>(classesBox);
  static Box<Evaluation> get evaluationsBoxInstance =>
      Hive.box<Evaluation>(evaluationsBox);
  static Box<Grade> get gradesBoxInstance => Hive.box<Grade>(gradesBox);
  static Box<UserSettings> get settingsBoxInstance =>
      Hive.box<UserSettings>(settingsBox);

  static Future<void> clearAll() async {
    await coursesBoxInstance.clear();
    await classesBoxInstance.clear();
    await evaluationsBoxInstance.clear();
    await gradesBoxInstance.clear();
    await settingsBoxInstance.clear();
  }
}
