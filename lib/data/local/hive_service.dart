import 'package:hive_flutter/hive_flutter.dart';
import '../models/course_model.dart';
import '../models/class_schedule_model.dart';
import '../models/evaluation_model.dart';
import '../models/grade_model.dart';
import '../models/semester_model.dart';
import '../models/user_settings_model.dart';
import '../models/app_settings_model.dart';

class HiveService {
  static const String coursesBox = 'courses';
  static const String classesBox = 'classes';
  static const String evaluationsBox = 'evaluations';
  static const String gradesBox = 'grades';
  static const String semestersBox = 'semesters';
  static const String settingsBox = 'settings';
  static const String appSettingsBox = 'app_settings';

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
    Hive.registerAdapter(SemesterAdapter());
    Hive.registerAdapter(UserSettingsAdapter());
    Hive.registerAdapter(ThemeModeAdapter());
    Hive.registerAdapter(AppSettingsAdapter());

    // Abrir boxes
    await Hive.openBox<Course>(coursesBox);
    await Hive.openBox<ClassSchedule>(classesBox);
    await Hive.openBox<Evaluation>(evaluationsBox);
    await Hive.openBox<Grade>(gradesBox);
    await Hive.openBox<Semester>(semestersBox);
    await Hive.openBox<UserSettings>(settingsBox);
    await Hive.openBox<AppSettings>(appSettingsBox);
  }

  static Box<Course> get coursesBoxInstance => Hive.box<Course>(coursesBox);
  static Box<ClassSchedule> get classesBoxInstance =>
      Hive.box<ClassSchedule>(classesBox);
  static Box<Evaluation> get evaluationsBoxInstance =>
      Hive.box<Evaluation>(evaluationsBox);
  static Box<Grade> get gradesBoxInstance => Hive.box<Grade>(gradesBox);
  static Box<Semester> get semestersBoxInstance => Hive.box<Semester>(semestersBox);
  static Box<UserSettings> get settingsBoxInstance =>
      Hive.box<UserSettings>(settingsBox);
  static Box<AppSettings> get appSettingsBoxInstance =>
      Hive.box<AppSettings>(appSettingsBox);

  static Future<void> clearAll() async {
    await coursesBoxInstance.clear();
    await classesBoxInstance.clear();
    await evaluationsBoxInstance.clear();
    await gradesBoxInstance.clear();
    await semestersBoxInstance.clear();
    await settingsBoxInstance.clear();
    await appSettingsBoxInstance.clear();
  }
}
