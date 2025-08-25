import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../data/boxes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _clearBoxes(BuildContext context) async {
    try {
      await Boxes.habitsBox().clear();
      await Boxes.habitLogsBox().clear();
      await Boxes.appSettingsBox().clear();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Données vidées')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _deleteBoxes(BuildContext context) async {
    try {
      // Sassurer que les boxes sont ouvertes avant suppression
      if (!Hive.isBoxOpen(Boxes.habits)) await Hive.openBox(Boxes.habits);
      if (!Hive.isBoxOpen(Boxes.habitLogs)) await Hive.openBox(Boxes.habitLogs);
      if (!Hive.isBoxOpen(Boxes.appSettings))
        await Hive.openBox(Boxes.appSettings);

      await Boxes.habitsBox().deleteFromDisk();
      await Boxes.habitLogsBox().deleteFromDisk();
      await Boxes.appSettingsBox().deleteFromDisk();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Boxes supprimes du disque')),
        );
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
      appBar: AppBar(title: const Text('Paramtres')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rinitialiser les donnes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _clearBoxes(context),
                icon: const Icon(Icons.cleaning_services),
                label: const Text('Vider les boxes (conserver les fichiers)'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _deleteBoxes(context),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Supprimer les boxes (fichiers inclus)'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
              const SizedBox(height: 20),
              const Text(
                'Astuce: aprs suppression de fichiers, redmarrez l\'app.',
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
