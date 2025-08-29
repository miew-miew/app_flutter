import 'package:app_flutter/data/models/enums.dart';
import 'package:app_flutter/data/models/habit.dart';
import 'package:app_flutter/data/models/habit_log.dart';
import 'package:app_flutter/data/models/habit_reminder.dart';
import 'package:app_flutter/data/models/habit_schedule.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/onboarding_page.dart';
import 'presentation/pages/create_habit_page.dart';
import 'presentation/pages/settings_page.dart';
import 'presentation/pages/edit_habit_page.dart';
import 'data/boxes.dart';
import 'core/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Initialisation de Hive
  await Hive.initFlutter();

  Hive
    ..registerAdapter(HabitAdapter())
    ..registerAdapter(HabitScheduleAdapter())
    ..registerAdapter(HabitReminderAdapter())
    ..registerAdapter(HabitLogAdapter())
    ..registerAdapter(ScheduleTypeAdapter())
    ..registerAdapter(HabitStatusAdapter())
    ..registerAdapter(TrackingTypeAdapter());

  await Hive.openBox<Habit>(Boxes.habits);
  await Hive.openBox<HabitSchedule>(Boxes.habitSchedules);
  await Hive.openBox<HabitLog>(Boxes.habitLogs);

  // Migration légère des données existantes (sécurisation nulls)
  // await _migrateLegacySchedules();
  // Migration des statuts/typos de schedule avant suppression d'enums
  // await _migrateStatusesAndSchedules();

  // Debug: afficher les habitudes et leurs schedules (une fois au démarrage)
  _debugPrintHabitsAndSchedules();

  runApp(const MyApp());
}

// Future<void> _migrateLegacySchedules() async {
//   final box = Hive.box<HabitSchedule>(Boxes.habitSchedules);
//   final now = DateTime.now();
//   final today = DateTime(now.year, now.month, now.day);
//   for (final key in box.keys) {
//     final sched = box.get(key);
//     if (sched == null) continue;
//     DateTime start = sched.startDate ?? today;
//     DateTime? end = sched.endDate;
//     if (end != null && end.isBefore(start)) {
//       end = null;
//     }
//     if (start != sched.startDate || end != sched.endDate) {
//       final fixed = HabitSchedule(
//         id: sched.id,
//         type: sched.type,
//         daysOfWeek: sched.daysOfWeek,
//         times: sched.times,
//         timezone: sched.timezone,
//         startDate: start,
//         endDate: end,
//         intervalN: sched.intervalN,
//         specificDates: sched.specificDates,
//       );
//       await box.put(sched.id, fixed);
//     }
//   }
// }


//à supprimer
// Future<void> _migrateStatusesAndSchedules() async {
//   // Remapper anciens statuts vers valeurs actives (skipped -> missed)
//   final logs = Hive.box<HabitLog>(Boxes.habitLogs);
//   final List<HabitLog> toUpdateLogs = [];
//   for (final log in logs.values) {
//     // Note: skipped n'existe plus dans l'enum; on détecte par index brut
//     // si l'adapter lit une valeur inconnue, elle peut échouer. Ici, on
//     // ne peut plus référencer HabitStatus.skipped; on tente le remap
//     // uniquement si la valeur décodée correspond encore à missed/done/running.
//     // Si vous avez encore des données avec 'skipped', exécutez cette
//     // migration avant de supprimer les anciennes valeurs.
//     if (log.status == HabitStatus.missed) {
//       toUpdateLogs.add(
//         HabitLog(
//           id: log.id,
//           habitId: log.habitId,
//           date: log.date,
//           eventTime: log.eventTime,
//           status: HabitStatus.missed,
//           countIndex: log.countIndex,
//           durationMinutes: log.durationMinutes,
//           note: log.note,
//         ),
//       );
//     }
//   }
//   for (final l in toUpdateLogs) {
//     await logs.put(l.id, l);
//   }

//   // Convertir schedules intervalN/specificDates en daily (en conservant start/end)
//   final schedules = Hive.box<HabitSchedule>(Boxes.habitSchedules);
//   final List<HabitSchedule> toUpdateSchedules = [];
//   for (final sched in schedules.values) {
//     final isActiveType =
//         sched.type == ScheduleType.daily ||
//         sched.type == ScheduleType.weekdays ||
//         sched.type == ScheduleType.customDays;
//     if (!isActiveType) {
//       toUpdateSchedules.add(
//         HabitSchedule(
//           id: sched.id,
//           type: ScheduleType.daily,
//           daysOfWeek: null,
//           times: sched.times,
//           timezone: sched.timezone,
//           startDate: sched.startDate,
//           endDate: sched.endDate,
//           intervalN: null,
//           specificDates: null,
//         ),
//       );
//     }
//   }
//   for (final s in toUpdateSchedules) {
//     await schedules.put(s.id, s);
//   }
// }

void _debugPrintHabitsAndSchedules() {
  try {
    final habits = Hive.box<Habit>(Boxes.habits).values.toList();
    final schedBox = Hive.box<HabitSchedule>(Boxes.habitSchedules);
    // En-tête
    // ignore: avoid_print
    print('[DEBUG] Habits count: ${habits.length}');
    for (final h in habits) {
      final sched = schedBox.get(h.scheduleId);
      // ignore: avoid_print
      print(
        '[DEBUG] Habit{id=${h.id}, title=${h.title}, type=${h.trackingType}, '
        'targetPerDay=${h.targetPerDay}, targetDurationSeconds=${h.targetDurationSeconds}, '
        'reminderTime=${h.reminderTime}, createdAt=${h.createdAt.toIso8601String()}, '
        'updatedAt=${h.updatedAt.toIso8601String()}, scheduleId=${h.scheduleId}}',
      );
      if (sched != null) {
        // ignore: avoid_print
        print(
          '        Schedule{id=${sched.id}, type=${sched.type}, daysOfWeek=${sched.daysOfWeek}, '
          'times=${sched.times}, startDate=${sched.startDate}, endDate=${sched.endDate}}',
        );
      } else {
        // ignore: avoid_print
        print('        Schedule{missing for id=${h.scheduleId}}');
      }
    }
  } catch (_) {
    // no-op: debug only
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: appProviders,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MOE - Habit Tracker',
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashPage(),
          '/onboarding': (context) => const OnboardingPage(),
          '/home': (context) => const HomePage(),
          '/create-habit': (context) => const CreateHabitPage(),
          '/settings': (context) => const SettingsPage(),
          // Edit route expects arguments: { 'habitId': String }
          '/edit-habit': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map?;
            final habitId = args?['habitId'] as String?;
            if (habitId == null) {
              return const Scaffold(
                body: Center(child: Text('HabitId manquant')),
              );
            }
            return EditHabitPage(habitId: habitId);
          },
        },
      ),
    );
  }
}
