# Guide de débogage du matching

## Symptôme

Le matching ne fonctionne pas (aucune correspondance affichée).

## Étapes de débogage

### Étape 1 : Vérifier les logs Flutter

1. **Lancez l'application** : `flutter run`
2. **Connectez-vous** avec un compte (ex: Alice)
3. **Allez dans l'onglet "Matching"**
4. **Regardez les logs** dans le terminal

**Logs attendus :**
```
🔍 Recherche de correspondances pour l'utilisateur: [UID]
👤 Utilisateur actuel: [Prénom] [Nom]
🎬 Favoris de l'utilisateur actuel: X films
   IDs: [liste des IDs]
👥 Total d'utilisateurs dans la base: X
🔍 Comparaison avec: [Autre utilisateur]
   Favoris: X films - IDs: [liste]
   Taux de correspondance: X%
✨ Total de correspondances trouvées: X
```

**Si vous voyez une erreur :**
- Notez l'erreur exacte
- Vérifiez si elle contient "permission" ou "denied"

### Étape 2 : Vérifier les données Firestore

#### A. Vérifier que vous avez des favoris

1. Ouvrez [Firebase Console](https://console.firebase.google.com/)
2. Allez dans **Firestore Database**
3. Ouvrez la collection `users`
4. Trouvez votre document utilisateur (par email)
5. **Vérifiez** : Le champ `favoriteMovies` doit contenir au moins 1 ID de film

**Exemple correct :**
```json
{
  "favoriteMovies": ["1", "2", "550"]
}
```

**Problème si :**
- `favoriteMovies` est vide `[]`
- `favoriteMovies` n'existe pas
- **Solution** : Ajoutez des films à vos favoris dans l'onglet "Films"

#### B. Vérifier qu'il y a d'autres utilisateurs

1. Toujours dans la collection `users`
2. **Comptez** le nombre de documents utilisateurs
3. Il doit y avoir **au moins 2 utilisateurs** (vous + un autre)

**Problème si :**
- Un seul utilisateur existe
- **Solution** : Créez d'autres comptes de test

#### C. Vérifier que les autres utilisateurs ont des favoris

1. Ouvrez les documents des autres utilisateurs
2. **Vérifiez** : Chaque utilisateur doit avoir un champ `favoriteMovies` avec au moins 1 film

**Problème si :**
- Les autres utilisateurs n'ont pas de favoris
- **Solution** : Connectez-vous avec chaque compte et ajoutez des films aux favoris

### Étape 3 : Vérifier les règles Firestore

1. Dans Firebase Console, allez dans **Firestore Database** > **Rules**
2. **Vérifiez** que les règles permettent aux utilisateurs de lire d'autres profils

**Règles correctes :**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    function isAdmin() {
      return request.auth != null && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    match /users/{userId} {
      // Lecture : L'utilisateur peut lire son propre profil
      allow read: if request.auth != null && request.auth.uid == userId;
      
      // Lecture : Les admins peuvent lire tous les profils
      allow read: if isAdmin();
      
      // Création : Un utilisateur peut créer son propre profil
      allow create: if request.auth != null && request.auth.uid == userId;
      
      // Mise à jour : Un utilisateur peut modifier son propre profil (sauf role/isActive)
      allow update: if request.auth != null && 
                       request.auth.uid == userId &&
                       !request.resource.data.diff(resource.data).affectedKeys().hasAny(['role', 'isActive']);
      
      // Mise à jour : Les admins peuvent tout modifier
      allow update: if isAdmin();
    }
    
    match /movies/{movieId} {
      allow read: if request.auth != null;
      allow create, update, delete: if isAdmin();
    }
  }
}
```

**Problème identifié :**
⚠️ **Les règles actuelles ne permettent PAS aux utilisateurs de lire les profils des autres !**

Un utilisateur normal peut seulement :
- Lire son propre profil : `allow read: if request.auth.uid == userId;`

Pour que le matching fonctionne, il faut que les utilisateurs puissent lire les profils des autres.

### Étape 4 : SOLUTION - Mettre à jour les règles Firestore

**Remplacez vos règles par :**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    function isAdmin() {
      return request.auth != null && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    match /users/{userId} {
      // Lecture : TOUS les utilisateurs authentifiés peuvent lire TOUS les profils
      // (nécessaire pour le matching)
      allow read: if request.auth != null;
      
      // Création : Un utilisateur peut créer son propre profil
      allow create: if request.auth != null && request.auth.uid == userId;
      
      // Mise à jour : Un utilisateur peut modifier son propre profil (sauf role/isActive)
      allow update: if request.auth != null && 
                       request.auth.uid == userId &&
                       !request.resource.data.diff(resource.data).affectedKeys().hasAny(['role', 'isActive']);
      
      // Mise à jour : Les admins peuvent tout modifier
      allow update: if isAdmin();
    }
    
    match /movies/{movieId} {
      allow read: if request.auth != null;
      allow create, update, delete: if isAdmin();
    }
  }
}
```

**Changement clé :**
- **AVANT** : `allow read: if request.auth.uid == userId;` (seulement son propre profil)
- **APRÈS** : `allow read: if request.auth != null;` (tous les profils)

### Étape 5 : Publier et tester

1. Dans Firebase Console, cliquez sur **Publish** (Publier)
2. Attendez 10-20 secondes
3. **Hot restart** de l'application (`R` majuscule dans le terminal)
4. Allez dans l'onglet "Matching"
5. **Vérifiez** : Vous devriez voir des correspondances

### Étape 6 : Vérifier le taux de correspondance

Le matching utilise l'algorithme de **similarité de Jaccard** :

```
Taux = (Nombre de films en commun) / (Total de films uniques des deux utilisateurs) × 100
```

**Exemples :**

1. **Alice** : Films [1, 2, 3] (3 films)
   **Bob** : Films [1, 2, 3] (3 films)
   - Films en commun : 3
   - Films uniques : 3
   - **Taux = 3/3 × 100 = 100%** ✅ Match !

2. **Alice** : Films [1, 2, 3] (3 films)
   **Bob** : Films [1, 2] (2 films)
   - Films en commun : 2
   - Films uniques : 3
   - **Taux = 2/3 × 100 = 66.7%** ❌ Pas de match (< 75%)

3. **Alice** : Films [1, 2, 3, 4] (4 films)
   **Bob** : Films [1, 2, 3] (3 films)
   - Films en commun : 3
   - Films uniques : 4
   - **Taux = 3/4 × 100 = 75%** ❌ Pas de match (= 75%, il faut > 75%)

**Pour avoir un match, il faut > 75% de correspondance.**

### Créer des utilisateurs de test avec correspondance garantie

#### Méthode facile : Mêmes favoris

1. **Créez Alice** : Ajoutez les films "Inception", "Interstellar", "The Matrix"
2. **Créez Bob** : Ajoutez les mêmes films "Inception", "Interstellar", "The Matrix"
3. **Résultat** : 100% de correspondance ✅

#### Méthode avancée : Contrôler le taux

Pour 80% de correspondance :
- **Alice** : 5 films [1, 2, 3, 4, 5]
- **Bob** : 4 films [1, 2, 3, 4] (80% en commun)
- **Taux** = 4/5 × 100 = 80% ✅

## Résumé des causes possibles

| Problème | Symptôme | Solution |
|----------|----------|----------|
| Règles Firestore trop strictes | Erreur "permission denied" | Mettre à jour les règles (Étape 4) |
| Pas de favoris | "Aucune correspondance" | Ajouter des films aux favoris |
| Pas d'autres utilisateurs | "Aucune correspondance" | Créer d'autres comptes |
| Taux < 75% | "Aucune correspondance" | Ajouter plus de films en commun |
| Utilisateurs désactivés | "Aucune correspondance" | Vérifier `isActive: true` dans Firestore |

## Commandes de débogage

### Voir les logs complets

```powershell
flutter run
```

Puis allez dans l'onglet Matching et regardez la console.

### Forcer un hot restart

Dans le terminal où Flutter tourne, appuyez sur `R` (majuscule).

### Effacer le cache Flutter

```powershell
flutter clean
flutter pub get
flutter run
```

## Contact

Si le problème persiste après avoir suivi toutes ces étapes, copiez-collez les logs du terminal (la section avec les emojis 🔍👤🎬) pour analyse.

