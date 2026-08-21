# Guide de dépannage

## Erreur lors de l'inscription

Si vous obtenez une erreur lors de l'inscription, voici les causes possibles et leurs solutions :

### 1. Firebase Authentication non activé

**Symptôme** : Erreur "operation-not-allowed" ou "L'inscription par email n'est pas activée"

**Solution** :
1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet
3. Allez dans **Authentication** > **Sign-in method**
4. Activez **Email/Password**
5. Cliquez sur **Enregistrer**

### 2. Firestore non configuré ou règles de sécurité trop strictes

**Symptôme** : Erreur "permission-denied" ou "Permission refusée"

**Solution** :
1. Allez dans **Firestore Database** dans Firebase Console
2. Allez dans l'onglet **Règles**
3. Pour le développement, utilisez ces règles temporaires :
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null;
    }
    match /movies/{movieId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```
4. Cliquez sur **Publier**

**⚠️ ATTENTION** : Ces règles sont pour le développement uniquement. Pour la production, utilisez des règles plus strictes.

### 3. Firebase Storage non configuré

**Symptôme** : L'inscription fonctionne mais la photo n'est pas uploadée

**Solution** :
1. Allez dans **Storage** dans Firebase Console
2. Cliquez sur **Commencer**
3. Choisissez un emplacement (ex: us-central)
4. Configurez les règles de sécurité :
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_photos/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 4. Problème de connexion réseau

**Symptôme** : Erreur "network-request-failed" ou "Erreur de connexion réseau"

**Solution** :
- Vérifiez votre connexion internet
- Vérifiez que l'émulateur/appareil a accès à internet
- Vérifiez que Firebase est accessible depuis votre réseau

### 5. Email déjà utilisé

**Symptôme** : Erreur "email-already-in-use"

**Solution** :
- Utilisez un autre email
- Ou connectez-vous avec cet email existant

### 6. Vérifier les logs

Pour voir les erreurs détaillées :
1. Ouvrez la console de débogage dans Android Studio ou VS Code
2. Regardez les messages qui commencent par "Erreur" ou "Error"
3. Les messages de débogage commencent par "debugPrint"

## Vérification de la configuration Firebase

Pour vérifier que tout est bien configuré :

1. **Firebase Core** : Vérifiez que `google-services.json` est présent dans `android/app/`
2. **Authentication** : Vérifiez que Email/Password est activé
3. **Firestore** : Vérifiez que la base de données est créée
4. **Storage** : Vérifiez que Storage est activé

## Test sans photo

Si l'inscription échoue à cause de la photo, vous pouvez tester sans photo :
- Laissez le champ photo vide lors de l'inscription
- L'inscription devrait fonctionner sans photo

## Messages d'erreur courants

- **"Erreur lors de l'inscription"** : Erreur générique, vérifiez les logs pour plus de détails
- **"Cet email est déjà utilisé"** : L'email existe déjà dans Firebase Auth
- **"Email invalide"** : Format d'email incorrect
- **"Mot de passe trop faible"** : Le mot de passe doit contenir au moins 6 caractères
- **"Permission refusée"** : Problème avec les règles Firestore/Storage
- **"Service temporairement indisponible"** : Problème côté Firebase, réessayez plus tard

