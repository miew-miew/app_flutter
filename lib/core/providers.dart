import 'package:provider/provider.dart';
import '../data/repositories/habit_repository_impl.dart';
import '../domain/repositories/habit_repository.dart';
import '../domain/services/habit_service.dart';

/// Liste de tous les providers de l'application
final List<Provider> appProviders = [
  // Fournit l'implémentation du repository
  Provider<HabitRepository>(create: (_) => HabitRepositoryImpl()),

  // Fournit le service qui utilise le repository
  Provider<HabitService>(
    create: (context) => HabitService(context.read<HabitRepository>()),
  ),
];
