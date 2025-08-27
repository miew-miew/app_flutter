# app_flutter

Application Flutter de suivi d'habitudes.

## Prérequis

- Flutter SDK installé (version recommandée: stable actuelle)
- Git installé

Vérifiez votre environnement:

```bash
flutter doctor
```

## Installation

1) Cloner le dépôt

```bash
git clone https://github.com/miew-miew/app_flutter.git
cd app_flutter
```

2) Récupérer les dépendances

```bash
flutter pub get
```

3) (Optionnel) Générer les fichiers si nécessaire

Le projet utilise Hive (adapters déjà générés et versionnés). Si vous ajoutez des modèles Hive, générez les adapters:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Lancement
Lancement sur Windows (recommandé)

```bash
# Web (Chrome)
flutter run -d chrome

# Windows
flutter run -d windows 

# macOS / Linux
flutter run -d macos
flutter run -d linux
```

## Commandes utiles

- Analyser le code:

```bash
flutter analyze
```

- Nettoyage du cache de build:

```bash
flutter clean && flutter pub get
```

## Dépannage

- Assurez-vous que `flutter doctor` ne remonte pas de problèmes bloquants.
- Si l'app ne se lance pas: exécutez `flutter clean`, puis `flutter pub get` et relancez.
- Si des erreurs d'analyse mineures apparaissent (infos de style), elles n'empêchent pas l'exécution. Corrigez-les si nécessaire.

## Structure du projet

Dans le fichier PROJECT_STRUCTURE.md

## Contribuer (branches et Pull Requests)

Pour contribuer sans impacter directement la branche `main`, utilisez une branche dédiée pour chaque fonctionnalité ou correction.

---

### 1️⃣ Mettre à jour `main`

Avant de créer une branche, récupérez les dernières modifications de `main` :

```bash
git checkout main
git pull origin main
```

### 2️⃣ Créer et basculer sur une branche de travail

```bash
git checkout -b feature/ui
```

### 3️⃣ Commiter et pousser vos changements

```bash
git add .
git commit -m "feat: description courte"
git push -u origin feature/ui
```

### 4️⃣ Synchroniser votre branche avec main

```bash
git pull origin main
```

### 5️⃣ Ouvrir une Pull Request (PR)

- Sur GitHub: “Compare & pull request” (ou “New pull request”)
- Base: `main`, Compare: votre branche (ex: `feature/ui`)
- Titre clair et description brève (quoi + pourquoi)
- Si changement d’UI: ajoutez 1–2 captures d’écran
- Demandez une relecture; appliquez les retours si besoin
- Quand c’est validé: merge vers `main`, puis supprimez la branche

### 6️⃣ Conseils
- Préfixer les messages: `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`.

---
