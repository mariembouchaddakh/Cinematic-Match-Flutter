# Flutter Cinematic Matching Platform

## Contexte du Projet (Recherche & Application Entreprise)
Les systèmes de recommandation traditionnels se limitent souvent à des algorithmes de filtrage collaboratif gérés côté serveur.
- **Aspect Recherche (Algorithmique & Recommandation)** : Cette application explore le calcul décentralisé d'affinité utilisateur en temps réel. Elle implémente l'indice de similarité de Jaccard pour comparer les matrices de goûts cinématographiques et identifier les corrélations de profils (taux d'affinité supérieur à 75%).
- **Aspect Entreprise (Mobile & Cloud-Native)** : Démonstrateur d'architecture mobile B2C développée avec Flutter. Le backend s'appuie sur Firebase (Backend-as-a-Service) pour garantir une haute disponibilité, une synchronisation NoSQL temps réel (Firestore) et une gestion sécurisée de l'authentification.

## Architecture et Stack Technologique
Le projet est architecturé selon le pattern MVC/MVVM classique sous Flutter, assurant une séparation stricte des responsabilités.
- **Frontend Mobile** : Framework `Flutter` (Dart), gestion d'états réactifs.
- **Backend (BaaS Firebase)** :
  - `Firebase Auth` : Authentification sécurisée (Email/Password).
  - `Cloud Firestore` : Base de données NoSQL (Collections: `users`, `movies`).
  - `Firebase Storage` : Gestion des blobs binaires (avatars).
- **Intégration API Tierce** : Appels asynchrones REST via `http` vers l'API The Movie Database (TMDb).

## Algorithme de Matching (Similarité de Jaccard)
Le moteur de correspondance calcule l'intersection des graphes de préférences entre les utilisateurs.
- **Formule** : (Films en commun) / (Ensemble des films uniques des deux utilisateurs) * 100
- **Optimisation** : Le calcul est effectué localement pour minimiser la latence réseau et les coûts de lecture cloud.

## Structure de la Documentation
L'ensemble de la documentation technique a été refactorisée et consolidée dans le répertoire `/docs` afin de maintenir un dépôt propre.
- `/docs/ARCHITECTURE_ET_DOCUMENTATION.md` : Détails des flux de données et architecture.
- `/docs/ADMIN_SETUP.md` : Guide de l'interface d'administration.
- `/docs/CONFIGURER_API_TMDB.md` : Paramétrage du provider de métadonnées.

## Instructions d'Installation et de Déploiement

### Prérequis
- Flutter SDK (3.9.2+)
- Compte Firebase (Firestore, Auth, Storage activés)
- Clé développeur TMDb

### Initialisation de l'Environnement Local
1. **Cloner le dépôt** :
   ```bash
   git clone https://github.com/mariembouchaddakh/movie-app.git
   cd movie-app
   ```
2. **Résoudre les dépendances** :
   ```bash
   flutter pub get
   ```
3. **Configuration Firebase** :
   Intégrer les fichiers de configuration natifs (`google-services.json` dans `android/app/` et `GoogleService-Info.plist` dans `ios/Runner/`).
4. **Configuration TMDb** :
   Modifier `lib/utils/constants.dart` avec le jeton d'API valide.
5. **Compilation et Exécution** :
   ```bash
   flutter run
   ```

## Structure des Collections (Firestore)
- **users** : Métadonnées du profil, rôles (user/admin), vecteur de favoris (liste d'IDs de films).
- **movies** : Métadonnées structurées du film (Titre, Genre, Note globale TMDb).
