# Commandes rapides pour GitHub 🚀

## Commandes à exécuter dans l'ordre

### 1. Initialiser Git (si pas déjà fait)
```bash
git init
```

### 2. Vérifier les fichiers qui seront committés
```bash
git status
```

**⚠️ IMPORTANT :** Vérifiez que ces fichiers NE SONT PAS dans la liste :
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- Fichiers avec vos vraies clés API

### 3. Ajouter tous les fichiers
```bash
git add .
```

### 4. Créer le premier commit
```bash
git commit -m "Initial commit: Application Flutter de gestion de films avec Firebase"
```

### 5. Créer le dépôt sur GitHub
1. Allez sur https://github.com/new
2. Nom du dépôt : `movie-app` (ou votre choix)
3. Description : "Application Flutter de gestion de films avec Firebase"
4. Choisissez Public ou Private
5. **NE COCHEZ PAS** "Initialize with README"
6. Cliquez sur "Create repository"

### 6. Connecter le dépôt local à GitHub
```bash
# Remplacez USERNAME et REPO_NAME par vos valeurs
git remote add origin https://github.com/USERNAME/REPO_NAME.git
```

**Exemple :**
```bash
git remote add origin https://github.com/marie/movie-app.git
```

### 7. Pousser le code sur GitHub
```bash
git branch -M main
git push -u origin main
```

Si GitHub vous demande de vous authentifier :
- **Nom d'utilisateur** : Votre nom d'utilisateur GitHub
- **Mot de passe** : Utilisez un **Personal Access Token** (pas votre mot de passe)
  - Créez-en un ici : https://github.com/settings/tokens
  - Sélectionnez les permissions : `repo` (toutes les permissions repo)

## ✅ Vérification finale

1. Allez sur votre dépôt GitHub
2. Vérifiez que tous les fichiers sont présents
3. Vérifiez que le README.md s'affiche correctement
4. Vérifiez que `google-services.json` n'est PAS visible

## 🔄 Commandes pour les prochaines modifications

```bash
# Voir les modifications
git status

# Ajouter les modifications
git add .

# Créer un commit
git commit -m "Description des modifications"

# Pousser vers GitHub
git push
```

## ❓ Besoin d'aide ?

Consultez le guide complet dans **GITHUB_SETUP.md** pour plus de détails.



