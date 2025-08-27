```
app_flutter/
├── lib/
│   ├── main.dart                   # Point d'entrée de l'application
│   ├── core/
│   │   └── providers.dart          # Configuration des providers
│   ├── data/
│   │   ├── models/                 # Modèles de données
│   │   ├── repositories/           # Implémentation des repositories
│   │   └── boxes.dart              # Configuration/accès aux box Hive
│   ├── domain/
│   │   ├── repositories/           # Interfaces des repositories
│   │   └── services/               # Services métier
│   ├── presentation/
│   │   ├── pages/                  # Écrans
│   │   ├── widgets/                # Composants réutilisables
├── assets/                        # Ressources statiques (images, fonts, etc.)
├── pubspec.yaml                   # Configuration des dépendances et métadonnées
├── README.md                      # Aperçu et instructions du projet
└── PROJECT_STRUCTURE.md           # Documentation de la structure du projet
```
