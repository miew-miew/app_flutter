import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

import '../../data/models/enums.dart';
import '../../domain/services/habit_service.dart';

class CreateHabitPage extends StatefulWidget {
  const CreateHabitPage({super.key});

  @override
  State<CreateHabitPage> createState() => _CreateHabitPageState();
}

class _CreateHabitPageState extends State<CreateHabitPage> {
  final _formKey = GlobalKey<FormState>();

  // Champs
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _emojiController = TextEditingController();
  TrackingType _trackingType = TrackingType.task;

  // Champs conditionnels
  final TextEditingController _quantityController = TextEditingController(
    text: '8',
  );
  Duration _timeDuration = const Duration(minutes: 25);

  String _frequency = 'daily'; // daily | custom
  final Set<int> _weeklyDays = {1, 2, 3, 4, 5, 6, 7}; // L..D par défaut

  TimeOfDay? _reminder;
  DateTime? _startDate = DateTime.now();
  bool _noEnd = true;
  DateTime? _endDate;

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _emojiController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final res = await showTimePicker(
      context: context,
      initialTime: _reminder ?? const TimeOfDay(hour: 20, minute: 30),
    );
    if (res != null) {
      setState(() => _reminder = res);
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final base = isStart
        ? (_startDate ?? today)
        : (_endDate ?? (_startDate ?? today).add(const Duration(days: 7)));
    final res = await showDatePicker(
      context: context,
      firstDate: isStart ? today : (_startDate ?? today),
      lastDate: DateTime(now.year + 10),
      initialDate: base,
    );
    if (res != null) {
      setState(() => isStart ? _startDate = res : _endDate = res);
    }
  }

  Future<void> _pickDuration() async {
    int hours = _timeDuration.inHours;
    int minutes = _timeDuration.inMinutes % 60;
    int seconds = _timeDuration.inSeconds % 60;

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 250,
          child: Row(
            children: [
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32,
                  scrollController: FixedExtentScrollController(
                    initialItem: hours,
                  ),
                  onSelectedItemChanged: (v) => hours = v,
                  children: List.generate(
                    24,
                    (i) => Center(child: Text('$i h')),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32,
                  scrollController: FixedExtentScrollController(
                    initialItem: minutes,
                  ),
                  onSelectedItemChanged: (v) => minutes = v,
                  children: List.generate(
                    60,
                    (i) => Center(child: Text('$i m')),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32,
                  scrollController: FixedExtentScrollController(
                    initialItem: seconds,
                  ),
                  onSelectedItemChanged: (v) => seconds = v,
                  children: List.generate(
                    60,
                    (i) => Center(child: Text('$i s')),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    setState(() {
      _timeDuration = Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
      );
    });
  }

  String? _timeToString(TimeOfDay? t) => t == null
      ? null
      : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final habitService = Provider.of<HabitService>(context, listen: false);

      // Mapper selon le type de suivi
      int targetPerDay = 1;
      int? targetDurationSeconds;
      if (_trackingType == TrackingType.quantity) {
        targetPerDay = int.tryParse(_quantityController.text.trim()) ?? 1;
      } else if (_trackingType == TrackingType.time) {
        targetDurationSeconds = _timeDuration.inSeconds;
      }

      // Créer un ID unique pour le schedule
      final scheduleId = 'schedule_${DateTime.now().millisecondsSinceEpoch}';

      // Déterminer le type de schedule
      ScheduleType scheduleType;
      List<int>? daysOfWeek;

      if (_frequency == 'daily') {
        scheduleType = ScheduleType.daily;
      } else if (_frequency == 'custom') {
        scheduleType = ScheduleType.customDays;
        daysOfWeek = List.from(_weeklyDays);
      } else {
        scheduleType = ScheduleType.daily; // Par défaut
      }

      // Créer le schedule d'abord
      await habitService.createHabitSchedule(
        id: scheduleId,
        type: scheduleType,
        daysOfWeek: daysOfWeek,
        times: _reminder != null
            ? [
                '${_reminder!.hour.toString().padLeft(2, '0')}:${_reminder!.minute.toString().padLeft(2, '0')}',
              ]
            : null,
        timezone: null,
        startDate: _startDate!,
        endDate: _noEnd ? null : _endDate,
        intervalN: null,
        specificDates: null,
      );

      // Créer l'habitude avec le schedule
      await habitService.createHabit(
        title: _titleController.text.trim(),
        scheduleId: scheduleId,
        iconEmoji: _emojiController.text.trim().isEmpty
            ? null
            : _emojiController.text.trim(),
        targetPerDay: targetPerDay,
        targetDurationSeconds: targetDurationSeconds,
        trackingType: _trackingType,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Habitude créée')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle habitude')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom
                const Text(
                  'Nom',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Ex: Boire de l\'eau',
                  ),
                  validator: (v) => (v == null || v.trim().length < 2)
                      ? 'Minimum 2 caractères'
                      : null,
                ),
                const SizedBox(height: 16),

                // Type de suivi
                const Text(
                  'Suivi',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<TrackingType>(
                  initialValue: _trackingType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: TrackingType.task,
                      child: Text('Tâche simple'),
                    ),
                    DropdownMenuItem(
                      value: TrackingType.quantity,
                      child: Text('Quantité'),
                    ),
                    DropdownMenuItem(
                      value: TrackingType.time,
                      child: Text('Temps'),
                    ),
                  ],
                  onChanged: (v) =>
                      setState(() => _trackingType = v ?? TrackingType.task),
                ),

                if (_trackingType == TrackingType.quantity) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Objectif (fois)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'ex: 8',
                    ),
                    validator: (v) {
                      if (_trackingType != TrackingType.quantity) return null;
                      final n = int.tryParse((v ?? '').trim());
                      if (n == null || n < 1) return '>= 1';
                      return null;
                    },
                  ),
                ],

                if (_trackingType == TrackingType.time) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Durée',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickDuration,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer),
                          const SizedBox(width: 12),
                          Text(_formatDuration(_timeDuration)),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Emoji
                const Text(
                  'Emoji',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emojiController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Collez un emoji ici (ex: 💧)',
                  ),
                ),
                const SizedBox(height: 16),

                // Fréquence
                const Text(
                  'Fréquence',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _frequency,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'daily',
                      child: Text('Quotidienne'),
                    ),
                    DropdownMenuItem(
                      value: 'custom',
                      child: Text('Personnalisée'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _frequency = v ?? 'daily'),
                ),
                const SizedBox(height: 8),

                if (_frequency == 'custom') _buildWeeklyDaysPicker(),

                const SizedBox(height: 16),

                // Rappel
                const Text(
                  'Rappel',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickTime,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 12),
                        Text(_timeToString(_reminder) ?? 'Aucun'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Dates
                const Text(
                  'Commence le',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _pickDate(isStart: true),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month),
                        const SizedBox(width: 12),
                        Text(
                          _startDate == null
                              ? 'Non défini'
                              : _startDate!
                                    .toLocal()
                                    .toString()
                                    .split(' ')
                                    .first,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Switch(
                      value: _noEnd,
                      onChanged: (v) => setState(() => _noEnd = v),
                    ),
                    const SizedBox(width: 8),
                    const Text('Jamais'),
                  ],
                ),
                const SizedBox(height: 8),
                if (!_noEnd)
                  InkWell(
                    onTap: () => _pickDate(isStart: false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event),
                          const SizedBox(width: 12),
                          Text(
                            _endDate == null
                                ? 'Sélectionner une date'
                                : _endDate!
                                      .toLocal()
                                      .toString()
                                      .split(' ')
                                      .first,
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: const Text('Enregistrer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Widget _buildWeeklyDaysPicker() {
    const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        spacing: 10,
        children: List.generate(7, (i) {
          final day = i + 1;
          final selected = _weeklyDays.contains(day);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (selected) {
                  _weeklyDays.remove(day);
                } else {
                  _weeklyDays.add(day);
                }
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Center(child: Text(labels[i])),
            ),
          );
        }),
      ),
    );
  }
}
