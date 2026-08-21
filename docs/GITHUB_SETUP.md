# Guide pour déposer le projet sur GitHub 🚀

Ce guide vous explique étape par étape comment déposer votre projet Flutter sur GitHub.

## ⚠️ Important : Sécurité

**NE COMMITEZ JAMAIS** les fichiers suivants qui contiennent des informations sensibles :
- `android/app/google-services.json` (configuration Firebase Android)
- `ios/Runner/GoogleService-Info.plist` (configuration Firebase iOS)
- Clés API dans `lib/utils/constants.dart` (remplacez-les par des placeholders)

Ces fichiers sont déjà dans le `.gitignore`, mais vérifiez avant de commiter !

## 📋 Prérequis

1. Un compte GitHub (créez-en un sur [github.com](https://github.com) si nécessaire)
2. Git installé sur votre machine
3. Le projet Flutter configuré et fonctionnel

## 🔧 Étapes pour déposer sur GitHub

### Étape 1 : Préparer le projet

#### 1.1 Vérifier les fichiers sensibles

Avant de commiter, assurez-vous que les clés API sont remplacées par des placeholders :

**Dans `lib/utils/constants.dart` :**
```dart
// Remplacez votre clé API réelle par un placeholder
static const String tmdbApiKey = 'YOUR_TMDB_API_KEY';
```

**Note :** Si vous avez déjà committé une clé API, vous devrez :
1. La révoquer dans le service concerné (TMDb, Firebase, etc.)
2. Générer une nouvelle clé
3. La mettre à jour localement

#### 1.2 Vérifier le .gitignore

Le fichier `.gitignore` est déjà configuré pour exclure :
- Les fichiers de build
- Les fichiers de configuration Firebase
- Les fichiers sensibles

### Étape 2 : Initialiser Git (si pas déjà fait)

Ouvrez un terminal dans le dossier du projet et exécutez :

```bash
# Initialiser le dépôt Git
git init

# Vérifier l'état des fichiers
git status
```

### Étape 3 : Créer un dépôt sur GitHub

1. Allez sur [GitHub.com](https://github.com)
2. Cliquez sur le bouton **"+"** en haut à droite
3. Sélectionnez **"New repository"**
4. Remplissez les informations :
   - **Repository name** : `movie-app` (ou le nom de votre choix)
   - **Description** : "Application Flutter de gestion de films avec Firebase"
   - **Visibility** : 
     - **Public** : Visible par tous (recommandé pour les projets éducatifs)
     - **Private** : Visible uniquement par vous et les collaborateurs
   - **NE COCHEZ PAS** "Initialize this repository with a README" (vous avez déjà un README)
5. Cliquez sur **"Create repository"**

### Étape 4 : Ajouter les fichiers au dépôt Git

Dans votre terminal, exécutez :

```bash
# Ajouter tous les fichiers (sauf ceux dans .gitignore)
git add .

# Vérifier les fichiers qui seront committés
git status

# Créer le premier commit
git commit -m "Initial commit: Application Flutter de gestion de films"
```

**Vérification importante :** 
Regardez la sortie de `git status` et assurez-vous que ces fichiers **NE SONT PAS** listés :
- ❌ `android/app/google-services.json`
- ❌ `ios/Runner/GoogleService-Info.plist`
- ❌ Fichiers avec vos clés API réelles

### Étape 5 : Connecter au dépôt GitHub

GitHub vous donnera une URL pour votre dépôt. Utilisez-la dans cette commande :

```bash
# Remplacer USERNAME et REPO_NAME par vos valeurs
git remote add origin https://github.com/USERNAME/REPO_NAME.git

# Vérifier que la connexion est établie
git remote -v
```

**Exemple :**
```bash
git remote add origin https://github.com/marie/movie-app.git
```

### Étape 6 : Pousser le code sur GitHub

```bash
# Pousser le code sur GitHub (branche main)
git branch -M main
git push -u origin main
```

Si c'est la première fois que vous utilisez Git sur cette machine, vous devrez peut-être vous authentifier :
- **HTTPS** : GitHub vous demandera votre nom d'utilisateur et un token d'accès personnel
- **SSH** : Configurez une clé SSH (voir [GitHub Docs](https://docs.github.com/en/authentication/connecting-to-github-with-ssh))

### Étape 7 : Vérifier sur GitHub

1. Rafraîchissez la page de votre dépôt sur GitHub
2. Vous devriez voir tous vos fichiers
3. Le README.md devrait s'afficher automatiquement

## 🔄 Commandes Git utiles pour la suite

### Ajouter des modifications

```bash
# Voir les fichiers modifiés
git status

# Ajouter des fichiers spécifiques
git add nom_du_fichier.dart

# Ou ajouter tous les fichiers modifiés
git add .

# Créer un commit avec un message
git commit -m "Description des modifications"

# Pousser vers GitHub
git push
```

### Créer une branche pour une nouvelle fonctionnalité

```bash
# Créer et basculer sur une nouvelle branche
git checkout -b nouvelle-fonctionnalite

# Faire des modifications, puis commiter
git add .
git commit -m "Ajout de la nouvelle fonctionnalité"

# Pousser la branche sur GitHub
git push -u origin nouvelle-fonctionnalite
```

### Mettre à jour depuis GitHub

```bash
# Récupérer les dernières modifications
git pull
```

## 📝 Bonnes pratiques

### Messages de commit

Utilisez des messages de commit clairs et descriptifs :

✅ **Bons exemples :**
- `"Ajout de la fonctionnalité de recherche de films"`
- `"Correction du bug d'affichage des favoris"`
- `"Mise à jour de la documentation"`

❌ **Mauvais exemples :**
- `"fix"`
- `"update"`
- `"changements"`

### Fréquence des commits

- Commitez régulièrement (après chaque fonctionnalité ou correction)
- Ne commitez pas de code cassé ou non testé
- Utilisez des branches pour les fonctionnalités importantes

### Documentation

- Maintenez le README.md à jour
- Ajoutez des commentaires dans le code
- Documentez les fonctionnalités complexes

## 🔐 Sécurité supplémentaire

### Si vous avez accidentellement committé une clé API

1. **Révoquer la clé** dans le service concerné (TMDb, Firebase, etc.)
2. **Générer une nouvelle clé**
3. **Supprimer l'historique Git** (si le dépôt est privé et récent) :
   ```bash
   # ATTENTION : Ceci réécrit l'historique Git
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch lib/utils/constants.dart" \
     --prune-empty --tag-name-filter cat -- --all
   ```
4. **Ou utiliser BFG Repo-Cleaner** (plus simple) : [bfg-repo-cleaner](https://rtyley.github.io/bfg-repo-cleaner/)

### Utiliser des variables d'environnement (optionnel)

Pour une meilleure sécurité, vous pouvez utiliser des variables d'environnement :

1. Créer un fichier `.env` (déjà dans .gitignore)
2. Utiliser le package `flutter_dotenv`
3. Charger les variables au démarrage de l'app

## 📚 Ressources

- [Documentation Git](https://git-scm.com/doc)
- [Guide GitHub](https://guides.github.com/)
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)

## ✅ Checklist avant de pousser

- [ ] Les clés API sont remplacées par des placeholders
- [ ] `google-services.json` n'est pas dans le dépôt
- [ ] `GoogleService-Info.plist` n'est pas dans le dépôt
- [ ] Le README.md est à jour
- [ ] Le .gitignore est correctement configuré
- [ ] Tous les fichiers sensibles sont exclus
- [ ] Le code compile sans erreurs
- [ ] Les commentaires sont à jour

---

**Bon dépôt sur GitHub ! 🎉**



