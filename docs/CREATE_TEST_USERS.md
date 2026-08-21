# Créer des utilisateurs de test pour le matching

## Méthode 1 : Via l'application (Recommandé)

1. **Créer des comptes via l'inscription** :
   - Ouvrez l'application
   - Inscrivez-vous avec différents comptes :
     - `alice@test.com` / mot de passe
     - `bob@test.com` / mot de passe
     - `charlie@test.com` / mot de passe
   
2. **Ajouter des favoris à chaque compte** :
   - Connectez-vous avec chaque compte
   - Ajoutez des films aux favoris
   - Pour tester le matching, assurez-vous que plusieurs utilisateurs ont des films en commun

## Méthode 2 : Via Firebase Console

### Étape 1 : Créer les comptes dans Firebase Auth

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet
3. Allez dans **Authentication** > **Users**
4. Cliquez sur **Add user**
5. Créez les utilisateurs suivants :

| Email | Mot de passe | UID (à noter) |
|-------|--------------|---------------|
| alice@test.com | test123456 | (sera généré) |
| bob@test.com | test123456 | (sera généré) |
| charlie@test.com | test123456 | (sera généré) |

### Étape 2 : Ajouter les profils dans Firestore

1. Allez dans **Firestore Database**
2. Collection `users`
3. Pour chaque utilisateur créé, ajoutez un document avec l'UID comme ID :

**Document 1 (UID d'alice@test.com)** :
```json
{
  "email": "alice@test.com",
  "firstName": "Alice",
  "lastName": "Martin",
  "age": 25,
  "role": "user",
  "isActive": true,
  "favoriteMovies": ["1", "2", "3"]
}
```

**Document 2 (UID de bob@test.com)** :
```json
{
  "email": "bob@test.com",
  "firstName": "Bob",
  "lastName": "Dupont",
  "age": 30,
  "role": "user",
  "isActive": true,
  "favoriteMovies": ["1", "2"]
}
```

**Document 3 (UID de charlie@test.com)** :
```json
{
  "email": "charlie@test.com",
  "firstName": "Charlie",
  "lastName": "Bernard",
  "age": 28,
  "role": "user",
  "isActive": true,
  "favoriteMovies": ["1", "2", "3", "4"]
}
```

### Étape 3 : Tester le matching

1. Connectez-vous avec `alice@test.com`
2. Allez dans l'onglet **Matching**
3. Vous devriez voir :
   - **Bob** : ~67% de correspondance (2 films en commun sur 3)
   - **Charlie** : ~75% de correspondance (3 films en commun sur 4)

## Explication du matching

Le système calcule le taux de correspondance avec la formule de Jaccard :
- **Formule** : (Films en commun) / (Tous les films uniques) × 100
- **Seuil** : Affiche uniquement les utilisateurs avec > 75% de correspondance

### Exemple :
- Alice a les films : [1, 2, 3]
- Bob a les films : [1, 2]
- Films en commun : [1, 2] = 2
- Tous les films uniques : [1, 2, 3] = 3
- Taux de correspondance : (2/3) × 100 = 66.7%

## Notes importantes

- Les IDs de films (`"1"`, `"2"`, etc.) correspondent aux films de démonstration
- Pour utiliser des films réels, remplacez par les IDs des films de l'API
- Assurez-vous que les utilisateurs ont au moins quelques films en commun pour voir des correspondances

