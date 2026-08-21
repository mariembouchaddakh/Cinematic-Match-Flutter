# Comment ajouter plus de films

## Option 1 : Utiliser l'API TMDb (Recommandé - Automatique) ⭐

C'est la méthode la plus simple pour avoir beaucoup de films automatiquement !

### Étape 1 : Obtenir une clé API TMDb (Gratuit)

1. Allez sur [The Movie Database](https://www.themoviedb.org/)
2. Créez un compte (gratuit)
3. Allez dans **Paramètres** > **API**
4. Cliquez sur **Request API Key**
5. Choisissez **Developer** (gratuit)
6. Remplissez le formulaire :
   - Type d'application : Application mobile
   - Nom de l'application : Movie App
   - Site web : (votre site ou localhost)
7. Copiez votre clé API

### Étape 2 : Configurer la clé dans l'application

1. Ouvrez le fichier `lib/utils/constants.dart`
2. Trouvez la ligne :
   ```dart
   static const String tmdbApiKey = 'YOUR_TMDB_API_KEY';
   ```
3. Remplacez `YOUR_TMDB_API_KEY` par votre clé API :
   ```dart
   static const String tmdbApiKey = 'VOTRE_CLE_API_ICI';
   ```

### Étape 3 : Redémarrer l'application

1. Arrêtez l'application
2. Relancez avec `flutter run`
3. Les films devraient maintenant être chargés depuis TMDb (20 films populaires)

### Avantages

- ✅ **Automatique** : Les films sont chargés automatiquement
- ✅ **Gratuit et illimité**
- ✅ **Beaucoup de films** : 20 films populaires à chaque chargement
- ✅ **Données complètes** : Affiches, descriptions, notes, etc.

---

## Option 2 : Ajouter des films via l'interface Admin (Manuel)

Si vous êtes administrateur, vous pouvez ajouter des films manuellement :

### Étape 1 : Devenir administrateur

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet
3. Allez dans **Firestore Database**
4. Collection `users`
5. Trouvez votre document utilisateur (par UID)
6. Modifiez le champ `role` de `"user"` à `"admin"`
7. Sauvegardez

### Étape 2 : Ajouter des films

1. Connectez-vous avec votre compte admin
2. Allez dans l'onglet **Admin**
3. Cliquez sur **Ajouter un film**
4. Remplissez le formulaire :
   - **Titre** : (obligatoire)
   - **Description** : (optionnel)
   - **URL de l'image** : (optionnel, utilisez une URL d'image)
   - **Note** : (0-10)
   - **Année** : (ex: 2020)
   - **Genre** : (ex: Action, Comédie)
   - **Réalisateur** : (optionnel)
5. Cliquez sur **Ajouter**

### Exemples d'URLs d'images

Vous pouvez utiliser des URLs d'images de films :
- [The Movie Database Images](https://www.themoviedb.org/) - Cherchez un film et copiez l'URL de l'affiche
- [Unsplash](https://unsplash.com/s/photos/movie) - Images libres de droits
- Ou utilisez des placeholders : `https://via.placeholder.com/500x750?text=Movie+Title`

---

## Option 3 : Ajouter des films en masse via Firestore (Avancé)

Si vous voulez ajouter plusieurs films rapidement :

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet
3. Allez dans **Firestore Database**
4. Collection `movies`
5. Cliquez sur **Add document**
6. Utilisez un ID unique (ex: `movie_1`, `movie_2`)
7. Ajoutez les champs :

```json
{
  "id": "movie_1",
  "title": "Titre du film",
  "description": "Description du film",
  "imageUrl": "https://example.com/image.jpg",
  "rating": 8.5,
  "year": 2020,
  "genre": "Action, Thriller",
  "director": "Nom du réalisateur"
}
```

8. Répétez pour chaque film

---

## Recommandation

**Utilisez l'Option 1 (TMDb)** - C'est le plus simple et vous obtiendrez automatiquement 20 films populaires à chaque chargement de l'application !

Une fois configuré, vous n'aurez plus besoin d'ajouter des films manuellement.

