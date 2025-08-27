import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/boxes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le compte ?'),
          content: const Text(
            'Cette action supprimera définitivement toutes vos données.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    try {
      // Ouvrir si nécessaire
      if (!Hive.isBoxOpen(Boxes.habits)) await Hive.openBox(Boxes.habits);
      if (!Hive.isBoxOpen(Boxes.habitLogs)) await Hive.openBox(Boxes.habitLogs);
      if (!Hive.isBoxOpen(Boxes.habitSchedules)) {
        await Hive.openBox(Boxes.habitSchedules);
      }
      if (!Hive.isBoxOpen(Boxes.habitReminders)) {
        await Hive.openBox(Boxes.habitReminders);
      }
      if (!Hive.isBoxOpen(Boxes.userProfile)) {
        await Hive.openBox(Boxes.userProfile);
      }
      if (!Hive.isBoxOpen(Boxes.appSettings)) {
        await Hive.openBox(Boxes.appSettings);
      }

      // Supprimer toutes les boxes du disque
      await Boxes.habitsBox().deleteFromDisk();
      await Boxes.habitLogsBox().deleteFromDisk();
      await Boxes.habitSchedulesBox().deleteFromDisk();
      await Boxes.habitRemindersBox().deleteFromDisk();
      await Boxes.userProfileBox().deleteFromDisk();
      await Boxes.appSettingsBox().deleteFromDisk();

      // Nettoyer SharedPreferences (nom + onboarding)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte supprimé. Données nettoyées.')),
        );
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/onboarding', (r) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Compte',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _deleteAccount(context),
                  icon: const Icon(Icons.person_remove_alt_1),
                  label: const Text('Supprimer le compte'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
