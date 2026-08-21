# Guide de test des fonctionnalités

## ✅ Fonctionnalités à tester

### 1. Inscription et Connexion
- [x] Inscription avec nom, prénom, âge, email, mot de passe, photo
- [x] Connexion avec email et mot de passe
- [x] Gestion des erreurs (email déjà utilisé, mot de passe faible, etc.)

### 2. Gestion des films
- [x] Affichage de la liste des films
- [x] Recherche de films
- [x] Affichage des détails d'un film
- [x] Ajout de films aux favoris
- [x] Retrait de films des favoris
- [x] Affichage de la liste des favoris

### 3. Fonctionnalité Matching
- [x] Calcul du taux de correspondance (> 75%)
- [x] Affichage des utilisateurs avec goûts similaires
- [x] Tri par taux de correspondance

### 4. Panel Administrateur
- [x] Ajout de films (admin seulement)
- [x] Gestion des utilisateurs (activer/désactiver)
- [x] Affichage de la liste des utilisateurs

## 🧪 Comment tester le matching

### Étape 1 : Créer plusieurs comptes

Créez au moins 3 comptes différents via l'inscription :
1. **Compte 1** : `alice@test.com` / `test123456`
2. **Compte 2** : `bob@test.com` / `test123456`
3. **Compte 3** : `charlie@test.com` / `test123456`

### Étape 2 : Ajouter des favoris à chaque compte

**Compte 1 (Alice)** :
- Connectez-vous avec `alice@test.com`
- Ajoutez les films suivants aux favoris :
  - Film 1 (ex: Inception)
  - Film 2 (ex: The Dark Knight)
  - Film 3 (ex: Pulp Fiction)

**Compte 2 (Bob)** :
- Déconnectez-vous et connectez-vous avec `bob@test.com`
- Ajoutez les films suivants aux favoris :
  - Film 1 (même que Alice)
  - Film 2 (même que Alice)
  - Film 4 (différent)

**Compte 3 (Charlie)** :
- Déconnectez-vous et connectez-vous avec `charlie@test.com`
- Ajoutez les films suivants aux favoris :
  - Film 1 (même que Alice)
  - Film 2 (même que Alice)
  - Film 3 (même qu'Alice)
  - Film 5 (différent)

### Étape 3 : Tester le matching

1. Connectez-vous avec **Alice** (`alice@test.com`)
2. Allez dans l'onglet **Matching**
3. Vous devriez voir :
   - **Charlie** : ~75% de correspondance (3 films en commun sur 4)
   - **Bob** : ~67% de correspondance (2 films en commun sur 3) - **ne s'affichera pas** car < 75%

### Calcul du matching

**Alice vs Charlie** :
- Alice : [Film1, Film2, Film3] = 3 films
- Charlie : [Film1, Film2, Film3, Film5] = 4 films
- Films en commun : [Film1, Film2, Film3] = 3
- Tous les films uniques : [Film1, Film2, Film3, Film5] = 4
- **Taux : (3/4) × 100 = 75%** ✅

**Alice vs Bob** :
- Alice : [Film1, Film2, Film3] = 3 films
- Bob : [Film1, Film2, Film4] = 3 films
- Films en commun : [Film1, Film2] = 2
- Tous les films uniques : [Film1, Film2, Film3, Film4] = 4
- **Taux : (2/4) × 100 = 50%** ❌ (ne s'affiche pas car < 75%)

## 🔧 Créer un compte administrateur

Pour créer un compte admin, vous devez modifier manuellement le rôle dans Firestore :

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet
3. Allez dans **Firestore Database**
4. Collection `users`
5. Trouvez le document de votre utilisateur (par UID)
6. Modifiez le champ `role` de `"user"` à `"admin"`
7. Sauvegardez

Maintenant, quand vous vous connectez avec ce compte, vous verrez l'onglet **Admin** dans l'application.

## 📝 Checklist de test complète

### Test 1 : Inscription
- [ ] Créer un nouveau compte
- [ ] Vérifier que la photo de profil est uploadée
- [ ] Vérifier que le profil est créé dans Firestore

### Test 2 : Connexion
- [ ] Se connecter avec un compte existant
- [ ] Vérifier la navigation vers l'écran d'accueil
- [ ] Vérifier que les données utilisateur sont chargées

### Test 3 : Films
- [ ] Voir la liste des films
- [ ] Rechercher un film
- [ ] Voir les détails d'un film
- [ ] Ajouter un film aux favoris
- [ ] Vérifier qu'il apparaît dans l'onglet Favoris
- [ ] Retirer un film des favoris
- [ ] Vérifier qu'il disparaît de l'onglet Favoris

### Test 4 : Matching
- [ ] Créer au moins 2 comptes avec des favoris en commun
- [ ] Vérifier que les correspondances apparaissent (> 75%)
- [ ] Vérifier que le taux de correspondance est correct
- [ ] Vérifier que les utilisateurs sont triés par taux décroissant

### Test 5 : Admin
- [ ] Créer un compte admin (via Firestore)
- [ ] Vérifier que l'onglet Admin apparaît
- [ ] Ajouter un film via l'interface admin
- [ ] Vérifier que le film apparaît dans la liste
- [ ] Désactiver un utilisateur
- [ ] Vérifier que l'utilisateur est désactivé
- [ ] Réactiver un utilisateur

## 🐛 Problèmes courants

### Le matching ne fonctionne pas
- **Cause** : Pas assez d'utilisateurs avec des favoris en commun
- **Solution** : Créez plusieurs comptes et ajoutez des favoris similaires

### Les favoris ne s'affichent pas
- **Cause** : Le profil utilisateur n'existe pas dans Firestore
- **Solution** : Le profil est créé automatiquement lors de l'ajout du premier favori

### L'onglet Admin n'apparaît pas
- **Cause** : Le compte n'a pas le rôle "admin"
- **Solution** : Modifiez le rôle dans Firestore (voir section ci-dessus)

