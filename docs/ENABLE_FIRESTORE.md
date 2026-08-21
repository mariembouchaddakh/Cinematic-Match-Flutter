# Activer Cloud Firestore dans Firebase

## Erreur rencontrée

```
PERMISSION_DENIED: Cloud Firestore API has not been used in project project-73978 before or it is disabled.
```

## ⚠️ IMPORTANT : Si vous ne voyez pas "Firestore Database"

Si l'option "Firestore Database" n'apparaît pas dans Firebase Console, c'est que l'API n'est pas encore activée. Suivez d'abord l'**Étape 1** ci-dessous.

## Solution : Activer Firestore

### Étape 1 : Activer l'API Firestore (OBLIGATOIRE EN PREMIER)

**Option A : Lien direct (le plus rapide)**
1. Cliquez sur ce lien : [Activer Firestore API](https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=project-73978)
2. Cliquez sur le bouton bleu **"ENABLE"** (Activer)
3. Attendez que la page se charge (peut prendre 10-30 secondes)
4. Vous devriez voir "API enabled" (API activée)

**Option B : Via Google Cloud Console**
1. Allez sur [Google Cloud Console](https://console.cloud.google.com/)
2. En haut à gauche, cliquez sur le sélecteur de projet
3. Sélectionnez votre projet `project-73978`
4. Dans le menu de gauche, allez dans **APIs & Services** > **Library** (ou **Bibliothèque**)
5. Dans la barre de recherche, tapez : `Cloud Firestore API`
6. Cliquez sur "Cloud Firestore API"
7. Cliquez sur le bouton **"ENABLE"** (Activer)
8. Attendez que l'activation se termine

### Étape 2 : Attendre et rafraîchir Firebase Console

1. **Attendez 1-2 minutes** après avoir activé l'API
2. Allez sur [Firebase Console](https://console.firebase.google.com/)
3. Sélectionnez votre projet `project-73978`
4. **Rafraîchissez la page** (F5 ou Ctrl+R)
5. Maintenant, vous devriez voir **"Firestore Database"** dans le menu de gauche

### Étape 3 : Créer la base de données Firestore

1. Cliquez sur **"Firestore Database"** dans le menu de gauche
2. Si vous voyez "Get started" ou "Create database", cliquez dessus
3. Choisissez le mode :
   - **Mode test** (pour le développement) - ✅ Recommandé pour commencer
   - **Mode production** (pour la production)
4. Choisissez une région :
   - `europe-west` (Europe) - ✅ Recommandé si vous êtes en Europe
   - `us-central` (États-Unis)
   - Ou une autre région proche de vous
5. Cliquez sur **"Enable"** (Activer)
6. Attendez que la base de données soit créée (30 secondes à 2 minutes)

### Étape 3 : Configurer les règles de sécurité

1. Toujours dans **Firestore Database**
2. Allez dans l'onglet **Rules** (Règles)
3. Remplacez les règles par :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Règles pour les utilisateurs
    match /users/{userId} {
      // Permettre la lecture si l'utilisateur est connecté
      allow read: if request.auth != null;
      // Permettre l'écriture si l'utilisateur modifie son propre profil
      allow write: if request.auth != null && request.auth.uid == userId;
      // Permettre la création si l'utilisateur est connecté
      allow create: if request.auth != null;
    }
    
    // Règles pour les films
    match /movies/{movieId} {
      // Permettre la lecture si l'utilisateur est connecté
      allow read: if request.auth != null;
      // Permettre l'écriture si l'utilisateur est connecté (pour les admins)
      allow write: if request.auth != null;
    }
  }
}
```

4. Cliquez sur **Publish** (Publier)

### Étape 4 : Attendre la propagation

- Après avoir activé l'API, attendez **2-5 minutes** pour que les changements se propagent
- Redémarrez l'application Flutter

### Étape 5 : Tester

1. Redémarrez l'application
2. Essayez d'ajouter un film aux favoris
3. Vérifiez que cela fonctionne maintenant

## Vérification

Pour vérifier que Firestore est bien activé :

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet `project-73978`
3. Dans le menu de gauche, vous devriez voir **"Firestore Database"**
4. Cliquez dessus
5. Vous devriez voir une interface avec :
   - "Start collection" (Commencer une collection)
   - Ou des collections existantes si vous en avez déjà créé

## 🔍 Si "Firestore Database" n'apparaît toujours pas

### Vérification 1 : Vérifier que l'API est activée

1. Allez sur [Google Cloud Console - APIs](https://console.cloud.google.com/apis/library?project=project-73978)
2. Recherchez "Cloud Firestore API"
3. Vérifiez que le statut est **"Enabled"** (Activé)
4. Si ce n'est pas le cas, activez-le (voir Étape 1)

### Vérification 2 : Vérifier le projet

1. Assurez-vous d'être dans le bon projet : `project-73978`
2. Vérifiez que vous êtes connecté avec le bon compte Google

### Vérification 3 : Attendre plus longtemps

- Parfois, l'activation peut prendre jusqu'à 5-10 minutes
- Fermez et rouvrez Firebase Console
- Essayez en navigation privée/incognito

### Vérification 4 : Vérifier les permissions

1. Assurez-vous d'avoir les permissions d'administrateur sur le projet
2. Si vous n'êtes pas le propriétaire, demandez à l'administrateur d'activer Firestore

## Alternative : Utiliser Realtime Database

Si vous préférez utiliser Realtime Database au lieu de Firestore :

1. Allez dans **Realtime Database** dans Firebase Console
2. Cliquez sur **Create database**
3. Choisissez le mode test
4. Notez l'URL de la base de données

**Note** : L'application actuelle utilise Firestore, donc il faudrait modifier le code pour utiliser Realtime Database.

## Support

Si le problème persiste après avoir activé Firestore :
- Vérifiez que vous êtes bien connecté avec le bon compte Google
- Vérifiez que le projet Firebase est bien `project-73978`
- Attendez quelques minutes supplémentaires
- Vérifiez les logs dans Firebase Console pour voir s'il y a d'autres erreurs

