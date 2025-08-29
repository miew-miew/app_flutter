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

  runApp(const MyApp());
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
