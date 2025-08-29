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
      // Nettoyer SharedPreferences (nom + onboarding) EN PREMIER
      final prefs = await SharedPreferences.getInstance();
      
      // Supprimer explicitement les clés importantes d'abord
      await prefs.remove('onboarding_completed');
      await prefs.remove('user_name');
      
      // Puis tout nettoyer
      await prefs.clear();
      
      // commit() est déprécié et no-op sur les plateformes récentes, on s'appuie sur clear/remove

      // REDIRIGER IMMÉDIATEMENT vers le splash
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte supprimé. Données nettoyées.')),
        );
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/', (r) => false);
      }
      
      // SUPPRIMER LES BOXES HIVE APRÈS la redirection (dans une Future détachée)
      // pour éviter tout blocage/erreur visible côté UI
      Future(() async {
        try {
          try {
            await Boxes.habitsBox().deleteFromDisk();
          } catch (e) {
            await Boxes.habitsBox().clear();
          }
          try {
            await Boxes.habitLogsBox().deleteFromDisk();
          } catch (e) {
            await Boxes.habitLogsBox().clear();
          }
          try {
            await Boxes.habitSchedulesBox().deleteFromDisk();
          } catch (e) {
            await Boxes.habitSchedulesBox().clear();
          }
          try {
            await Boxes.habitRemindersBox().deleteFromDisk();
          } catch (e) {
            await Boxes.habitRemindersBox().clear();
          }
          try {
            await Hive.box(Boxes.userProfile).deleteFromDisk();
          } catch (e) {
            try {
              await Hive.box(Boxes.userProfile).clear();
            } catch (_) {}
          }
          try {
            await Hive.box(Boxes.appSettings).deleteFromDisk();
          } catch (e) {
            try {
              await Hive.box(Boxes.appSettings).clear();
            } catch (_) {}
          }
        } catch (_) {}
      });
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
