lib/
│
├── main.dart                # Point d'entrée de l'application
│
├── core/
│   └── providers.dart     ← Configuration des providers
├── data/                    # Couche données (implémentation)
│   ├── datasources/         # Sources de données (Hive, API)
│   ├── models/              # Modèles de données
│   ├──  repositories/       # Implémentation des repositories
│   └── boxes.dart 
├── domain/                  # Couche métier (interface)
│   ├── entities/            # Entités métier (optionnel, souvent = models)
│   ├── repositories/        # Interfaces des repositories
│   ├── usecases/            # Cas d'usage métier
│   └── services/            # Services métier
└── presentation/            # Couche présentation
    ├── pages/               # Écrans
    ├── widgets/             # Composants réutilisables
    ├── controllers/         # Contrôleurs (GetX, Riverpod)
    └── viewmodels/          # ViewModels (Provider, Bloc)


Flux du code:
UI (HomePage) 
    ↓ appelle
Service (HabitService) 
    ↓ utilise
Interface (HabitRepository) 
    ↓ implémentée par
Implémentation (HabitRepositoryImpl) 
    ↓ accède à
Base de données (Hive)