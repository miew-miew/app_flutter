import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/habit.dart';
import '../../data/models/enums.dart';
import '../../domain/services/habit_service.dart';

class _CardData {
  final String subtitle;
  final VoidCallback onTap;
  _CardData({required this.subtitle, required this.onTap});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = '';
  DateTime _selectedDate = DateTime.now();
  late List<DateTime> _weekDates;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _generateWeekDates();
  }

  void _generateWeekDates() {
    // Trouver le début de la semaine (lundi)
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    _weekDates = List.generate(7, (index) {
      return monday.add(Duration(days: index));
    });

    // Mettre à jour la date sélectionnée si elle n'est pas dans la semaine actuelle
    if (!_weekDates.contains(_selectedDate)) {
      _selectedDate = now;
    }
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? 'Utilisateur';
    setState(() {
      _userName = name;
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _previousWeek() {
    setState(() {
      _weekDates = _weekDates
          .map((date) => date.subtract(const Duration(days: 7)))
          .toList();
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _weekDates = _weekDates
          .map((date) => date.add(const Duration(days: 7)))
          .toList();
      _selectedDate = _selectedDate.add(const Duration(days: 7));
    });
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
      _generateWeekDates();
    });
  }

  String _getDayAbbreviation(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'MO';
      case DateTime.tuesday:
        return 'TU';
      case DateTime.wednesday:
        return 'WE';
      case DateTime.thursday:
        return 'TH';
      case DateTime.friday:
        return 'FR';
      case DateTime.saturday:
        return 'SA';
      case DateTime.sunday:
        return 'SU';
      default:
        return '';
    }
  }

  bool _isSelected(DateTime date) {
    return date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;
  }

  @override
  Widget build(BuildContext context) {
    final habitService = Provider.of<HabitService>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F6F1,
      ), // Fond crème comme dans le design
      body: SafeArea(
        child: Column(
          children: [
            // Header avec salutation
            _buildHeader(),

            // Bande de calendrier
            _buildCalendarStrip(),

            // Message motivant avec personnages
            _buildMotivationalSection(),

            // Liste des habitudes
            Expanded(child: _buildHabitsList(habitService)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Text(
            'Heyy, ',
            style: const TextStyle(fontSize: 24, color: Colors.black87),
          ),
          Text(
            _userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Text(
            ' !',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarStrip() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Boutons de navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _previousWeek,
                icon: const Icon(Icons.chevron_left, color: Colors.green),
              ),
              TextButton(
                onPressed: _goToToday,
                child: const Text(
                  'Aujourd\'hui',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: _nextWeek,
                icon: const Icon(Icons.chevron_right, color: Colors.green),
              ),
            ],
          ),
          // Bande de calendrier
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _weekDates.map((date) {
              return _buildCalendarDay(date);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(DateTime date) {
    final isSelected = _isSelected(date);
    final dayAbbr = _getDayAbbreviation(date.weekday);

    return GestureDetector(
      onTap: () => _selectDate(date),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dayAbbr,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.green : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.green : Colors.transparent,
              border: isSelected
                  ? null
                  : Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          const Text(
            "Commence ta journée avec un verre d'eau. Énergie garantie !",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCartoonCharacter('🔶', Colors.green),
              _buildCartoonCharacter('💧', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartoonCharacter(String emoji, Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color, width: 2),
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 30))),
    );
  }

  Widget _buildHabitsList(HabitService habitService) {
    // On mémorise la future pour éviter de relancer et de remonter la liste à chaque setState
    _habitsFuture ??= habitService.getTodayHabits();
    return FutureBuilder<List<Habit>>(
      future: _habitsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final habits = snapshot.data ?? [];
        if (habits.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: habits.length,
          itemBuilder: (context, index) {
            final habit = habits[index];
            return _buildHabitCard(habit, index);
          },
        );
      },
    );
  }

  Future<List<Habit>>? _habitsFuture;

  Widget _buildHabitCard(Habit habit, int index) {
    // Emoji réel de l'habitude
    final String icon = habit.iconEmoji?.trim().isNotEmpty == true
        ? habit.iconEmoji!.trim()
        : '✅';

    return FutureBuilder<_CardData>(
      future: _getCardData(habit),
      builder: (context, snapshot) {
        final card = snapshot.data ?? _fallbackCard(habit);
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icône de l'habitude
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 15),

              // Informations de l'habitude
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      card.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              GestureDetector(
                onTap: card.onTap,
                child: _buildTrailingAction(habit),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatMMSS(int minutes) {
    if (minutes <= 0) return '00:00';
    final int totalSeconds = minutes * 60;
    final int hours = totalSeconds ~/ 3600;
    final int mins = (totalSeconds % 3600) ~/ 60;
    final int secs = totalSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
    }
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildTrailingAction(Habit habit) {
    final svc = Provider.of<HabitService>(context, listen: false);
    switch (habit.trackingType) {
      case TrackingType.quantity:
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue.shade300, width: 2),
          ),
          child: Icon(Icons.add, color: Colors.blue.shade500, size: 20),
        );
      case TrackingType.time:
        final bool active = svc.isTimerActive(habit.id);
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.yellow.shade200,
            shape: BoxShape.circle,
          ),
          child: Icon(
            active ? Icons.pause : Icons.play_arrow,
            color: Colors.black87,
            size: 22,
          ),
        );
      case TrackingType.task:
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.red.shade300, width: 2),
          ),
        );
    }
  }

  Future<_CardData> _getCardData(Habit habit) async {
    final svc = Provider.of<HabitService>(context, listen: false);
    switch (habit.trackingType) {
      case TrackingType.quantity:
        final count = await svc.getTodayQuantityCount(habit.id);
        final target = habit.targetPerDay <= 1 ? 1 : habit.targetPerDay;
        return _CardData(
          subtitle: '$count/$target fois',
          onTap: () async {
            await svc.incrementQuantityToday(habit);
            if (mounted) setState(() {});
          },
        );
      case TrackingType.time:
        final minutes = await svc.getTodayDurationMinutes(habit.id);
        final targetMin = habit.targetDurationMinutes ?? 0;
        return _CardData(
          subtitle: '${_formatMMSS(minutes)}/${_formatMMSS(targetMin)}',
          onTap: () async {
            await svc.toggleTimeTracking(habit);
            if (mounted) setState(() {});
          },
        );
      case TrackingType.task:
        final done = await svc.isTaskCompletedToday(habit.id);
        return _CardData(
          subtitle: done ? 'Complété' : 'Non complété',
          onTap: () async {
            if (!done) {
              await svc.completeTaskToday(habit);
              if (mounted) setState(() {});
            }
          },
        );
    }
  }

  _CardData _fallbackCard(Habit habit) {
    switch (habit.trackingType) {
      case TrackingType.quantity:
        return _CardData(
          subtitle: '0/${habit.targetPerDay} fois',
          onTap: () {},
        );
      case TrackingType.time:
        final int targetMin = habit.targetDurationMinutes ?? 0;
        return _CardData(
          subtitle: '${_formatMMSS(0)}/${_formatMMSS(targetMin)}',
          onTap: () {},
        );
      case TrackingType.task:
        return _CardData(subtitle: 'Non complété', onTap: () {});
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_task, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          const Text(
            "Ajouter vos habitudes",
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 6),
            // Bouton vert "+ Nouvelle habitude"
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final created = await Navigator.of(
                    context,
                  ).pushNamed('/create-habit');
                  if (created == true && mounted) {
                    // Réinitialiser la future pour forcer un nouveau fetch
                    _habitsFuture = null;
                    setState(() {});
                  }
                },
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Nouvelle habitude',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Icône paramètres
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/settings');
              },
              icon: const Icon(Icons.settings, color: Colors.white70),
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}
