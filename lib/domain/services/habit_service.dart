import 'package:app_flutter/data/models/habit.dart';
import 'package:app_flutter/domain/repositories/habit_repository.dart';
import 'package:app_flutter/data/models/enums.dart';
import 'package:app_flutter/data/models/habit_log.dart';
import 'package:app_flutter/data/models/habit_schedule.dart';
import 'package:app_flutter/data/boxes.dart';
import 'package:hive/hive.dart';

class HabitService {
  final HabitRepository _habitRepository;
  final Map<String, DateTime> _activeTimers = {};

  HabitService(this._habitRepository) {
    _loadActiveTimers();
  }

  /// Charge les timers actifs depuis la base de données
  Future<void> _loadActiveTimers() async {
    final Box<HabitLog> box = Boxes.habitLogsBox();
    final now = DateTime.now();

    // Récupérer tous les logs avec status "running" (timers actifs)
    final runningLogs = box.values.where(
      (log) => log.status == HabitStatus.running,
    );

    for (final log in runningLogs) {
      // Vérifier si le timer n'a pas expiré (plus de 24h)
      final startTime = log.eventTime;
      if (now.difference(startTime).inHours < 24) {
        _activeTimers[log.habitId] = startTime;
      } else {
        // Timer expiré, le marquer comme terminé
        final expiredLog = HabitLog(
          id: log.id,
          habitId: log.habitId,
          date: log.date,
          eventTime: log.eventTime,
          status: HabitStatus.done,
          countIndex: log.countIndex,
          durationMinutes: 24 * 60, // 24h max
          note: 'Timer expiré automatiquement',
        );
        await box.put(log.id, expiredLog);
      }
    }
  }

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

  /// Crée un nouveau schedule d'habitude
  Future<HabitSchedule> createHabitSchedule({
    required String id,
    required ScheduleType type,
    List<int>? daysOfWeek,
    List<String>? times,
    String? timezone,
    required DateTime startDate,
    DateTime? endDate,
    int? intervalN,
    List<DateTime>? specificDates,
  }) async {
    final schedule = HabitSchedule(
      id: id,
      type: type,
      daysOfWeek: daysOfWeek,
      times: times,
      timezone: timezone,
      startDate: startDate,
      endDate: endDate,
      intervalN: intervalN,
      specificDates: specificDates,
    );

    await _habitRepository.createHabitSchedule(schedule);
    return schedule;
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

  /// Récupère les habitudes actives pour une date donnée
  Future<List<Habit>> getHabitsForDate(DateTime date) async {
    final habits = await getAllHabits(includeArchived: false);
    final weekday = date.weekday; // 1=lundi, 7=dimanche

    // Récupérer tous les schedules pour vérifier la fréquence
    final schedules = await _habitRepository.getAllSchedules();
    final scheduleMap = {for (var s in schedules) s.id: s};

    // Filtrer les habitudes qui doivent être faites à cette date
    return habits
        .where((habit) {
          final schedule = scheduleMap[habit.scheduleId];
          if (schedule == null) {
            // Si pas de schedule, créer un schedule quotidien par défaut
            final defaultSchedule = HabitSchedule(
              id: habit.scheduleId,
              type: ScheduleType.daily,
              daysOfWeek: null,
              times: null,
              timezone: null,
              startDate: habit.createdAt,
              endDate: null,
              intervalN: null,
              specificDates: null,
            );
            scheduleMap[habit.scheduleId] = defaultSchedule;
            // Respect start/end
            if (_isOutsideRange(defaultSchedule, date)) return false;
            return true; // Habitude quotidienne par défaut à l'intérieur de la plage
          }
          // Respecter startDate / endDate
          if (_isOutsideRange(schedule, date)) return false;

          switch (schedule.type) {
            case ScheduleType.daily:
              // Habitudes quotidiennes : tous les jours
              return true;
            case ScheduleType.weekdays:
              // Habitudes en semaine : lundi à vendredi (1-5)
              return weekday >= 1 && weekday <= 5;
            case ScheduleType.customDays:
              // Habitudes personnalisées : seulement les jours spécifiés
              final daysOfWeek = schedule.daysOfWeek;
              if (daysOfWeek == null || daysOfWeek.isEmpty) return false;
              return daysOfWeek.contains(weekday);
            case ScheduleType.intervalN:
              // Habitudes tous les N jours : calculer depuis la date de début
              if (schedule.intervalN == null) return false;
              final daysSinceStart = date.difference(schedule.startDate).inDays;
              return daysSinceStart % schedule.intervalN! == 0;
            case ScheduleType.specificDates:
              // Habitudes à des dates précises
              final specificDates = schedule.specificDates;
              if (specificDates == null) return false;
              final dateKey = DateTime(date.year, date.month, date.day);
              return specificDates.any(
                (d) =>
                    DateTime(d.year, d.month, d.day).isAtSameMomentAs(dateKey),
              );
          }
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
              frequency: habit.frequency ?? 'daily',
              weeklyDays: habit.weeklyDays,
              reminderTime: habit.reminderTime,
              startDate: habit.startDate,
              endDate: habit.endDate,
            );
          }
          return habit;
        })
        .toList();
  }

  bool _isOutsideRange(HabitSchedule schedule, DateTime date) {
    final DateTime dayKey = _dayKey(date);
    final DateTime startKey = _dayKey(schedule.startDate);
    if (dayKey.isBefore(startKey)) return true;
    if (schedule.endDate != null) {
      final endKey = _dayKey(schedule.endDate!);
      if (dayKey.isAfter(endKey)) return true;
    }
    return false;
  }

  // === Requêtes par date (complétion) ===
  Future<int> getQuantityCountForDate(String habitId, DateTime date) async {
    final Box<HabitLog> box = Boxes.habitLogsBox();
    final DateTime key = _dayKey(date);
    return box.values
        .where(
          (l) => l.habitId == habitId && _dayKey(l.date).isAtSameMomentAs(key),
        )
        .length;
  }

  Future<int> getDurationSecondsForDate(String habitId, DateTime date) async {
    final Box<HabitLog> box = Boxes.habitLogsBox();
    final DateTime key = _dayKey(date);
    int secondsFromLogs = box.values
        .where(
          (l) =>
              l.habitId == habitId &&
              _dayKey(l.date).isAtSameMomentAs(key) &&
              l.status == HabitStatus.done,
        )
        .fold<int>(0, (sum, l) => sum + ((l.durationMinutes ?? 0) * 60));
    // Pour la journée courante, ajouter le timer actif si présent
    if (_dayKey(DateTime.now()).isAtSameMomentAs(key) &&
        _activeTimers.containsKey(habitId)) {
      final DateTime start = _activeTimers[habitId]!;
      final int runningSeconds = DateTime.now().difference(start).inSeconds;
      if (runningSeconds > 0) secondsFromLogs += runningSeconds;
    }
    return secondsFromLogs;
  }

  Future<bool> isTaskCompletedOnDate(String habitId, DateTime date) async {
    return (await getQuantityCountForDate(habitId, date)) > 0;
  }

  /// Statut pour un jour donné: complété/manqué/en attente
  Future<String> getDayStatus(String habitId, DateTime date) async {
    // Complété si au moins un log (done) ce jour
    final Box<HabitLog> box = Boxes.habitLogsBox();
    final DateTime key = _dayKey(date);
    final hasDone = box.values.any(
      (l) =>
          l.habitId == habitId &&
          _dayKey(l.date).isAtSameMomentAs(key) &&
          l.status == HabitStatus.done,
    );
    if (hasDone) return 'completed';

    final DateTime todayKey = _dayKey(DateTime.now());
    if (key.isAfter(todayKey)) return 'pending';
    // Jour passé et pas complété => manqué
    return 'missed';
  }

  /// Récupère les habitudes actives pour aujourd'hui
  Future<List<Habit>> getTodayHabits() async {
    return getHabitsForDate(DateTime.now());
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
      // Arrêt: arrêter le timer et créer un log avec la durée
      final DateTime start = _activeTimers.remove(habitId)!;
      final int minutes = now.difference(start).inMinutes;

      // Supprimer le log "running" s'il existe
      final runningLogs = box.values.where(
        (l) =>
            l.habitId == habitId &&
            l.status == HabitStatus.running &&
            _dayKey(l.date).isAtSameMomentAs(today),
      );
      for (final log in runningLogs) {
        await box.delete(log.id);
      }

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
      // Démarrage: créer un log "running" et démarrer le timer
      _activeTimers[habitId] = now;

      // Créer un log pour marquer le timer comme actif
      final HabitLog runningLog = HabitLog(
        id: _generateLogId(),
        habitId: habitId,
        date: today,
        eventTime: now,
        status: HabitStatus.running,
        countIndex: _countToday(box, habitId, today) + 1,
        durationMinutes: null,
        note: 'Timer actif',
      );
      await box.put(runningLog.id, runningLog);
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

    // Récupérer la durée depuis les logs terminés
    int minutesFromLogs = box.values
        .where(
          (l) =>
              l.habitId == habitId &&
              _dayKey(l.date).isAtSameMomentAs(today) &&
              l.status == HabitStatus.done,
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

    // Récupérer la durée depuis les logs terminés
    int secondsFromLogs = box.values
        .where(
          (l) =>
              l.habitId == habitId &&
              _dayKey(l.date).isAtSameMomentAs(today) &&
              l.status == HabitStatus.done,
        )
        .fold<int>(0, (sum, l) => sum + ((l.durationMinutes ?? 0) * 60));

    // Ajouter le temps en cours si un timer est actif
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

  // (doublon supprimé, utiliser la version basée sur getQuantityCountForDate)

  bool isTimerActive(String habitId) => _activeTimers.containsKey(habitId);
  bool hasActiveTimers() => _activeTimers.isNotEmpty;

  // Helpers
  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);
  String _generateLogId() => 'log_${DateTime.now().microsecondsSinceEpoch}';
  int _countToday(Box<HabitLog> box, String habitId, DateTime day) => box.values
      .where(
        (l) =>
            l.habitId == habitId &&
            _dayKey(l.date).isAtSameMomentAs(day) &&
            l.status == HabitStatus.done,
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

  /// Méthode de test pour créer une habitude "Relaxation" avec fréquence personnalisée
  Future<void> createTestRelaxationHabit() async {
    // Créer un schedule pour vendredi, samedi, dimanche (5, 6, 7)
    final scheduleId = 'test_relaxation_schedule';
    await createHabitSchedule(
      id: scheduleId,
      type: ScheduleType.daily,
      daysOfWeek: [5, 6, 7], // Vendredi, samedi, dimanche
      times: null,
      timezone: null,
      startDate: DateTime.now(),
      endDate: null,
      intervalN: null,
      specificDates: null,
    );

    // Créer l'habitude "Relaxation"
    await createHabit(
      title: 'Relaxation',
      scheduleId: scheduleId,
      iconEmoji: '🧘',
      targetPerDay: 1,
      trackingType: TrackingType.time,
      targetDurationSeconds: 300, // 5 minutes
    );
  }

  /// Méthode de test pour créer une habitude avec un timer actif
  Future<void> createTestHabitWithActiveTimer() async {
    // Créer un schedule quotidien
    final scheduleId = 'test_timer_schedule';
    await createHabitSchedule(
      id: scheduleId,
      type: ScheduleType.daily,
      daysOfWeek: null,
      times: null,
      timezone: null,
      startDate: DateTime.now(),
      endDate: null,
      intervalN: null,
      specificDates: null,
    );

    // Créer l'habitude "Test Timer"
    final habit = await createHabit(
      title: 'Test Timer',
      scheduleId: scheduleId,
      iconEmoji: '⏱️',
      targetPerDay: 1,
      trackingType: TrackingType.time,
      targetDurationSeconds: 60, // 1 minute
    );

    // Démarrer un timer pour cette habitude
    await toggleTimeTracking(habit);
  }
}
