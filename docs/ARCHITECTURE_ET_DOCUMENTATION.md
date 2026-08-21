# Architecture et Documentation du Projet 🎬

## 📋 Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Architecture du projet](#architecture-du-projet)
3. [Processus Firebase](#processus-firebase)
4. [Fonctionnalités](#fonctionnalités)
5. [Structure des fichiers](#structure-des-fichiers)
6. [Modèles de données](#modèles-de-données)
7. [Services](#services)
8. [Flux d'authentification](#flux-dauthentification)
9. [Flux de données](#flux-de-données)

---

## 🎯 Vue d'ensemble

Cette application Flutter est une **plateforme de gestion de films** qui permet aux utilisateurs de :
- S'inscrire et s'authentifier
- Parcourir une collection de films
- Créer une liste de films favoris
- Trouver d'autres utilisateurs avec des goûts similaires (matching)
- Gérer les utilisateurs et les films (pour les administrateurs)

### Technologies utilisées

- **Framework** : Flutter (Dart)
- **Backend** : Firebase
  - Firebase Authentication (email/password)
  - Cloud Firestore (base de données)
  - Firebase Storage (photos de profil)
- **API externe** : TMDb (The Movie Database) pour récupérer des films
- **Architecture** : MVC (Model-View-Controller) simplifié

---

## 🏗️ Architecture du projet

### Structure générale

```
projet/
├── lib/
│   ├── main.dart                    # Point d'entrée de l'application
│   ├── models/                      # Modèles de données
│   │   ├── movie.dart              # Modèle Film
│   │   └── user.dart               # Modèle Utilisateur
│   ├── screens/                     # Écrans de l'application
│   │   ├── login_screen.dart       # Écran de connexion
│   │   ├── signup_screen.dart      # Écran d'inscription
│   │   ├── home_screen.dart        # Écran d'accueil (films, favoris)
│   │   ├── movie_detail_screen.dart # Détails d'un film
│   │   ├── matching_screen.dart    # Utilisateurs avec goûts similaires
│   │   └── admin_screen.dart      # Interface administrateur
│   ├── services/                    # Services métier
│   │   ├── firestore_service.dart  # Gestion Firestore
│   │   └── movie_service.dart      # Gestion des films (API + Firestore)
│   └── utils/                       # Utilitaires
│       └── constants.dart           # Constantes de l'application
├── android/                         # Configuration Android
├── ios/                             # Configuration iOS
└── pubspec.yaml                     # Dépendances du projet
```

### Pattern architectural

L'application suit un pattern **MVC simplifié** :

- **Model** : `lib/models/` - Définit les structures de données
- **View** : `lib/screens/` - Interface utilisateur
- **Controller** : `lib/services/` - Logique métier et accès aux données

### Flux de données

```
Utilisateur (UI)
    ↓
Screen (View)
    ↓
Service (Controller)
    ↓
Firebase (Model/Backend)
```

---

## 🔥 Processus Firebase

### 1. Configuration Firebase

#### Étape 1 : Créer un projet Firebase

1. Aller sur [Firebase Console](https://console.firebase.google.com/)
2. Créer un nouveau projet
3. Activer les services nécessaires :
   - **Authentication** (Email/Password)
   - **Cloud Firestore**
   - **Storage** (pour les photos)

#### Étape 2 : Configuration Android

1. Télécharger `google-services.json`
2. Placer dans `android/app/`
3. Configurer dans `android/build.gradle` et `android/app/build.gradle`

#### Étape 3 : Configuration iOS

1. Télécharger `GoogleService-Info.plist`
2. Placer dans `ios/Runner/`
3. Configurer dans Xcode

### 2. Collections Firestore

#### Collection `users`

Structure d'un document utilisateur :

```json
{
  "id": "uid-firebase-auth",
  "email": "user@example.com",
  "firstName": "Prénom",
  "lastName": "Nom",
  "age": 25,
  "photoUrl": "https://...",
  "role": "user" | "admin",
  "isActive": true,
  "favoriteMovies": ["movie_id_1", "movie_id_2"]
}
```

**Champs :**
- `id` : UID Firebase Auth (ID du document)
- `email` : Email de l'utilisateur
- `firstName` : Prénom
- `lastName` : Nom de famille
- `age` : Âge (number, optionnel)
- `photoUrl` : URL de la photo de profil (string, optionnel)
- `role` : Rôle ("user" ou "admin")
- `isActive` : Statut actif/désactivé (boolean)
- `favoriteMovies` : Liste des IDs de films favoris (array)

#### Collection `movies`

Structure d'un document film :

```json
{
  "id": "movie_id",
  "title": "Titre du film",
  "description": "Description...",
  "imageUrl": "https://...",
  "rating": 8.5,
  "year": 2020,
  "genre": "Action, Thriller",
  "director": "Nom du réalisateur"
}
```

**Champs :**
- `id` : Identifiant unique du film
- `title` : Titre (obligatoire)
- `description` : Description (optionnel)
- `imageUrl` : URL de l'affiche (optionnel)
- `rating` : Note sur 10 (number)
- `year` : Année de sortie (number)
- `genre` : Genre(s) (string)
- `director` : Réalisateur (string)

### 3. Règles de sécurité Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Collection users
    match /users/{userId} {
      // L'utilisateur peut lire son propre document
      allow read: if request.auth != null && request.auth.uid == userId;
      // L'utilisateur peut créer/mettre à jour son propre document
      allow create, update: if request.auth != null && request.auth.uid == userId;
      // Les admins peuvent lire tous les utilisateurs
      allow read: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
      // Les admins peuvent désactiver/activer des utilisateurs
      allow update: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Collection movies
    match /movies/{movieId} {
      // Tous les utilisateurs authentifiés peuvent lire
      allow read: if request.auth != null;
      // Seuls les admins peuvent créer/modifier
      allow create, update, delete: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

### 4. Firebase Storage

**Structure :**
```
profile_photos/
  └── {userId}.jpg
```

**Règles de sécurité :**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_photos/{userId}.jpg {
      // L'utilisateur peut uploader sa propre photo
      allow write: if request.auth != null && request.auth.uid == userId;
      // Tous les utilisateurs authentifiés peuvent lire
      allow read: if request.auth != null;
    }
  }
}
```

---

## ✨ Fonctionnalités

### 1. Authentification

#### Inscription (`signup_screen.dart`)

**Processus :**
1. L'utilisateur remplit le formulaire (nom, prénom, âge, email, mot de passe, photo)
2. Validation des champs
3. Création du compte Firebase Auth
4. Upload de la photo (si fournie) vers Firebase Storage
5. Création du profil utilisateur dans Firestore
6. Redirection vers l'écran de connexion

**Champs requis :**
- Email (valide)
- Mot de passe (minimum 6 caractères)
- Prénom
- Nom
- Âge (1-150)

#### Connexion (`login_screen.dart`)

**Processus :**
1. L'utilisateur entre email et mot de passe
2. Authentification Firebase Auth
3. Chargement du profil depuis Firestore
4. Redirection vers l'écran d'accueil

**Gestion des erreurs :**
- Email invalide
- Mot de passe incorrect
- Utilisateur non trouvé
- Compte désactivé
- Erreurs réseau

### 2. Gestion des films

#### Affichage des films (`home_screen.dart`)

**Sources de données :**
1. **Firestore** : Films ajoutés par les administrateurs (priorité)
2. **API TMDb** : Films populaires récupérés depuis l'API
3. **Films de démonstration** : Si aucune autre source n'est disponible

**Fonctionnalités :**
- Liste de tous les films
- Recherche par titre
- Affichage des détails (titre, description, note, année, genre)
- Ajout/retrait des favoris

#### Détails d'un film (`movie_detail_screen.dart`)

**Affichage :**
- Affiche du film
- Titre
- Description complète
- Note, année, genre, réalisateur
- Bouton pour ajouter/retirer des favoris

### 3. Films favoris

#### Ajout aux favoris

**Processus :**
1. L'utilisateur clique sur le cœur dans les détails d'un film
2. L'ID du film est ajouté au tableau `favoriteMovies` dans Firestore
3. Retry automatique en cas d'erreur réseau (3 tentatives avec backoff exponentiel)

#### Affichage des favoris

**Processus :**
1. Récupération de la liste `favoriteMovies` depuis Firestore
2. Pour chaque ID, récupération des détails du film
3. Affichage dans un onglet dédié

### 4. Matching (Correspondance)

#### Algorithme de matching (`matching_screen.dart`)

**Principe :**
- Compare les listes de films favoris entre utilisateurs
- Calcule le taux de correspondance (Jaccard similarity)
- Affiche les utilisateurs avec >75% de correspondance

**Formule Jaccard :**
```
similarity = (A ∩ B) / (A ∪ B)
taux = similarity * 100
```

**Processus :**
1. Récupération de tous les utilisateurs actifs
2. Pour chaque utilisateur :
   - Calcul de l'intersection des favoris
   - Calcul de l'union des favoris
   - Calcul du taux de correspondance
3. Filtrage des utilisateurs avec >75% de correspondance
4. Tri par taux décroissant
5. Affichage avec nombre de films en commun

### 5. Interface administrateur (`admin_screen.dart`)

#### Accès admin

**Condition :**
- L'utilisateur doit avoir `role: "admin"` dans Firestore
- L'onglet "Admin" apparaît automatiquement si la condition est remplie

#### Fonctionnalités admin

**1. Ajouter un film**
- Formulaire avec tous les champs du film
- Sauvegarde dans Firestore
- Apparaît immédiatement dans la liste des films

**2. Gérer les utilisateurs**
- Liste de tous les utilisateurs
- Affichage : nom, email, âge, rôle, statut
- Action : Activer/Désactiver un utilisateur
- Un utilisateur désactivé ne peut plus se connecter

---

## 📁 Structure des fichiers

### Models (`lib/models/`)

#### `movie.dart`
- Classe `Movie` : Représente un film
- Méthodes : `fromJson()`, `toJson()`
- Champs : id, title, description, imageUrl, rating, year, genre, director

#### `user.dart`
- Classe `AppUser` : Représente un utilisateur
- Méthodes : `fromJson()`, `toJson()`, `copyWith()`
- Propriété calculée : `isAdmin` (vérifie si `role == "admin"`)
- Champs : id, email, firstName, lastName, age, photoUrl, role, isActive, favoriteMovies

### Screens (`lib/screens/`)

#### `main.dart`
- Point d'entrée de l'application
- Initialisation Firebase
- Gestion des erreurs globales
- `AuthWrapper` : Redirige vers login ou home selon l'état d'authentification

#### `login_screen.dart`
- Formulaire de connexion
- Validation des champs
- Gestion des erreurs Firebase Auth
- Navigation vers home après connexion

#### `signup_screen.dart`
- Formulaire d'inscription complet
- Sélection/téléchargement de photo
- Validation des champs
- Création du compte et du profil
- Gestion des erreurs

#### `home_screen.dart`
- Écran principal avec onglets
- Onglet Films : Liste et recherche
- Onglet Favoris : Films favoris
- Onglet Matching : Utilisateurs similaires
- Onglet Admin : (si admin) Interface admin
- Chargement des données utilisateur
- Gestion du statut admin

#### `movie_detail_screen.dart`
- Affichage détaillé d'un film
- Bouton favori (ajout/retrait)
- Navigation depuis la liste

#### `matching_screen.dart`
- Calcul du matching
- Affichage des utilisateurs avec >75% de correspondance
- Affichage du nombre de films en commun

#### `admin_screen.dart`
- Onglet 1 : Ajouter un film
- Onglet 2 : Gérer les utilisateurs
- Actions : Activer/Désactiver utilisateurs

### Services (`lib/services/`)

#### `firestore_service.dart`
**Opérations utilisateurs :**
- `createOrUpdateUser()` : Créer/mettre à jour un utilisateur
- `getUserById()` : Récupérer un utilisateur par ID
- `getCurrentUser()` : Récupérer l'utilisateur connecté
- `isCurrentUserAdmin()` : Vérifier si l'utilisateur est admin
- `getAllUsers()` : Récupérer tous les utilisateurs
- `disableUser()` / `enableUser()` : Désactiver/Activer un utilisateur
- `uploadProfilePhoto()` : Uploader une photo de profil

**Opérations favoris :**
- `addFavoriteMovie()` : Ajouter un film aux favoris (avec retry)
- `removeFavoriteMovie()` : Retirer un film des favoris (avec retry)
- `isFavoriteMovie()` : Vérifier si un film est favori
- `getFavoriteMovies()` : Récupérer la liste des favoris

**Opérations films :**
- `addMovie()` : Ajouter un film (admin)
- `getMoviesFromFirestore()` : Récupérer tous les films depuis Firestore
- `getMovieByIdFromFirestore()` : Récupérer un film par ID

**Opérations matching :**
- `calculateMatchRate()` : Calculer le taux de correspondance
- `findMatchingUsers()` : Trouver les utilisateurs avec >75% de correspondance

**Fonction utilitaire :**
- `_ensureUserFieldsComplete()` : Compléter automatiquement les champs manquants

#### `movie_service.dart`
- `getMovies()` : Récupérer tous les films (Firestore + API)
- `getMovieById()` : Récupérer un film par ID
- `searchMovies()` : Rechercher des films par titre
- `_getMoviesFromAPI()` : Récupérer depuis l'API TMDb
- `_getMoviesFromTMDB()` : Récupérer plusieurs pages depuis TMDb
- `_parseMovieFromTMDB()` : Parser les données TMDb
- `_getDemoMovies()` : Films de démonstration

### Utils (`lib/utils/`)

#### `constants.dart`
- Constantes de l'application
- Configuration API (TMDb)
- Messages d'erreur/succès
- Validation

---

## 🔐 Flux d'authentification

### Inscription

```
1. Utilisateur remplit le formulaire
   ↓
2. Validation des champs
   ↓
3. Firebase Auth : createUserWithEmailAndPassword()
   ↓
4. Firebase Storage : Upload photo (si fournie)
   ↓
5. Firestore : createOrUpdateUser() → Création du profil
   ↓
6. Navigation vers login_screen
```

### Connexion

```
1. Utilisateur entre email/password
   ↓
2. Firebase Auth : signInWithEmailAndPassword()
   ↓
3. Firestore : getCurrentUser() → Chargement du profil
   ↓
4. Vérification du statut (actif/désactivé)
   ↓
5. Navigation vers home_screen
```

### Déconnexion

```
1. Utilisateur clique sur déconnexion
   ↓
2. Firebase Auth : signOut()
   ↓
3. Navigation vers login_screen
```

---

## 📊 Flux de données

### Chargement des films

```
1. home_screen initState()
   ↓
2. movie_service.getMovies()
   ↓
3. firestore_service.getMoviesFromFirestore() → Films Firestore
   ↓
4. movie_service._getMoviesFromAPI() → Films API TMDb
   ↓
5. Combinaison des deux listes (priorité Firestore)
   ↓
6. Affichage dans l'interface
```

### Ajout aux favoris

```
1. Utilisateur clique sur cœur
   ↓
2. movie_detail_screen._toggleFavorite()
   ↓
3. firestore_service.addFavoriteMovie()
   ↓
4. Firestore : Update document user (ajout ID dans favoriteMovies)
   ↓
5. Retry automatique si erreur réseau (3 tentatives)
   ↓
6. Mise à jour de l'interface
```

### Matching

```
1. matching_screen initState()
   ↓
2. firestore_service.findMatchingUsers()
   ↓
3. Pour chaque utilisateur :
   - Récupération de ses favoris
   - Calcul de l'intersection avec mes favoris
   - Calcul du taux de correspondance (Jaccard)
   ↓
4. Filtrage : taux > 75%
   ↓
5. Tri par taux décroissant
   ↓
6. Affichage dans l'interface
```

---

## 🛠️ Configuration requise

### Dépendances principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^latest
  firebase_auth: ^latest
  cloud_firestore: ^latest
  firebase_storage: ^latest
  http: ^latest
  image_picker: ^latest
```

### Configuration API TMDb

1. Obtenir une clé API sur [TMDb](https://www.themoviedb.org/settings/api)
2. Configurer dans `lib/utils/constants.dart` :
   ```dart
   static const String tmdbApiKey = 'VOTRE_CLE_API';
   ```

### Configuration Firebase

1. Créer un projet Firebase
2. Activer Authentication (Email/Password)
3. Créer une base Firestore
4. Configurer Storage
5. Ajouter les fichiers de configuration (`google-services.json`, `GoogleService-Info.plist`)

---

## 📝 Notes importantes

### Gestion des erreurs

- **Erreurs Firebase internes** : Ignorées automatiquement (PigeonUserDetails)
- **Erreurs réseau** : Retry automatique avec backoff exponentiel
- **Erreurs de permission** : Messages d'erreur explicites pour l'utilisateur

### Performance

- **Chargement des films** : Combinaison Firestore + API en parallèle
- **Favoris** : Chargement asynchrone avec indicateur de chargement
- **Matching** : Calcul optimisé avec filtrage précoce

### Sécurité

- **Règles Firestore** : Vérification des permissions côté serveur
- **Règles Storage** : Accès restreint aux photos de profil
- **Validation** : Côté client et serveur

---

## 🚀 Déploiement

### Android

1. Configurer la signature de l'application
2. Ajouter les SHA-1/SHA-256 dans Firebase Console
3. Télécharger le nouveau `google-services.json`
4. Build : `flutter build apk` ou `flutter build appbundle`

### iOS

1. Configurer les certificats dans Xcode
2. Build : `flutter build ios`

---

## 📚 Ressources

- [Documentation Flutter](https://flutter.dev/docs)
- [Documentation Firebase](https://firebase.google.com/docs)
- [Documentation TMDb API](https://www.themoviedb.org/documentation/api)
- [Guide Firebase Flutter](https://firebase.flutter.dev/)

---

**Dernière mise à jour** : 2024

