import 'package:hive/hive.dart';
import 'enums.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  // Emoji
  @HiveField(3)
  final String? iconEmoji;

  // Couleur
  @HiveField(4)
  final int? colorValue;

  // Référence vers HabitSchedule.id (legacy)
  @HiveField(5)
  final String scheduleId;

  // Combien de fois par jour (1 par défaut)
  @HiveField(6)
  final int targetPerDay;

  // Minutes à viser pour une occurrence (facultatif)
  @HiveField(7)
  final int? targetDurationMinutes;

  @HiveField(8)
  final bool isArchived;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  // Pour ordonner dans la liste
  @HiveField(11)
  final int orderIndex;

  // Optionnel: catégories/tags
  @HiveField(12)
  final List<String>? tagIds;

  // === Nouveaux champs ===
  @HiveField(13)
  final TrackingType trackingType; // tâche, quantité, temps

  // Fréquence: daily/weekly/custom
  @HiveField(14)
  final String frequency; // 'daily' | 'weekly' | 'custom'

  // Si weekly: jours de semaine (1=lun..7=dim)
  @HiveField(15)
  final List<int>? weeklyDays;

  // Si custom: nb de fois/semaine
  @HiveField(16)
  final int? timesPerWeek;

  // Rappel à HH:mm (ex: 20:30)
  @HiveField(17)
  final String? reminderTime;

  // Dates de début/fin
  @HiveField(18)
  final DateTime? startDate;

  @HiveField(19)
  final DateTime? endDate; // null = jamais

  const Habit({
    required this.id,
    required this.title,
    this.description,
    this.iconEmoji,
    this.colorValue,
    required this.scheduleId,
    this.targetPerDay = 1,
    this.targetDurationMinutes,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
    this.orderIndex = 0,
    this.tagIds,
    this.trackingType = TrackingType.task,
    this.frequency = 'daily',
    this.weeklyDays,
    this.timesPerWeek,
    this.reminderTime,
    this.startDate,
    this.endDate,
  });
}
