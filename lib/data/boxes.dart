import 'package:hive/hive.dart';

import 'models/habit.dart';
import 'models/habit_schedule.dart';
import 'models/habit_reminder.dart';
import 'models/habit_log.dart';
import 'models/user_profile.dart';
import 'models/app_settings.dart';

class Boxes {
  static const habits = 'habits';
  static const habitSchedules = 'habit_schedules';
  static const habitReminders = 'habit_reminders';
  static const habitLogs = 'habit_logs';
  static const userProfile = 'user_profile';
  static const appSettings = 'app_settings';

  static Box<Habit> habitsBox() => Hive.box<Habit>(habits);
  static Box<HabitSchedule> habitSchedulesBox() =>
      Hive.box<HabitSchedule>(habitSchedules);
  static Box<HabitReminder> habitRemindersBox() =>
      Hive.box<HabitReminder>(habitReminders);
  static Box<HabitLog> habitLogsBox() => Hive.box<HabitLog>(habitLogs);
  static Box<UserProfile> userProfileBox() =>
      Hive.box<UserProfile>(userProfile);
  static Box<AppSettings> appSettingsBox() =>
      Hive.box<AppSettings>(appSettings);
}
