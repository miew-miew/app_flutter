lib/
│
├── main.dart                   # Point d'entrée de l'application
│
├── core/                       
│   └── providers.dart           # Configuration des providers
│
├── data/                        # Couche données (implémentation)
│   ├── datasources/             # Sources de données (Hive, API, etc.)
│   ├── models/                  # Modèles de données
│   ├── repositories/            # Implémentation des repositories
│   └── boxes.dart               # Configuration/accès aux box Hive
│
├── domain/                      # Couche métier (interfaces et logique)
│   ├── entities/                # Entités métier (optionnel, proches des models)
│   ├── repositories/            # Interfaces des repositories
│   ├── usecases/                # Cas d’usage métier
│   └── services/                # Services métier
│
└── presentation/                # Couche présentation (UI)
    ├── pages/                   # Écrans
    ├── widgets/                 # Composants réutilisables
    ├── controllers/             # Contrôleurs (ex : GetX, Riverpod)
    └── viewmodels/              # ViewModels (Provider, Bloc, etc.)
