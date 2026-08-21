# Guide pour tester le Matching

## Pourquoi je ne vois pas de correspondances ?

Le matching nécessite :
1. **Au moins 2 utilisateurs** avec des favoris
2. **Des films en commun** entre les utilisateurs
3. **Un taux de correspondance > 75%**

## Comment tester le matching

### Méthode 1 : Créer plusieurs comptes (Recommandé)

#### Étape 1 : Créer 3 comptes différents

1. **Compte 1 - Alice** :
   - Email: `alice@test.com`
   - Mot de passe: `test123456`
   - Ajoutez ces films aux favoris : **Film 1, Film 2, Film 3**

2. **Compte 2 - Bob** :
   - Email: `bob@test.com`
   - Mot de passe: `test123456`
   - Ajoutez ces films aux favoris : **Film 1, Film 2, Film 4**
   - (2 films en commun avec Alice = ~67% - ne s'affichera PAS car < 75%)

3. **Compte 3 - Charlie** :
   - Email: `charlie@test.com`
   - Mot de passe: `test123456`
   - Ajoutez ces films aux favoris : **Film 1, Film 2, Film 3, Film 5**
   - (3 films en commun avec Alice = 75% - s'affichera ✅)

#### Étape 2 : Tester le matching

1. Connectez-vous avec **Alice** (`alice@test.com`)
2. Allez dans l'onglet **Matching**
3. Vous devriez voir **Charlie** avec 75% de correspondance

### Méthode 2 : Utiliser les IDs des films de démonstration

Les films de démonstration ont ces IDs :
- Film 1 : `"1"` (Inception)
- Film 2 : `"2"` (The Dark Knight)
- Film 3 : `"3"` (Pulp Fiction)

#### Exemple de configuration pour avoir des correspondances :

**Utilisateur A** (vous) :
- Favoris : `["1", "2", "3"]` (3 films)

**Utilisateur B** (autre compte) :
- Favoris : `["1", "2", "3", "4"]` (4 films, 3 en commun)
- **Taux : (3/4) × 100 = 75%** ✅

**Utilisateur C** (autre compte) :
- Favoris : `["1", "2"]` (2 films, 2 en commun)
- **Taux : (2/3) × 100 = 66.7%** ❌ (ne s'affichera pas car < 75%)

## Comment ajouter des favoris manuellement dans Firestore

Si vous voulez ajouter des favoris directement dans Firestore :

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet
3. Allez dans **Firestore Database**
4. Collection `users`
5. Trouvez le document de l'utilisateur (par UID)
6. Ajoutez ou modifiez le champ `favoriteMovies` :

```json
{
  "favoriteMovies": ["1", "2", "3"]
}
```

**Important** : Les IDs doivent correspondre aux IDs des films dans votre application.

## Vérifier les logs

Quand vous allez dans l'onglet Matching, regardez les logs dans la console Flutter. Vous devriez voir :

```
🔍 Recherche de correspondances pour l'utilisateur: [userId]
👤 Utilisateur actuel: [nom]
🎬 Favoris de l'utilisateur actuel: X films
👥 Total d'utilisateurs dans la base: X
🔍 Comparaison avec: [nom]
   Taux de correspondance: X%
✅ Correspondance trouvée! (X%)
```

## Calcul du taux de correspondance

**Formule** : (Films en commun) / (Tous les films uniques) × 100

### Exemples :

**Exemple 1** :
- Alice : [1, 2, 3] (3 films)
- Bob : [1, 2, 3, 4] (4 films)
- Films en commun : [1, 2, 3] = 3
- Films uniques : [1, 2, 3, 4] = 4
- **Taux : (3/4) × 100 = 75%** ✅

**Exemple 2** :
- Alice : [1, 2, 3] (3 films)
- Charlie : [1, 2] (2 films)
- Films en commun : [1, 2] = 2
- Films uniques : [1, 2, 3] = 3
- **Taux : (2/3) × 100 = 66.7%** ❌ (< 75%)

**Exemple 3** :
- Alice : [1, 2, 3] (3 films)
- Diana : [1, 2, 3, 4, 5] (5 films)
- Films en commun : [1, 2, 3] = 3
- Films uniques : [1, 2, 3, 4, 5] = 5
- **Taux : (3/5) × 100 = 60%** ❌ (< 75%)

## Conseils pour avoir des correspondances

1. **Ajoutez plusieurs films aux favoris** (au moins 3-4)
2. **Créez plusieurs comptes** avec des favoris similaires
3. **Assurez-vous qu'au moins 75% des films sont en commun**
4. **Vérifiez les logs** pour voir ce qui se passe

## Dépannage

### "Aucune correspondance trouvée"

**Causes possibles** :
- Vous n'avez pas assez de favoris
- Les autres utilisateurs n'ont pas de favoris
- Le taux de correspondance est < 75%
- Les utilisateurs sont désactivés

**Solution** :
- Ajoutez plus de films aux favoris
- Créez d'autres comptes avec des favoris similaires
- Vérifiez les logs pour voir les taux de correspondance

### Les correspondances ne se chargent pas

**Vérifiez** :
- Que vous êtes bien connecté
- Que Firestore est activé
- Les logs dans la console Flutter
- Que les autres utilisateurs ont des favoris

