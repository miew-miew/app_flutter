import 'package:app_flutter/data/models/habit.dart';
import 'package:app_flutter/domain/repositories/habit_repository.dart';
import 'package:app_flutter/data/models/enums.dart';
import 'package:app_flutter/data/models/habit_log.dart';
import 'package:app_flutter/data/boxes.dart';
import 'package:hive/hive.dart';

class HabitService {
  final HabitRepository _habitRepository;
  final Map<String, DateTime> _activeTimers = {};

  HabitService(this._habitRepository);

  /// Récupère toutes les habitudes (non archivées par défaut)
  Future<List<Habit>> getAllHabits({bool includeArchived = false}) async {
    final habits = await _habitRepository.getAllHabits();
    if (includeArchived) return habits;
    return habits.where((h) => !h.isArchived).toList();
  }

  /// Récupère une habitude par son ID
  Future<Habit?> getHabitById(String id) async {
    return await _habitRepository.getHabitById(id);
  }

  /// Crée une nouvelle habitude
  Future<Habit> createHabit({
    required String title,
    required String scheduleId,
    String? description,
    String? iconEmoji,
    int? colorValue,
    int targetPerDay = 1,
    int? targetDurationSeconds,
    List<String>? tagIds,
    TrackingType trackingType = TrackingType.task,
  }) async {
    final habit = Habit(
      id: _generateId(),
      title: title.trim(),
      description: description?.trim(),
      iconEmoji: iconEmoji,
      colorValue: colorValue,
      scheduleId: scheduleId,
      targetPerDay: targetPerDay,
      targetDurationSeconds: targetDurationSeconds,
      isArchived: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      orderIndex: await _getNextOrderIndex(),
      tagIds: tagIds,
      trackingType: trackingType,
    );

    await _habitRepository.createHabit(habit);
    return habit;
  }

  /// Met à jour une habitude existante
  Future<Habit> updateHabit({
    required String id,
    String? title,
    String? description,
    String? iconEmoji,
    int? colorValue,
    String? scheduleId,
    int? targetPerDay,
    int? targetDurationSeconds,
    List<String>? tagIds,
    TrackingType? trackingType,
  }) async {
    final existingHabit = await _habitRepository.getHabitById(id);
    if (existingHabit == null) {
      throw ArgumentError('Habitude non trouvée avec l\'ID: $id');
    }

    final updatedHabit = Habit(
      id: existingHabit.id,
      title: title ?? existingHabit.title,
      description: description ?? existingHabit.description,
      iconEmoji: iconEmoji ?? existingHabit.iconEmoji,
      colorValue: colorValue ?? existingHabit.colorValue,
      scheduleId: scheduleId ?? existingHabit.scheduleId,
      targetPerDay: targetPerDay ?? existingHabit.targetPerDay,
      targetDurationSeconds:
          targetDurationSeconds ?? existingHabit.targetDurationSeconds,
      isArchived: existingHabit.isArchived,
      createdAt: existingHabit.createdAt,
      updatedAt: DateTime.now(),
      orderIndex: existingHabit.orderIndex,
      tagIds: tagIds ?? existingHabit.tagIds,
      trackingType: trackingType ?? existingHabit.trackingType,
    );

    await _habitRepository.updateHabit(updatedHabit);
    return updatedHabit;
  }

  /// Supprime une habitude
  Future<void> deleteHabit(String id) async {
    final habit = await _habitRepository.getHabitById(id);
    if (habit == null) {
      throw ArgumentError('Habitude non trouvée avec l\'ID: $id');
    }

    await _habitRepository.deleteHabit(id);
  }

  /// Récupère les habitudes actives pour aujourd'hui
  Future<List<Habit>> getTodayHabits() async {
    final habits = await getAllHabits(includeArchived: false);

    // Filtrer les habitudes qui doivent être faites aujourd'hui
    return habits
        .where((habit) {
          // TODO: Plus tard, on pourra ajouter la logique de planning ici
          // - Habitudes quotidiennes (tous les jours)
          // - Habitudes en semaine (lundi à vendredi)
          // - Habitudes certains jours spécifiques
          return true;
        })
        .map((habit) {
          // Si trackingType est null, le définir par défaut comme task
          if (habit.trackingType == null) {
            return Habit(
              id: habit.id,
              title: habit.title,
              description: habit.description,
              iconEmoji: habit.iconEmoji,
              colorValue: habit.colorValue,
              scheduleId: habit.scheduleId,
              targetPerDay: habit.targetPerDay,
              targetDurationSeconds: habit.targetDurationSeconds,
              isArchived: habit.isArchived,
              createdAt: habit.createdAt,
              updatedAt: habit.updatedAt,
              orderIndex: habit.orderIndex,
              tagIds: habit.tagIds,
              trackingType: TrackingType.task, // Valeur par défaut
              frequency: habit.frequency,
              weeklyDays: habit.weeklyDays,
              timesPerWeek: habit.timesPerWeek,
              reminderTime: habit.reminderTime,
              startDate: habit.startDate,
              endDate: habit.endDate,
            );
          }
          return habit;
        })
        .toList();
  }

  // === UTILITAIRES ===

  /// Incrémente une occurrence pour une habitude de type quantité
  /// Retourne le nouveau compteur du jour
  Future<int> incrementQuantityToday(Habit habit) async {
    if (habit.trackingType != TrackingType.quantity) {
      throw ArgumentError(
        'incrementQuantityToday s\'applique aux habitudes quantité',
      );
    }
    final Box<HabitLog> box = Boxes.habitLogsBox();
    final DateTime today = _dayKey(DateTime.now());
    final logsToday = box.values.where(
      (l) => l.habitId == habit.id && _dayKey(l.date).isAtSameMomentAs(today),
    );
    final int current = logsToday.length;
    if (current >= habit.targetPerDay) {
      return current;
    }
    final int nextIndex = current + 1;
    final HabitLog log = HabitLog(
      id: _generateLogId(),
      habitId: habit.id,
      date: today,
      eventTime: DateTime.now(),
      status: HabitStatus.done,
      countIndex: nextIndex,
      durationMinutes: null,
      note: null,
    );
    await box.put(log.id, log);
    return nextIndex;
  }

  /// Démarre/arrête un suivi de temps pour une habitude de type temps
  /// Retourne la durée totale du jour (minutes)
  Future<int> toggleTimeTracking(Habit habit) async {
    if (habit.trackingType != TrackingType.time) {
      throw ArgumentError('toggleTimeTracking s\'applique aux habitudes temps');
    }
    final Box<HabitLog> box = Boxes.habitLogsBox();
    final String habitId = habit.id;
    final DateTime now = DateTime.now();
    final DateTime today = _dayKey(now);

    if (_activeTimers.containsKey(habitId)) {
      // Arrêt: créer un log avec la durée
      final DateTime start = _activeTimers.remove(habitId)!;
      final int minutes = now.difference(start).inMinutes;
      if (minutes > 0) {
        final HabitLog log = HabitLog(
          id: _generateLogId(),
          habitId: habitId,
          date: today,
          eventTime: now,
          status: HabitStatus.done,
          countIndex: _countToday(box, habitId, today) + 1,
          durationMinutes: minutes,
          note: null,
        );
        await box.put(log.id, log);
      }
    } else {
      // Démarrage
      _activeTimers[habitId] = now;
    }

    return await getTodayDurationMinutes(habitId);
  }

  /// Marque une tâche simple comme complétée aujourd'hui
  Future<void> completeTaskToday(Habit habit) async {
    if (habit.trackingType != TrackingType.task) {
      throw ArgumentError('completeTaskToday s\'applique aux tâches simples');
    }
    final Box<HabitLog> box = Boxes.habitLogsBox();
    final DateTime today = _dayKey(DateTime.now());
    final logsToday = box.values.where(
      (l) => l.habitId == habit.id && _dayKey(l.date).isAtSameMomentAs(today),
    );
    if (logsToday.isNotEmpty) return; // déjà fait
    final HabitLog log = HabitLog(
      id: _generateLogId(),
      habitId: habit.id,
      date: today,
      eventTime: DateTime.now(),
      status: HabitStatus.done,
      countIndex: 1,
      durationMinutes: null,
      note: null,
    );
    await box.put(log.id, log);
  }

  /// Retourne le nombre d'occurrences faites aujourd'hui (quantité ou tâche)
  Future<int> getTodayQuantityCount(String habitId) async {
    final Box<HabitLog> box = Boxes.habitLogsBox();
    final DateTime today = _dayKey(DateTime.now());
    return box.values
        .where(
          (l) =>
              l.habitId == habitId && _dayKey(l.date).isAtSameMomentAs(today),
        )
        .length;
  }

  /// Retourne la durée cumulée aujourd'hui (en minutes) pour une habitude temps
  Future<int> getTodayDurationMinutes(String habitId) async {
    final Box<HabitLog> box = Boxes.habitLogsBox();
    final DateTime today = _dayKey(DateTime.now());
    int minutesFromLogs = box.values
        .where(
          (l) =>
              l.habitId == habitId && _dayKey(l.date).isAtSameMomentAs(today),
        )
        .fold<int>(0, (sum, l) => sum + (l.durationMinutes ?? 0));

    // Ajouter le temps en cours si un timer est actif
    if (_activeTimers.containsKey(habitId)) {
      final DateTime start = _activeTimers[habitId]!;
      final int runningMinutes = DateTime.now().difference(start).inMinutes;
      if (runningMinutes > 0) {
        minutesFromLogs += runningMinutes;
      }
    }

    return minutesFromLogs;
  }

  /// Retourne la durée cumulée aujourd'hui (en secondes) pour une habitude temps
  Future<int> getTodayDurationSeconds(String habitId) async {
    final Box<HabitLog> box = Boxes.habitLogsBox();
    final DateTime today = _dayKey(DateTime.now());
    int secondsFromLogs = box.values
        .where(
          (l) =>
              l.habitId == habitId && _dayKey(l.date).isAtSameMomentAs(today),
        )
        .fold<int>(0, (sum, l) => sum + ((l.durationMinutes ?? 0) * 60));

    if (_activeTimers.containsKey(habitId)) {
      final DateTime start = _activeTimers[habitId]!;
      final int runningSeconds = DateTime.now().difference(start).inSeconds;
      if (runningSeconds > 0) {
        secondsFromLogs += runningSeconds;
      }
    }

    return secondsFromLogs;
  }

  /// Indique si une tâche simple est complétée aujourd'hui
  Future<bool> isTaskCompletedToday(String habitId) async {
    return (await getTodayQuantityCount(habitId)) > 0;
  }

  bool isTimerActive(String habitId) => _activeTimers.containsKey(habitId);
  bool hasActiveTimers() => _activeTimers.isNotEmpty;

  // Helpers
  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);
  String _generateLogId() => 'log_${DateTime.now().microsecondsSinceEpoch}';
  int _countToday(Box<HabitLog> box, String habitId, DateTime day) => box.values
      .where(
        (l) => l.habitId == habitId && _dayKey(l.date).isAtSameMomentAs(day),
      )
      .length;

  String _generateId() {
    return 'habit_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  Future<int> _getNextOrderIndex() async {
    final habits = await getAllHabits();
    if (habits.isEmpty) return 0;

    final maxOrder = habits
        .map((h) => h.orderIndex)
        .reduce((a, b) => a > b ? a : b);
    return maxOrder + 1;
  }
}
