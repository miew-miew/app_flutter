# app_flutter

Application Flutter de suivi d'habitudes.

## Sommaire

- [Prérequis](#prérequis)

<details>
  <summary><strong>Installation</strong></summary>

- [Étape 1 — Cloner le dépôt](#étape-1--cloner-le-dépôt)
- [Étape 2 — Installer les dépendances](#étape-2--installer-les-dépendances)
- [Étape 3 — Générer les fichiers (optionnel)](#étape-3--générer-les-fichiers-optionnel)

</details>

- [Lancement](#lancement)
- [Commandes utiles](#commandes-utiles)
- [Dépannage](#dépannage)
- [Structure du projet](#structure-du-projet)

<details>
  <summary><strong>Contribuer (branches et Pull Requests)</strong></summary>

- [Étape 1 — Mettre à jour `main`](#étape-1--mettre-à-jour-main)
- [Étape 2 — Créer et basculer sur une branche de travail](#étape-2--créer-et-basculer-sur-une-branche-de-travail)
- [Étape 3 — Commiter et pousser vos changements](#étape-3--commiter-et-pousser-vos-changements)
- [Étape 4 — Synchroniser votre branche avec `main`](#étape-4--synchroniser-votre-branche-avec-main)
- [Étape 5 — Ouvrir une Pull Request (PR)](#étape-5--ouvrir-une-pull-request-pr)
- [Étape 6 — Conseils](#étape-6--conseils)
- [Annexe — Gérer `git pull` avec modifications locales](#annexe--gérer-git-pull-avec-modifications-locales)

</details>

## Prérequis

- Flutter SDK installé (version recommandée: stable actuelle)
- Git installé

Vérifiez votre environnement:

```bash
flutter doctor
```

## Installation

### Étape 1 — Cloner le dépôt

```bash
git clone https://github.com/miew-miew/app_flutter.git
cd app_flutter
```

### Étape 2 — Installer les dépendances

```bash
flutter pub get
```

### Étape 3 — Générer les fichiers (optionnel)

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
# (si nécessaire la première fois)
flutter config --enable-windows-desktop
flutter run -d windows

# macOS / Linux
flutter run -d macos
flutter run -d linux
```

## Commandes utiles

- Analyse du code:

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

Voir le fichier [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) pour plus de détails.

## Contribuer (branches et Pull Requests)

Pour contribuer sans impacter directement la branche `main`, utilisez une branche dédiée pour chaque fonctionnalité ou correction.

---

### Étape 1 — Mettre à jour `main`

Avant de créer une branche, récupérez les dernières modifications de `main` :

```bash
git checkout main
git pull origin main
```

### Annexe — Gérer `git pull` avec modifications locales

Quand `git pull` bloque parce que des fichiers modifiés seraient écrasés, choisissez une des options suivantes.

#### Avant `git pull`

- Garder mes changements (et les enregistrer)

```bash
git add .
git commit -m "wip"
git pull origin main
```

- Garder sans commit (mettre de côté puis récupérer)

```bash
git stash
git pull origin main
git stash pop
```

- Ne pas garder (tout jeter)

```bash
git reset --hard
git pull origin main
```

#### Après `git pull` (ex: après `stash pop`)

S’il reste des fichiers modifiés:

- Je garde mes modifs locales

```bash
git add <fichier>
git commit -m "fix: maj après pull"
```

- Je garde uniquement la version distante (GitHub)

```bash
git restore <fichier>
```


### Étape 2 — Créer et basculer sur une branche de travail

```bash
git checkout -b feature/ui-home
```

### Étape 3 — Commiter et pousser vos changements

```bash
git add .
git commit -m "feat(ui): description courte"
git push -u origin feature/ui-home
```

### Étape 4 — Synchroniser votre branche avec `main`

```bash
git pull origin main
```

### Étape 5 — Ouvrir une Pull Request (PR)

- Sur GitHub: “Compare & pull request” (ou “New pull request”)
- Base: `main`, Compare: votre branche (ex: `feature/ui`)
- Titre clair et description brève (quoi + pourquoi)
- Si changement d’UI: ajoutez 1–2 captures d’écran
- Demandez une relecture; appliquez les retours si besoin
- Quand c’est validé: merge vers `main`, puis supprimez la branche

### Étape 6 — Conseils
- Préfixer les messages: `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`.

---
