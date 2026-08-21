# Configuration de l'API pour les films

## Option 1 : TMDb (The Movie Database) - RECOMMANDÉ ⭐

**TMDb est gratuit, facile à utiliser et très populaire !**

### Étape 1 : Obtenir une clé API TMDb

1. Allez sur [The Movie Database](https://www.themoviedb.org/)
2. Créez un compte (gratuit)
3. Allez dans **Paramètres** > **API**
4. Cliquez sur **Request API Key**
5. Choisissez **Developer** (gratuit)
6. Remplissez le formulaire
7. Copiez votre clé API (API Key)

### Étape 2 : Configurer la clé dans l'application

1. Ouvrez le fichier `lib/utils/constants.dart`
2. Remplacez `YOUR_TMDB_API_KEY` par votre clé API :

```dart
static const String tmdbApiKey = 'VOTRE_CLE_TMDB_ICI';
```

### Étape 3 : Tester l'application

1. Redémarrez l'application
2. Les films devraient maintenant être chargés depuis TMDb

### Avantages de TMDb

- ✅ **100% gratuit**
- ✅ **Illimité** (pas de limite de requêtes)
- ✅ **Données complètes** (affiches, descriptions, notes, etc.)
- ✅ **Très populaire** et bien documenté
- ✅ **Support français**

---

## Option 2 : RapidAPI (Alternative)

Si vous préférez utiliser RapidAPI :

### Étape 1 : Trouver une API Movie sur RapidAPI

1. Allez sur [RapidAPI](https://rapidapi.com/)
2. Recherchez "movie" ou "film" dans la barre de recherche
3. Choisissez une API (ex: "The Movie Database Alternative", "IMDb API", etc.)
4. Cliquez sur **Subscribe to Test** (gratuit)
5. Copiez votre clé API (X-RapidAPI-Key)

### Étape 2 : Configurer la clé dans l'application

1. Ouvrez le fichier `lib/utils/constants.dart`
2. Remplacez `YOUR_RAPIDAPI_KEY` par votre clé API
3. Mettez à jour `rapidApiHost` et `rapidApiBaseUrl` selon l'API choisie

---

## Option 3 : Films de démonstration

Si vous ne configurez pas d'API, l'application utilisera automatiquement **3 films de démonstration** pour que vous puissiez tester l'application :
- Inception
- The Dark Knight
- Pulp Fiction

---

## Recommandation

**Utilisez TMDb (Option 1)** - C'est le plus simple, gratuit et illimité !

