# Configuration de l'API TMDb

## Problème
L'application ne récupère pas de films depuis l'API car la clé API TMDb n'est pas configurée.

## Solution : Obtenir une clé API gratuite

### Étape 1 : Créer un compte sur TMDb
1. Allez sur https://www.themoviedb.org/
2. Cliquez sur **"S'inscrire"** (en haut à droite)
3. Remplissez le formulaire d'inscription
4. Confirmez votre email

### Étape 2 : Demander une clé API
1. Une fois connecté, allez dans **Paramètres** (icône profil en haut à droite)
2. Cliquez sur **"API"** dans le menu de gauche
3. Cliquez sur **"Demander une clé API"**
4. Sélectionnez **"Developer"** (gratuit)
5. Acceptez les conditions d'utilisation
6. Remplissez le formulaire :
   - **Type d'application** : Application
   - **Nom de l'application** : Movie App (ou votre nom)
   - **URL de l'application** : http://localhost (ou votre URL)
   - **Résumé** : Application Flutter pour découvrir des films
7. Cliquez sur **"Soumettre"**

### Étape 3 : Copier votre clé API
1. Une fois la clé générée, vous verrez votre **API Key (v3 auth)**
2. **Copiez cette clé** (elle ressemble à : `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6`)

### Étape 4 : Configurer la clé dans le projet
1. Ouvrez le fichier `lib/utils/constants.dart`
2. Trouvez la ligne :
   ```dart
   static const String tmdbApiKey = 'YOUR_TMDB_API_KEY';
   ```
3. Remplacez `'YOUR_TMDB_API_KEY'` par votre clé API :
   ```dart
   static const String tmdbApiKey = 'a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6';
   ```
4. **Sauvegardez** le fichier

### Étape 5 : Redémarrer l'application
1. Arrêtez l'application si elle est en cours d'exécution
2. Relancez l'application avec `flutter run`
3. Les films devraient maintenant se charger depuis l'API TMDb !

## Vérification

### Logs attendus dans la console
Si la clé API est correctement configurée, vous devriez voir :
```
🎬 Début du chargement des films...
📚 0 films depuis Firestore
🔑 Clé API TMDb détectée, tentative de récupération...
📡 Récupération de 5 pages de films depuis TMDb...
📡 Page 1/5...
✅ Page 1: 20 films ajoutés (Total: 20)
📡 Page 2/5...
✅ Page 2: 20 films ajoutés (Total: 40)
...
✅ Total: 100 films récupérés depuis TMDb
🌐 100 films depuis l'API
✅ Total: 100 films chargés
```

### Erreurs possibles

#### Erreur 401 : Clé API invalide
```
❌ Erreur TMDb page 1 - Status: 401
❌ Clé API invalide ou expirée
```
**Solution** : Vérifiez que vous avez bien copié la clé API complète dans `constants.dart`

#### Aucune clé API configurée
```
⚠️ Aucune clé API configurée.
⚠️ Clé TMDb actuelle: YOUR_TMDB_API_KEY...
```
**Solution** : Suivez les étapes ci-dessus pour obtenir et configurer votre clé API

## Limites de l'API gratuite TMDb
- **Gratuite** : Oui, complètement gratuite
- **Limite de requêtes** : 40 requêtes toutes les 10 secondes
- **Données disponibles** : Films populaires, détails, images, etc.
- **Pas de limite de volume** : Vous pouvez faire autant de requêtes que vous voulez (dans la limite de 40/10s)

## Alternative : Films de démonstration
Si vous ne souhaitez pas configurer l'API, l'application utilisera automatiquement 3 films de démonstration (Inception, The Dark Knight, Pulp Fiction).

## Support
- Documentation officielle TMDb : https://www.themoviedb.org/documentation/api
- Forum TMDb : https://www.themoviedb.org/talk

